---
layout: post
title: Linux命令记录
tags: linux
---

1. lsof
	* 查看谁正在使用某个文件

			lsof   /filepath/file 
    
	* 递归查看某个目录的文件信息

			lsof +D /filepath/filepath2/
        
	* 不使用+D选项，遍历查看某个目录的所有文件信息 的方法

			lsof | grep ‘/filepath/filepath2/’
        
	* 列出某个用户打开的文件信息

			lsof  -u username
        
	* 列出某个程序所打开的文件信息

			lsof -c mysql
        
	* 列出多个程序多打开的文件信息

			lsof -c mysql -c java
        
	* 列出某个用户和某个程序所打开的文件信息

			lsof -u test -c mysql
        
	* 列出除了某个用户外的被打开的文件信息

			lsof   -u ^root
        
	* 通过某个进程号显示该进行打开的文件

			lsof -p 123
            lsof -p 123,456,789 ##多个进程
            
	* 查看网络连接
    		
        	lsof -i 		##列出所有网络连接
            lsof -i tcp 	##列出所有udp网络连接信息
            lsof -i :3306	##列出某个端口占用情况
            lsof -i udp:55	
            lsof -i tcp:80

	* 列出某个用户的所有活跃的网络端口

			lsof  -a -u test -i
        
	* 列出所有网络文件系统

			lsof -N

	* 某个用户组所打开的文件信息

			lsof -g 5555

2. 使用rsync代替scp并实现断点续传功能

		rsync -avzP --rsh=ssh localfile  user@server:/dir/
        rsync -avzP --rsh=ssh user@server:/dir/file  /dir/

3. 安装或修复grub引导

	* 方法1

            grub> find /boot/grub/stage1 ##查找/boot在哪个分区  
            grub> root (hd0,0)  ##设置/boot在哪个分区
            grub> setup (hd0) ##将grub安装到硬盘的MBR中
            grub> setup (hd0,0)##将grub安装到硬盘第一个分区中

	* 方法2
    	
            # grub-install --root-directory=/boot /dev/hda
            
4. 几个简单有用的命令
	* 以 root 帐户执行上一条命令

			sudo !!
	* 利用 Python 搭建一个简单的 Web 服务器，可通过 http://$HOSTNAME:8000访问       
		
        	python -m SimpleHTTPServer
	* 切换到上一次访问的目录 

			cd -
	* 将上一条命令中的 foo 替换为 bar，并执行  

			^foo^bar
	* traceroute + ping    

			mtr google.com
	* 快速调用一个编辑器来编写一个命令 

			ctrl-x e
	* 执行一个命令，但不保存在命令历史记录中 

			<space>command
	* 重新初始化终端 

			reset
	* 调出上次命令使用的参数 

			'ALT+.' or '<ESC> .'
	* 以更加清晰的方式显示当前系统挂载的文件系统 

			mount | column -t
	* 在给定的时间执行命令 

			echo "ls -l" | at midnight
	* 通过DNS控制台查询维基百科 

			dig +short txt <keyword>.wp.dg.cx
	* 从80端口向你本地的2001端口开启隧道 

			ssh -N -L2001:localhost:80 somemachine
	* 快速访问ASCII表  

			man ascii
	* 获取你的外部IP地址 

			curl ifconfig.me
	* !! 表示重复执行上一条命令，并用 :gs/foo/bar 进行替换操作 

			!!:gs/foo/bar
	* 输出你的麦克风到远程机器的扬声器 

			dd if=/dev/dsp | ssh -c arcfour -C username@host dd of=/dev/dsp
	* 挂载一个临时的内存分区 

			mount -t tmpfs tmpfs /mnt -o size=1024m
	* 以SSH方式挂载目录/文件系统 

			sshfs name@server:/path/to/folder /path/to/mount/point

5. Linux man 命令数字含义

	1. User Commands.用户在shell环境中可以操作的命令或可执行文件 
	2. System Calls.系统内核可调用的函数与工具等，即由内核提供的函数。 如open,write之类的(通过这个，可以很方便的查到调用这个函数时需要加什么头文件) 
	3. C Library Functions.一些常用的函数与函数库，大部分为C的函数库，如printf,fread 
	4. Devices and Special Files.设备文件的说明，通常在/dev下的文件 
	5. File Formats and Conventions.配置文件或者是某些文件的格式 比如passwd 
	6. Games et. Al.给游戏留的,由各个游戏自己定义 
	7. Miscellanea.惯例与协议等杂项，Linux文件系统、网络协议、ASCII code等说明，例如man,environ 
	8. System Administration tools and Deamons.系统管理用的命令,这些命令只能由系统管理员使用,如ifconfig 
