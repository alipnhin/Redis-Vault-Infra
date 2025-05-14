# Basic Setup Example

This example demonstrates a basic setup with a single Redis instance and Vault server.

## Prerequisites
- Docker and Docker Compose
- OpenSSL for certificate generation

## Directory Structure
```
basic-setup/
├── docker-compose.yml
├── redis/
│   └── redis.conf
├── vault/
│   ├── config/
│   │   └── vault.hcl
│   └── certs/
│       ├── ca.crt
│       ├── server.crt
│       └── server.key
└── README.md
```

## Configuration Files

### docker-compose.yml
```yaml
version: '3.8'

services:
  redis:
    image: redis:7.2.4
    container_name: redis
    ports:
      - "6379:6379"
    volumes:
      - ./redis/redis.conf:/usr/local/etc/redis/redis.conf
    command: redis-server /usr/local/etc/redis/redis.conf
    networks:
      - app_network

  vault:
    image: hashicorp/vault:1.15.2
    container_name: vault
    ports:
      - "8200:8200"
    volumes:
      - ./vault/config:/vault/config
      - ./vault/certs:/vault/certs
      - vault_data:/vault/data
    cap_add:
      - IPC_LOCK
    environment:
      - VAULT_ADDR=https://127.0.0.1:8200
    command: server -config=/vault/config/vault.hcl
    networks:
      - app_network

networks:
  app_network:
    driver: bridge

volumes:
  vault_data:
```

### redis.conf
```conf
port 6379
bind 0.0.0.0
protected-mode yes
requirepass YourStrongPassword
```

### vault.hcl
```hcl
ui = true

listener "tcp" {
  address = "0.0.0.0:8200"
  tls_cert_file = "/vault/certs/server.crt"
  tls_key_file = "/vault/certs/server.key"
}

storage "file" {
  path = "/vault/data"
}

api_addr = "https://127.0.0.1:8200"
cluster_addr = "https://127.0.0.1:8201"
```

## Usage

1. Generate SSL certificates:
```bash
./scripts/generate-certs.sh
```

2. Start the services:
```bash
docker-compose up -d
```

3. Initialize Vault:
```bash
docker exec -it vault vault operator init
```

4. Unseal Vault:
```bash
docker exec -it vault vault operator unseal <unseal-key>
```

5. Test Redis connection:
```bash
docker exec -it redis redis-cli -a YourStrongPassword ping
```

## Security Notes
- This is a basic setup for development/testing
- Use strong passwords in production
- Enable TLS for Redis in production
- Configure proper access controls
- Use proper certificate management 