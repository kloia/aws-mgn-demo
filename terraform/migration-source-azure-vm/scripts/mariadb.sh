#!/bin/bash
sudo yum -y update
sudo yum -y install mariadb-server mariadb
sudo systemctl enable mariadb
sudo systemctl start mariadb