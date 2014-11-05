---
layout: post
title: ssh通过corkscrew代理软件连接远程主机
tags: linux
---

在存在代理的网络中无法直接通过ssh连接远程主机,这就需要通过`corkscrew`来为ssh设置代理.

----


* 下载[corkscrew](http://www.agroman.net/corkscrew/corkscrew-2.0.tar.gz).
* 解压文件：`tar zxvf corkscrew-2.0.tar.gz`
* 切换目录：`cd corkscrew-2.0`
* 编译安装：`./configure`，`make && make install`
* 编辑文件`/etc/ssh/ssh_config`，加入如下内容：<br>

		Host 10.12.6.*    \\远程目标主机网段
		ControlPersist 4h \\长连接，防止自动断开连接.
        				  \\现在你每次通过SSH与服务器建立连接之后，
                          \\这条连接将被保持4个小时，即使在你退出服务器之后，
                          \\这条连接依然可以重用，
                          \\因此，在你下一次（4小时之内）登录服务器时，
                          \\你会发现连接以闪电般的速度建立完成，
                          \\这个选项对于通过scp拷贝多个文件提速尤其明显，
                          \\因为你不在需要为每个文件做单独的认证了。
		ProxyCommand corkscrew HTTP代理IP HTTP代理端口 %h %p 认证文件
        
		Host  172.168.10.1 172.168.10.2  \\针对多个代理多个主机 
		ControlPersist 4h
		ProxyCommand corkscrew HTTP代理IP HTTP代理端口 %h %p 认证文件

