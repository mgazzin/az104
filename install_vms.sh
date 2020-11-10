#!/bin/bash

echo "Disabling SELINUX"

setenforce 0 >> /tmp/setenforce.out
cat /etc/selinux/config > /tmp/beforeSelinux.out
sed -i 's^SELINUX=enforcing^SELINUX=disabled^g' /etc/selinux/config || true
cat /etc/selinux/config > /tmp/afterSeLinux.out

setenforce 0

yum makecache fast

rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm

yum -y install nginx18 php56w-fpm git nano wget

yum -y install php56w-mysql php56w-pear php56w-bcmath php56w-gd php56w-pdo php56w-mcrypt php56w-soap php56w-mbstring php56w-opcache php56w-devel gcc mariadb

echo "oauth install"

printf "\n" | pecl install oauth

echo -n extension=oauth.so >> /etc/php.ini

echo "Restarting and setting nginx to start on boot"

systemctl restart nginx; systemctl enable nginx

echo "Setting user and group = nginx in PHP-FPM"

sed -i 's/apache/nginx/g' /etc/php-fpm.d/www.conf

chown nginx:root /var/log/php-fpm -R

echo "Restarting PHP-FPM"

systemctl restart php-fpm; systemctl enable php-fpm

echo "Creating SSL folder in nginx root"
mkdir /etc/nginx/ssl

echo "n
p
1


p
w

" | fdisk /dev/sdc

mkfs -t ext4 /dev/sdc1

mkdir /data

mount /dev/sdc1 /data

var=$(blkid /dev/sdc1 -s UUID | awk -F'UUID="|"' '{print $2}')

echo >> /etc/fstab "UUID=$var /data ext4 defaults,noatime,data=writeback,barrier=0,nobh,errors=remount-ro 0 2"

echo "Creating a www folder on the data drive"

mkdir -p /data/www/

echo " Giving ownership to nginx on the WWW folder in the attached data disk"

chown nginx:nginx -R /data/www

echo "Enabling Swap"

sed -i 's/ResourceDisk.EnableSwap=n/ResourceDisk.EnableSwap=y/g' /etc/waagent.conf

sed -i 's/ResourceDisk.SwapSizeMB=0/ResourceDisk.SwapSizeMB=16384/g' /etc/waagent.conf

echo "* soft nofile 65536" >> /etc/security/limits.conf

echo "* hard nofile 65536" >> /etc/security/limits.conf

echo "* soft nproc 65536" >> /etc/security/limits.conf

echo "* hard nproc 65536" >>  /etc/security/limits.conf

echo "Setting maximum open file limit to 65536"

ulimit -SHn 65536

ulimit -SHu 65536

echo “ulimit -SHn 65536” >>/etc/rc.local

echo “ulimit -SHu 65536” >>/etc/rc.local

echo "Setting Time Zone To Europe/Rome"

timedatectl set-timezone Europe/Rome

echo "Optimizing TCP Stack"

echo net.ipv4.tcp_sack=1 >> /etc/sysctl.conf
echo net.core.rmem_max=4194304 >> /etc/sysctl.conf
echo net.core.wmem_max=4194304 >> /etc/sysctl.conf
echo net.core.rmem_default=4194304 >> /etc/sysctl.conf
echo net.core.wmem_default=4194304 >> /etc/sysctl.conf
echo net.core.optmem_max=4194304 >> /etc/sysctl.conf
echo net.ipv4.tcp_rmem="4096 87380 4194304" >> /etc/sysctl.conf
echo net.ipv4.tcp_wmem="4096 65536 4194304" >> /etc/sysctl.conf
echo net.ipv4.tcp_low_latency=1 >> /etc/sysctl.conf
sed -i "s/defaults        0 0/defaults,noatime        0 0/" /etc/fstab
