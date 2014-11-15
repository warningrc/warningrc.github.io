---
layout: post
title: mongodb简单使用
tags: linux 
---

mongodb的安装和简单启动配置

----

## 1. 安装

### 1.1 下载安装包 

安装包可以从[官网](http://www.mongodb.org/downloads)下载不同平台的不同版本.Linux平台可使用如下命令下载

	[root@localhost /]# wget -c -O  mongodb-linux-x86_64-2.6.5.tgz  https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-2.6.5.tgz?_ga=1.189808747.1303898323.1416035774

### 1.2 安装

mongodb是免安装的,解压安装包变可使用.

	[root@localhost /]# mv mongodb-linux-x86_64-2.6.5.tgz /opt/mongodb/ && cd /opt/mongodb/
	[root@localhost mongodb]#  tar xvf mongodb-linux-x86_64-2.6.5.tgz
	[root@localhost mongodb]# ls
	mongodb-linux-x86_64-2.4.12  mongodb-linux-x86_64-2.4.12.tar
	[root@localhost mongodb]# ls mongodb-linux-x86_64-2.4.12
	bin  GNU-AGPL-3.0  README  THIRD-PARTY-NOTICES
	[root@localhost mongodb]# ls mongodb-linux-x86_64-2.4.12/bin
	bsondump  mongo  mongod  mongodump  mongoexport  mongofiles  mongoimport  mongooplog  mongoperf  mongorestore  mongos  mongosniff  mongostat  mongotop

## 2. 启动

如果只是简单的测试使用,可是不给mongodb提供任何参数,mongodb将使用默认参数值.

	[root@localhost mongodb]# ./mongodb-linux-x86_64-2.4.12/bin/mongod 

但是我们这里指定数据文件和日志文件的存放目录.

	[root@localhost mongodb]# mkdir -p data/db && mkdir -p data/log ##创建数据文件和日志文件的存放目录
	[root@localhost mongodb]# chown `id -u` data -R 
	[root@localhost mongodb]# ./mongodb-linux-x86_64-2.4.12/bin/mongod --dbpath ./data/db --logpath ./data/log --logappend  ##启动


每次这样启动mongodb会很繁琐,我们通过sh脚本启动mongodb.创建startMongod.sh,写入如下内容

	#!/bin/bash
	MONGODB_HOME=/opt/mongodb/mongodb-linux-x86_64-2.4.12
	MONGODB_DATA=$MONGODB_HOME/../data
	$MONGODB_HOME/bin/mongod -dbpath=$MONGODB_DATA/db -logpath=$MONGODB_DATA/log --logappend --fork

赋予`startMongod.sh`可执行权限

	[root@localhost mongodb]# chmod u+x startMongod.sh


接下来便可以通过sh文件启动mongodb服务了.