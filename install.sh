#!/bin/bash

#IP地址池
ip=("192.168.2.2" "192.168.2.3")
#linux-soft文件所在路径
soft_path='/root/linux-soft'

####################################################################
#功能:安装并启动MySQL
####################################################################
function install_mysqld(){
	for i in ${ip[@]}
	do
		scp ${soft_path}/03/mysql/mysql-5.7.17.tar $i:/root
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
		scp ${soft_path}/02/lnmp_soft/nginx-1.12.2.tar.gz $i:/root/
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
		scp -r ${soft_path}/03/redis $i:/root/
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
#功能:安装Zabbix Server端
####################################################################
function install_zabbix(){
	for i in ${ip[@]}
	do
		scp -r ${soft_path}/03/Zabbix $i:/root/

		ssh $i "yum -y install gcc openssl-devel pcre-devel"
		ssh $i "yum -y install php php-fpm php-mysql php-gd php-xml php-ldap php-bcmath php-mbstring"
		ssh $i "yum -y install mariadb mariadb-server mariadb-devel"
		ssh $i "yum -y install libevent-devel net-snmp-devel curl-devel"

		ssh $i "cd Zabbix/;tar -xf nginx-1.12.2.tar.gz"
		ssh $i "cd /root/Zabbix/nginx-1.12.2/;./configure;make&&make install"
		ssh $i "ln -s /usr/local/nginx/sbin/nginx /sbin/nginx"
		scp /root/nginx.conf $i:/usr/local/nginx/conf/
		ssh $i "cd /root/Zabbix/zabbix-3.4.4/frontends/php;cp -r ./* /usr/local/nginx/html/"
		ssh $i "chmod -R 777 /usr/local/nginx/html/*;nginx"

		ssh $i "sed -i '384c max_execution_time = 300' /etc/php.ini; \
sed -i '394c max_input_time = 300' /etc/php.ini; \
sed -i '672c post_max_size = 32M' /etc/php.ini; \
sed -i '878c date.timezone = Asia/Shanghai' /etc/php.ini"
		ssh $i "systemctl restart php-fpm;systemctl enable php-fpm"

		ssh $i "systemctl restart mariadb.service"
		ssh $i "mysql -e 'create database zabbix character set utf8;'"
		ssh $i "mysql -e \"grant all on zabbix.* to zabbix@localhost identified by 'zabbix';\""
		ssh $i "mysql -uzabbix -pzabbix zabbix < /root/Zabbix/zabbix-3.4.4/database/mysql/schema.sql"
		ssh $i "mysql -uzabbix -pzabbix zabbix < /root/Zabbix/zabbix-3.4.4/database/mysql/images.sql"
		ssh $i "mysql -uzabbix -pzabbix zabbix < /root/Zabbix/zabbix-3.4.4/database/mysql/data.sql"
		ssh $i "systemctl restart mariadb.service;systemctl enable mariadb.service"

		ssh $i "cd /root/Zabbix;tar -xf zabbix-3.4.4.tar.gz;"
		ssh $i "cd /root/Zabbix/zabbix-3.4.4;./configure --enable-server --enable-agent --enable-proxy --with-mysql=/usr/bin/mysql_config --with-net-snmp --with-libcurl;make install"
		ssh $i "sed -i '/DBUser=zabbix/a DBPassword=zabbix' /usr/local/etc/zabbix_server.conf"
		ssh $i "sed -i '/# DBHost=localhost/c DBHost=localhost' /usr/local/etc/zabbix_server.conf"
		ssh $i "useradd -s /sbin/nologin zabbix"
		ssh $i "zabbix_server"
	done
}

####################################################################
#功能:安装Zabbix agent客户端
####################################################################
function install_zabbix_agent(){
	for i in ${ip[@]}
	do
		scp -r ${soft_path}/03/Zabbix $i:/root/
                ssh $i "yum -y install gcc openssl-devel pcre-devel"

		ssh $i "useradd -s /sbin/nologin zabbix"
		ssh $i "tar -xf /root/Zabbix/zabbix-3.4.4.tar.gz -C /root/"
		ssh $i "cd /root/zabbix-3.4.4;./configure --enable-agent;make install"

		ssh $i "sed -i '93c Server=127.0.0.1,192.168.1.100' /usr/local/etc/zabbix_agentd.conf"
		ssh $i "sed -i '134c ServerActive=127.0.0.1,192.168.1.100' /usr/local/etc/zabbix_agentd.conf"
		ssh $i 'sed -i "145c Hostname=$HOSTNAME" /usr/local/etc/zabbix_agentd.conf'
		ssh $i "sed -i '69c EnableRemoteCommands=1' /usr/local/etc/zabbix_agentd.conf"
		ssh $i "sed -i '280c UnsafeUserParameters=1' /usr/local/etc/zabbix_agentd.conf"

		ssh $i "zabbix_agentd"
	done
}

####################################################################
#菜单函数:判断要安装的服务,并启动对应函数安装
####################################################################
function menu(){
	while true
	do
		clear
		echo -e "请输入你要安装的服务\n1.MySQL\n2.Nginx\n3.redis\n4.Zabbix_Server\n5.Zabbix_agent\n输入q退出"
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
			echo 'install zabbix_server'
			install_zabbix
			;;
		"5")
			echo 'install zabbix_agent'
			install_zabbix_agent
			;;
		"q")
			exit 0
			;;
		esac
	done
}
function init(){
	clear

	read -p '是否需要磁盘扩容[y/n]:' disk_flag

	echo '将会被安装服务的IP为：'
	for i in ${ip[@]}
	do
		if [ `ping -w 3 -c 2 $i &> /dev/null;echo $?` -eq 0 ];then 
			echo -e "$i\t\033[32m[ok]\033[0m"
		else 
			echo -e "$i\t\033[31m[error]\033[0m"
		fi
	done

	read -p '是否继续执行安装[y/n]' flag
	if [ ${flag} = 'n' ];then
		exit 1
	elif [ ${flag} = 'y' ];then
		if [ ${disk_flag} = 'y' ];then
			echo '磁盘初始化过程-----------------------------------'
			#for i in ${ip[@]}
        		#do
			#	ssh $i "LANG=en;growpart /dev/vda 1;xfs_growfs /dev/vda1"
			#done
		fi
		[ ! -d ${soft_path} ] && echo "${soft_path}目录不存在" && exit 2 || menu
	else
		echo '输入有误'
		exit 1
	fi
	
}
####################################################################
#主函数
####################################################################
init
