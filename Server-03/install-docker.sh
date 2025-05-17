#!/bin/bash
# Commands for installing Docker and Docker Compose on Ubuntu 24.04 LTS

# Set colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Starting Docker and Docker Compose Installation ===${NC}"

# Update package list
echo -e "${YELLOW}Updating package list...${NC}"
sudo apt-get update

# Install required prerequisites
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Add Docker's official GPG key
echo -e "${YELLOW}Adding Docker's official GPG key...${NC}"
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Set up the stable repository
echo -e "${YELLOW}Setting up Docker repository...${NC}"
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
echo -e "${YELLOW}Installing Docker Engine...${NC}"
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# Install Docker Compose
echo -e "${YELLOW}Installing Docker Compose...${NC}"
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Add current user to docker group
echo -e "${YELLOW}Adding current user to docker group...${NC}"
sudo usermod -aG docker $USER

echo -e "${GREEN}=== Docker and Docker Compose Installation Completed ===${NC}"
echo -e "${YELLOW}Please log out and log back in for the group changes to take effect.${NC}"

# فعال کردن سرویس Docker برای راه‌اندازی در استارت سیستم
echo -e "${YELLOW}در حال فعال‌سازی سرویس Docker...${NC}"
sudo systemctl enable docker
sudo systemctl start docker

# ایجاد فایل پیکربندی Docker
echo -e "${YELLOW}در حال ایجاد فایل پیکربندی Docker...${NC}"
mkdir -p /etc/docker
cat > /tmp/daemon.json << 'EOF'
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m",
    "max-file": "3"
  },
  "default-ulimits": {
    "nofile": {
      "Name": "nofile",
      "Hard": 65536,
      "Soft": 65536
    }
  },
  "icc": false,
  "storage-driver": "overlay2",
  "iptables": true,
  "live-restore": true,
  "userland-proxy": false,
  "metrics-addr": "0.0.0.0:9323",
  "experimental": true
}
EOF

sudo mv /tmp/daemon.json /etc/docker/
sudo systemctl restart docker

# بررسی نسخه Docker نصب شده
echo -e "${YELLOW}در حال بررسی نسخه Docker نصب شده...${NC}"
docker --version
docker compose version

# ایجاد ساختار دایرکتوری‌ها برای کانفیگ‌های Vault و Redis
echo -e "${YELLOW}در حال ایجاد ساختار دایرکتوری...${NC}"
sudo mkdir -p /opt/cluster/{vault/{certs,config,snapshots},redis/{master-config,replica-config}}

# تنظیم محدودیت‌های سیستمی مناسب برای Redis
echo -e "${YELLOW}در حال تنظیم محدودیت‌های سیستمی برای Redis و Vault...${NC}"

# افزایش تعداد فایل‌های باز
echo "fs.file-max = 1000000" | sudo tee -a /etc/sysctl.conf

# تنظیم حداکثر تعداد دستگیره‌های فایل برای Redis
cat << EOF | sudo tee -a /etc/security/limits.conf
redis soft nofile 65536
redis hard nofile 65536
root soft nofile 65536
root hard nofile 65536
EOF

# فعال کردن overcommit_memory برای Redis
echo "vm.overcommit_memory = 1" | sudo tee -a /etc/sysctl.conf

# غیرفعال کردن transparent huge pages برای Redis
echo "never" | sudo tee /sys/kernel/mm/transparent_hugepage/enabled

# اعمال تنظیمات sysctl
sudo sysctl -p

# ایجاد فایل برای غیرفعال‌سازی THP در هنگام بوت
cat << EOF | sudo tee /etc/systemd/system/disable-thp.service
[Unit]
Description=Disable Transparent Huge Pages (THP)
After=network.target

[Service]
Type=oneshot
ExecStart=/bin/sh -c 'echo never > /sys/kernel/mm/transparent_hugepage/enabled'
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

# فعال‌سازی سرویس غیرفعال‌سازی THP
sudo systemctl enable disable-thp.service
sudo systemctl start disable-thp.service

# نصب ابزارهای مفید برای مدیریت
echo -e "${YELLOW}در حال نصب ابزارهای مفید برای مدیریت...${NC}"
sudo apt install -y net-tools htop iotop iftop tcpdump nmap jq

echo ""
echo -e "${GREEN}Docker و Docker Compose با موفقیت نصب شدند.${NC}"
echo -e "${GREEN}تنظیمات سیستمی برای Redis و Vault انجام شد.${NC}"
echo -e "${GREEN}ساختار دایرکتوری‌های لازم در /opt/cluster ایجاد شد.${NC}"
echo ""
echo -e "${YELLOW}لطفاً فایل‌های docker-compose.yml و کانفیگ‌های Redis و Vault را در مسیرهای مناسب قرار دهید.${NC}"
echo -e "${YELLOW}سپس با استفاده از دستور 'docker compose up -d' سرویس‌ها را راه‌اندازی کنید.${NC}"