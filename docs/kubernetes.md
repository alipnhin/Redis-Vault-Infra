# Kubernetes Deployment Guide

This guide explains how to deploy Redis and Vault in a Kubernetes cluster.

## Prerequisites

### Required Tools
- kubectl (v1.19+)
- Helm (v3+)
- OpenSSL
- jq (for JSON processing)

### Cluster Requirements
- Kubernetes cluster (v1.19+)
- Storage class with ReadWriteOnce support
- Network policies enabled
- RBAC enabled

## Architecture

### Components
1. Redis
   - Master node (StatefulSet)
   - Replica nodes (StatefulSet)
   - Sentinel nodes (optional)

2. Vault
   - 3-node HA cluster (StatefulSet)
   - Raft storage backend
   - TLS encryption

3. Monitoring
   - Prometheus for metrics
   - Grafana for visualization
   - ServiceMonitors for scraping

### Network Architecture
```
                    [Load Balancer]
                           |
                    [HAProxy/Ingress]
                           |
        +----------------+----------------+
        |                |                |
    [Redis Master]  [Redis Replica]  [Redis Replica]
        |                |                |
        +----------------+----------------+
                           |
                    [Vault Cluster]
        +----------------+----------------+
        |                |                |
     [Vault-0]       [Vault-1]        [Vault-2]
```

## Deployment

### Using the Deployment Script
```bash
./scripts/k8s-deploy.sh
```

The script will:
1. Check prerequisites
2. Create namespace
3. Generate certificates
4. Create TLS secrets
5. Deploy Redis
6. Deploy Vault
7. Initialize Vault
8. Deploy monitoring

### Manual Deployment
1. Create namespace:
```bash
kubectl create namespace redis-vault
```

2. Generate certificates:
```bash
./scripts/generate-certs.sh
```

3. Create TLS secrets:
```bash
kubectl create secret generic vault-tls \
  --from-file=ca.crt=certs/ca.crt \
  --from-file=server.crt=certs/server.crt \
  --from-file=server.key=certs/server.key \
  -n redis-vault
```

4. Deploy Redis:
```bash
kubectl apply -f examples/kubernetes-setup/redis/redis-master.yaml
kubectl apply -f examples/kubernetes-setup/redis/redis-replica.yaml
```

5. Deploy Vault:
```bash
kubectl apply -f examples/kubernetes-setup/vault/vault-config.yaml
```

6. Initialize Vault:
```bash
kubectl exec -it vault-0 -n redis-vault -- vault operator init
```

7. Unseal Vault:
```bash
kubectl exec -it vault-0 -n redis-vault -- vault operator unseal <unseal-key>
```

## Configuration

### Redis Configuration
- Master node: `examples/kubernetes-setup/redis/redis-master.yaml`
- Replica nodes: `examples/kubernetes-setup/redis/redis-replica.yaml`
- Sentinel nodes: `examples/kubernetes-setup/redis/redis-sentinel.yaml`

### Vault Configuration
- Main config: `examples/kubernetes-setup/vault/vault-config.yaml`
- TLS config: `examples/kubernetes-setup/vault/vault-tls.yaml`

### Monitoring Configuration
- Prometheus: `examples/kubernetes-setup/monitoring/prometheus.yaml`
- Grafana: `examples/kubernetes-setup/monitoring/grafana.yaml`

## Security

### Network Policies
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: redis-network-policy
  namespace: redis-vault
spec:
  podSelector:
    matchLabels:
      app: redis
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: redis
    ports:
    - protocol: TCP
      port: 6379
```

### RBAC Configuration
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: redis-vault-role
  namespace: redis-vault
rules:
- apiGroups: [""]
  resources: ["pods", "services"]
  verbs: ["get", "list", "watch"]
```

## Monitoring

### Prometheus Metrics
- Redis metrics: `/metrics` endpoint
- Vault metrics: `/v1/sys/metrics` endpoint
- HAProxy metrics: `/metrics` endpoint

### Grafana Dashboards
1. Redis Dashboard
   - Replication status
   - Memory usage
   - Command statistics
   - Client connections

2. Vault Dashboard
   - HA status
   - Token usage
   - Secret access
   - Performance metrics

3. System Dashboard
   - CPU usage
   - Memory usage
   - Network traffic
   - Disk I/O

## Backup and Restore

### Redis Backup
```bash
# Create backup
kubectl exec -it redis-master-0 -n redis-vault -- redis-cli SAVE
kubectl cp redis-vault/redis-master-0:/data/dump.rdb ./redis-backup.rdb

# Restore backup
kubectl cp ./redis-backup.rdb redis-vault/redis-master-0:/data/dump.rdb
kubectl exec -it redis-master-0 -n redis-vault -- redis-cli DEBUG RELOAD
```

### Vault Backup
```bash
# Create backup
kubectl exec -it vault-0 -n redis-vault -- vault operator raft snapshot save /tmp/vault.snap
kubectl cp redis-vault/vault-0:/tmp/vault.snap ./vault-backup.snap

# Restore backup
kubectl cp ./vault-backup.snap redis-vault/vault-0:/tmp/vault.snap
kubectl exec -it vault-0 -n redis-vault -- vault operator raft snapshot restore /tmp/vault.snap
```

## Troubleshooting

### Common Issues

1. Pod Startup Issues
   - Check pod logs: `kubectl logs -f <pod-name> -n redis-vault`
   - Check pod events: `kubectl describe pod <pod-name> -n redis-vault`
   - Verify volume mounts: `kubectl exec -it <pod-name> -n redis-vault -- ls /data`

2. Network Connectivity
   - Check service endpoints: `kubectl get endpoints -n redis-vault`
   - Test DNS resolution: `kubectl exec -it <pod-name> -n redis-vault -- nslookup redis-master`
   - Verify network policies: `kubectl get networkpolicy -n redis-vault`

3. Storage Issues
   - Check PVC status: `kubectl get pvc -n redis-vault`
   - Verify storage class: `kubectl get storageclass`
   - Check volume mounts: `kubectl describe pod <pod-name> -n redis-vault`

### Debug Commands
```bash
# Check pod status
kubectl get pods -n redis-vault

# Check pod logs
kubectl logs -f <pod-name> -n redis-vault

# Check service endpoints
kubectl get endpoints -n redis-vault

# Check persistent volumes
kubectl get pv,pvc -n redis-vault

# Check events
kubectl get events -n redis-vault

# Check network policies
kubectl get networkpolicy -n redis-vault
```

## Maintenance

### Scaling
```bash
# Scale Redis replicas
kubectl scale statefulset redis-replica --replicas=3 -n redis-vault

# Scale Vault nodes
kubectl scale statefulset vault --replicas=5 -n redis-vault
```

### Updates
```bash
# Update Redis image
kubectl set image statefulset/redis-master redis=redis:7.2.4 -n redis-vault
kubectl set image statefulset/redis-replica redis=redis:7.2.4 -n redis-vault

# Update Vault image
kubectl set image statefulset/vault vault=hashicorp/vault:1.15.2 -n redis-vault
```

### Cleanup
```bash
# Delete namespace (includes all resources)
kubectl delete namespace redis-vault

# Delete specific resources
kubectl delete statefulset redis-master redis-replica vault -n redis-vault
kubectl delete service redis-master redis-replica vault -n redis-vault
kubectl delete pvc --all -n redis-vault
``` 