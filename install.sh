#!/bin/bash

#IP地址池
ip=("192.168.1.76" "192.168.1.77" "192.168.1.78" "192.168.1.79" "192.168.1.80" "192.168.1.81")

####################################################################
#功能:安装并启动MySQL
####################################################################
function install_mysqld(){
	for i in ${ip[@]}
	do
		scp /linux-soft/03/mysql/mysql-5.7.17.tar $i:/root
		ssh $i "LANG=en;growpart /dev/vda 1;xfs_growfs /dev/vda1"
		ssh $i "tar -xf mysql-5.7.17.tar"
		ssh $i "yum -y install mysql-community-*.rpm"
		ssh $i "systemctl restart mysqld;systemctl enable mysqld"
	done
}

####################################################################
#功能:安装并启动Nginx,安装一些基础模块,添加程序链接
####################################################################
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

####################################################################
#功能:安装Redis,设置Redis服务的端口,开启集群功能
####################################################################
function install_redis(){
redis_startup=/etc/init.d/redis_6379
redis_conf=/etc/redis/6379.conf
	for i in ${ip[@]}
	do
		host_ip=${i##*.}
		scp -r /linux-soft/03/redis $i:/root/
		ssh $i "LANG=en;growpart /dev/vda 1;xfs_growfs /dev/vda1"
		ssh $i "yum -y install gcc"
		ssh $i "cd redis;tar -xf redis-4.0.8.tar.gz"
		ssh $i "cd /root/redis/redis-4.0.8;make&&make install"
		ssh $i "echo -e "\n\n\n\n\n\n" | /root/redis/redis-4.0.8/utils/install_server.sh"		
		
		ssh $i "sed -i '70c bind ${i}' $redis_conf"
		ssh $i "sed -i '93c port 63${host_ip}' $redis_conf"
		ssh $i "sed -i '501c #requirepass 123456' $redis_conf"
		ssh $i "sed -i '43c \$CLIEXEC -h ${i} -p 63${host_ip} shutdown' $redis_startup"

		ssh $i "sed -i '815c cluster-enabled yes' $redis_conf"
		ssh $i "sed -i '823c cluster-config-file nodes-6379.conf' $redis_conf"
		ssh $i "sed -i '829c cluster-node-timeout 5000' $redis_conf"
		
		ssh $i "killall redis-server"
		ssh $i "rm -rf /var/lib/redis/6379/*"
		ssh $i "/etc/init.d/redis_6379 restart"
	done
}

####################################################################
#功能:安装Zabbix,未实现
####################################################################
function install_zabbix(){
	for i in ${ip[@]}
	do
		scp -r /linux-soft/03/Zabbix $i:/root/
		ssh $i "LANG=en;growpart /dev/vda 1;xfs_growfs /dev/vda1"
		ssh $i "yum -y install gcc openssl-devel pcre-devel php php-fpm php-mysql php-gd php-xml php-ldap php-bcmath php-mbstring mariadb mariadb-server mariadb-devel"
		ssh $i "cd Zabbix/;tar -xf nginx-1.12.2.tar.gz;cd nginx-1.12.2/;./configure;make&&make install;ln -s /usr/local/nginx/sbin/nginx /sbin/nginx;nginx"
		ssh $i "sed -i '/^http/a fastcgi_buffers 8 16k; \
fastcgi_buffer_size 32k; \
fastcgi_connect_timeout 300; \
fastcgi_send_timeout 300; \
fastcgi_read_timeout 300;' nginx.conf"
		ssh $i ""


	done
}

####################################################################
#主函数:判断要安装的服务,并启动对应函数安装
####################################################################
while true
do
	echo -e "请输入你要安装的服务\n1.MySQL\n2.Nginx\n3.redis\n输入q退出"
	read -p ':' num
	case $num in
	"1")
		echo 'install mysqld'
		install_mysqld
		;;
	"2")
		echo 'install nginx'
		install_nginx
		;;
	"3")
		echo 'instal redis'
		install_redis
		;;
	"4")
		echo 'install zabbix'
		echo '未实现'
		#install_zabbix
		;;
	"q")
		exit 1
		;;
	esac
done
