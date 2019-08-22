import os
import requests
import wget
import hashlib
import tarfile

def has_new_ver(ver_url, ver_fname):
    "有新版本返回True，否则返回False"
    # 本地没有版本文件，返回True
    if not os.path.exists(ver_fname):
        return True

    # 取出本地版本文件内容
    with open(ver_fname) as fobj:
        version = fobj.read()

    # 取出远程最新版本号
    r = requests.get(ver_url)

    # 判断版本号一致为False，不一致为True
    if version == r.text:
        return False
    else:
        return True

def check_app(md5_url, fname):
    "校验软件包，未损坏返回True，损坏返回False"
    # 计算本地md5值
    m = hashlib.md5()
    # 每次读取4096个字节,加快计算速度,在计算大文件时很有效果
    with open(fname, 'rb') as fobj:
        while True:
            data = fobj.read(4096)
            if not data:
                break
            m.update(data)

    # 读取远程md5值
    r = requests.get(md5_url)

    # 判断
    if m.hexdigest() == r.text.strip():
        return True
    else:
        return False

def deploy(app_fname, deploy_dir):
    "部署软件：解压、创建链接"
    # 解压缩
    # 存放业务代码包绝对路径
    tar = tarfile.open(app_fname)
    # path=解压至该目录
    tar.extractall(path=deploy_dir)
    # 释放压缩对象
    tar.close()

    # 创建链接
    dest = '/var/www/html/nsd1903'
    # 取出业务代码包名
    app_dir = os.path.basename(app_fname) # myblog-1.0.tar.gz
    # 字符串截取,过滤.tar.gz
    app_dir = app_dir.replace('.tar.gz', '')  # myblog-1.0
    # 组合成最新业务代码的绝对路径
    app_dir = os.path.join(deploy_dir, app_dir) # 绝对路径

    # 如果链接已经存在，先删除，否则无法再创建
    if os.path.exists(dest):
        os.remove(dest)
    # 通过操作链接的方式,将链接指向最新业务代码,访问时访问该软连接
    os.symlink(app_dir, dest)


if __name__ == '__main__':
    # 如果未发现新版本，则退出
    # 本地tag文件存放目录
    deploy_dir = '/var/www/html/jenkins_test'
    # 指定一个目录,用于存放从jenkins拉取下来的代码
    download_dir = '/var/www/download'
    # jenkins上的最新tag文件
    ver_url = 'http://192.168.1.12/jenkins_test/live_ver'
    # 本地tag文件的绝对路径
    ver_fname = os.path.join(deploy_dir, 'live_ver')
    # 该函数判断是否有新版本,有新版本就往下执行更新业务代码
    if not has_new_ver(ver_url, ver_fname):
        print('未发现新版本。')
        exit(1)

    # 下载最新tag文件
    r = requests.get(ver_url)
    # 取出版本号
    ver = r.text.strip()
    # 最新的业务代码压缩包
    app_url = 'http://192.168.1.12/jenkins_test/pkgs/my_jenkins_%s.tar.gz' % ver
    # 下载最新的业务代码包并放到之前指定的存放目录
    wget.download(app_url, download_dir)

    # 对比MD5校验值,检查软件是否损坏，损坏则删除软件包并退出
    # jenkins上的MD5校验文件
    md5_url = app_url + '.md5'
    # 将文件名取出来
    app_fname = app_url.split('/')[-1]
    # 组合成本地业务代码包的绝对路径
    app_fname = os.path.join(download_dir, app_fname)
    # 该函数对比本地与远程的MD5值是否一致
    if not check_app(md5_url, app_fname):
        print('文件已损坏。')
        # 删除本地损坏的业务代码包
        os.remove(app_fname)
        exit(2)

    # 部署业务代码包
    deploy(app_fname, deploy_dir)

    # 更新本地live_ver文件
    if os.path.exists(ver_fname):
        os.remove(ver_fname)

    wget.download(ver_url, ver_fname)
