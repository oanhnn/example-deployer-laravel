#!/usr/bin/env bash

# ======================================================
# Install MySQL
# ======================================================

# Set environment variables
export $(cat .env | grep -v ^# | xargs)

# Set The Automated Root Password
export DEBIAN_FRONTEND=noninteractive
debconf-set-selections <<< "mysql-community-server mysql-community-server/data-dir select ''"
debconf-set-selections <<< "mysql-community-server mysql-community-server/root-pass password $MYSQL_ROOT_PASSWORD"
debconf-set-selections <<< "mysql-community-server mysql-community-server/re-root-pass password $MYSQL_ROOT_PASSWORD"

# Install MySQL
apt-get install -y mysql-server
systemctl enable mysql

# Configure Password Expiration
echo "default_password_lifetime = 0" >> /etc/mysql/mysql.conf.d/mysqld.cnf

# Configure Access Permissions For Root & User
sed -i '/^bind-address/s/bind-address.*=.*/bind-address = */' /etc/mysql/mysql.conf.d/mysqld.cnf
mysql --user="root" --password="$MYSQL_ROOT_PASSWORD" -e "GRANT ALL ON *.* TO root@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';"
mysql --user="root" --password="$MYSQL_ROOT_PASSWORD" -e "GRANT ALL ON *.* TO root@'127.0.0.1' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';"

mysql --user="root" --password="$MYSQL_ROOT_PASSWORD" -e "CREATE DATABASE $MYSQL_DATABASE;"
mysql --user="root" --password="$MYSQL_ROOT_PASSWORD" -e "CREATE USER '$MYSQL_USERNAME'@'localhost' IDENTIFIED BY '$MYSQL_PASSWORD';"
mysql --user="root" --password="$MYSQL_ROOT_PASSWORD" -e "GRANT ALL ON $MYSQL_DATABASE.* TO '$MYSQL_USERNAME'@'localhost' IDENTIFIED BY '$MYSQL_PASSWORD' WITH GRANT OPTION;"
mysql --user="root" --password="$MYSQL_ROOT_PASSWORD" -e "GRANT ALL ON $MYSQL_DATABASE.* TO '$MYSQL_USERNAME'@'127.0.0.1' IDENTIFIED BY '$MYSQL_PASSWORD' WITH GRANT OPTION;"
#mysql --user="root" --password="$MYSQL_ROOT_PASSWORD" -e "GRANT ALL ON $MYSQL_DATABASE.* TO '$MYSQL_USERNAME'@'%' IDENTIFIED BY '$MYSQL_PASSWORD' WITH GRANT OPTION;"

mysql --user="root" --password="$MYSQL_ROOT_PASSWORD" -e "DROP DATABASE IF EXISTS test;"
mysql --user="root" --password="$MYSQL_ROOT_PASSWORD" -e "FLUSH PRIVILEGES;"
service mysql restart

# Unset environment variables
unset $(cat .env | grep -v ^# | sed -E 's/(.*)=.*/\1/' | xargs)
