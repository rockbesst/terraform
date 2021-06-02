#!/bin/bash
yum -y update
amazon-linux-extras -y install nginx1
sudo service nginx start
chkconfig nginx on