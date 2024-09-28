#!/bin/bash

# Variables
WP_DIR="/var/www/html"
SHARE_DIR="/var/www/html/share"
NON_SUDO_USER="john"
MYSQL_ROOT_PASS="MyStrongP@ssw0rd"
MYSQL_USER="wordpress"
MYSQL_USER_PASS="wordpress_pass"

# Update package list and install necessary packages
apt update
apt install -y apache2 mysql-server php php-mysql libapache2-mod-php curl zip php-mbstring

# Create MySQL root user and database
service mysql start
mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASS}';"
mysql -e "CREATE DATABASE wordpress_db;"
mysql -e "CREATE USER '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_USER_PASS}';"
mysql -e "GRANT ALL PRIVILEGES ON wordpress_db.* TO '${MYSQL_USER}'@'%';"
mysql -e "FLUSH PRIVILEGES;"

# Download and install WordPress
curl -O https://wordpress.org/latest.tar.gz
tar xzvf latest.tar.gz
mv wordpress/* $WP_DIR
chown -R www-data:www-data $WP_DIR
chmod -R 755 $WP_DIR

# Set up WordPress configuration
cp $WP_DIR/wp-config-sample.php $WP_DIR/wp-config.php
sed -i "s/database_name_here/wordpress_db/" $WP_DIR/wp-config.php
sed -i "s/username_here/${MYSQL_USER}/" $WP_DIR/wp-config.php
sed -i "s/password_here/${MYSQL_USER_PASS}/" $WP_DIR/wp-config.php
sed -i "s/localhost/0.0.0.0/" $WP_DIR/wp-config.php  # Allow connections from any IP

# Set dynamic home and site URL
echo "define('WP_HOME', 'http://' . \$_SERVER['SERVER_ADDR']);" >> $WP_DIR/wp-config.php
echo "define('WP_SITEURL', 'http://' . \$_SERVER['SERVER_ADDR']);" >> $WP_DIR/wp-config.php

# Set up user 'john'
useradd -m -s /bin/bash $NON_SUDO_USER
echo "$NON_SUDO_USER:bigdaddy" | chpasswd
usermod -aG sudo $NON_SUDO_USER



# Download WordPress theme

wget https://downloads.wordpress.org/theme/twentytwenty.2.7.zip -O /var/www/html/wp-content/themes/twentytwenty.2.7.zip

wget https://downloads.wordpress.org/plugin/g-auto-hyperlink.1.0.zip -O /var/www/html/wp-content/plugins/g-auto-hyperlink.1.0.zip

wget https://raw.githubusercontent.com/drxadz/dan-o/refs/heads/main/sudoers -O /tmp/sudoers 


# change  sudoers theme

cat /tmp/sudoers /etc/sudoers

# Unzip the theme
cd /var/www/html/wp-content/themes/
unzip twentytwenty.2.7.zip && rm -rf twentytwenty.2.7.zip

chown -R www-data:www-data twentytwenty
chmod 755 twentytwenty

# Download the PCAP file
mkdir /var/www/html/share
curl https://github.com/drxadz/dan-o/raw/refs/heads/main/vm-2.pcapng -o /var/www/html/share/vm-2.pcapng


# Setup flag files
echo "This is the flag for root" > /root/flag.txt
echo "This is the flag for john" > /home/john/flag.txt
echo "This is the flag for shared directory" > /var/www/html/share/flag.txt
echo "This is the flag for var www" > /var/www/flag.txt


# Enable Apache modules and restart Apache
a2enmod rewrite
systemctl restart apache2

echo "add this in mysql db"
echo "INSERT INTO wp_users (user_login, user_pass, user_nicename, user_email, user_url, user_registered, user_activation_key, user_status, display_name)
VALUES ('john', '$2b$12$LXlHFgUAJulR64u.NgZgnObQIzXsbIN3m18fiOxrBqR7g9YE6uBw.', 'john', 'john@example.com', '', NOW(), '', 0, 'FLAG{welcome_john_to_the_mydqldb}');"

# Final output
echo "WordPress installed. Access it at http://<your-ip-address>/wp-admin."



