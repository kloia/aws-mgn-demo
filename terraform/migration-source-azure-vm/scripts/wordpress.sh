#!/bin/bash
# install httpd
sudo yum -y update
sudo yum -y install httpd
sudo yum -y install php php-mysql php-fpm php-gd
sudo yum -y install 
sudo setsebool httpd_can_network_connect=1
sudo systemctl enable httpd.service
sudo systemctl start httpd.service
# install mysql client
sudo yum -y install mysql
# install WP CLI (note: yum package doesn't exist)
cd ~
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
sudo mv wp-cli.phar /usr/local/bin/wp