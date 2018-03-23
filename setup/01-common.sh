#!/usr/bin/env bash

# ======================================================
# Configure system
# ======================================================

# Set environment variables
export $(cat .env | grep -v ^# | xargs)

# Prefer IPv4 over IPv6 - make apt-get faster
sed -i "s/#precedence ::ffff:0:0\/96  100/precedence ::ffff:0:0\/96  100/" /etc/gai.conf
echo "[✔] Prefer IPv4 over IPv6 for apt-get faster"

# Upgrade The Base Packages
apt-get update
apt-get upgrade -y
echo "[✔] Upgrade installed packages"

# Add A Few PPAs To Stay Current
apt-get install -y software-properties-common
#apt-add-repository -y ppa:ondrej/php
#apt-add-repository -y ppa:certbot/certbot
echo "[✔] Add some PPAs"

# Update Package Lists
apt-get update

# Base Packages
apt-get install -y build-essential curl fail2ban gcc git libmcrypt4 libpcre3-dev \
make python2.7 python-pip ufw unattended-upgrades unzip whois zsh mc p7zip-full htop git acl
echo "[✔] Install base packages"

# Disable Password Authentication Over SSH
#sed -i "/PasswordAuthentication yes/d" /etc/ssh/sshd_config
#echo "" | sudo tee -a /etc/ssh/sshd_config
#echo "" | sudo tee -a /etc/ssh/sshd_config
#echo "PasswordAuthentication no" | sudo tee -a /etc/ssh/sshd_config

# Restart SSH
ssh-keygen -A
service ssh restart
echo "[✔] Restart SSH service"

# Set The Hostname If Necessary
sed -i "s/127\.0\.0\.1.*localhost/127.0.0.1	$SERVER_NAME localhost/" /etc/hosts
hostnamectl set-hostname $SERVER_NAME
echo "[✔] Set the hostname"

# Set The Timezone
timedatectl set-timezone $TIMEZONE
echo "[✔] Set the timezone"

# Configure Swap Disk
if [ -f /swapfile ]; then
    echo "Swap exists."
else
    fallocate -l $SWAP_SIZE /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    echo "/swapfile none swap sw 0 0" >> /etc/fstab
    echo "vm.swappiness=30" >> /etc/sysctl.conf
    echo "vm.vfs_cache_pressure=50" >> /etc/sysctl.conf
fi
echo "[✔] Configure swap disk"

# Create The Root SSH Directory If Necessary
#if [ ! -d /root/.ssh ]
#then
#    mkdir -p /root/.ssh
#    touch /root/.ssh/authorized_keys
#fi

# Setup Unattended Security Upgrades
cat > /etc/apt/apt.conf.d/50-unattended-upgrades << EOF
Unattended-Upgrade::Allowed-Origins {
    "Ubuntu xenial-security";
};
Unattended-Upgrade::Package-Blacklist {
    //
};
EOF
cat > /etc/apt/apt.conf.d/10-periodic << EOF
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Download-Upgradeable-Packages "1";
APT::Periodic::AutocleanInterval "7";
APT::Periodic::Unattended-Upgrade "1";
EOF
echo "[✔] Setup unattended security upgrades"

# Setup UFW Firewall
ufw allow 22
ufw allow 80
ufw allow 443
ufw --force enable
echo "[✔] Setup UFW firewall"

# Unset environment variables
unset $(cat .env | grep -v ^# | sed -E 's/(.*)=.*/\1/' | xargs)
