#!/bin/bash

# Exit on error
set -e

# Configuration
NAMESPACE="redis-vault"
CERT_DIR="certs"
BACKUP_DIR="backups"

# Log function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

# Check prerequisites
check_prerequisites() {
    log "Checking prerequisites..."
    
    # Check kubectl
    if ! command -v kubectl &> /dev/null; then
        log "ERROR: kubectl is not installed"
        exit 1
    fi
    
    # Check helm
    if ! command -v helm &> /dev/null; then
        log "ERROR: helm is not installed"
        exit 1
    fi
    
    # Check openssl
    if ! command -v openssl &> /dev/null; then
        log "ERROR: openssl is not installed"
        exit 1
    fi
}

# Create namespace
create_namespace() {
    log "Creating namespace $NAMESPACE..."
    kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -
}

# Generate certificates
generate_certificates() {
    log "Generating certificates..."
    ./scripts/generate-certs.sh
}

# Create TLS secrets
create_tls_secrets() {
    log "Creating TLS secrets..."
    kubectl create secret generic vault-tls \
        --from-file=ca.crt=$CERT_DIR/ca.crt \
        --from-file=server.crt=$CERT_DIR/server.crt \
        --from-file=server.key=$CERT_DIR/server.key \
        -n $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -
}

# Deploy Redis
deploy_redis() {
    log "Deploying Redis..."
    kubectl apply -f examples/kubernetes-setup/redis/redis-master.yaml -n $NAMESPACE
    kubectl apply -f examples/kubernetes-setup/redis/redis-replica.yaml -n $NAMESPACE
    
    # Wait for Redis to be ready
    log "Waiting for Redis to be ready..."
    kubectl wait --for=condition=ready pod -l app=redis,role=master -n $NAMESPACE --timeout=300s
    kubectl wait --for=condition=ready pod -l app=redis,role=replica -n $NAMESPACE --timeout=300s
}

# Deploy Vault
deploy_vault() {
    log "Deploying Vault..."
    kubectl apply -f examples/kubernetes-setup/vault/vault-config.yaml -n $NAMESPACE
    
    # Wait for Vault to be ready
    log "Waiting for Vault to be ready..."
    kubectl wait --for=condition=ready pod -l app=vault -n $NAMESPACE --timeout=300s
}

# Initialize Vault
initialize_vault() {
    log "Initializing Vault..."
    INIT_RESPONSE=$(kubectl exec -it vault-0 -n $NAMESPACE -- vault operator init -format=json)
    
    # Save unseal keys and root token
    echo "$INIT_RESPONSE" > $BACKUP_DIR/vault-init.json
    
    # Extract and display unseal keys
    UNSEAL_KEYS=$(echo "$INIT_RESPONSE" | jq -r '.unseal_keys_b64[]')
    ROOT_TOKEN=$(echo "$INIT_RESPONSE" | jq -r '.root_token')
    
    log "Vault initialized. Unseal keys and root token saved to $BACKUP_DIR/vault-init.json"
    log "Please securely store these credentials"
}

# Unseal Vault
unseal_vault() {
    log "Unsealing Vault..."
    
    if [ ! -f "$BACKUP_DIR/vault-init.json" ]; then
        log "ERROR: Vault initialization file not found"
        exit 1
    fi
    
    # Get first unseal key
    UNSEAL_KEY=$(jq -r '.unseal_keys_b64[0]' $BACKUP_DIR/vault-init.json)
    
    # Unseal each Vault instance
    for i in {0..2}; do
        kubectl exec -it vault-$i -n $NAMESPACE -- vault operator unseal $UNSEAL_KEY
    done
}

# Deploy monitoring
deploy_monitoring() {
    log "Deploying monitoring..."
    kubectl apply -f examples/kubernetes-setup/monitoring/prometheus.yaml -n $NAMESPACE
}

# Check deployment status
check_status() {
    log "Checking deployment status..."
    
    # Check Redis
    log "Redis status:"
    kubectl get pods -l app=redis -n $NAMESPACE
    
    # Check Vault
    log "Vault status:"
    kubectl get pods -l app=vault -n $NAMESPACE
    
    # Check monitoring
    log "Monitoring status:"
    kubectl get pods -l app=prometheus -n $NAMESPACE
}

# Main deployment process
main() {
    log "Starting deployment..."
    
    # Create backup directory
    mkdir -p $BACKUP_DIR
    
    # Run deployment steps
    check_prerequisites
    create_namespace
    generate_certificates
    create_tls_secrets
    deploy_redis
    deploy_vault
    initialize_vault
    unseal_vault
    deploy_monitoring
    check_status
    
    log "Deployment completed successfully"
}

# Run main function
main 