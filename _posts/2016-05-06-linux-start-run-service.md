---
layout: post
title: Linux下开机服务
tags: linux
---



### `chkconfig`命令

1. 查看所有的自启动服务列表：`chkconfig -–list`
2. 将iptables服务添加到chkconfig列表中：`chkconfig –-add iptables`
3. 查看iptables自启动状态：`chkconfig -–list iptables`
4. 将iptables服务设置为开机自启动:`chkconfig iptables on`

### `/etc/rc.d/rc.local`文件

```sh
vim /etc/rc.d/rc.local
#添加开机执行的命令
/usr/sbin/apachectl start
/etc/rc.d/init.d/mysqld start
/etc/rc.d/init.d/smb start
/usr/local/subversion/bin/svnserve -d

```