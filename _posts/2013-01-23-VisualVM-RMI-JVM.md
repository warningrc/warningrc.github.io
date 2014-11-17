---
layout: post
title: VisualVM的RMI方式监控JVM
tags: java
---

VisualVM是集成了多个JDK命令工具的一个可视化工具，它主要用来监控JVM的运行情况，可以用它来查看和浏览Heap Dump、Thread Dump、内存对象实例情况、GC执行情况、CPU消耗以及类的装载情况。

----

jstatd是一个rmi的server应用，用于监控jvm的创建和结束，并且提供接口让监控工具可以远程连接到本机的jvm 。jstatd位于 $JAVA_HOME/bin目录下，具体使用方法如下：

### 1.启动RMI服务

在需要被监控的服务器上面，通过jstatd来启动RMI服务

首先，配置java安全访问，将如下的代码存为文件 jstatd.all.policy：

	grant codebase "file:${java.home}/../lib/tools.jar" {
		permission java.security.AllPermission;
 	};
    
 然后在jstatd.all.policy所在目录下，通过如下的命令启动RMI服务：
 
 	jstatd -J-Djava.security.policy=jstatd.all.policy 
    
 
### 2.启动VisualVM，添加远程主机
 
在远程中添加对应主机，便可以使用VisualVM来监控远程JVM了。