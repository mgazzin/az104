#!/bin/bash

yum -y update


echo "Disabling SELINUX"

setenforce 0 >> /tmp/setenforce.out
cat /etc/selinux/config > /tmp/beforeSelinux.out
sed -i 's^SELINUX=enforcing^SELINUX=disabled^g' /etc/selinux/config || true
cat /etc/selinux/config > /tmp/afterSeLinux.out

setenforce 0

dnf -y install nginx

systemctl enable nginx
systemctl start nginx


firewall-cmd --permanent --add-service=http

firewall-cmd --reload

hostname=$(hostname)
echo "<h1> This is $hostname </h1>" > /usr/share/nginx/html/index.html
