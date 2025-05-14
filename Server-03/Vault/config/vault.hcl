# کانفیگ Vault برای سرور 3 (redis-03.etadbir.com / 192.168.57.68)

storage "raft" {
  path    = "/vault/data"
  node_id = "node3"

  # تنظیمات اتصال به کلاستر
  retry_join {
    leader_api_addr = "https://redis-01.etadbir.com:8200"
    leader_ca_cert_file = "/vault/certs/ca.crt"
    leader_client_cert_file = "/vault/certs/client.crt"
    leader_client_key_file = "/vault/certs/client.key"
  }
  retry_join {
    leader_api_addr = "https://redis-02.etadbir.com:8200"
    leader_ca_cert_file = "/vault/certs/ca.crt"
    leader_client_cert_file = "/vault/certs/client.crt"
    leader_client_key_file = "/vault/certs/client.key"
  }
  retry_join {
    leader_api_addr = "https://redis-03.etadbir.com:8200"
    leader_ca_cert_file = "/vault/certs/ca.crt"
    leader_client_cert_file = "/vault/certs/client.crt"
    leader_client_key_file = "/vault/certs/client.key"
  }
}

listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_cert_file = "/vault/certs/server.crt"
  tls_key_file  = "/vault/certs/server.key"
  # برای دسترسی از طریق si-vault.etadbir.com
  tls_disable_client_certs = true
}

# آدرس‌های API و کلاستر
api_addr = "https://redis-03.etadbir.com:8200"
cluster_addr = "https://redis-03.etadbir.com:8201"

# تنظیمات لاگ
log_level = "info"

# فعال‌سازی رابط کاربری وب
ui = true

# تنظیمات کش و پرفورمنس
default_lease_ttl = "768h"
max_lease_ttl = "768h"
cache_size = 100000
disable_mlock = true

# تنظیمات متفرقه
disable_clustering = false
disable_cache = false
disable_printable_check = false