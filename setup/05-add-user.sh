#!/usr/bin/env bash

# ======================================================
# Setup User
# ======================================================

# Set environment variables
export $(cat .env | grep -v ^# | xargs)

# Add user with www-data group
useradd -g www-data $USER
mkdir -p /home/$USER/.ssh
#touch /home/$USER/.ssh/authorized_keys
echo "[✔] Make new user $USER"

# Add to sudoers list
adduser $USER sudo
id $USER
groups $USER

# Allow FPM Restart
echo "$USER ALL=NOPASSWD: /usr/sbin/service php7.1-fpm reload" > /etc/sudoers.d/php-fpm
echo "[✔] Setup sudo permissions for user"

# Setup Bash For User
chsh -s /bin/bash $USER
cp /root/.profile /home/$USER/.profile
cp /root/.bashrc /home/$USER/.bashrc
echo "[✔] Setup bash for user"

# Set The Sudo Password For User
PASSWORD=$(mkpasswd $SUDO_PASSWORD)
usermod --password $PASSWORD $USER
echo "[✔] Set sudo password for user"

# Create The Server SSH Key
ssh-keygen -b 2048 -f /home/$USER/.ssh/id_rsa -t rsa -C developer@rabiloo.com -N ''
cp /home/$USER/.ssh/id_rsa.pub /home/$USER/.ssh/authorized_keys
echo "[✔] Create SSH key for user"

# Copy Github, Gitlab And Bitbucket Public Keys Into Known Hosts File
ssh-keyscan -H github.com >> /home/$USER/.ssh/known_hosts
ssh-keyscan -H gitlab.com >> /home/$USER/.ssh/known_hosts
ssh-keyscan -H bitbucket.org >> /home/$USER/.ssh/known_hosts
echo "[✔] Prepare known hosts file for user"

# Setup home directory permissions
chmod -R 755 /home/$USER
chmod -R 700 /home/$USER/.ssh
chmod 600 /home/$USER/.ssh/authorized_keys
chmod 600 /home/$USER/.ssh/id_rsa
chown -R $USER:www-data /home/$USER
echo "[✔] Setup permissions for user home directory"

# TODO: Backup SSH Key


# Unset environment variables
unset $(cat .env | grep -v ^# | sed -E 's/(.*)=.*/\1/' | xargs)
