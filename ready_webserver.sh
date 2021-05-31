#!/bin/bash
yum -y update
yum -y install httpd
ip=`curl http://169.254.169.254/latest/meta-data/local-ipv4`
aws s3 cp s3://rockbesst-img/IMG_3993.JPG /var/www/html/IMG_3993.JPG
echo "<h2>Server IP is $ip</h2>" > /var/www/html/index.html
echo "<br><img src = 'IMG_3993.JPG' style="width:500px;height:600px;>" > /var/www/html/index.html
sudo service httpd start
chkconfig httpd on