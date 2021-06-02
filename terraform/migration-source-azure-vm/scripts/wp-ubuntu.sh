#!/bin/bash
# install httpd
sudo apt -y update
sudo apt -y install httpd
sudo apt -y install php php-mysql php-fpm php-gd
sudo setsebool httpd_can_network_connect=1
sudo systemctl enable httpd.service
sudo systemctl start httpd.service
# install mysql client
sudo apt -y install mysql
# install WP CLI (note: yum package doesn't exist)
cd ~
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
sudo mv wp-cli.phar /usr/local/bin/wp