#!/usr/bin/env bash

echo "--- Good morning, master. Let's get to work. Installing now. ---"

echo "--- Updating packages list ---"
sudo apt-get update

echo "--- MySQL time ---"
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'

echo "--- Installing base packages ---"
sudo apt-get install -y vim curl python-software-properties

echo "--- We want the bleeding edge of PHP, right master? ---"
sudo add-apt-repository -y ppa:ondrej/php5

echo "--- Updating packages list ---"
sudo apt-get update

echo "--- Installing PHP-specific packages ---"
sudo apt-get install -y php5 apache2 libapache2-mod-php5 php5-curl php5-gd php5-mcrypt mysql-server-5.5 php5-mysql git-core wget

echo "--- Installing and configuring Xdebug ---"
sudo apt-get install -y php5-xdebug

cat << EOF | sudo tee -a /etc/php5/mods-available/xdebug.ini
xdebug.scream=1
xdebug.cli_color=1
xdebug.show_local_vars=1
EOF

echo "--- Enabling mod-rewrite ---"
sudo a2enmod rewrite


echo "--- What developer codes without errors turned on? Not you, master. ---"
sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php5/apache2/php.ini
sed -i "s/display_errors = .*/display_errors = On/" /etc/php5/apache2/php.ini

sed -i 's/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf

echo "--- Restarting Apache ---"
sudo service apache2 restart

echo "--- Composer is the future. But you knew that, did you master? Nice job. ---"
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer

echo "--- creating wordpress user and database ---"
mysql -uroot -proot -e "create database wordpress;GRANT ALL PRIVILEGES ON wordpress.* TO root@"

echo "--- Download wordpress ---"

cd /var/www/
wget http://wordpress.org/latest.tar.gz
tar xzvf latest.tar.gz
sudo mv -f wordpress/* html/
cd html
sudo rm index.html
sudo mv wp-config-sample.php wp-config.php

sed -i "s/define('DB_NAME', 'database_name_here');/define('DB_NAME', 'wordpress');/" /var/www/html/wp-config.php
sed -i "s/define('DB_USER', 'username_here');/define('DB_USER', 'root');/" /var/www/html/wp-config.php
sed -i "s/define('DB_PASSWORD', 'password_here');/define('DB_PASSWORD', 'root');/" /var/www/html/wp-config.php


echo "--- All set to go! Would you like to play a game? ---"
