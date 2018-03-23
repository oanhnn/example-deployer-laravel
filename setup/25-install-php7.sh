#!/usr/bin/env bash

# ======================================================
# Install & Configure PHP7
# ======================================================

# Set environment variables
export $(cat .env | grep -v ^# | xargs)

# Install Base PHP Packages
apt-get install -y \
    php7.1-common \
    php7.1-cli \
    php7.1-fpm \
    php7.1-bcmath \
    php7.1-curl \
    php7.1-gd \
    php7.1-intl \
    php7.1-json \
    php7.1-mbstring \
    php7.1-mcrypt \
    php7.1-mysql \
    php7.1-opcache \
    php7.1-soap \
    php7.1-xml \
    php7.1-zip \
    php-imagick \
    php-redis

# For debug only
apt-get install -y php-xdebug

echo "[✔] Prefer IPv4 over IPv6 for apt-get faster"

# Configure php-cli
cp /etc/php/7.1/cli/php.ini /etc/php/7.1/cli/php.ini.bak
sed -i "s|;*date.timezone =.*|date.timezone = ${TIMEZONE}|i" /etc/php/7.1/cli/php.ini
sed -i "s|;*memory_limit =.*|memory_limit = ${PHP_MEMORY_LIMIT}|i" /etc/php/7.1/cli/php.ini
sed -i "s|;*upload_max_filesize =.*|upload_max_filesize = ${PHP_UPLOAD_MAX_FILESIZE}|i" /etc/php/7.1/cli/php.ini
sed -i "s|;*max_file_uploads =.*|max_file_uploads = ${PHP_MAX_FILE_UPLOAD}|i" /etc/php/7.1/cli/php.ini
sed -i "s|;*post_max_size =.*|post_max_size = ${PHP_POST_MAX_SIZE}|i" /etc/php/7.1/cli/php.ini
sed -i "s|;*cgi.fix_pathinfo=.*|cgi.fix_pathinfo = 0|i" /etc/php/7.1/cli/php.ini
echo "[✔] Configure /etc/php/7.1/cli/php.ini"

# Configure php-fpm
cp /etc/php/7.1/fpm/php.ini /etc/php/7.1/fpm/php.ini.bak
sed -i "s|;*date.timezone =.*|date.timezone = ${TIMEZONE}|i" /etc/php/7.1/fpm/php.ini
sed -i "s|;*memory_limit =.*|memory_limit = ${PHP_MEMORY_LIMIT}|i" /etc/php/7.1/fpm/php.ini
sed -i "s|;*upload_max_filesize =.*|upload_max_filesize = ${PHP_UPLOAD_MAX_FILESIZE}|i" /etc/php/7.1/fpm/php.ini
sed -i "s|;*max_file_uploads =.*|max_file_uploads = ${PHP_MAX_FILE_UPLOAD}|i" /etc/php/7.1/fpm/php.ini
sed -i "s|;*post_max_size =.*|post_max_size = ${PHP_POST_MAX_SIZE}|i" /etc/php/7.1/fpm/php.ini
sed -i "s|;*cgi.fix_pathinfo=.*|cgi.fix_pathinfo = 0|i" /etc/php/7.1/fpm/php.ini
echo "[✔] Configure /etc/php/7.1/fpm/php.ini"

# Configure www pool
cp /etc/php/7.1/fpm/pool.d/www.conf /etc/php/7.1/fpm/pool.d/www.conf.bak
sed -i "s|;*user =.*|user = www-data|i" /etc/php/7.1/fpm/pool.d/www.conf
sed -i "s|;*group =.*|group = www-data|i" /etc/php/7.1/fpm/pool.d/www.conf
sed -i "s|;*listen =.*|listen = /run/php/php7.1-fpm.sock|i" /etc/php/7.1/fpm/pool.d/www.conf
sed -i "s|;*listen.owner =.*|listen.user = www-data|i" /etc/php/7.1/fpm/pool.d/www.conf
sed -i "s|;*listen.group =.*|listen.group = www-data|i" /etc/php/7.1/fpm/pool.d/www.conf
sed -i "s|;*listen.mode =.*|listen.mode = 0660|i" /etc/php/7.1/fpm/pool.d/www.conf
sed -i "s|;*listen.allowed_clients =.*|listen.allowed_clients = 127.0.0.1|i" /etc/php/7.1/fpm/pool.d/www.conf
echo "[✔] Configure /etc/php/7.1/fpm/pool.d/www.conf"

# Install Composer Package Manager
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer
echo "[✔] Install Composer"

# Configure Sessions Directory Permissions
chmod 733 /var/lib/php/sessions
chmod +t /var/lib/php/sessions
echo "[✔] Configure session directory"

# Unset environment variables
unset $(cat .env | grep -v ^# | sed -E 's/(.*)=.*/\1/' | xargs)
