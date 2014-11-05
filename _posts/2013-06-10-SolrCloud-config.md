---
layout: post
title: solr集群配置文档
tags: solr linux
---

**SolrCloud** 是基于Solr和Zookeeper的分布式搜索方案，是Solr4.X的核心组件之一，它的主要思想是使用Zookeeper作为集群的配置信息中心。它有几个特色功能：

 1. 集中式的配置信息
 2. 自动容错
 3. 近实时搜索
 4. 查询时自动负载均衡
![aa](/images/2shard4serverFull.jpg)

----

基本可以用上面这幅图来概述，这是一个拥有4个Solr节点的集群，索引分布在两个Shard里面，每个Shard包含两个Solr节点，一个是Leader节点，一个是Replica节点，此外集群中有一个负责维护集群状态信息的Overseer节点，它是一个总控制器。集群的所有状态信息都放在Zookeeper集群中统一维护。从图中还可以看到，任何一个节点都可以接收索引更新的请求，然后再将这个请求转发到文档所应该属于的那个Shard的Leader节点，Leader节点更新结束完成，最后将版本号和文档转发给同属于一个Shard的replicas节点。




模拟solr平台配置

 1. 硬件配置：`Intel(R) Core(TM) i7-3610QM CPU @ 2.30GHz`，`8G 内存`
 2. 操作系统：`CentOs 6.4`，`Linux 2.6.32-358.18.1.el6.x86_64`
 3. 各软件版本：[`JAVA 7.0`][1]，`zookeeper 3.4.5`，`solr 4.4.0`，`jetty 9.0.5`
 
### Java 7.0安装

由于`solr`，`zookeeper`，`jetty`都是使用Java语言开发，因此需要安装Java运行环境，我们可以从ORACLE官网下载[`JRE 7.0`][2]或者[`JDK7.0`][3]，我们以JRE 7.0为例，演示JAVA 7.0的安装。

使用`Linux`自带命令`wget`下载`JRE 7.0`

    [warning@localhost opt]$ wget -c http://download.oracle.com/otn-pub/java/jdk/7u40-b43/jre-7u40-linux-x64.tar.gz?AuthParam=1380008347_e645463cb6061298c79d5bd647c7add0
    --2013-09-24 15:36:25--  http://download.oracle.com/otn-pub/java/jdk/7u40-b43/jre-7u40-linux-x64.tar.gz?AuthParam=1380008347_e645463cb6061298c79d5bd647c7add0
    正在连接 10.12.16.16:808... 已连接。
    已发出 Proxy 请求，正在等待回应... 200 OK
    长度：46808550 (45M) [application/x-gzip]
    正在保存至: “jre-7u40-linux-x64.tar.gz?AuthParam=1380008347_e645463cb6061298c79d5bd647c7add0”
    ....省略下载过程，wget使用-c可以断点续传，当网络不稳定时，这个参数是很有用的。
    
    [warning@localhost opt]$ ll
    总用量 46108
    -rw-r--r--. 1 warning root   361240 9月  24 15:36 jre-7u40-linux-x64.tar.gz?AuthParam=1380008347_e645463cb6061298c79d5bd647c7add0
    drwxr-xr-x. 6 warning root     4096 9月  24 14:51 zookeeper
    [warning@localhost opt]$ mv jre-7u40-linux-x64.tar.gz\?AuthParam\=1380008347_e645463cb6061298c79d5bd647c7add0 jre-7u40-linux-x64.tar.gz
    [warning@localhost opt]$ ll
    总用量 46108
    -rw-r--r--. 1 warning root   361240 9月  24 15:36 jre-7u40-linux-x64.tar.gz
    drwxr-xr-x. 6 warning root     4096 9月  24 14:51 zookeeper
    [warning@localhost opt]$ tar zxf jre-7u40-linux-x64.tar.gz ##解压安装包
    [warning@localhost opt]$ ll
    总用量 45752
    drwxr-xr-x. 6 warning root     4096 8月  27 15:19 jre1.7.0_40
    -rwxr-xr-x. 1 warning root 46808550 9月  24 15:07 jre-7u40-linux-x64.tar.gz
    drwxr-xr-x. 6 warning root     4096 9月  24 14:51 zookeeper
    
通过上述的操作，在你的`linux`中便安装了`Java 7.0`的运行环境，我们可以使用`/opt/jre1.7.0_40/bin/java`命令来启动任何Java应用，你肯定会觉得这个命令太繁琐了，我也这么觉得！！哈哈～～那么有没有一种简便的方法呢，答案是肯定的，我们可以将`/opt/jre1.7.0_40/bin/java`命令添加到系统环境变量中，然后便可以使用java命令启动Java应用了，接下来我们看一下怎么将该命令添加到系统环境变量中：

在Linux中存在四个环境变量的文件，分别是：`/etc/profile`,`/etc/bashrc`,`~/.bash_profile`,`~/.bashrc`，通过编辑这四个文件都可可以设置环境变量，只是它们四者之间有区别，大家可以查阅资料了解，由于我们主要关注solr集群的配置，在此不做阐述，我们通过编辑`/etc/profile`文件将Java命令添加到系统环境变量中。

    [warning@localhost opt]$ sudo vim /etc/profile ##由于/etc/profile文件为系统配置文件，只有root用户有编辑权限，在此需要使用sudo命令。
    [sudo] password for warning: 

在`/etc/profile`文件末尾加入如下内容：

    export JAVA_HOME=/opt/jre1.7.0_40
    export PATH=$JAVA_HOME/bin:$PATH

保存文件，`/etc/profile`文件内容被修改，但配置没有生效，需要通过`source`命令使得配置生效

    [warning@localhost opt]$ source /etc/profile
    [warning@localhost opt]$ java -version
    java version "1.7.0_40"
    Java(TM) SE Runtime Environment (build 1.7.0_40-b43)
    Java HotSpot(TM) 64-Bit Server VM (build 24.0-b56, mixed mode)
    [warning@localhost opt]$ 

输入`java -version`，控制台打印出了Java的版本信息，说明java命令已经被添加到系统环境变量中。

到此，`Java 7.0`已经成功的安装到了我们的`Linux`系统中。


### zookeeper安装

#### zookeeper是什么
 
`ZooKeeper`是`Hadoop`的正式子项目，`ZooKeeper`是一个针对大型分布式系统、以[Fast Paxos][4]算法为基础，实现同步服务，配置维护和命名服务等的可靠协调系统，提供的功能包括：配置维护、名字服务、分布式同步、组服务等。`ZooKeeper`的目标就是封装好复杂易出错的关键服务，将简单易用的接口和性能高效、功能稳定的系统提供给用户。`Apache Hbase`和` Apache Solr` 以及`LinkedIn sensei`  等项目中都采用到了 `Zookeeper`。
 
下面我们在Linux系统中以三个`zookeeper`+4个`solr`来看一个简单的`SolrCloud`集群的配置过程。(作为演示，我们在本地通过启动多个不同端口的服务模拟集群装，并且配置中各个目录名称为我本地目录地址，开发人员可根据服务器配置进行相应更改)
 
接下来，在本地启动三个使用不同端口的zookeeper服务来模拟一个zookeeper集群。我们可以从apache镜像站点([人人][5],[北理工][6])下载zookeeper,同样使用wget工具现在，现在过程不再阐述。

创建目录`/opt/zookeeper`,将`zookeeper-3.4.5.tar.gz`文件复制到`/opt/zookeeper`

    [warning@localhost zookeeper]$ mkdir /opt/zookeeper
    [warning@localhost zookeeper]$ cp zookeeper-3.4.5.tar.gz /opt/zookeeper/
    [warning@localhost zookeeper]$ cd /opt/zookeeper/
    [warning@localhost zookeeper]$ ll
    总用量 16020
    -rwxr-xr-x. 1 warning root 16402010 9月  24 14:45 zookeeper-3.4.5.tar.gz
    [warning@localhost zookeeper]$ 


在`/opt/zookeeper`目录下创建`server1`,`server2`,`server3`目录，并将`zookeeper`分别解压三个目录中，用于模拟三台主机

    [warning@localhost zookeeper]$ mkdir server1 server2 server3 ##创建三个目录
    [warning@localhost zookeeper]$ ll
    总用量 16032
    drwxr-xr-x. 2 warning root     4096 9月  24 14:50 server1
    drwxr-xr-x. 2 warning root     4096 9月  24 14:50 server2
    drwxr-xr-x. 2 warning root     4096 9月  24 14:50 server3
    -rwxr-xr-x. 1 warning root 16402010 9月  24 14:45 zookeeper-3.4.5.tar.gz
    [warning@localhost zookeeper]$ tar zxvf zookeeper-3.4.5.tar.gz ##解压
	...##省略输出信息
	[warning@localhost zookeeper]$ ll
    总用量 16036
    drwxr-xr-x.  2 warning root     4096 9月  24 14:50 server1
    drwxr-xr-x.  2 warning root     4096 9月  24 14:50 server2
    drwxr-xr-x.  2 warning root     4096 9月  24 14:50 server3
    drwxr-xr-x. 10 warning root     4096 11月  5 2012 zookeeper-3.4.5
    -rwxr-xr-x.  1 warning root 16402010 9月  24 14:45 zookeeper-3.4.5.tar.gz
    [warning@localhost zookeeper]$ cp -r zookeeper-3.4.5 server1/zookeeper  ##将zookeeper复制到三个目录中
	[warning@localhost zookeeper]$ cp -r zookeeper-3.4.5 server2/zookeeper
    [warning@localhost zookeeper]$ cp -r zookeeper-3.4.5 server3/zookeeper
	[warning@localhost zookeeper]$ ll server1 server2 server3
    server1:
    总用量 4
    drwxr-xr-x. 10 warning root 4096 9月  24 14:53 zookeeper
    server2:
    总用量 4
    drwxr-xr-x. 10 warning root 4096 9月  24 14:53 zookeeper
    server3:
    总用量 4
    drwxr-xr-x. 10 warning root 4096 9月  24 14:53 zookeeper
    [warning@localhost zookeeper]$ 

现在三个模拟服务器目录结构已经搭建完成，我们开始为每个`zookeeper`服务器配置相应参数

    [warning@localhost zookeeper]$ cd server1/zookeeper/conf/
	[warning@localhost conf]$ ls
    configuration.xsl  log4j.properties  zoo_sample.cfg
    [warning@localhost conf]$ cp zoo_sample.cfg zoo.cfg
	[warning@localhost conf]$ vim zoo.cfg 

编辑`server1`中`zoo.cfg`文件，写入如下内容：

    # The number of milliseconds of each tick
    # zookeeper每次心跳的毫秒数
    tickTime=2000
    # The number of ticks that the initial  synchronization phase can take
    # 初始同步阶段消耗的心跳次数
    #这个配置项是用来配置Zookeeper服务器集群中连接到 Leader的Follower服务器
    #初始化连接时最长能忍受多少个心跳时间间隔数。当已经超过 10 个心跳的时间
    #(也就是tickTime)长度后 Zookeeper服务器
    #还没有收到返回信息，那么表明这个Zookeeper服务器连接失败。
    #总的时间长度就是 5*2000=10 秒
    initLimit=10
    # The number of ticks that can pass between  sending a request and getting an acknowledgement
    # 从发起一次请求到得到回应所消耗的心跳次数,也就是Leader与Follower 之间发送消息，请求和应答时间长度，最长不能超过多少个 tickTime 的时间长度
    syncLimit=5
    # tickTime , syncLimit两个参数的大小可根据服务器性能、网络传输速度做适当调整，两者之间成反比
    # the directory where the snapshot is stored.
    # zookeeper数据的存放目录
    dataDir=/opt/zookeeper/server1/zookeeper/data
    # the port at which the clients will connect
    # zookeeper客户端连接的端口号，使用该端口可以与zookeeper服务进行交互
    clientPort=2181
    # The number of snapshots to retain in dataDir
    #autopurge.snapRetainCount=3
    # Purge task interval in hours
    # Set to "0" to disable auto purge feature
    #autopurge.purgeInterval=1
    
    
    #server.A=B：C：D：其中 A 是一个数字，表示这个是第几号服务器
    #(对应每个zookeeper服务器的ID，该ID号需要和dataDir目录下myid文件内容一致)
    #B是这个服务器的 ip 地址；
    #C表示的是这个服务器与集群中的 Leader 服务器交换信息的端口；
    #D表示的是万一集群中的 Leader 服务器挂了，需要一个端口来重新进行选举，
    #选出一个新的 Leader，而这个端口就是用来执行选举时服务器相互通信的端口。
    #由于我们现在的是伪集群的配置方式，B都是一样，所以不同的 Zookeeper
    #实例通信端口号不能一样，所以要给它们分配不同的端口号。
    #以下是我们模拟集群的三台zookeeper服务器ID，IP和内部交互所使用的两个端口号。
    server.1=127.0.0.1:2881:3881
    server.2=127.0.0.1:2882:3882
    server.3=127.0.0.1:2883:3883

同样`server2`，`server3`中`zoo.cfg`文件与上述内容大体一致，只需要对`dataDir`和`clientPort`做相应修改即可(本模拟环境中`server2`服务器`clientPort`为2182，`server3`服务器`clientPort`为2183)，然后需要在各个服务器`dataDir`中创建`myid`文件，文件内容为各个服务器ID(`zoo.cfg`文件中提到过该ID)

    [warning@localhost zookeeper]$ mkdir ./server1/zookeeper/data ./server2/zookeeper/data ./server3/zookeeper/data
    [warning@localhost zookeeper]$ echo 1 >./server1/zookeeper/data/myid
    [warning@localhost zookeeper]$ echo 2 >./server2/zookeeper/data/myid
    [warning@localhost zookeeper]$ echo 3 >./server3/zookeeper/data/myid
    [warning@localhost zookeeper]$ cat ./server1/zookeeper/data/myid ./server2/zookeeper/data/myid ./server3/zookeeper/data/myid
    1
    2
    3
    [warning@localhost zookeeper]$ 

到此为止，模拟的三台zookeeper服务器便配置完成了，接下来我们启动三个服务

    [warning@localhost zookeeper]$ cd server1/
    [warning@localhost server1]$ ./zookeeper/bin/zkServer.sh start #启动ID为1的服务器
    JMX enabled by default
    Using config: /opt/zookeeper/server1/zookeeper/bin/../conf/zoo.cfg
    Starting zookeeper ... STARTED
    [warning@localhost server1]$ cd ../server2
    [warning@localhost server2]$ ./zookeeper/bin/zkServer.sh start #启动ID为2的服务器
    JMX enabled by default
    Using config: /opt/zookeeper/server2/zookeeper/bin/../conf/zoo.cfg
    Starting zookeeper ... STARTED
    [warning@localhost server2]$ cd ../server3
    [warning@localhost server3]$ ./zookeeper/bin/zkServer.sh start #启动ID为3的服务器
    JMX enabled by default
    Using config: /opt/zookeeper/server3/zookeeper/bin/../conf/zoo.cfg
    Starting zookeeper ... STARTED
    [warning@localhost server3]$


三台zookeeper服务器启动完成，然后我们测试一下三台服务器是否可用

    [warning@localhost server3]$ echo ruok |nc 127.0.0.1 2181
    imok
    [warning@localhost server3]$ echo ruok |nc 127.0.0.1 2182
    imok
    [warning@localhost server3]$ echo ruok |nc 127.0.0.1 2183
    imok
    [warning@localhost server3]$ 

使用linux下的nc命令向三台zookeeper服务器发送问候"`ruok`",如果zookeeper服务器回复"`imok`"则证明zookeeper服务器启动成功。

通过上述方法启动的zookeeper服务是后台运行的，无法直接看到其打印到控制台的信息，不过zookeeper将控制台信息转发到了文件中，在zookeeper的启动目录下会找到一个`zookeeper.out`文件，该文件中内容便是zookeeper打印到控制台的信息，通过linux自带的tail命令可以实时查看zookeeper输出到控制台的信息。

由于上述模拟的集群中第一台服务器是在`/opt/zookeeper/server1`目录下启动的，因此可以在该目录下找到`zookeeper.out`文件，现在查看一下该文件内容

    [warning@localhost server1]$ tail -f zookeeper.out 
    2013-09-26 11:44:20,831 [myid:1] - INFO  [QuorumPeer[myid=1]/0:0:0:0:0:0:0:0:2181:Environment@100] - Server environment:os.name=Linux
    2013-09-26 11:44:20,831 [myid:1] - INFO  [QuorumPeer[myid=1]/0:0:0:0:0:0:0:0:2181:Environment@100] - Server environment:os.arch=amd64
    2013-09-26 11:44:20,832 [myid:1] - INFO  [QuorumPeer[myid=1]/0:0:0:0:0:0:0:0:2181:Environment@100] - Server environment:os.version=2.6.32-358.18.1.el6.x86_64
    2013-09-26 11:44:20,832 [myid:1] - INFO  [QuorumPeer[myid=1]/0:0:0:0:0:0:0:0:2181:Environment@100] - Server environment:user.name=warning
    2013-09-26 11:44:20,832 [myid:1] - INFO  [QuorumPeer[myid=1]/0:0:0:0:0:0:0:0:2181:Environment@100] - Server environment:user.home=/home/warning
    2013-09-26 11:44:20,832 [myid:1] - INFO  [QuorumPeer[myid=1]/0:0:0:0:0:0:0:0:2181:Environment@100] - Server environment:user.dir=/opt/zookeeper/server1
    2013-09-26 11:44:20,833 [myid:1] - INFO  [QuorumPeer[myid=1]/0:0:0:0:0:0:0:0:2181:ZooKeeperServer@162] - Created server with tickTime 2000 minSessionTimeout 4000 maxSessionTimeout 40000 datadir /opt/zookeeper/server1/zookeeper/data/version-2 snapdir /opt/zookeeper/server1/zookeeper/data/version-2
    2013-09-26 11:44:20,834 [myid:1] - INFO  [QuorumPeer[myid=1]/0:0:0:0:0:0:0:0:2181:Follower@63] - FOLLOWING - LEADER ELECTION TOOK - 32
    2013-09-26 11:44:20,839 [myid:1] - INFO  [QuorumPeer[myid=1]/0:0:0:0:0:0:0:0:2181:Learner@322] - Getting a diff from the leader 0x100000111
    2013-09-26 11:44:20,843 [myid:1] - INFO  [QuorumPeer[myid=1]/0:0:0:0:0:0:0:0:2181:FileTxnSnapLog@240] - Snapshotting: 0x100000111 to /opt/zookeeper/server1/zookeeper/data/version-2/snapshot.100000111

现在在linux终端中便可以实时查看zookeeper的运行信息了。当然我们可以把`zookeeper.out`文件存放在固定的目录下，设置方法就是定义一个环境变量`ZOO_LOG_DIR`,zookeeper会将其产生的日志文件放置与`ZOO_LOG_DIR`设置的目录下。

现在我们将zookeeper的日志目录设置为solr安装目录下的logs下(`/opt/zookeeper/server1/zookeeper/logs)`,在`/opt/zookeeper/server1/zookeeper/bin`目录下创建文件zk.sh,写入如下内容：

    THISBIN=`dirname ${BASH_SOURCE}`
    ZOO_LOG_DIR="${THISBIN}/../logs" ##将zookeeper日子目录设置为zookeeper/logs
    if [ ! -d "$ZOO_LOG_DIR" ]; then
        mkdir -p "$ZOO_LOG_DIR"
    fi
    ZOO_LOG_DIR=`cd $ZOO_LOG_DIR;pwd`
    export ZOO_LOG_DIR
    $THISBIN/zkServer.sh $1
    
然后需要赋予`zk.sh`文件执行权限

    [warning@localhost bin]$ chmod 755 zk.sh
    [warning@localhost bin]$ ll
    总用量 40
    -rwxr-xr-x. 1 warning root     238 9月  24 14:53 README.txt
    -rwxr-xr-x. 1 warning root    1909 9月  24 14:53 zkCleanup.sh
    -rwxr-xr-x. 1 warning root    1049 9月  24 14:53 zkCli.cmd
    -rwxr-xr-x. 1 warning root    1512 9月  24 14:53 zkCli.sh
    -rwxr-xr-x. 1 warning root    1333 9月  24 14:53 zkEnv.cmd
    -rwxr-xr-x. 1 warning root    2599 9月  26 14:26 zkEnv.sh
    -rwxr-xr-x. 1 warning root    1084 9月  24 14:53 zkServer.cmd
    -rwxr-xr-x. 1 warning root    5465 9月  26 14:26 zkServer.sh
    -rwxr-xr-x. 1 warning warning  208 9月  26 14:50 zk.sh
    [warning@localhost bin]$ 
    
接下来我们便可以通过`zk.sh`文件来启动，停止zookeeper了，并且将zookeeper的日志文件存放在了指定目录。

将zk.sh文件复制到server2，server3的zookeeper相应文件夹下

    [warning@localhost zookeeper]$ cd /opt/zookeeper/
    [warning@localhost zookeeper]$ cp ./server1/zookeeper/bin/zk.sh ./server2/zookeeper/bin/
    [warning@localhost zookeeper]$ cp ./server1/zookeeper/bin/zk.sh ./server3/zookeeper/bin/
    [warning@localhost zookeeper]$ 
    
启动zookeeper集群

    [warning@localhost zookeeper]$ cd /opt/zookeeper/
    [warning@localhost zookeeper]$ ./server1/zookeeper/bin/zk.sh start
    JMX enabled by default
    Using config: /opt/zookeeper/server1/zookeeper/bin/../conf/zoo.cfg
    Starting zookeeper ... STARTED
    [warning@localhost zookeeper]$ ./server2/zookeeper/bin/zk.sh start
    JMX enabled by default
    Using config: /opt/zookeeper/server2/zookeeper/bin/../conf/zoo.cfg
    Starting zookeeper ... STARTED
    [warning@localhost zookeeper]$ ./server3/zookeeper/bin/zk.sh start
    JMX enabled by default
    Using config: /opt/zookeeper/server3/zookeeper/bin/../conf/zoo.cfg
    Starting zookeeper ... STARTED
    [warning@localhost zookeeper]$ 
    
这样，zookeeper启动之后的日志文件便会存放在指定的目录中。



#### zookeeper操作命令

 1. zookeeper启动：`zk.sh start`(后台启动),`zk.sh start-foreground`(前台启动)
 2. zookeeper停止：`zk.sh stop`
 3. zookeeper重启：`zk.sh restart`
 4. zookeeper状态检测：`zk.sh status`
 


#### 我需要运行几个ZooKeeper?

运行一个zookeeper也是可以的，但是在生产环境中，你最好部署3，5，7个节点。部署的越多，可靠性就越高，最好是部署奇数个，zookeeper集群是以宕机个数过半才会让整个集群宕机的，所以奇数个集群更佳。需要给每个zookeeper 1G左右的内存，如果可能的话，最好有独立的磁盘。 (独立磁盘可以确保zookeeper是高性能的。).


### solrcloud 安装
#### solr是什么

Solr是一个独立的企业级搜索应用服务器，它对外提供类似于Web-service的API接口。用户可以通过http请求，向搜索引擎服务器提交一定格式的XML文件，生成索引；也可以通过Http Get操作提出查找请求，并得到XML格式的返回结果；

与zookeeper一样，我们在本地通过使用不同端口启动多个solr服务来模拟solr集群。

创建目录`/opt/solr,solr-warningrc.zip`文件复制到`/opt/solr`



    [warning@localhost /]$ mkdir /opt/solr
    [warning@localhost solr]$ cp solr-warningrc.zip /opt/solr/
    [warning@localhost solr]$ cd /opt/solr
    [warning@localhost solr]$ ll
    总用量 129372
    -rwxrwxr-x. 1 warning warning 132473383 9月  24 17:19 solr-warningrc.zip
    [warning@localhost solr]$ 

在`/opt/solr`目录下创建`server1`,`server2`,`server3`,`server4`目录，并将solr分别解压三个目录中，用于模拟四台主机
    
    [warning@localhost solr]$ mkdir server1 server2 server3 server4
    [warning@localhost solr]$ ll
    总用量 129388
    drwxrwxr-x. 2 warning warning      4096 9月  24 17:21 server1
    drwxrwxr-x. 2 warning warning      4096 9月  24 17:21 server2
    drwxrwxr-x. 2 warning warning      4096 9月  24 17:21 server3
    drwxrwxr-x. 2 warning warning      4096 9月  24 17:21 server4
    -rwxrwxr-x. 1 warning warning 132473383 9月  24 17:19 solr-warningrc.zip
    [warning@localhost solr]$ unzip solr-warningrc.zip 
    ...省略解压输出信息
    [warning@localhost solr]$ ll
    总用量 129392
    drwxrwxr-x.  2 warning warning      4096 9月  24 17:21 server1
    drwxrwxr-x.  2 warning warning      4096 9月  24 17:21 server2
    drwxrwxr-x.  2 warning warning      4096 9月  24 17:21 server3
    drwxrwxr-x.  2 warning warning      4096 9月  24 17:21 server4
    drwxrwxr-x. 10 warning warning      4096 9月  12 11:27 solr-warningrc
    -rwxrwxr-x.  1 warning warning 132473383 9月  24 17:19 solr-warningrc.zip
    [warning@localhost solr]$ cp -r solr-warningrc server1/solr
    [warning@localhost solr]$ cp -r solr-warningrc server2/solr
    [warning@localhost solr]$ cp -r solr-warningrc server3/solr
    [warning@localhost solr]$ cp -r solr-warningrc server4/solr
    [warning@localhost solr]$ ll server1 server2 server3 server4
    server1:
    总用量 4
    drwxrwxr-x. 10 warning warning 4096 9月  24 17:23 solr
    server2:
    总用量 4
    drwxrwxr-x. 10 warning warning 4096 9月  24 17:24 solr
    server3:
    总用量 4
    drwxrwxr-x. 10 warning warning 4096 9月  24 17:24 solr
    server4:
    总用量 4
    drwxrwxr-x. 10 warning warning 4096 9月  24 17:24 solr
    [warning@localhost solr]$ 
    
四台模拟的solr服务器文件已经部署好，接下来我们进行`solrcloud`的配置

    [warning@localhost solr]$ cd server1/solr/solr/
    [warning@localhost solr]$ ls
    collection  contrib  dist  README.txt  solr.xml  zoo.cfg
    ##在solr中已经存在一个名为collection的core，接下来我们新建一个testCore的core，配置与collection相同
    [warning@localhost solr]$ mkdir testCore 
    [warning@localhost solr]$ cp -r  collection/conf testCore/
    ##往testCore/core.properties文件写入内容，该文件标志一个core的存在
    [warning@localhost solr]$ echo name=testCore>testCore/core.properties ##name=testCore代表core的名称
    [warning@localhost solr]$ echo shard=shard1>>testCore/core.properties ##shard=shard1代表当前solr服务器将被分配到solr集群的shard1分片下面
    [warning@localhost solr]$ cat testCore/core.properties 
    name=testCore
    shard=shard1
    [warning@localhost solr]$ 
    
    
编辑solr跟目录下的`start.ini`文件，在其末尾加入如下代码：

    -DzkHost=127.0.0.1:2181,127.0.0.1:2182,127.0.0.1:2183 ##zookeeper集群的ip和端口
    -Dbootstrap_conf=true   ##启动时同步core的配置
    -DnumShards=2 ##集群中分片的数量
    -Djetty.port=8981 ##jetty启动端口
    
然后找到`start.ini`文件中`jetty.port=8983`一行，将其删除。这样我们第一台solr服务器便配置完成。接下来我们配置第二，三，四台solr服务器，其配置与第一台服务器稍有不同。


    ##配置第二台服务器
    [warning@localhost solr]$ cd server2/solr/solr/
    [warning@localhost solr]$ ls
    collection  contrib  dist  README.txt  solr.xml  zoo.cfg
    ##创建testCore目录，作为testCore的主目录
    [warning@localhost solr]$ mkdir testCore
    ##往testCore/core.properties文件写入内容，该文件标志一个core的存在
    [warning@localhost solr]$ echo name=testCore>testCore/core.properties 
    [warning@localhost solr]$ echo shard=shard2>>testCore/core.properties ##当前solr服务器将被分配到solr集群的shard2分片下面
    [warning@localhost solr]$ cat testCore/core.properties 
    name=testCore
    shard=shard2
    [warning@localhost solr]$ cd ..
    ##在start.ini中加入zeekeelper集群信息并修改jetty启动端口
    [warning@localhost solr]$ echo -DzkHost=127.0.0.1:2181,127.0.0.1:2182,127.0.0.1:2183 >>start.ini 
    [warning@localhost solr]$ echo -Djetty.port=8982 >>start.ini
    [warning@localhost solr]$ cd ../../
    
    
    ##配置第三台服务器
    [warning@localhost solr]$ cd server3/solr/solr/
    [warning@localhost solr]$ ls
    collection  contrib  dist  README.txt  solr.xml  zoo.cfg
    ##创建testCore目录，作为testCore的主目录
    [warning@localhost solr]$ mkdir testCore
    ##往testCore/core.properties文件写入内容，该文件标志一个core的存在
    [warning@localhost solr]$ echo name=testCore>testCore/core.properties
    [warning@localhost solr]$ echo shard=shard1>>testCore/core.properties ##当前solr服务器将被分配到solr集群的shard1分片下面
    [warning@localhost solr]$ cat testCore/core.properties
    name=testCore
    shard=shard1
    [warning@localhost solr]$ cd ..
    ##在start.ini中加入zeekeelper集群信息并修改jetty启动端口
    [warning@localhost solr]$ echo -DzkHost=127.0.0.1:2181,127.0.0.1:2182,127.0.0.1:2183 >>start.ini
    [warning@localhost solr]$ echo -Djetty.port=8983 >>start.ini
    [warning@localhost solr]$ cd ../../
    
    ##配置第四台服务器
    [warning@localhost solr]$ cd server4/solr/solr/
    [warning@localhost solr]$ ls
    collection  contrib  dist  README.txt  solr.xml  zoo.cfg
    ##创建testCore目录，作为testCore的主目录
    [warning@localhost solr]$ mkdir testCore
    [warning@localhost solr]$ echo name=testCore>testCore/core.properties
    [warning@localhost solr]$ echo shard=shard2>>testCore/core.properties ##当前solr服务器将被分配到solr集群的shard2分片下面
    [warning@localhost solr]$ cat testCore/core.properties
    name=testCore
    shard=shard2
    [warning@localhost solr]$ cd ..
    ##在start.ini中加入zeekeelper集群信息并修改jetty启动端口
    [warning@localhost solr]$ echo -DzkHost=127.0.0.1:2181,127.0.0.1:2182,127.0.0.1:2183 >>start.ini
    [warning@localhost solr]$ echo -Djetty.port=8984 >>start.ini


同时将三台服务器`start.ini`文件中`jetty.port=8983`一行删除，与第一台服务器配置不同的是，后面三台服务器中名称为`testCore`的core中并没有加入配置文件，只是加入了一个`core.properties`文件，并且在jetty启动配置文件`start.ini`中没有加入`-Dbootstrap_conf=true`和`-DnumShards=2`配置。第一台solr服务器启动后会将`testCore`中的配置信息同步到zookeeper集群中，第二，三，四台solr服务器启动时会从zookeeper集群中获取testCore中的配置信息。

接下来分别修改solr服务器的启动脚本的权限

    [warning@localhost solr]$ chmod 764 server1/solr/bin/*.sh
    [warning@localhost solr]$ chmod 764 server2/solr/bin/*.sh
    [warning@localhost solr]$ chmod 764 server3/solr/bin/*.sh
    [warning@localhost solr]$ chmod 764 server4/solr/bin/*.sh
    

这样，四台solr服务器便配置成功。接下来我们启动solr集群，需要指出的是，在启动solr集群之前，需要先将zookeeper集群启动。刚才我们一经启动了zookeeper集群，现在我们再检查一下zookeeper集群是否可用

    [warning@localhost solr]$ echo ruok | nc 127.0.0.1 2181
    imok
    [warning@localhost solr]$ echo ruok | nc 127.0.0.1 2182
    imok
    [warning@localhost solr]$ echo ruok | nc 127.0.0.1 2183
    imok
    [warning@localhost solr]$ 

zookeeper集群正常，然后我们开始启动solr集群

    [warning@localhost solr]$ cd server1/solr/
    [warning@localhost solr]$ ./bin/jetty.sh start
    Starting Jetty: WARNING: System properties and/or JVM args set.  Consider using --dry-run or --exec
    2013-09-24 18:49:53.513:INFO::main: Redirecting stderr/stdout to /opt/solr/server1/solr/logs/2013_09_24.stderrout.log
    . . . . . OK 2013年 09月 24日 星期二 18:50:16 CST
    
    [warning@localhost solr]$ cd ../../server2/solr/
    [warning@localhost solr]$ ./bin/jetty.sh start
    Starting Jetty: WARNING: System properties and/or JVM args set.  Consider using --dry-run or --exec
    2013-09-24 18:51:36.079:INFO::main: Redirecting stderr/stdout to /opt/solr/server2/solr/logs/2013_09_24.stderrout.log
    . OK 2013年 09月 24日 星期二 18:51:43 CST
    
    [warning@localhost solr]$ cd ../../server3/solr/
    [warning@localhost solr]$ ./bin/jetty.sh start
    Starting Jetty: WARNING: System properties and/or JVM args set.  Consider using --dry-run or --exec
    2013-09-24 18:52:22.612:INFO::main: Redirecting stderr/stdout to /opt/solr/server3/solr/logs/2013_09_24.stderrout.log
    . OK 2013年 09月 24日 星期二 18:52:29 CST
    
    [warning@localhost solr]$ cd ../../server4/solr/
    [warning@localhost solr]$ ./bin/jetty.sh start
    Starting Jetty: WARNING: System properties and/or JVM args set.  Consider using --dry-run or --exec
    2013-09-24 18:52:37.919:INFO::main: Redirecting stderr/stdout to /opt/solr/server4/solr/logs/2013_09_24.stderrout.log
    . OK 2013年 09月 24日 星期二 18:52:45 CST

启动完成，使用浏览器访问[http://127.0.0.1:8981/solr/#/~cloud][7] 将会看到如下结果:
{<2>}![abc](/images/solrcloud.jpg)

通过上图可以看到，在集群中存在两个core，并且每个core存在两个分片，每个分片下又存在两个节点。由于在第一，二台服务器上的`core.properties`文件中配置了shard=shard2，因此被分配到了第一个分片上。


启动jetty时常见错误：

    [warning@localhost solr]$ ./bin/jetty.sh start
    Starting Jetty: WARNING: System properties and/or JVM args set.  Consider using --dry-run or --exec
    2013-09-24 19:31:35.707:WARN:oejx.XmlConfiguration:main: Config error at <New id="ServerLog" class="java.io.PrintStream"><Arg>|        <New class="org.eclipse.jetty.util.RolloverFileOutputStream"><Arg><Property name="jetty.logs" default="./logs"/>/yyyy_mm_dd.stderrout.log</Arg><Arg type="boolean">false</Arg><Arg type="int">90</Arg><Arg><Call class="java.util.TimeZone" name="getTimeZone"><Arg>GMT</Arg></Call></Arg><Get id="ServerLogName" name="datedFilename"/></New>|      </Arg></New> java.lang.reflect.InvocationTargetException in file:/opt/solr/server4/solr/etc/jetty-logging.xml
    java.lang.reflect.InvocationTargetException
    	at sun.reflect.NativeMethodAccessorImpl.invoke0(Native Method)
    	at sun.reflect.NativeMethodAccessorImpl.invoke(Unknown Source)
    	at sun.reflect.DelegatingMethodAccessorImpl.invoke(Unknown Source)
    	at java.lang.reflect.Method.invoke(Unknown Source)
    	at org.eclipse.jetty.start.Main.invokeMain(Main.java:509)
    	at org.eclipse.jetty.start.Main.start(Main.java:651)
    	at org.eclipse.jetty.start.Main.main(Main.java:99)
    Caused by: java.lang.reflect.InvocationTargetException
    	at sun.reflect.NativeConstructorAccessorImpl.newInstance0(Native Method)
    	at sun.reflect.NativeConstructorAccessorImpl.newInstance(Unknown Source)
    	at sun.reflect.DelegatingConstructorAccessorImpl.newInstance(Unknown Source)
    	at java.lang.reflect.Constructor.newInstance(Unknown Source)
    	at org.eclipse.jetty.util.TypeUtil.construct(TypeUtil.java:549)
    	at org.eclipse.jetty.xml.XmlConfiguration$JettyXmlConfiguration.newObj(XmlConfiguration.java:795)
    	at org.eclipse.jetty.xml.XmlConfiguration$JettyXmlConfiguration.itemValue(XmlConfiguration.java:1112)
    	at org.eclipse.jetty.xml.XmlConfiguration$JettyXmlConfiguration.value(XmlConfiguration.java:1017)
    	at org.eclipse.jetty.xml.XmlConfiguration$JettyXmlConfiguration.newObj(XmlConfiguration.java:764)
    	at org.eclipse.jetty.xml.XmlConfiguration$JettyXmlConfiguration.configure(XmlConfiguration.java:413)
    	at org.eclipse.jetty.xml.XmlConfiguration$JettyXmlConfiguration.configure(XmlConfiguration.java:344)
    	at org.eclipse.jetty.xml.XmlConfiguration.configure(XmlConfiguration.java:262)
    	at org.eclipse.jetty.xml.XmlConfiguration$1.run(XmlConfiguration.java:1225)
    	at java.security.AccessController.doPrivileged(Native Method)
    	at org.eclipse.jetty.xml.XmlConfiguration.main(XmlConfiguration.java:1161)
    	... 7 more
    Caused by: java.io.IOException: Cannot write log directory /opt/solr/server4/solr/logs
    	at org.eclipse.jetty.util.RolloverFileOutputStream.setFile(RolloverFileOutputStream.java:219)
    	at org.eclipse.jetty.util.RolloverFileOutputStream.<init>(RolloverFileOutputStream.java:166)
    	at org.eclipse.jetty.util.RolloverFileOutputStream.<init>(RolloverFileOutputStream.java:120)
    	... 22 more
    
    Usage: java -jar start.jar [options] [properties] [configs]
           java -jar start.jar --help  # for more information
    FAILED 2013年 09月 24日 星期二 19:31:39 CST
    
上述问题是因为jetty启动时需要创建日志文件`logs/**.log`，而logs文件夹不存在，只需要创建该目录即可

    [warning@localhost solr]$ mkdir logs
    [warning@localhost solr]$ ./bin/jetty.sh start
    Starting Jetty: WARNING: System properties and/or JVM args set.  Consider using --dry-run or --exec
    2013-09-24 19:34:53.950:INFO::main: Redirecting stderr/stdout to /opt/solr/server4/solr/logs/2013_09_24.stderrout.log
    
在jetty启动时可能会因为8443端口占用而导致如下错误
    
        2013-09-24 19:39:50.498:WARN:oejuc.AbstractLifeCycle:main: FAILED ServerConnector@31490eab{SSL-http/1.1}{0.0.0.0:8443}: java.net.BindException: 地址已在使用
    java.net.BindException: 地址已在使用
    	at sun.nio.ch.Net.bind0(Native Method)
    	at sun.nio.ch.Net.bind(Unknown Source)
    	at sun.nio.ch.Net.bind(Unknown Source)
    	at sun.nio.ch.ServerSocketChannelImpl.bind(Unknown Source)
    	at sun.nio.ch.ServerSocketAdaptor.bind(Unknown Source)
    	at org.eclipse.jetty.server.ServerConnector.open(ServerConnector.java:244)
    	at org.eclipse.jetty.server.AbstractNetworkConnector.doStart(AbstractNetworkConnector.java:80)
    	at org.eclipse.jetty.util.component.AbstractLifeCycle.start(AbstractLifeCycle.java:69)
    	at org.eclipse.jetty.server.Server.doStart(Server.java:303)
    	at org.eclipse.jetty.util.component.AbstractLifeCycle.start(AbstractLifeCycle.java:69)
    	at org.eclipse.jetty.xml.XmlConfiguration$1.run(XmlConfiguration.java:1237)
    	at java.security.AccessController.doPrivileged(Native Method)
    	at org.eclipse.jetty.xml.XmlConfiguration.main(XmlConfiguration.java:1161)
    	at sun.reflect.NativeMethodAccessorImpl.invoke0(Native Method)
    	at sun.reflect.NativeMethodAccessorImpl.invoke(Unknown Source)
    	at sun.reflect.DelegatingMethodAccessorImpl.invoke(Unknown Source)
    	at java.lang.reflect.Method.invoke(Unknown Source)
    	at org.eclipse.jetty.start.Main.invokeMain(Main.java:509)
    	at org.eclipse.jetty.start.Main.start(Main.java:651)
    	at org.eclipse.jetty.start.Main.main(Main.java:99)
    2013-09-24 19:39:50.499:WARN:oejuc.AbstractLifeCycle:main: FAILED org.eclipse.jetty.server.Server@3e7dad3b: java.net.BindException: 地址已在使用
    java.net.BindException: 地址已在使用
    	at sun.nio.ch.Net.bind0(Native Method)
    	at sun.nio.ch.Net.bind(Unknown Source)
    	at sun.nio.ch.Net.bind(Unknown Source)
    	at sun.nio.ch.ServerSocketChannelImpl.bind(Unknown Source)
    	at sun.nio.ch.ServerSocketAdaptor.bind(Unknown Source)
    	at org.eclipse.jetty.server.ServerConnector.open(ServerConnector.java:244)
    	at org.eclipse.jetty.server.AbstractNetworkConnector.doStart(AbstractNetworkConnector.java:80)
    	at org.eclipse.jetty.util.component.AbstractLifeCycle.start(AbstractLifeCycle.java:69)
    	at org.eclipse.jetty.server.Server.doStart(Server.java:303)
    	at org.eclipse.jetty.util.component.AbstractLifeCycle.start(AbstractLifeCycle.java:69)
    	at org.eclipse.jetty.xml.XmlConfiguration$1.run(XmlConfiguration.java:1237)
    	at java.security.AccessController.doPrivileged(Native Method)
    	at org.eclipse.jetty.xml.XmlConfiguration.main(XmlConfiguration.java:1161)
    	at sun.reflect.NativeMethodAccessorImpl.invoke0(Native Method)
    	at sun.reflect.NativeMethodAccessorImpl.invoke(Unknown Source)
    	at sun.reflect.DelegatingMethodAccessorImpl.invoke(Unknown Source)
    	at java.lang.reflect.Method.invoke(Unknown Source)
    	at org.eclipse.jetty.start.Main.invokeMain(Main.java:509)
    	at org.eclipse.jetty.start.Main.start(Main.java:651)
    	at org.eclipse.jetty.start.Main.main(Main.java:99)
    java.lang.reflect.InvocationTargetException
    	at sun.reflect.NativeMethodAccessorImpl.invoke0(Native Method)
    	at sun.reflect.NativeMethodAccessorImpl.invoke(Unknown Source)
    	at sun.reflect.DelegatingMethodAccessorImpl.invoke(Unknown Source)
    	at java.lang.reflect.Method.invoke(Unknown Source)
    	at org.eclipse.jetty.start.Main.invokeMain(Main.java:509)
    	at org.eclipse.jetty.start.Main.start(Main.java:651)
    	at org.eclipse.jetty.start.Main.main(Main.java:99)
    Caused by: java.net.BindException: 地址已在使用
    	at sun.nio.ch.Net.bind0(Native Method)
    	at sun.nio.ch.Net.bind(Unknown Source)
    	at sun.nio.ch.Net.bind(Unknown Source)
    	at sun.nio.ch.ServerSocketChannelImpl.bind(Unknown Source)
    	at sun.nio.ch.ServerSocketAdaptor.bind(Unknown Source)
    	at org.eclipse.jetty.server.ServerConnector.open(ServerConnector.java:244)
    	at org.eclipse.jetty.server.AbstractNetworkConnector.doStart(AbstractNetworkConnector.java:80)
    	at org.eclipse.jetty.util.component.AbstractLifeCycle.start(AbstractLifeCycle.java:69)
    	at org.eclipse.jetty.server.Server.doStart(Server.java:303)
    	at org.eclipse.jetty.util.component.AbstractLifeCycle.start(AbstractLifeCycle.java:69)
    	at org.eclipse.jetty.xml.XmlConfiguration$1.run(XmlConfiguration.java:1237)
    	at java.security.AccessController.doPrivileged(Native Method)
    	at org.eclipse.jetty.xml.XmlConfiguration.main(XmlConfiguration.java:1161)
    	... 7 more

出现该错误时只需要删除`solr/start.d/900-demo.ini`文件即可, 再次启动

    [warning@localhost solr]$ rm -r start.d/*
    [warning@localhost solr]$ ./bin/jetty.sh start
    Starting Jetty: WARNING: System properties and/or JVM args set.  Consider using --dry-run or --exec
    2013-09-24 19:42:47.412:INFO::main: Redirecting stderr/stdout to /opt/solr/server2/solr/logs/2013_09_24.stderrout.log

#### solr操作命令 

 1. solr启动：`jetty.sh start`
 2. solr停止：`jetty.sh stop`
 3. solr重启：`jetty.sh restart`
 4. solr状态检测：`jetty.sh status`
    
    


  [1]: http://www.oracle.com/technetwork/java/javase/downloads/jdk7-downloads-1880260.html
  [2]: http://www.oracle.com/technetwork/java/javase/downloads/jre7-downloads-1880261.html
  [3]: http://www.oracle.com/technetwork/java/javase/downloads/jdk7-downloads-1880260.html
  [4]: http://zh.wikipedia.org/wiki/Paxos%E7%AE%97%E6%B3%95
  [5]: http://labs.renren.com/apache-mirror/zookeeper/
  [6]: http://mirror.bit.edu.cn/apache/zookeeper/
  [7]: http://127.0.0.1:8981/solr/#/~cloud
