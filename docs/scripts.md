# Helper Scripts Documentation

This document describes the helper scripts included in the `scripts/` directory.

## Certificate Generation Script (`generate-certs.sh`)

This script generates SSL certificates for Redis and Vault.

### Prerequisites
- OpenSSL installed
- Root or sudo access

### Usage
```bash
./scripts/generate-certs.sh
```

### Generated Files
- `ca.crt`: CA certificate
- `ca.key`: CA private key
- `server.crt`: Server certificate
- `server.key`: Server private key
- `client.crt`: Client certificate
- `client.key`: Client private key

### Security Notes
- Keep private keys secure
- Rotate certificates regularly
- Use strong key sizes
- Set proper file permissions

## Backup Script (`backup.sh`)

This script creates backups of Redis and Vault data.

### Prerequisites
- Docker installed
- Sufficient disk space
- Proper permissions

### Configuration
Edit the following variables in the script:
- `BACKUP_DIR`: Backup directory path
- `REDIS_PASSWORD`: Redis password
- `VAULT_ADDR`: Vault address
- `VAULT_TOKEN`: Vault token

### Usage
```bash
./scripts/backup.sh
```

### Backup Contents
- Redis dump file
- Vault snapshot
- Compressed archive

### Retention
- Keeps last 7 days of backups
- Automatically removes older backups

## Monitoring Script (`monitor.sh`)

This script monitors the health of Redis, Vault, and HAProxy.

### Prerequisites
- Docker installed
- curl installed
- Proper permissions

### Configuration
Edit the following variables in the script:
- `REDIS_PASSWORD`: Redis password
- `VAULT_ADDR`: Vault address
- `VAULT_TOKEN`: Vault token
- `LOG_FILE`: Log file path

### Usage
```bash
./scripts/monitor.sh
```

### Monitoring Checks
1. Redis
   - Master availability
   - Replica availability
   - Replication status

2. Vault
   - Instance availability
   - HA status
   - Cluster health

3. HAProxy
   - Configuration validity
   - Stats page accessibility
   - Service health

### Logging
- Timestamps for all events
- Error messages
- Health status
- Rotates logs automatically

## Best Practices

1. Certificate Management
   - Generate certificates in a secure environment
   - Use strong passwords
   - Implement proper key rotation
   - Secure private keys

2. Backup Strategy
   - Schedule regular backups
   - Test backup restoration
   - Store backups securely
   - Monitor backup success

3. Monitoring
   - Set up alerting
   - Monitor disk space
   - Check log rotation
   - Review monitoring logs

4. Security
   - Use strong passwords
   - Implement proper access controls
   - Regular security audits
   - Monitor for suspicious activity

## Troubleshooting

### Certificate Issues
- Check OpenSSL installation
- Verify file permissions
- Ensure proper paths
- Check certificate validity

### Backup Issues
- Verify disk space
- Check Docker access
- Validate credentials
- Test backup restoration

### Monitoring Issues
- Check log files
- Verify service access
- Validate credentials
- Test connectivity

## Contributing

When adding new scripts:
1. Follow the existing style
2. Add proper documentation
3. Include error handling
4. Add logging
5. Test thoroughly 