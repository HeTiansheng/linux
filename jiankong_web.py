import os
import time
import subprocess

###################################################################
#检测指定网站指定端口是否存活,存活输出ok,不存活输出error
# http_url = input('请输入想检测的网站url:')
# http_port = input('请输入网站端口:')
# http_stat = os.system('nc -zw 5 %s %s' %(http_url,http_port))
# # http_stat = os.system('nc -zw 5 www.chengbi.cn 80')
# if http_stat == 0 :
#     os.system('. /etc/init.d/functions;action ok /bin/true')
#     # print('\033[32;1mok\033[0m')
# else :
#     os.system('. /etc/init.d/functions;action error /bin/false')
#     # print('\033[31;1merror\033[0m')
#####################################################################
url = '127.0.0.1'
port = '80'
# 函数功能:
# 检测指定网站指定端口是否存活,存活输出确认,不存活输出失败
def check_web() :
    if os.path.exists('/etc/init.d/functions') == False :
        print('/etc/init.d/functions文件不存在')
        exit()
    http_state = subprocess.run('nc -zw 5 %s %s' %(url, port) , shell=True).returncode
    if http_state == 0:

    #http_state = os.system('nc -zw 5 %s %s &> /dev/null' %(url, port))
    #if http_state == 0:

    #http_state = int(subprocess.run("echo -e '\n' | telnet %s %s | grep 'Connected' | wc -l" %(url, port), shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE).stdout)
    #if http_state == 1:

    #http_state = int(subprocess.run('nmap %s -p %s | grep open | wc -l' %(url, port), shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE).stdout)
    #if http_state == 1:

    #http_state = int(subprocess.run('curl -I %s 2> /dev/null | egrep "200|301|302" | wc -l' %(url), shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE).stdout)
    #if http_state == 1 :

        os.system('. /etc/init.d/functions;action "%s %s" /bin/true' %(url, port))
    else :
        os.system('. /etc/init.d/functions;action "%s %s" /bin/false' %(url, port))

if __name__ == '__main__':
    while True :
        check_web()
        time.sleep(60)
#####################################################################