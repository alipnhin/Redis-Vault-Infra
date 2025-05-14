#!/bin/bash

# Exit on error
set -e

# Configuration
BACKUP_DIR="/backup"
DATE=$(date +%Y%m%d_%H%M%S)
REDIS_PASSWORD="YourStrongPassword"
VAULT_ADDR="https://127.0.0.1:8200"
VAULT_TOKEN="your-vault-token"

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Backup Redis
echo "Backing up Redis..."
docker exec redis-master redis-cli -a "$REDIS_PASSWORD" SAVE
docker cp redis-master:/data/dump.rdb "$BACKUP_DIR/redis_$DATE.rdb"

# Backup Vault
echo "Backing up Vault..."
docker exec vault-1 vault operator raft snapshot save "$BACKUP_DIR/vault_$DATE.snap"

# Compress backups
echo "Compressing backups..."
tar -czf "$BACKUP_DIR/backup_$DATE.tar.gz" \
    "$BACKUP_DIR/redis_$DATE.rdb" \
    "$BACKUP_DIR/vault_$DATE.snap"

# Clean up individual files
rm "$BACKUP_DIR/redis_$DATE.rdb" "$BACKUP_DIR/vault_$DATE.snap"

# Keep only last 7 days of backups
find "$BACKUP_DIR" -name "backup_*.tar.gz" -mtime +7 -delete

echo "Backup completed successfully: $BACKUP_DIR/backup_$DATE.tar.gz" 