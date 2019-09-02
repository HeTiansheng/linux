#!/bin/bash
#./etc/init.d/functions
###############################################
#功能：检查/var/www/html/下页面是否被篡改
#作者：hts
#最后修改时间：2019-9-02
#版本：1.0
###############################################

function init(){
##############################################
#初始化/var/www/html的tar包以及记录所有文件的md5值
##############################################
	tar -cf /tmp/last_html.tar /var/www/html &> /dev/null
	for file_name in `ls /var/www/html`
	do
		md5sum /var/www/html/$file_name >> /tmp/pag_md5.txt
	done
}

function check_tar(){
##############################################
#对比现在目录的tar包与上一次的tar包md5值是否一致
##############################################
	#echo 'check tar'
	tar -cf /tmp/live_html.tar /var/www/html &> /dev/null
	last_tar_md5=$(md5sum /tmp/last_html.tar | awk '{print $1}')
	live_tar_md5=$(md5sum /tmp/live_html.tar | awk '{print $1}')
	if [ ${last_tar_md5} == ${live_tar_md5} ];then
		#action '页面未被篡改' /bin/true
		return 0
	
	else
		#action '页面被篡改' /bin/false
		return 1
	fi
}

function check_pag(){
##############################################
#对比所有文件的md5值，判断具体是哪一个文件被篡改
##############################################
	for file_name in `ls /var/www/html`
	do
		#判断现在的文件是否为新增文件，能过滤出来说明不是，反之则是新增文件
		grep "/var/www/html/${file_name}" /tmp/pag_md5.txt &> /dev/null
		if [ $? -ne 0 ];then
			#将文件名追加到list列表中
			list[${#list[@]}]=${file_name}
		else
			last_md5=`grep "/var/www/html/${file_name}" /tmp/pag_md5.txt | awk '{print $1}'`
			live_md5=`md5sum /var/www/html/${file_name} | awk '{print $1}'`
			if [ ${last_md5} != ${live_md5} ];then
				list[${#list[@]}]=${file_name}
			fi
		fi
	done
}

function send_email(){
##############################################
#发送邮件，内容是被篡改的文件名
##############################################
	file='\n'
	#将list列表内容转换为字符串
	for str in ${list[*]}
	do
		file+="$str\n"
	done
	messages="问题简述: /var/www/html目录文件发生改变\n报警级别: 严重\n改变时间: `date +%F-%H:%M`\n改变文件: $file"
	subject="$HOMENAME主机Web页面发生篡改"
	to='hts_0000@sina.com'
	#发送邮件
	echo -e $messages | mail -s $subject $to &>> /tmp/mailx.log
}

function main(){
##############################################
#主函数
##############################################

#存储被篡改的文件名
list=()

[ ! -f /tmp/last_html.tar ] && init && sleep 180
check_tar
#判断check_tar函数的返回值
[ $? -ne 0 ] && check_pag && send_email
sleep 180
}

while true
do
	main
done

