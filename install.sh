#!/bin/bash

####################################################################
#
#
#
#
#
####################################################################

#IP地址池
ip=("192.168.1.30" "192.168.1.31" "192.168.1.32")

function install_nginx(){
	for i in ${ip[@]}
	do
		scp /linux-soft/02/lnmp_soft/nginx-1.12.2.tar.gz $i:/root/
		ssh $i "LANG=en;growpart /dev/vda 1;xfs_growfs /dev/vda1"
		ssh $i "yum -y install gcc pcre-devel openssl-devel"
		ssh $i "tar -xf /root/nginx-1.12.2.tar.gz"
		ssh $i "cd /root/nginx-1.12.2;./configure --prefix=/usr/local/nginx --with-http_ssl_module --with-stream;make&&make install"
		ssh $i "ln -s /usr/local/nginx/sbin/nginx /sbin/nginx"
		ssh $i "nginx"
		
	done
}

while true
do
	echo -e "请输入你要安装的服务\n1.MySQL\n2.Nginx\n3.lnmp\n输入q退出"
	read -p ':' num
	case $num in
	"1")
		echo 'install mysqld'
		;;
	"2")
		#echo 'install nginx'
		install_nginx
		;;
	"3")
		echo 'instal lnmp'
		;;
	"q")
		exit 1
		;;
	esac
done
