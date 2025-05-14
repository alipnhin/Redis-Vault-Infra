# Redis-Vault-Infra

A comprehensive infrastructure solution combining Redis and HashiCorp Vault.

## Features
- Redis master-replica setup
- Vault HA cluster
- TLS encryption
- Monitoring and alerting
- Backup and restore
- Kubernetes support

## Prerequisites
- Docker and Docker Compose
- OpenSSL for certificate generation
- kubectl (for Kubernetes deployment)
- Minimum 3 servers for HA setup

## Quick Start

### 1. Clone the Repository
```bash
git clone https://github.com/alipnhin/Redis-Vault-Infra.git
cd Redis-Vault-Infra
```

### 2. Generate SSL Certificates
```bash
./scripts/generate-certs.sh
```

### 3. Start Services
```bash
docker-compose up -d
```

### 4. Initialize Vault
```bash
# Initialize Vault
docker exec vault-1 vault operator init

# Unseal Vault (repeat for each unseal key)
docker exec vault-1 vault operator unseal <unseal-key>
```

### 5. Test the Setup
```bash
# Test Redis
docker exec redis-master redis-cli -a YourStrongPassword ping

# Test Vault
docker exec vault-1 vault status
```

## Version Information

### Redis
- Version: 7.2.4
- Features:
  - Master-Replica Architecture
  - Sentinel for High Availability
  - TLS Encryption
  - Authentication
  - Persistence Configuration

### Vault
- Version: 1.15.2
- Features:
  - High Availability Mode
  - Raft Storage Backend
  - TLS Encryption
  - Auto-Unsealing
  - Audit Logging

## Documentation
- [Architecture](docs/architecture.md)
- [Security](docs/security.md)
- [Kubernetes Setup](docs/kubernetes.md)
- [Contributing](CONTRIBUTING.md)

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Version Compatibility and Upgrade Guidelines

### Redis Version Compatibility

#### Version Upgrade Path
```yaml
# Supported Upgrade Paths
6.0.0 -> 6.2.x -> 7.0.x -> 7.2.x -> Latest

# Breaking Changes by Version
7.2.x:
  - New ACL features
  - Enhanced replication
  - Improved memory management

7.0.x:
  - RESP3 protocol
  - Function libraries
  - Enhanced ACL

6.2.x:
  - ACL improvements
  - Client-side caching
  - Redis Functions
```

#### Version-Specific Features
```yaml
# Redis 7.2.x Features
- Enhanced ACL with pattern matching
- Improved replication performance
- Better memory management
- New commands: FUNCTION LOAD, FUNCTION DELETE
- Improved cluster management

# Redis 7.0.x Features
- RESP3 protocol support
- Redis Functions
- Enhanced ACL system
- Client-side caching
- Improved cluster management

# Redis 6.2.x Features
- ACL improvements
- Client-side caching
- Redis Functions (beta)
- Improved replication
```

### Vault Version Compatibility

#### Version Upgrade Path
```yaml
# Supported Upgrade Paths
1.13.0 -> 1.14.x -> 1.15.x -> Latest

# Breaking Changes by Version
1.15.x:
  - Enhanced audit logging
  - Improved performance
  - New secrets engines

1.14.x:
  - New authentication methods
  - Enhanced UI
  - Improved security features

1.13.x:
  - Basic features
  - Core functionality
  - Essential security features
```

#### Version-Specific Features
```yaml
# Vault 1.15.x Features
- Enhanced audit logging
- Improved performance
- New secrets engines
- Enhanced UI
- Better security features

# Vault 1.14.x Features
- New authentication methods
- Enhanced UI
- Improved security features
- Better performance

# Vault 1.13.x Features
- Core functionality
- Essential security features
- Basic UI
```

### Upgrade Procedures

#### Redis Upgrade Steps
```bash
# 1. Backup Data
redis-cli SAVE
cp dump.rdb /backup/redis-$(date +%Y%m%d).rdb

# 2. Stop Redis Service
systemctl stop redis

# 3. Install New Version
apt-get update
apt-get install redis-server

# 4. Verify Configuration
redis-cli --version
redis-cli ping

# 5. Start Redis Service
systemctl start redis

# 6. Verify Data
redis-cli INFO
```

#### Vault Upgrade Steps
```bash
# 1. Backup Vault Data
vault operator raft snapshot save /backup/vault-$(date +%Y%m%d).snap

# 2. Stop Vault Service
systemctl stop vault

# 3. Install New Version
apt-get update
apt-get install vault

# 4. Verify Configuration
vault version
vault status

# 5. Start Vault Service
systemctl start vault

# 6. Verify Unseal Status
vault status
```

### Version-Specific Configuration

#### Redis Configuration by Version
```yaml
# Redis 7.2.x Configuration
redis.conf:
  aclfile: /etc/redis/users.acl
  io-threads: 4
  io-threads-do-reads: yes
  replica-lazy-flush: yes
  acl-pubsub-default: allchannels

# Redis 7.0.x Configuration
redis.conf:
  aclfile: /etc/redis/users.acl
  io-threads: 4
  io-threads-do-reads: yes

# Redis 6.2.x Configuration
redis.conf:
  aclfile: /etc/redis/users.acl
```

#### Vault Configuration by Version
```yaml
# Vault 1.15.x Configuration
config.hcl:
  ui = true
  api_addr = "https://vault.example.com:8200"
  cluster_addr = "https://vault.example.com:8201"
  audit {
    file {
      path = "/var/log/vault/audit.log"
      format = "json"
    }
  }

# Vault 1.14.x Configuration
config.hcl:
  ui = true
  api_addr = "https://vault.example.com:8200"
  cluster_addr = "https://vault.example.com:8201"

# Vault 1.13.x Configuration
config.hcl:
  api_addr = "https://vault.example.com:8200"
  cluster_addr = "https://vault.example.com:8201"
```

### Version Compatibility Matrix

#### Redis Compatibility
```yaml
# Client Compatibility
- Redis 7.2.x: All clients
- Redis 7.0.x: Clients supporting RESP3
- Redis 6.2.x: All clients

# Feature Compatibility
- ACL: 6.0.0+
- RESP3: 7.0.0+
- Functions: 7.0.0+
- Client-side caching: 6.2.0+
```

#### Vault Compatibility
```yaml
# Client Compatibility
- Vault 1.15.x: All clients
- Vault 1.14.x: All clients
- Vault 1.13.x: All clients

# Feature Compatibility
- UI: 1.14.0+
- Enhanced audit: 1.15.0+
- New auth methods: 1.14.0+
- Improved performance: 1.15.0+
```

## Architecture

The solution consists of three servers:
- Server-01: Vault Leader + Redis Master + Redis Replica
- Server-02: Vault Follower + Redis Master + Redis Replica
- Server-03: Vault Follower + Redis Master + Redis Replica

### Components
- Redis 7.2 with replication
- HashiCorp Vault 1.15.2
- Docker and Docker Compose
- TLS/SSL encryption

## Security Considerations

- All Redis traffic is encrypted using TLS
- Vault is configured with TLS
- Strong password authentication
- Network isolation using Docker networks
- Regular security updates recommended

## Monitoring

The setup includes:
- Health checks for all services
- Prometheus metrics endpoints
- Grafana dashboards (optional)

## Backup and Restore

Regular backups are configured for:
- Redis data
- Vault data
- Configuration files

## Troubleshooting

Common issues and solutions are documented in the [TROUBLESHOOTING.md](TROUBLESHOOTING.md) file.

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## Support

For support, please open an issue in the GitHub repository.

## Load Balancer Configuration

### Supported Load Balancers
The setup supports various load balancer solutions:
- F5 BIG-IP
- HAProxy
- Nginx
- AWS ELB/ALB
- Azure Load Balancer
- Custom load balancer solutions

### Load Balancer Requirements

#### Redis Load Balancing
- TCP load balancing for ports:
  - 6379 (Redis Master)
  - 6380 (Redis Replica)
  - 16379 (Sentinel)
  - 16380 (Sentinel)
- Health check endpoints:
  - TCP health check on Redis ports
  - Redis PING command for application-level health check
- Session persistence: Not required for Redis
- SSL termination: Optional (handled by Redis TLS)

#### Vault Load Balancing
- TCP/HTTPS load balancing for ports:
  - 8200 (Vault API)
  - 8201 (Vault Cluster)
- Health check endpoints:
  - HTTPS GET /v1/sys/health
  - Expected status codes: 200, 429, 473, 501, 503
- Session persistence: Required for Vault
- SSL termination: Required (handled by Vault TLS)

### F5 BIG-IP Specific Configuration

#### Pool Configuration
```bash
# Redis Master Pool
pool redis-master-pool {
    members {
        redis-01.example.com:6379
        redis-02.example.com:6379
        redis-03.example.com:6379
    }
    monitor tcp
    load-balancing-mode round-robin
}

# Redis Replica Pool
pool redis-replica-pool {
    members {
        redis-01.example.com:6380
        redis-02.example.com:6380
        redis-03.example.com:6380
    }
    monitor tcp
    load-balancing-mode round-robin
}

# Vault API Pool
pool vault-api-pool {
    members {
        vault-01.example.com:8200
        vault-02.example.com:8200
        vault-03.example.com:8200
    }
    monitor https
    load-balancing-mode least-connections
    persistence ssl
}
```

#### Virtual Server Configuration
```bash
# Redis Master Virtual Server
virtual redis-master-vs {
    destination 10.0.0.10:6379
    pool redis-master-pool
    profiles {
        tcp
        ssl
    }
}

# Redis Replica Virtual Server
virtual redis-replica-vs {
    destination 10.0.0.11:6380
    pool redis-replica-pool
    profiles {
        tcp
        ssl
    }
}

# Vault API Virtual Server
virtual vault-api-vs {
    destination 10.0.0.12:8200
    pool vault-api-pool
    profiles {
        http
        ssl
    }
}
```

### Health Check Configuration

#### Redis Health Check
```bash
# TCP Health Check
monitor tcp-redis {
    type tcp
    interval 5
    timeout 16
    send "PING\r\n"
    receive "PONG"
}

# Application Health Check
monitor redis-health {
    type http
    interval 5
    timeout 16
    send "GET /ping HTTP/1.1\r\nHost: example.com\r\n\r\n"
    receive "PONG"
}
```

#### Vault Health Check
```bash
monitor vault-health {
    type https
    interval 5
    timeout 16
    send "GET /v1/sys/health HTTP/1.1\r\nHost: example.com\r\n\r\n"
    receive "200 OK"
    status-codes 200 429 473 501 503
}
```

### SSL/TLS Configuration

#### Certificate Requirements
- Valid SSL certificates for all domains
- Certificate chain must be complete
- Private keys must be securely stored
- Regular certificate rotation

#### SSL Profile Configuration
```bash
profile ssl-profile {
    cert /Common/cert.crt
    key /Common/key.key
    chain /Common/ca.crt
    ciphers HIGH:!aNULL:!MD5
    options no-sslv3 no-tlsv1 no-tlsv1.1
}
```

### High Availability Considerations

1. **Load Balancer Redundancy**
   - Deploy multiple load balancer instances
   - Configure active-active or active-passive setup
   - Implement proper failover mechanisms

2. **Session Persistence**
   - Required for Vault API
   - SSL session persistence recommended
   - Cookie-based persistence as fallback

3. **Health Check Strategy**
   - Multiple health check types
   - Appropriate intervals and timeouts
   - Proper failure thresholds

4. **SSL/TLS Security**
   - Strong cipher suites
   - Regular certificate rotation
   - Proper certificate validation

5. **Monitoring and Logging**
   - Load balancer metrics
   - Connection statistics
   - Error logging
   - Performance monitoring

### HAProxy Configuration

#### Global Configuration
```haproxy
global
    log /dev/log local0
    log /dev/log local1 notice
    chroot /var/lib/haproxy
    stats socket /run/haproxy/admin.sock mode 660 level admin expose-fd listeners
    stats timeout 30s
    user haproxy
    group haproxy
    daemon
    ssl-default-bind-options no-tls-tickets
    ssl-default-bind-ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384
    ssl-default-bind-ciphersuites TLS_AES_128_GCM_SHA256:TLS_AES_256_GCM_SHA384
    ssl-default-server-options no-tls-tickets
    ssl-default-server-ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384
    ssl-default-server-ciphersuites TLS_AES_128_GCM_SHA256:TLS_AES_256_GCM_SHA384
```

#### Default Settings
```haproxy
defaults
    log     global
    mode    tcp
    option  tcplog
    option  dontlognull
    timeout connect 5000
    timeout client  50000
    timeout server  50000
    errorfile 400 /etc/haproxy/errors/400.http
    errorfile 403 /etc/haproxy/errors/403.http
    errorfile 408 /etc/haproxy/errors/408.http
    errorfile 500 /etc/haproxy/errors/500.http
    errorfile 502 /etc/haproxy/errors/502.http
    errorfile 503 /etc/haproxy/errors/503.http
    errorfile 504 /etc/haproxy/errors/504.http
```

#### Redis Frontend Configuration
```haproxy
frontend redis_master_front
    bind *:6379 ssl crt /etc/haproxy/certs/redis.pem
    mode tcp
    option tcplog
    default_backend redis_master_back

frontend redis_replica_front
    bind *:6380 ssl crt /etc/haproxy/certs/redis.pem
    mode tcp
    option tcplog
    default_backend redis_replica_back

frontend redis_sentinel_front
    bind *:16379
    mode tcp
    option tcplog
    default_backend redis_sentinel_back
```

#### Redis Backend Configuration
```haproxy
backend redis_master_back
    mode tcp
    option tcp-check
    tcp-check connect
    tcp-check send PING\r\n
    tcp-check expect string +PONG
    server redis-master-1 redis-01.example.com:6379 check ssl verify none
    server redis-master-2 redis-02.example.com:6379 check ssl verify none
    server redis-master-3 redis-03.example.com:6379 check ssl verify none

backend redis_replica_back
    mode tcp
    option tcp-check
    tcp-check connect
    tcp-check send PING\r\n
    tcp-check expect string +PONG
    server redis-replica-1 redis-01.example.com:6380 check ssl verify none
    server redis-replica-2 redis-02.example.com:6380 check ssl verify none
    server redis-replica-3 redis-03.example.com:6380 check ssl verify none

backend redis_sentinel_back
    mode tcp
    option tcp-check
    tcp-check connect
    server sentinel-1 redis-01.example.com:16379 check
    server sentinel-2 redis-02.example.com:16379 check
    server sentinel-3 redis-03.example.com:16379 check
```

#### Vault Frontend Configuration
```haproxy
frontend vault_front
    bind *:8200 ssl crt /etc/haproxy/certs/vault.pem
    mode http
    option httplog
    http-request set-header X-Forwarded-Proto https if { ssl_fc }
    http-request set-header X-Forwarded-Port %[dst_port]
    default_backend vault_back
```

#### Vault Backend Configuration
```haproxy
backend vault_back
    mode http
    option httpchk GET /v1/sys/health
    http-check expect status 200,429,473,501,503
    cookie SERVERID insert indirect nocache
    server vault-1 vault-01.example.com:8200 check ssl verify none cookie vault-1
    server vault-2 vault-02.example.com:8200 check ssl verify none cookie vault-2
    server vault-3 vault-03.example.com:8200 check ssl verify none cookie vault-3
```

#### Stats Configuration
```haproxy
listen stats
    bind *:8404
    mode http
    stats enable
    stats uri /stats
    stats refresh 10s
    stats admin if TRUE
    stats auth admin:YourStrongPassword
```

### Load Balancer High Availability Scenarios

#### Active-Active Configuration
1. **Multiple Load Balancer Instances**
   - Deploy load balancers in different availability zones
   - Use DNS round-robin for initial load balancer selection
   - Implement health checks between load balancers

2. **Session Synchronization**
   - Share session information between load balancers
   - Use distributed session storage
   - Implement session replication

3. **Configuration Synchronization**
   - Automate configuration deployment
   - Use version control for configurations
   - Implement configuration validation

#### Disaster Recovery
1. **Failover Procedures**
   - Automatic failover detection
   - Manual failover procedures
   - Failback procedures

2. **Backup and Restore**
   - Regular configuration backups
   - Configuration restore procedures
   - Testing restore procedures

3. **Geographic Redundancy**
   - Cross-region deployment
   - Global load balancing
   - Regional failover 

### Nginx Load Balancer Configuration

#### Main Configuration
```nginx
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log warn;
pid /var/run/nginx.pid;

events {
    worker_connections 1024;
    multi_accept on;
    use epoll;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    
    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';
    
    access_log /var/log/nginx/access.log main;
    
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;
    
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers on;
    ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384;
    
    include /etc/nginx/conf.d/*.conf;
}
```

#### Redis Stream Configuration
```nginx
stream {
    upstream redis_master {
        server redis-01.example.com:6379;
        server redis-02.example.com:6379;
        server redis-03.example.com:6379;
    }
    
    upstream redis_replica {
        server redis-01.example.com:6380;
        server redis-02.example.com:6380;
        server redis-03.example.com:6380;
    }
    
    upstream redis_sentinel {
        server redis-01.example.com:16379;
        server redis-02.example.com:16379;
        server redis-03.example.com:16379;
    }
    
    server {
        listen 6379 ssl;
        proxy_pass redis_master;
        ssl_certificate /etc/nginx/ssl/redis.crt;
        ssl_certificate_key /etc/nginx/ssl/redis.key;
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers HIGH:!aNULL:!MD5;
        ssl_prefer_server_ciphers on;
    }
    
    server {
        listen 6380 ssl;
        proxy_pass redis_replica;
        ssl_certificate /etc/nginx/ssl/redis.crt;
        ssl_certificate_key /etc/nginx/ssl/redis.key;
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers HIGH:!aNULL:!MD5;
        ssl_prefer_server_ciphers on;
    }
    
    server {
        listen 16379;
        proxy_pass redis_sentinel;
    }
}
```

#### Vault HTTP Configuration
```nginx
http {
    upstream vault_backend {
        server vault-01.example.com:8200;
        server vault-02.example.com:8200;
        server vault-03.example.com:8200;
    }
    
    server {
        listen 8200 ssl;
        server_name vault.example.com;
        
        ssl_certificate /etc/nginx/ssl/vault.crt;
        ssl_certificate_key /etc/nginx/ssl/vault.key;
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers HIGH:!aNULL:!MD5;
        ssl_prefer_server_ciphers on;
        
        location / {
            proxy_pass https://vault_backend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            
            proxy_connect_timeout 60s;
            proxy_send_timeout 60s;
            proxy_read_timeout 60s;
        }
        
        location /v1/sys/health {
            proxy_pass https://vault_backend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            
            proxy_connect_timeout 60s;
            proxy_send_timeout 60s;
            proxy_read_timeout 60s;
        }
    }
}
```

#### Health Check Configuration
```nginx
http {
    match redis_health {
        status 200;
        header Content-Type = application/json;
        body ~ '"status":"UP"';
    }
    
    match vault_health {
        status 200;
        header Content-Type = application/json;
        body ~ '"sealed":false';
    }
    
    upstream redis_master {
        server redis-01.example.com:6379 max_fails=3 fail_timeout=30s;
        server redis-02.example.com:6379 max_fails=3 fail_timeout=30s;
        server redis-03.example.com:6379 max_fails=3 fail_timeout=30s;
    }
    
    upstream vault_backend {
        server vault-01.example.com:8200 max_fails=3 fail_timeout=30s;
        server vault-02.example.com:8200 max_fails=3 fail_timeout=30s;
        server vault-03.example.com:8200 max_fails=3 fail_timeout=30s;
    }
}
```

#### Monitoring Configuration
```nginx
http {
    server {
        listen 8080;
        server_name monitoring.example.com;
        
        location /nginx_status {
            stub_status on;
            access_log off;
            allow 127.0.0.1;
            deny all;
        }
        
        location /metrics {
            access_log off;
            allow 127.0.0.1;
            deny all;
        }
    }
}
```

### Load Balancer Performance Tuning

#### Connection Pooling
1. **Keep-Alive Settings**
   - Optimize keep-alive timeouts
   - Configure maximum keep-alive requests
   - Monitor connection reuse

2. **Buffer Settings**
   - Adjust buffer sizes
   - Configure buffer timeouts
   - Monitor buffer usage

3. **Worker Process Configuration**
   - Set appropriate worker processes
   - Configure worker connections
   - Optimize worker CPU affinity

#### SSL/TLS Optimization
1. **Session Caching**
   - Enable SSL session cache
   - Configure session timeout
   - Monitor cache hit rates

2. **Certificate Management**
   - Implement OCSP stapling
   - Configure certificate rotation
   - Monitor certificate expiration

3. **Cipher Suite Selection**
   - Use modern cipher suites
   - Enable perfect forward secrecy
   - Monitor cipher usage 

### Advanced High Availability Scenarios

#### Multi-Datacenter Deployment
1. **Active-Active Across Datacenters**
   ```yaml
   # Datacenter 1 (Primary)
   redis_master_dc1:
     - redis-01-dc1.example.com:6379
     - redis-02-dc1.example.com:6379
     - redis-03-dc1.example.com:6379
   
   # Datacenter 2 (Secondary)
   redis_master_dc2:
     - redis-01-dc2.example.com:6379
     - redis-02-dc2.example.com:6379
     - redis-03-dc2.example.com:6379
   ```

2. **Cross-Datacenter Replication**
   - Configure Redis replication across DCs
   - Set up Vault replication
   - Implement network latency monitoring
   - Configure failover thresholds

3. **Global Load Balancing**
   ```yaml
   # DNS Configuration
   redis.example.com:
     - dc1.redis.example.com (Priority: 10)
     - dc2.redis.example.com (Priority: 20)
   
   vault.example.com:
     - dc1.vault.example.com (Priority: 10)
     - dc2.vault.example.com (Priority: 20)
   ```

#### Disaster Recovery Scenarios
1. **Complete Datacenter Failure**
   ```bash
   # Failover Procedure
   1. Monitor health checks
   2. Detect DC failure
   3. Update DNS records
   4. Promote secondary DC
   5. Update load balancer configuration
   6. Verify service health
   ```

2. **Partial Service Failure**
   ```bash
   # Service Recovery
   1. Identify failed components
   2. Isolate affected services
   3. Initiate service recovery
   4. Verify data consistency
   5. Resume normal operations
   ```

3. **Network Partition Recovery**
   ```bash
   # Network Recovery
   1. Detect network partition
   2. Maintain service in isolated segments
   3. Monitor network connectivity
   4. Reconcile data on reconnection
   5. Resume normal operations
   ```

### Comprehensive Monitoring Setup

#### Prometheus Configuration
```yaml
# prometheus.yml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'redis'
    static_configs:
      - targets: ['redis-01:9121', 'redis-02:9121', 'redis-03:9121']
    metrics_path: /metrics

  - job_name: 'vault'
    static_configs:
      - targets: ['vault-01:8200', 'vault-02:8200', 'vault-03:8200']
    metrics_path: /v1/sys/metrics

  - job_name: 'load_balancer'
    static_configs:
      - targets: ['lb-01:9101', 'lb-02:9101']
    metrics_path: /metrics
```

#### Grafana Dashboards
1. **Redis Dashboard**
   ```yaml
   # Key Metrics
   - Memory Usage
   - Connected Clients
   - Commands Processed
   - Replication Lag
   - Key Space Statistics
   - Performance Metrics
   ```

2. **Vault Dashboard**
   ```yaml
   # Key Metrics
   - Seal Status
   - Unseal Progress
   - Token Operations
   - Secret Operations
   - Audit Log Metrics
   - Performance Metrics
   ```

3. **Load Balancer Dashboard**
   ```yaml
   # Key Metrics
   - Connection Rates
   - Error Rates
   - Response Times
   - Backend Health
   - SSL/TLS Metrics
   - Resource Usage
   ```

#### Alerting Configuration
```yaml
# alertmanager.yml
route:
  group_by: ['alertname', 'cluster', 'service']
  group_wait: 30s
  group_interval: 5m
  repeat_interval: 4h
  receiver: 'team-email'

receivers:
- name: 'team-email'
  email_configs:
  - to: 'team@example.com'
    from: 'alertmanager@example.com'
    smarthost: 'smtp.example.com:587'

inhibit_rules:
  - source_match:
      severity: 'critical'
    target_match:
      severity: 'warning'
    equal: ['alertname', 'cluster', 'service']
```

#### Log Aggregation
1. **ELK Stack Configuration**
   ```yaml
   # Filebeat Configuration
   filebeat.inputs:
   - type: log
     paths:
       - /var/log/redis/*.log
       - /var/log/vault/*.log
       - /var/log/loadbalancer/*.log
     fields:
       service: redis-vault-ha
     fields_under_root: true
   ```

2. **Log Shipping**
   ```yaml
   # Logstash Configuration
   input {
     beats {
       port => 5044
     }
   }
   
   filter {
     if [service] == "redis" {
       grok {
         match => { "message" => "%{REDISLOG}" }
       }
     }
     if [service] == "vault" {
       grok {
         match => { "message" => "%{VAULTLOG}" }
       }
     }
   }
   ```

#### Performance Monitoring
1. **Resource Metrics**
   ```yaml
   # Node Exporter Configuration
   node_exporter:
     collectors:
       - cpu
       - memory
       - disk
       - network
       - filesystem
     scrape_interval: 15s
   ```

2. **Application Metrics**
   ```yaml
   # Custom Metrics
   - Redis:
     - Memory usage
     - Connection count
     - Command latency
     - Replication status
   
   - Vault:
     - Seal status
     - Token operations
     - Secret operations
     - Audit log entries
   
   - Load Balancer:
     - Connection rates
     - Error rates
     - Response times
     - Backend health
   ```

#### Health Check Endpoints
```yaml
# Health Check Configuration
health_checks:
  redis:
    endpoint: /ping
    method: GET
    expected_status: 200
    timeout: 5s
    interval: 30s
  
  vault:
    endpoint: /v1/sys/health
    method: GET
    expected_status: [200, 429, 473, 501, 503]
    timeout: 5s
    interval: 30s
  
  load_balancer:
    endpoint: /health
    method: GET
    expected_status: 200
    timeout: 5s
    interval: 30s
```

#### Capacity Planning
1. **Resource Forecasting**
   ```yaml
   # Capacity Metrics
   - CPU Usage Trends
   - Memory Growth
   - Storage Requirements
   - Network Bandwidth
   - Connection Patterns
   ```

2. **Scaling Triggers**
   ```yaml
   # Auto-scaling Rules
   - CPU > 80% for 5 minutes
   - Memory > 85% for 5 minutes
   - Connection count > 1000
   - Response time > 200ms
   ```

### Redis Monitoring and Management Tools

#### 1. RedisInsight (Recommended)
RedisInsight یک رابط کاربری گرافیکی قدرتمند برای مدیریت Redis است که توسط Redis Labs ارائه می‌شود.

**ویژگی‌های کلیدی:**
- مدیریت چندین Redis instance
- مانیتورینگ real-time
- تجزیه و تحلیل داده‌ها
- مدیریت کلیدها
- اجرای دستورات Redis
- پشتیبانی از Redis Stack

**نصب و راه‌اندازی:**
```bash
# Docker Installation
docker run -d --name redis-insight \
    -p 8001:8001 \
    redislabs/redisinsight:latest

# Access UI
http://localhost:8001
```

#### 2. Grafana + Prometheus Redis Exporter
ترکیب Grafana و Prometheus برای مانیتورینگ پیشرفته Redis.

**نصب Redis Exporter:**
```bash
# Docker Installation
docker run -d --name redis-exporter \
    -p 9121:9121 \
    oliver006/redis_exporter \
    --redis.addr=redis://redis-01:6379 \
    --redis.password=YourStrongPassword
```

**Grafana Dashboard Configuration:**
```yaml
# Redis Dashboard Metrics
- Memory Usage
- Connected Clients
- Commands Processed
- Replication Status
- Key Space Statistics
- Performance Metrics
- Slow Log Analysis
```

#### 3. Redis Commander
یک رابط کاربری وب سبک برای مدیریت Redis.

**نصب:**
```bash
# Docker Installation
docker run -d --name redis-commander \
    -p 8081:8081 \
    rediscommander/redis-commander:latest \
    --redis-host=redis-01 \
    --redis-password=YourStrongPassword
```

#### 4. Redis Desktop Manager (AnotherRedisDesktopManager)
یک ابزار مدیریت Redis با رابط کاربری گرافیکی.

**ویژگی‌ها:**
- مدیریت چندین اتصال
- مشاهده و ویرایش داده‌ها
- اجرای دستورات
- مانیتورینگ real-time
- پشتیبانی از SSL/TLS

#### 5. Redis Sentinel Dashboard
داشبورد مخصوص مانیتورینگ Redis Sentinel.

**نصب:**
```bash
# Docker Installation
docker run -d --name redis-sentinel-dashboard \
    -p 8082:8082 \
    -e REDIS_SENTINEL_HOST=redis-01 \
    -e REDIS_SENTINEL_PORT=26379 \
    redis-sentinel-dashboard
```

#### 6. Custom Monitoring Stack

**Prometheus Configuration:**
```yaml
scrape_configs:
  - job_name: 'redis'
    static_configs:
      - targets: ['redis-01:9121', 'redis-02:9121', 'redis-03:9121']
    metrics_path: /metrics
    params:
      target: ['redis-01:6379', 'redis-02:6379', 'redis-03:6379']
```

**Grafana Dashboard Variables:**
```yaml
variables:
  - name: redis_instance
    type: query
    query: label_values(redis_up, instance)
    refresh: 2
    sort: 1
```

**Key Metrics to Monitor:**
```yaml
# Performance Metrics
- redis_commands_processed_total
- redis_connected_clients
- redis_memory_used_bytes
- redis_net_input_bytes
- redis_net_output_bytes

# Replication Metrics
- redis_connected_slaves
- redis_replication_offset
- redis_replication_backlog_bytes

# Memory Metrics
- redis_memory_used_bytes
- redis_memory_peak_bytes
- redis_memory_fragmentation_ratio

# Key Space Metrics
- redis_keyspace_keys_total
- redis_keyspace_expires_total
- redis_keyspace_avg_ttl_seconds
```

#### 7. Alerting Rules

**Prometheus Alert Rules:**
```yaml
groups:
- name: redis
  rules:
  - alert: RedisDown
    expr: redis_up == 0
    for: 1m
    labels:
      severity: critical
    annotations:
      summary: "Redis instance down"
      description: "Redis instance {{ $labels.instance }} has been down for more than 1 minute."

  - alert: RedisMemoryHigh
    expr: redis_memory_used_bytes / redis_memory_max_bytes > 0.85
    for: 5m
    labels:
      severity: warning
    annotations:
      summary: "Redis memory usage high"
      description: "Redis instance {{ $labels.instance }} memory usage is above 85%."

  - alert: RedisReplicationBroken
    expr: redis_connected_slaves < 1
    for: 1m
    labels:
      severity: critical
    annotations:
      summary: "Redis replication broken"
      description: "Redis instance {{ $labels.instance }} has no connected slaves."
```

#### 8. Backup and Monitoring Integration

**Backup Monitoring:**
```yaml
# Backup Status Metrics
- redis_backup_last_success_timestamp
- redis_backup_duration_seconds
- redis_backup_size_bytes

# Backup Alerts
- alert: RedisBackupFailed
  expr: time() - redis_backup_last_success_timestamp > 86400
  for: 1h
  labels:
    severity: warning
  annotations:
    summary: "Redis backup failed"
    description: "No successful backup in the last 24 hours."
```

## Testing

This project includes a comprehensive test suite to ensure the reliability and security of Redis and Vault configurations.

**Test Types:**
- **Unit Tests:** Validate Kubernetes YAML configuration for Redis and Vault.
- **Integration Tests:** Ensure Redis and Vault work together as expected.
- **Performance Tests:** Measure the speed and resource usage of Redis and Vault operations.

**How to Run Tests:**
```bash
pip install -r requirements-test.txt
python -m pytest tests/unit/ -v
python -m pytest tests/integration/ -v
python -m pytest tests/performance/ -v
```

**Continuous Integration:**
All tests are automatically run on each push and pull request via GitHub Actions (`.github/workflows/test.yml`).

---

## Security (update)

- Both pod-level and container-level `securityContext` are set in Kubernetes manifests.
- `runAsNonRoot: true` and `runAsRoot: false` are enforced to prevent running services as root user.
- Example:
  ```yaml
  spec:
    securityContext:
      runAsNonRoot: true
      runAsUser: 1000
      runAsRoot: false
  ```

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## Support

For support, please open an issue in the GitHub repository.

## Load Balancer Configuration

### Supported Load Balancers
The setup supports various load balancer solutions:
- F5 BIG-IP
- HAProxy
- Nginx
- AWS ELB/ALB
- Azure Load Balancer
- Custom load balancer solutions

### Load Balancer Requirements

#### Redis Load Balancing
- TCP load balancing for ports:
  - 6379 (Redis Master)
  - 6380 (Redis Replica)
  - 16379 (Sentinel)
  - 16380 (Sentinel)
- Health check endpoints:
  - TCP health check on Redis ports
  - Redis PING command for application-level health check
- Session persistence: Not required for Redis
- SSL termination: Optional (handled by Redis TLS)

#### Vault Load Balancing
- TCP/HTTPS load balancing for ports:
  - 8200 (Vault API)
  - 8201 (Vault Cluster)
- Health check endpoints:
  - HTTPS GET /v1/sys/health
  - Expected status codes: 200, 429, 473, 501, 503
- Session persistence: Required for Vault
- SSL termination: Required (handled by Vault TLS)

### F5 BIG-IP Specific Configuration

#### Pool Configuration
```bash
# Redis Master Pool
pool redis-master-pool {
    members {
        redis-01.example.com:6379
        redis-02.example.com:6379
        redis-03.example.com:6379
    }
    monitor tcp
    load-balancing-mode round-robin
}

# Redis Replica Pool
pool redis-replica-pool {
    members {
        redis-01.example.com:6380
        redis-02.example.com:6380
        redis-03.example.com:6380
    }
    monitor tcp
    load-balancing-mode round-robin
}

# Vault API Pool
pool vault-api-pool {
    members {
        vault-01.example.com:8200
        vault-02.example.com:8200
        vault-03.example.com:8200
    }
    monitor https
    load-balancing-mode least-connections
    persistence ssl
}
```

#### Virtual Server Configuration
```bash
# Redis Master Virtual Server
virtual redis-master-vs {
    destination 10.0.0.10:6379
    pool redis-master-pool
    profiles {
        tcp
        ssl
    }
}

# Redis Replica Virtual Server
virtual redis-replica-vs {
    destination 10.0.0.11:6380
    pool redis-replica-pool
    profiles {
        tcp
        ssl
    }
}

# Vault API Virtual Server
virtual vault-api-vs {
    destination 10.0.0.12:8200
    pool vault-api-pool
    profiles {
        http
        ssl
    }
}
```

### Health Check Configuration

#### Redis Health Check
```bash
# TCP Health Check
monitor tcp-redis {
    type tcp
    interval 5
    timeout 16
    send "PING\r\n"
    receive "PONG"
}

# Application Health Check
monitor redis-health {
    type http
    interval 5
    timeout 16
    send "GET /ping HTTP/1.1\r\nHost: example.com\r\n\r\n"
    receive "PONG"
}
```

#### Vault Health Check
```bash
monitor vault-health {
    type https
    interval 5
    timeout 16
    send "GET /v1/sys/health HTTP/1.1\r\nHost: example.com\r\n\r\n"
    receive "200 OK"
    status-codes 200 429 473 501 503
}
```

### SSL/TLS Configuration

#### Certificate Requirements
- Valid SSL certificates for all domains
- Certificate chain must be complete
- Private keys must be securely stored
- Regular certificate rotation

#### SSL Profile Configuration
```bash
profile ssl-profile {
    cert /Common/cert.crt
    key /Common/key.key
    chain /Common/ca.crt
    ciphers HIGH:!aNULL:!MD5
    options no-sslv3 no-tlsv1 no-tlsv1.1
}
```

### High Availability Considerations

1. **Load Balancer Redundancy**
   - Deploy multiple load balancer instances
   - Configure active-active or active-passive setup
   - Implement proper failover mechanisms

2. **Session Persistence**
   - Required for Vault API
   - SSL session persistence recommended
   - Cookie-based persistence as fallback

3. **Health Check Strategy**
   - Multiple health check types
   - Appropriate intervals and timeouts
   - Proper failure thresholds

4. **SSL/TLS Security**
   - Strong cipher suites
   - Regular certificate rotation
   - Proper certificate validation

5. **Monitoring and Logging**
   - Load balancer metrics
   - Connection statistics
   - Error logging
   - Performance monitoring

### HAProxy Configuration

#### Global Configuration
```haproxy
global
    log /dev/log local0
    log /dev/log local1 notice
    chroot /var/lib/haproxy
    stats socket /run/haproxy/admin.sock mode 660 level admin expose-fd listeners
    stats timeout 30s
    user haproxy
    group haproxy
    daemon
    ssl-default-bind-options no-tls-tickets
    ssl-default-bind-ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384
    ssl-default-bind-ciphersuites TLS_AES_128_GCM_SHA256:TLS_AES_256_GCM_SHA384
    ssl-default-server-options no-tls-tickets
    ssl-default-server-ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384
    ssl-default-server-ciphersuites TLS_AES_128_GCM_SHA256:TLS_AES_256_GCM_SHA384
```

#### Default Settings
```haproxy
defaults
    log     global
    mode    tcp
    option  tcplog
    option  dontlognull
    timeout connect 5000
    timeout client  50000
    timeout server  50000
    errorfile 400 /etc/haproxy/errors/400.http
    errorfile 403 /etc/haproxy/errors/403.http
    errorfile 408 /etc/haproxy/errors/408.http
    errorfile 500 /etc/haproxy/errors/500.http
    errorfile 502 /etc/haproxy/errors/502.http
    errorfile 503 /etc/haproxy/errors/503.http
    errorfile 504 /etc/haproxy/errors/504.http
```

#### Redis Frontend Configuration
```haproxy
frontend redis_master_front
    bind *:6379 ssl crt /etc/haproxy/certs/redis.pem
    mode tcp
    option tcplog
    default_backend redis_master_back

frontend redis_replica_front
    bind *:6380 ssl crt /etc/haproxy/certs/redis.pem
    mode tcp
    option tcplog
    default_backend redis_replica_back

frontend redis_sentinel_front
    bind *:16379
    mode tcp
    option tcplog
    default_backend redis_sentinel_back
```

#### Redis Backend Configuration
```haproxy
backend redis_master_back
    mode tcp
    option tcp-check
    tcp-check connect
    tcp-check send PING\r\n
    tcp-check expect string +PONG
    server redis-master-1 redis-01.example.com:6379 check ssl verify none
    server redis-master-2 redis-02.example.com:6379 check ssl verify none
    server redis-master-3 redis-03.example.com:6379 check ssl verify none

backend redis_replica_back
    mode tcp
    option tcp-check
    tcp-check connect
    tcp-check send PING\r\n
    tcp-check expect string +PONG
    server redis-replica-1 redis-01.example.com:6380 check ssl verify none
    server redis-replica-2 redis-02.example.com:6380 check ssl verify none
    server redis-replica-3 redis-03.example.com:6380 check ssl verify none

backend redis_sentinel_back
    mode tcp
    option tcp-check
    tcp-check connect
    server sentinel-1 redis-01.example.com:16379 check
    server sentinel-2 redis-02.example.com:16379 check
    server sentinel-3 redis-03.example.com:16379 check
```

#### Vault Frontend Configuration
```haproxy
frontend vault_front
    bind *:8200 ssl crt /etc/haproxy/certs/vault.pem
    mode http
    option httplog
    http-request set-header X-Forwarded-Proto https if { ssl_fc }
    http-request set-header X-Forwarded-Port %[dst_port]
    default_backend vault_back
```

#### Vault Backend Configuration
```haproxy
backend vault_back
    mode http
    option httpchk GET /v1/sys/health
    http-check expect status 200,429,473,501,503
    cookie SERVERID insert indirect nocache
    server vault-1 vault-01.example.com:8200 check ssl verify none cookie vault-1
    server vault-2 vault-02.example.com:8200 check ssl verify none cookie vault-2
    server vault-3 vault-03.example.com:8200 check ssl verify none cookie vault-3
```

#### Stats Configuration
```haproxy
listen stats
    bind *:8404
    mode http
    stats enable
    stats uri /stats
    stats refresh 10s
    stats admin if TRUE
    stats auth admin:YourStrongPassword
```

### Load Balancer High Availability Scenarios

#### Active-Active Configuration
1. **Multiple Load Balancer Instances**
   - Deploy load balancers in different availability zones
   - Use DNS round-robin for initial load balancer selection
   - Implement health checks between load balancers

2. **Session Synchronization**
   - Share session information between load balancers
   - Use distributed session storage
   - Implement session replication

3. **Configuration Synchronization**
   - Automate configuration deployment
   - Use version control for configurations
   - Implement configuration validation

#### Disaster Recovery
1. **Failover Procedures**
   - Automatic failover detection
   - Manual failover procedures
   - Failback procedures

2. **Backup and Restore**
   - Regular configuration backups
   - Configuration restore procedures
   - Testing restore procedures

3. **Geographic Redundancy**
   - Cross-region deployment
   - Global load balancing
   - Regional failover 

### Nginx Load Balancer Configuration

#### Main Configuration
```nginx
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log warn;
pid /var/run/nginx.pid;

events {
    worker_connections 1024;
    multi_accept on;
    use epoll;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    
    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';
    
    access_log /var/log/nginx/access.log main;
    
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;
    
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers on;
    ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384;
    
    include /etc/nginx/conf.d/*.conf;
}
```

#### Redis Stream Configuration
```nginx
stream {
    upstream redis_master {
        server redis-01.example.com:6379;
        server redis-02.example.com:6379;
        server redis-03.example.com:6379;
    }
    
    upstream redis_replica {
        server redis-01.example.com:6380;
        server redis-02.example.com:6380;
        server redis-03.example.com:6380;
    }
    
    upstream redis_sentinel {
        server redis-01.example.com:16379;
        server redis-02.example.com:16379;
        server redis-03.example.com:16379;
    }
    
    server {
        listen 6379 ssl;
        proxy_pass redis_master;
        ssl_certificate /etc/nginx/ssl/redis.crt;
        ssl_certificate_key /etc/nginx/ssl/redis.key;
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers HIGH:!aNULL:!MD5;
        ssl_prefer_server_ciphers on;
    }
    
    server {
        listen 6380 ssl;
        proxy_pass redis_replica;
        ssl_certificate /etc/nginx/ssl/redis.crt;
        ssl_certificate_key /etc/nginx/ssl/redis.key;
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers HIGH:!aNULL:!MD5;
        ssl_prefer_server_ciphers on;
    }
    
    server {
        listen 16379;
        proxy_pass redis_sentinel;
    }
}
```

#### Vault HTTP Configuration
```nginx
http {
    upstream vault_backend {
        server vault-01.example.com:8200;
        server vault-02.example.com:8200;
        server vault-03.example.com:8200;
    }
    
    server {
        listen 8200 ssl;
        server_name vault.example.com;
        
        ssl_certificate /etc/nginx/ssl/vault.crt;
        ssl_certificate_key /etc/nginx/ssl/vault.key;
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers HIGH:!aNULL:!MD5;
        ssl_prefer_server_ciphers on;
        
        location / {
            proxy_pass https://vault_backend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            
            proxy_connect_timeout 60s;
            proxy_send_timeout 60s;
            proxy_read_timeout 60s;
        }
        
        location /v1/sys/health {
            proxy_pass https://vault_backend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            
            proxy_connect_timeout 60s;
            proxy_send_timeout 60s;
            proxy_read_timeout 60s;
        }
    }
}
```

#### Health Check Configuration
```nginx
http {
    match redis_health {
        status 200;
        header Content-Type = application/json;
        body ~ '"status":"UP"';
    }
    
    match vault_health {
        status 200;
        header Content-Type = application/json;
        body ~ '"sealed":false';
    }
    
    upstream redis_master {
        server redis-01.example.com:6379 max_fails=3 fail_timeout=30s;
        server redis-02.example.com:6379 max_fails=3 fail_timeout=30s;
        server redis-03.example.com:6379 max_fails=3 fail_timeout=30s;
    }
    
    upstream vault_backend {
        server vault-01.example.com:8200 max_fails=3 fail_timeout=30s;
        server vault-02.example.com:8200 max_fails=3 fail_timeout=30s;
        server vault-03.example.com:8200 max_fails=3 fail_timeout=30s;
    }
}
```

#### Monitoring Configuration
```nginx
http {
    server {
        listen 8080;
        server_name monitoring.example.com;
        
        location /nginx_status {
            stub_status on;
            access_log off;
            allow 127.0.0.1;
            deny all;
        }
        
        location /metrics {
            access_log off;
            allow 127.0.0.1;
            deny all;
        }
    }
}
```

### Load Balancer Performance Tuning

#### Connection Pooling
1. **Keep-Alive Settings**
   - Optimize keep-alive timeouts
   - Configure maximum keep-alive requests
   - Monitor connection reuse

2. **Buffer Settings**
   - Adjust buffer sizes
   - Configure buffer timeouts
   - Monitor buffer usage

3. **Worker Process Configuration**
   - Set appropriate worker processes
   - Configure worker connections
   - Optimize worker CPU affinity

#### SSL/TLS Optimization
1. **Session Caching**
   - Enable SSL session cache
   - Configure session timeout
   - Monitor cache hit rates

2. **Certificate Management**
   - Implement OCSP stapling
   - Configure certificate rotation
   - Monitor certificate expiration

3. **Cipher Suite Selection**
   - Use modern cipher suites
   - Enable perfect forward secrecy
   - Monitor cipher usage 

### Advanced High Availability Scenarios

#### Multi-Datacenter Deployment
1. **Active-Active Across Datacenters**
   ```yaml
   # Datacenter 1 (Primary)
   redis_master_dc1:
     - redis-01-dc1.example.com:6379
     - redis-02-dc1.example.com:6379
     - redis-03-dc1.example.com:6379
   
   # Datacenter 2 (Secondary)
   redis_master_dc2:
     - redis-01-dc2.example.com:6379
     - redis-02-dc2.example.com:6379
     - redis-03-dc2.example.com:6379
   ```

2. **Cross-Datacenter Replication**
   - Configure Redis replication across DCs
   - Set up Vault replication
   - Implement network latency monitoring
   - Configure failover thresholds

3. **Global Load Balancing**
   ```yaml
   # DNS Configuration
   redis.example.com:
     - dc1.redis.example.com (Priority: 10)
     - dc2.redis.example.com (Priority: 20)
   
   vault.example.com:
     - dc1.vault.example.com (Priority: 10)
     - dc2.vault.example.com (Priority: 20)
   ```

#### Disaster Recovery Scenarios
1. **Complete Datacenter Failure**
   ```bash
   # Failover Procedure
   1. Monitor health checks
   2. Detect DC failure
   3. Update DNS records
   4. Promote secondary DC
   5. Update load balancer configuration
   6. Verify service health
   ```

2. **Partial Service Failure**
   ```bash
   # Service Recovery
   1. Identify failed components
   2. Isolate affected services
   3. Initiate service recovery
   4. Verify data consistency
   5. Resume normal operations
   ```

3. **Network Partition Recovery**
   ```bash
   # Network Recovery
   1. Detect network partition
   2. Maintain service in isolated segments
   3. Monitor network connectivity
   4. Reconcile data on reconnection
   5. Resume normal operations
   ```

### Comprehensive Monitoring Setup

#### Prometheus Configuration
```yaml
# prometheus.yml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'redis'
    static_configs:
      - targets: ['redis-01:9121', 'redis-02:9121', 'redis-03:9121']
    metrics_path: /metrics

  - job_name: 'vault'
    static_configs:
      - targets: ['vault-01:8200', 'vault-02:8200', 'vault-03:8200']
    metrics_path: /v1/sys/metrics

  - job_name: 'load_balancer'
    static_configs:
      - targets: ['lb-01:9101', 'lb-02:9101']
    metrics_path: /metrics
```

#### Grafana Dashboards
1. **Redis Dashboard**
   ```yaml
   # Key Metrics
   - Memory Usage
   - Connected Clients
   - Commands Processed
   - Replication Lag
   - Key Space Statistics
   - Performance Metrics
   ```

2. **Vault Dashboard**
   ```yaml
   # Key Metrics
   - Seal Status
   - Unseal Progress
   - Token Operations
   - Secret Operations
   - Audit Log Metrics
   - Performance Metrics
   ```

3. **Load Balancer Dashboard**
   ```yaml
   # Key Metrics
   - Connection Rates
   - Error Rates
   - Response Times
   - Backend Health
   - SSL/TLS Metrics
   - Resource Usage
   ```

#### Alerting Configuration
```yaml
# alertmanager.yml
route:
  group_by: ['alertname', 'cluster', 'service']
  group_wait: 30s
  group_interval: 5m
  repeat_interval: 4h
  receiver: 'team-email'

receivers:
- name: 'team-email'
  email_configs:
  - to: 'team@example.com'
    from: 'alertmanager@example.com'
    smarthost: 'smtp.example.com:587'

inhibit_rules:
  - source_match:
      severity: 'critical'
    target_match:
      severity: 'warning'
    equal: ['alertname', 'cluster', 'service']
```

#### Log Aggregation
1. **ELK Stack Configuration**
   ```yaml
   # Filebeat Configuration
   filebeat.inputs:
   - type: log
     paths:
       - /var/log/redis/*.log
       - /var/log/vault/*.log
       - /var/log/loadbalancer/*.log
     fields:
       service: redis-vault-ha
     fields_under_root: true
   ```

2. **Log Shipping**
   ```yaml
   # Logstash Configuration
   input {
     beats {
       port => 5044
     }
   }
   
   filter {
     if [service] == "redis" {
       grok {
         match => { "message" => "%{REDISLOG}" }
       }
     }
     if [service] == "vault" {
       grok {
         match => { "message" => "%{VAULTLOG}" }
       }
     }
   }
   ```

#### Performance Monitoring
1. **Resource Metrics**
   ```yaml
   # Node Exporter Configuration
   node_exporter:
     collectors:
       - cpu
       - memory
       - disk
       - network
       - filesystem
     scrape_interval: 15s
   ```

2. **Application Metrics**
   ```yaml
   # Custom Metrics
   - Redis:
     - Memory usage
     - Connection count
     - Command latency
     - Replication status
   
   - Vault:
     - Seal status
     - Token operations
     - Secret operations
     - Audit log entries
   
   - Load Balancer:
     - Connection rates
     - Error rates
     - Response times
     - Backend health
   ```

#### Health Check Endpoints
```yaml
# Health Check Configuration
health_checks:
  redis:
    endpoint: /ping
    method: GET
    expected_status: 200
    timeout: 5s
    interval: 30s
  
  vault:
    endpoint: /v1/sys/health
    method: GET
    expected_status: [200, 429, 473, 501, 503]
    timeout: 5s
    interval: 30s
  
  load_balancer:
    endpoint: /health
    method: GET
    expected_status: 200
    timeout: 5s
    interval: 30s
```

#### Capacity Planning
1. **Resource Forecasting**
   ```yaml
   # Capacity Metrics
   - CPU Usage Trends
   - Memory Growth
   - Storage Requirements
   - Network Bandwidth
   - Connection Patterns
   ```

2. **Scaling Triggers**
   ```yaml
   # Auto-scaling Rules
   - CPU > 80% for 5 minutes
   - Memory > 85% for 5 minutes
   - Connection count > 1000
   - Response time > 200ms
   ```

### Redis Monitoring and Management Tools

#### 1. RedisInsight (Recommended)
RedisInsight یک رابط کاربری گرافیکی قدرتمند برای مدیریت Redis است که توسط Redis Labs ارائه می‌شود.

**ویژگی‌های کلیدی:**
- مدیریت چندین Redis instance
- مانیتورینگ real-time
- تجزیه و تحلیل داده‌ها
- مدیریت کلیدها
- اجرای دستورات Redis
- پشتیبانی از Redis Stack

**نصب و راه‌اندازی:**
```bash
# Docker Installation
docker run -d --name redis-insight \
    -p 8001:8001 \
    redislabs/redisinsight:latest

# Access UI
http://localhost:8001
```

#### 2. Grafana + Prometheus Redis Exporter
ترکیب Grafana و Prometheus برای مانیتورینگ پیشرفته Redis.

**نصب Redis Exporter:**
```bash
# Docker Installation
docker run -d --name redis-exporter \
    -p 9121:9121 \
    oliver006/redis_exporter \
    --redis.addr=redis://redis-01:6379 \
    --redis.password=YourStrongPassword
```

**Grafana Dashboard Configuration:**
```yaml
# Redis Dashboard Metrics
- Memory Usage
- Connected Clients
- Commands Processed
- Replication Status
- Key Space Statistics
- Performance Metrics
- Slow Log Analysis
```

#### 3. Redis Commander
یک رابط کاربری وب سبک برای مدیریت Redis.

**نصب:**
```bash
# Docker Installation
docker run -d --name redis-commander \
    -p 8081:8081 \
    rediscommander/redis-commander:latest \
    --redis-host=redis-01 \
    --redis-password=YourStrongPassword
```

#### 4. Redis Desktop Manager (AnotherRedisDesktopManager)
یک ابزار مدیریت Redis با رابط کاربری گرافیکی.

**ویژگی‌ها:**
- مدیریت چندین اتصال
- مشاهده و ویرایش داده‌ها
- اجرای دستورات
- مانیتورینگ real-time
- پشتیبانی از SSL/TLS

#### 5. Redis Sentinel Dashboard
داشبورد مخصوص مانیتورینگ Redis Sentinel.

**نصب:**
```bash
# Docker Installation
docker run -d --name redis-sentinel-dashboard \
    -p 8082:8082 \
    -e REDIS_SENTINEL_HOST=redis-01 \
    -e REDIS_SENTINEL_PORT=26379 \
    redis-sentinel-dashboard
```

#### 6. Custom Monitoring Stack

**Prometheus Configuration:**
```yaml
scrape_configs:
  - job_name: 'redis'
    static_configs:
      - targets: ['redis-01:9121', 'redis-02:9121', 'redis-03:9121']
    metrics_path: /metrics
    params:
      target: ['redis-01:6379', 'redis-02:6379', 'redis-03:6379']
```

**Grafana Dashboard Variables:**
```yaml
variables:
  - name: redis_instance
    type: query
    query: label_values(redis_up, instance)
    refresh: 2
    sort: 1
```

**Key Metrics to Monitor:**
```yaml
# Performance Metrics
- redis_commands_processed_total
- redis_connected_clients
- redis_memory_used_bytes
- redis_net_input_bytes
- redis_net_output_bytes

# Replication Metrics
- redis_connected_slaves
- redis_replication_offset
- redis_replication_backlog_bytes

# Memory Metrics
- redis_memory_used_bytes
- redis_memory_peak_bytes
- redis_memory_fragmentation_ratio

# Key Space Metrics
- redis_keyspace_keys_total
- redis_keyspace_expires_total
- redis_keyspace_avg_ttl_seconds
```

#### 7. Alerting Rules

**Prometheus Alert Rules:**
```yaml
groups:
- name: redis
  rules:
  - alert: RedisDown
    expr: redis_up == 0
    for: 1m
    labels:
      severity: critical
    annotations:
      summary: "Redis instance down"
      description: "Redis instance {{ $labels.instance }} has been down for more than 1 minute."

  - alert: RedisMemoryHigh
    expr: redis_memory_used_bytes / redis_memory_max_bytes > 0.85
    for: 5m
    labels:
      severity: warning
    annotations:
      summary: "Redis memory usage high"
      description: "Redis instance {{ $labels.instance }} memory usage is above 85%."

  - alert: RedisReplicationBroken
    expr: redis_connected_slaves < 1
    for: 1m
    labels:
      severity: critical
    annotations:
      summary: "Redis replication broken"
      description: "Redis instance {{ $labels.instance }} has no connected slaves."
```

#### 8. Backup and Monitoring Integration

**Backup Monitoring:**
```yaml
# Backup Status Metrics
- redis_backup_last_success_timestamp
- redis_backup_duration_seconds
- redis_backup_size_bytes

# Backup Alerts
- alert: RedisBackupFailed
  expr: time() - redis_backup_last_success_timestamp > 86400
  for: 1h
  labels:
    severity: warning
  annotations:
    summary: "Redis backup failed"
    description: "No successful backup in the last 24 hours."
``` 