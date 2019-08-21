import tarfile
import os
import subprocess
import hashlib
import string
import sys
import re
#
# tar = tarfile.open('/var/www/html.tar.gz', 'w:gz')
#
# for root, dir, files in os.walk('/var/www/html'):
#     for file in files:
#         fullpath = os.path.join(root,file)
#         tar.add(fullpath)
# tar.close()
# html_tar = '/tmp/last_html.tar.gz'
#     # 页面所在目录
# html_dir = "/var/www/html"
# subprocess.run('tar -czf %s %s' % (html_tar, html_dir), shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)


# live_html_tar = '/var/www/html1.tar.gz'
# last_html_tar = '/var/www/html2.tar.gz'
# m1 = hashlib.md5()
# m2 = hashlib.md5()
#
# with open(last_html_tar, 'rb') as fobj:
#     while True:
#         data = fobj.read(4096)
#         # 没有数据了中断循环
#         if not data:
#             break
#         # 更新MD5值
#         m1.update(data)
# with open(live_html_tar, 'rb') as fobj:
#     while True:
#         data = fobj.read(4096)
#         # 没有数据了中断循环
#         if not data:
#             break
#         # 更新MD5值
#         m2.update(data)
#
#     last_html_md5 = m1.hexdigest()
#     live_html_md5 = m2.hexdigest()
#     print(m1.hexdigest(), m2.hexdigest())
#     if last_html_md5 != live_html_md5:
#         print('a')
#     else:
#         print('b')
# md5_html_log = '/tmp/md5_html.log'
# with open(md5_html_log, 'r') as fobj:
#     data = fobj.readlines()
# for i in data:
#     a = re.split(':', i)
#     print(a)
#
# result = []
# 取出页面文件绝对路径,存储在result列表中
# maindir:当前目录
# subdir:当前目录下所有目录
# file_name_list:当前目录下所有文件
# for maindir, subdir, file_name_list in os.walk(html_dir):
#     for file_name in file_name_list:
#         a_path = os.path.join(maindir, file_name)
#         result.append(a_path)

# for i in range(len(result)):
#     print(result[i])

# m2 = hashlib.md5()
# for i in result:
#     with open(i, 'rb') as fobj:
#         while True:
#             data = fobj.read(4096)
#             # 没有数据了中断循环
#             if not data:
#                 break
#             # 更新MD5值
#             m2.update(data)
#     print(m2.hexdigest())
# print(result)

# html_dir = '/var/www/html/'
# last_md5_log = '/tmp/last_md5.log'
# last_html_tar = '/tmp/last_html.tar.gz'
#
# t = tarfile.open(last_html_tar, 'w:gz')
# for maindir, subdir, file_name_list in os.walk(html_dir):
#     for file_name in file_name_list:
#         a_path = os.path.join(maindir, file_name)
#         t.add(a_path)
# t.close()
#
# str = 'aaaaaaaaaa:bbbbbbbbbbbbb'
#
# print(re.split(':', str))

list = []
live_list = []
last_list = []
html_dir = '/var/www/html/'
last_md5_log = '/tmp/last_md5.log'
live_md5_log = '/tmplive_md5.log'
last_html_tar = '/tmp/last_html.tar'
live_html_tar = '/tmp/live_html.tar'
m = hashlib.md5()
#
# with open(last_md5_log, 'r') as fobj:
#     data = fobj.readlines()
# for line in data:
#     f1 = re.split(':', line)
#     last_list.append(f1[0])
# for maindir, subdir, file_name_list in os.walk(html_dir):
#     for file_name in file_name_list:
#         a_path = os.path.join(maindir, file_name)
#         if not a_path in last_list:
#             list.append(a_path)
#         else:
#             with open(a_path, 'rb') as fobj:
#                 while True:
#                     data = fobj.read(4096)
#                     # 没有数据了中断循环
#                     if not data:
#                         break
#                     # 更新MD5值
#                     m.update(data)
#             print(a_path, m.hexdigest())
#             print(f1[0],f1[1])
#             # if m.hexdigest() != f1[1]:
#             #     list.append(a_path)
#         #     break
# print(list)


for maindir, subdir, file_name_list in os.walk(html_dir):
    for file_name in file_name_list:
        a_path = os.path.join(maindir, file_name)
        live_list.append(a_path)

print(live_list)

with open(last_md5_log, 'r') as fobj:
    data = fobj.readlines()
for line in data:
    f1 = re.split(':', line)
    last_list.append(f1[0])

print(last_list)

for file in live_list:
















