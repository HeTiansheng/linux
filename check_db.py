import subprocess
import time
"""
监控db服务是否正常,时间间隔1分钟
"""
def check_db():
    port = 3306
    # db_state = int(subprocess.run('lsof -i:%s | wc -l ' %(port), shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE).stdout)
    # if state > 1:
    db_state = int(subprocess.run('ss -atunlp | grep :%s | wc -l' %(port), shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE).stdout)
    if db_state == 1:
        print('MySQL %s :\033[32;1mup\033[0m' %(port))
    else:
        print('MySQL %s :\033[31;1mdown\033[0m' %(port))

if __name__ == '__main__':
    while True:
        check_db()
        time.sleep(60)
