# Vault configuration for Server 3 (redis-03.example.com / 192.168.57.68)

storage "raft" {
  path    = "/vault/data"
  node_id = "node3"

  # Cluster connection settings
  retry_join {
    leader_api_addr = "https://redis-01.example.com:8200"
    leader_ca_cert_file = "/vault/certs/ca.crt"
    leader_client_cert_file = "/vault/certs/client.crt"
    leader_client_key_file = "/vault/certs/client.key"
  }
  retry_join {
    leader_api_addr = "https://redis-02.example.com:8200"
    leader_ca_cert_file = "/vault/certs/ca.crt"
    leader_client_cert_file = "/vault/certs/client.crt"
    leader_client_key_file = "/vault/certs/client.key"
  }
  retry_join {
    leader_api_addr = "https://redis-03.example.com:8200"
    leader_ca_cert_file = "/vault/certs/ca.crt"
    leader_client_cert_file = "/vault/certs/client.crt"
    leader_client_key_file = "/vault/certs/client.key"
  }
}

listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_cert_file = "/vault/certs/server.crt"
  tls_key_file  = "/vault/certs/server.key"
  # For access through si-vault.example.com
  tls_disable_client_certs = true
}

# API and cluster addresses
api_addr = "https://redis-03.example.com:8200"
cluster_addr = "https://redis-03.example.com:8201"

# Log settings
log_level = "info"

# Enable web UI
ui = true

# Cache and performance settings
default_lease_ttl = "768h"
max_lease_ttl = "768h"
cache_size = 100000
disable_mlock = true

# Miscellaneous settings
disable_clustering = false
disable_cache = false
disable_printable_check = false