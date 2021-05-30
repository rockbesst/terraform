#!/bin/bash
yum -y update
yum -y install httpd
ip=`curl http://169.254.169.254/latest/meta-data/local-ipv4`
echo "<h2>Server IP is $ip</h2>" > /var/www/html/index.html
echo "<br><img src = 'https://rockbesst-img.s3.eu-central-1.amazonaws.com/IMG_3993.JPG'>"
sudo service httpd start
chkconfig httpd on