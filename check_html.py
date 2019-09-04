import os
import time
import hashlib
import tarfile
import re

def init(html_dir, last_md5_log, last_html_tar):
    """
    初始化MD5文件和压缩包文件
    存放于/tmp目录下
    """
    # 初始化一个空的MD5对象
    m = hashlib.md5()
    # 创建last_html.tar.gz文件
    t = tarfile.open(last_html_tar, 'w')
    # 取出页面文件绝对路径,并压缩至last_html_tar文件
    # maindir:当前目录
    # subdir:当前目录下所有目录
    # file_name_list:当前目录下所有文件
    for maindir, subdir, file_name_list in os.walk(html_dir):
        for file_name in file_name_list:
            a_path = os.path.join(maindir, file_name)

            with open(a_path, 'rb') as fobj:
                while True:
                    # 每次只读4096字节,加快计算速度
                    data = fobj.read(4096)
                    # 没有数据了中断循环
                    if not data:
                        break
                    # 更新MD5值
                    m.update(data)
            # 写入文件名和MD5值
            with open(last_md5_log, 'a') as fobj:
                data = a_path + ':' + m.hexdigest() + '\n'
                fobj.writelines(data)
            t.add(a_path)
    t.close()

def check_tar(html_dir, last_html_tar, live_html_tar):
    """
    检查当前压缩包文件与之前的压缩包文件MD5值是否一致
    不一致返回True
    一致返回False
    """
    # 创建live_html.tar.gz文件
    t = tarfile.open(live_html_tar, 'w')
    # 用于存储文件的MD5值
    m1 = hashlib.md5()
    m2 = hashlib.md5()

    # 取出页面文件绝对路径,并压缩至live_html_tar文件
    # maindir:当前目录
    # subdir:当前目录下所有目录
    # file_name_list:当前目录下所有文件
    for maindir, subdir, file_name_list in os.walk(html_dir):
        for file_name in file_name_list:
            a_path = os.path.join(maindir, file_name)
            t.add(a_path)
    t.close()

    # 计算last_html_tar文件的MD5值
    with open(last_html_tar, 'rb') as fobj:
        while True:
            data = fobj.read(4096)
            # 没有数据了中断循环
            if not data:
                break
            # 更新MD5值
            m1.update(data)
    # 计算live_html_tar文件的MD5值
    with open(live_html_tar, 'rb') as fobj:
        while True:
            data = fobj.read(4096)
            # 没有数据了中断循环
            if not data:
                break
            # 更新MD5值
            m2.update(data)

    last_html_md5 = m1.hexdigest()
    live_html_md5 = m2.hexdigest()
    # MD5值不一致就返回True
    if last_html_md5 != live_html_md5:
        return True
    else:
        return False

def check_pag(html_dir, last_md5_log):
    """
    检查具体是那个文件被篡改
    返回一个列表,内容是被篡改的文件绝对路径
    """
    list = []
    m = hashlib.md5()
    with open(last_md5_log, 'r') as fobj:
        data = fobj.readlines()
    for maindir, subdir, file_name_list in os.walk(html_dir):
        for file_name in file_name_list:
            a_path = os.path.join(maindir, file_name)
            for line in data:
                f1 = re.split(':', line)
                if a_path == f1[0]:
                    with open(a_path, 'rb') as fobj:
                        while True:
                            data = fobj.read(4096)
                            # 没有数据了中断循环
                            if not data:
                                break
                            # 更新MD5值
                            m.update(data)
                    if m.hexdigest() != f1[1]:
                        list.append(a_path)
                    break
            list.append(a_path)
    return list

def send_email(list):
    """
    发送邮件给指定邮箱
    邮件内容为被篡改页面的名称
    :return:
    """
    print('有文件被篡改')
    for i in list:
        print(i)
    exit(1)

if __name__ == '__main__':
    html_dir = '/var/www/html/'
    last_md5_log = '/tmp/last_md5.log'
    live_md5_log = '/tmplive_md5.log'
    last_html_tar = '/tmp/last_html.tar'
    live_html_tar = '/tmp/live_html.tar'
    while True:
        if not os.path.exists(last_md5_log):
            init(html_dir, last_md5_log, last_html_tar)
            time.sleep(180)
        tar_flag = check_tar(html_dir, last_html_tar, live_html_tar)
        if tar_flag:
            list = check_pag(html_dir, last_md5_log)
            send_email(list)
        time.sleep(180)













