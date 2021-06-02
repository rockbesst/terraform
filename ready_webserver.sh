#!/bin/bash
yum -y update
amazon-linux-extras install -y nginx1
sudo service nginx start
chkconfig nginx on