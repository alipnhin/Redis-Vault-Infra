#!/bin/bash

# Exit on error
set -e

# Configuration
REDIS_PASSWORD="YourStrongPassword"
VAULT_ADDR="https://127.0.0.1:8200"
VAULT_TOKEN="your-vault-token"
LOG_FILE="/var/log/redis-vault-monitor.log"

# Log function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Check Redis
check_redis() {
    log "Checking Redis..."
    
    # Check master
    if ! docker exec redis-master redis-cli -a "$REDIS_PASSWORD" ping > /dev/null; then
        log "ERROR: Redis master is not responding"
        return 1
    fi
    
    # Check replicas
    for replica in redis-replica-1 redis-replica-2; do
        if ! docker exec "$replica" redis-cli -a "$REDIS_PASSWORD" ping > /dev/null; then
            log "ERROR: Redis replica $replica is not responding"
            return 1
        fi
    done
    
    # Check replication status
    REPLICATION_INFO=$(docker exec redis-master redis-cli -a "$REDIS_PASSWORD" info replication)
    CONNECTED_REPLICAS=$(echo "$REPLICATION_INFO" | grep "connected_slaves" | cut -d: -f2)
    
    if [ "$CONNECTED_REPLICAS" -ne 2 ]; then
        log "ERROR: Redis replication issue - $CONNECTED_REPLICAS replicas connected (expected 2)"
        return 1
    fi
    
    log "Redis health check passed"
    return 0
}

# Check Vault
check_vault() {
    log "Checking Vault..."
    
    # Check each Vault instance
    for vault in vault-1 vault-2 vault-3; do
        if ! docker exec "$vault" vault status > /dev/null; then
            log "ERROR: Vault instance $vault is not responding"
            return 1
        fi
    done
    
    # Check Vault HA status
    VAULT_STATUS=$(docker exec vault-1 vault status)
    if ! echo "$VAULT_STATUS" | grep -q "High-Availability Enabled: true"; then
        log "ERROR: Vault HA is not properly configured"
        return 1
    fi
    
    log "Vault health check passed"
    return 0
}

# Check HAProxy
check_haproxy() {
    log "Checking HAProxy..."
    
    if ! docker exec haproxy haproxy -c -f /usr/local/etc/haproxy/haproxy.cfg > /dev/null; then
        log "ERROR: HAProxy configuration is invalid"
        return 1
    fi
    
    # Check HAProxy stats
    if ! curl -s http://localhost:8404/stats > /dev/null; then
        log "ERROR: HAProxy stats page is not accessible"
        return 1
    fi
    
    log "HAProxy health check passed"
    return 0
}

# Main monitoring loop
while true; do
    log "Starting health check..."
    
    # Run all checks
    check_redis
    REDIS_STATUS=$?
    
    check_vault
    VAULT_STATUS=$?
    
    check_haproxy
    HAPROXY_STATUS=$?
    
    # Overall status
    if [ $REDIS_STATUS -eq 0 ] && [ $VAULT_STATUS -eq 0 ] && [ $HAPROXY_STATUS -eq 0 ]; then
        log "All systems are healthy"
    else
        log "WARNING: Some systems are unhealthy"
    fi
    
    # Wait before next check
    sleep 300
done 