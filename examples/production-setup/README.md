# Production Setup Example

This example demonstrates a production-ready setup with Redis replication and Vault HA.

## Prerequisites
- Docker and Docker Compose
- OpenSSL for certificate generation
- At least 3 servers for high availability

## Directory Structure
```
production-setup/
├── docker-compose.yml
├── redis/
│   ├── master/
│   │   └── redis.conf
│   ├── replica/
│   │   └── redis.conf
│   └── sentinel/
│       └── sentinel.conf
├── vault/
│   ├── config/
│   │   └── vault.hcl
│   └── certs/
│       ├── ca.crt
│       ├── server.crt
│       └── server.key
├── haproxy/
│   └── haproxy.cfg
└── README.md
```

## Configuration Files

### docker-compose.yml
```yaml
version: '3.8'

services:
  redis-master:
    image: redis:7.2.4
    container_name: redis-master
    ports:
      - "6379:6379"
    volumes:
      - ./redis/master/redis.conf:/usr/local/etc/redis/redis.conf
    command: redis-server /usr/local/etc/redis/redis.conf
    networks:
      - app_network

  redis-replica-1:
    image: redis:7.2.4
    container_name: redis-replica-1
    ports:
      - "6380:6379"
    volumes:
      - ./redis/replica/redis.conf:/usr/local/etc/redis/redis.conf
    command: redis-server /usr/local/etc/redis/redis.conf
    networks:
      - app_network

  redis-replica-2:
    image: redis:7.2.4
    container_name: redis-replica-2
    ports:
      - "6381:6379"
    volumes:
      - ./redis/replica/redis.conf:/usr/local/etc/redis/redis.conf
    command: redis-server /usr/local/etc/redis/redis.conf
    networks:
      - app_network

  redis-sentinel-1:
    image: redis:7.2.4
    container_name: redis-sentinel-1
    ports:
      - "26379:26379"
    volumes:
      - ./redis/sentinel/sentinel.conf:/usr/local/etc/redis/sentinel.conf
    command: redis-sentinel /usr/local/etc/redis/sentinel.conf
    networks:
      - app_network

  redis-sentinel-2:
    image: redis:7.2.4
    container_name: redis-sentinel-2
    ports:
      - "26380:26379"
    volumes:
      - ./redis/sentinel/sentinel.conf:/usr/local/etc/redis/sentinel.conf
    command: redis-sentinel /usr/local/etc/redis/sentinel.conf
    networks:
      - app_network

  redis-sentinel-3:
    image: redis:7.2.4
    container_name: redis-sentinel-3
    ports:
      - "26381:26379"
    volumes:
      - ./redis/sentinel/sentinel.conf:/usr/local/etc/redis/sentinel.conf
    command: redis-sentinel /usr/local/etc/redis/sentinel.conf
    networks:
      - app_network

  vault-1:
    image: hashicorp/vault:1.15.2
    container_name: vault-1
    ports:
      - "8200:8200"
    volumes:
      - ./vault/config:/vault/config
      - ./vault/certs:/vault/certs
      - vault_data_1:/vault/data
    cap_add:
      - IPC_LOCK
    environment:
      - VAULT_ADDR=https://127.0.0.1:8200
    command: server -config=/vault/config/vault.hcl
    networks:
      - app_network

  vault-2:
    image: hashicorp/vault:1.15.2
    container_name: vault-2
    ports:
      - "8201:8200"
    volumes:
      - ./vault/config:/vault/config
      - ./vault/certs:/vault/certs
      - vault_data_2:/vault/data
    cap_add:
      - IPC_LOCK
    environment:
      - VAULT_ADDR=https://127.0.0.1:8200
    command: server -config=/vault/config/vault.hcl
    networks:
      - app_network

  vault-3:
    image: hashicorp/vault:1.15.2
    container_name: vault-3
    ports:
      - "8202:8200"
    volumes:
      - ./vault/config:/vault/config
      - ./vault/certs:/vault/certs
      - vault_data_3:/vault/data
    cap_add:
      - IPC_LOCK
    environment:
      - VAULT_ADDR=https://127.0.0.1:8200
    command: server -config=/vault/config/vault.hcl
    networks:
      - app_network

  haproxy:
    image: haproxy:2.8
    container_name: haproxy
    ports:
      - "80:80"
      - "443:443"
      - "8404:8404"
    volumes:
      - ./haproxy/haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg
    networks:
      - app_network

networks:
  app_network:
    driver: bridge

volumes:
  vault_data_1:
  vault_data_2:
  vault_data_3:
```

### redis/master/redis.conf
```conf
port 6379
bind 0.0.0.0
protected-mode yes
requirepass YourStrongPassword
masterauth YourStrongPassword
```

### redis/replica/redis.conf
```conf
port 6379
bind 0.0.0.0
protected-mode yes
requirepass YourStrongPassword
masterauth YourStrongPassword
replicaof redis-master 6379
```

### redis/sentinel/sentinel.conf
```conf
port 26379
bind 0.0.0.0
sentinel monitor mymaster redis-master 6379 2
sentinel down-after-milliseconds mymaster 5000
sentinel parallel-syncs mymaster 1
sentinel failover-timeout mymaster 10000
sentinel auth-pass mymaster YourStrongPassword
```

### vault.hcl
```hcl
ui = true

listener "tcp" {
  address = "0.0.0.0:8200"
  tls_cert_file = "/vault/certs/server.crt"
  tls_key_file = "/vault/certs/server.key"
  tls_client_ca_file = "/vault/certs/ca.crt"
}

storage "raft" {
  path = "/vault/data"
  node_id = "vault_1"
  retry_join {
    leader_api_addr = "https://vault-2:8200"
  }
  retry_join {
    leader_api_addr = "https://vault-3:8200"
  }
}

api_addr = "https://127.0.0.1:8200"
cluster_addr = "https://127.0.0.1:8201"
```

### haproxy.cfg
```conf
global
    log /dev/log local0
    log /dev/log local1 notice
    chroot /var/lib/haproxy
    stats socket /run/haproxy/admin.sock mode 660 level admin expose-fd listeners
    stats timeout 30s
    user haproxy
    group haproxy
    daemon

defaults
    log     global
    mode    tcp
    option  dontlognull
    timeout connect 5000
    timeout client  50000
    timeout server  50000

frontend redis
    bind *:6379
    mode tcp
    default_backend redis_servers

backend redis_servers
    mode tcp
    balance roundrobin
    option tcp-check
    server redis-master redis-master:6379 check
    server redis-replica-1 redis-replica-1:6379 check
    server redis-replica-2 redis-replica-2:6379 check

frontend vault
    bind *:8200
    mode tcp
    default_backend vault_servers

backend vault_servers
    mode tcp
    balance roundrobin
    option tcp-check
    server vault-1 vault-1:8200 check
    server vault-2 vault-2:8200 check
    server vault-3 vault-3:8200 check

listen stats
    bind *:8404
    mode http
    stats enable
    stats uri /stats
    stats refresh 10s
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

3. Initialize Vault cluster:
```bash
docker exec -it vault-1 vault operator init
```

4. Unseal all Vault instances:
```bash
docker exec -it vault-1 vault operator unseal <unseal-key>
docker exec -it vault-2 vault operator unseal <unseal-key>
docker exec -it vault-3 vault operator unseal <unseal-key>
```

5. Test Redis replication:
```bash
docker exec -it redis-master redis-cli -a YourStrongPassword info replication
```

6. Test Redis Sentinel:
```bash
docker exec -it redis-sentinel-1 redis-cli -p 26379 sentinel master mymaster
```

7. Test Vault HA:
```bash
docker exec -it vault-1 vault status
```

## Security Notes
- Use strong passwords and TLS in production
- Configure proper firewall rules
- Enable Redis TLS
- Use proper certificate management
- Implement proper access controls
- Regular security audits
- Monitor system resources
- Implement backup strategy 