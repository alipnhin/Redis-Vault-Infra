# Kubernetes Setup Example

This example demonstrates how to deploy Redis and Vault in a Kubernetes cluster.

## Prerequisites
- Kubernetes cluster (v1.19+)
- kubectl configured
- Helm v3 installed
- OpenSSL for certificate generation

## Directory Structure
```
kubernetes-setup/
├── redis/
│   ├── redis-master.yaml
│   ├── redis-replica.yaml
│   └── redis-sentinel.yaml
├── vault/
│   ├── vault-config.yaml
│   └── vault-tls.yaml
├── monitoring/
│   ├── prometheus.yaml
│   └── grafana.yaml
└── README.md
```

## Configuration Files

### redis/redis-master.yaml
```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: redis-master
spec:
  serviceName: redis-master
  replicas: 1
  selector:
    matchLabels:
      app: redis
      role: master
  template:
    metadata:
      labels:
        app: redis
        role: master
    spec:
      containers:
      - name: redis
        image: redis:7.2.4
        ports:
        - containerPort: 6379
        volumeMounts:
        - name: redis-data
          mountPath: /data
        - name: redis-config
          mountPath: /usr/local/etc/redis
        command:
        - redis-server
        - /usr/local/etc/redis/redis.conf
  volumeClaimTemplates:
  - metadata:
      name: redis-data
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 10Gi
---
apiVersion: v1
kind: Service
metadata:
  name: redis-master
spec:
  ports:
  - port: 6379
    targetPort: 6379
  selector:
    app: redis
    role: master
```

### redis/redis-replica.yaml
```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: redis-replica
spec:
  serviceName: redis-replica
  replicas: 2
  selector:
    matchLabels:
      app: redis
      role: replica
  template:
    metadata:
      labels:
        app: redis
        role: replica
    spec:
      containers:
      - name: redis
        image: redis:7.2.4
        ports:
        - containerPort: 6379
        volumeMounts:
        - name: redis-data
          mountPath: /data
        - name: redis-config
          mountPath: /usr/local/etc/redis
        command:
        - redis-server
        - /usr/local/etc/redis/redis.conf
  volumeClaimTemplates:
  - metadata:
      name: redis-data
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 10Gi
---
apiVersion: v1
kind: Service
metadata:
  name: redis-replica
spec:
  ports:
  - port: 6379
    targetPort: 6379
  selector:
    app: redis
    role: replica
```

### vault/vault-config.yaml
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: vault-config
data:
  vault.hcl: |
    ui = true
    
    listener "tcp" {
      address = "0.0.0.0:8200"
      tls_cert_file = "/vault/tls/server.crt"
      tls_key_file = "/vault/tls/server.key"
      tls_client_ca_file = "/vault/tls/ca.crt"
    }
    
    storage "raft" {
      path = "/vault/data"
      node_id = "vault_0"
      retry_join {
        leader_api_addr = "https://vault-1.vault-internal:8200"
      }
      retry_join {
        leader_api_addr = "https://vault-2.vault-internal:8200"
      }
    }
    
    api_addr = "https://vault-0.vault-internal:8200"
    cluster_addr = "https://vault-0.vault-internal:8201"
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: vault
spec:
  serviceName: vault
  replicas: 3
  selector:
    matchLabels:
      app: vault
  template:
    metadata:
      labels:
        app: vault
    spec:
      containers:
      - name: vault
        image: hashicorp/vault:1.15.2
        ports:
        - containerPort: 8200
        - containerPort: 8201
        volumeMounts:
        - name: vault-config
          mountPath: /vault/config
        - name: vault-tls
          mountPath: /vault/tls
        - name: vault-data
          mountPath: /vault/data
        env:
        - name: VAULT_ADDR
          value: "https://127.0.0.1:8200"
        - name: VAULT_API_ADDR
          value: "https://$(POD_IP):8200"
        - name: POD_IP
          valueFrom:
            fieldRef:
              fieldPath: status.podIP
        command:
        - server
        - -config=/vault/config/vault.hcl
  volumeClaimTemplates:
  - metadata:
      name: vault-data
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 10Gi
---
apiVersion: v1
kind: Service
metadata:
  name: vault
spec:
  ports:
  - port: 8200
    targetPort: 8200
  selector:
    app: vault
```

### monitoring/prometheus.yaml
```yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: redis
spec:
  selector:
    matchLabels:
      app: redis
  endpoints:
  - port: redis
    interval: 15s
---
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: vault
spec:
  selector:
    matchLabels:
      app: vault
  endpoints:
  - port: vault
    interval: 15s
```

## Usage

1. Create namespace:
```bash
kubectl create namespace redis-vault
```

2. Generate SSL certificates:
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
kubectl apply -f redis/redis-master.yaml -n redis-vault
kubectl apply -f redis/redis-replica.yaml -n redis-vault
```

5. Deploy Vault:
```bash
kubectl apply -f vault/vault-config.yaml -n redis-vault
```

6. Initialize Vault:
```bash
kubectl exec -it vault-0 -n redis-vault -- vault operator init
```

7. Unseal Vault:
```bash
kubectl exec -it vault-0 -n redis-vault -- vault operator unseal <unseal-key>
```

8. Deploy monitoring:
```bash
kubectl apply -f monitoring/prometheus.yaml -n redis-vault
```

## Security Notes
- Use network policies to restrict access
- Enable TLS for all services
- Use proper RBAC configurations
- Implement proper secrets management
- Regular security audits
- Monitor system resources
- Implement backup strategy
- Use proper certificate management

## Monitoring

### Prometheus Metrics
- Redis metrics available at `/metrics` endpoint
- Vault metrics available at `/v1/sys/metrics` endpoint
- HAProxy metrics available at `/metrics` endpoint

### Grafana Dashboards
- Redis dashboard for monitoring replication and performance
- Vault dashboard for monitoring HA status and performance
- System dashboard for monitoring resources

## Backup and Restore

### Redis Backup
```bash
kubectl exec -it redis-master-0 -n redis-vault -- redis-cli SAVE
kubectl cp redis-vault/redis-master-0:/data/dump.rdb ./redis-backup.rdb
```

### Vault Backup
```bash
kubectl exec -it vault-0 -n redis-vault -- vault operator raft snapshot save /tmp/vault.snap
kubectl cp redis-vault/vault-0:/tmp/vault.snap ./vault-backup.snap
```

## Troubleshooting

### Common Issues
1. Pod startup issues
   - Check pod logs
   - Verify volume mounts
   - Check resource limits

2. Network connectivity
   - Verify service endpoints
   - Check network policies
   - Test DNS resolution

3. Storage issues
   - Check PVC status
   - Verify storage class
   - Check volume mounts

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
``` 