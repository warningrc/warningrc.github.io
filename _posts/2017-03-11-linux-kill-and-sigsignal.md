---
layout: post
title: linux kill和信号量
tags: linux
---


Linux中的kill命令用来终止指定的进程,最常用的杀死进程的命令是 `kill -9 pid`，很多人用过这个命令，却不知道`-9`是什么意思。

----


### 信号量

通过`man`查看`kill`命令，解释如下：
>The command kill sends the specified signal to the specified process or process group.  If no signal is specified, the TERM signal is sent.  The TERM signal will kill processes which do not catch this sig-nal.  For other processes, it may be necessary to use the KILL (9) signal, since this signal cannot be caught.

>Most modern shells have a builtin kill function, with a usage rather similar to that of the command described here. The ‘-a’ and ‘-p’ options, and the possibility to specify pids by command name is a local extension.

>If sig is 0, then no signal is sent, but error checking is still performed.


大致意思是：

>`kill`给指定进程发送指定信号. 如果没有指定信号,则发送 `TERM` 信号.`TERM` 信号会杀死不能俘获该信号的进程. 对于其他进程, 可能需要使用`KILL (9)` 信号, 因为该信号不能够被俘获. 

>如果sig是0的话，不会向进程发送任何信号，但是会继续检测错误(进程id或者进程组id是否存在)



通过`kill -l`可以列出所有信号名称

```shell
[root@warningrc ~]# kill -l
 1) SIGHUP       2) SIGINT       3) SIGQUIT      4) SIGILL       5) SIGTRAP
 6) SIGABRT      7) SIGBUS       8) SIGFPE       9) SIGKILL     10) SIGUSR1
11) SIGSEGV     12) SIGUSR2     13) SIGPIPE     14) SIGALRM     15) SIGTERM
16) SIGSTKFLT   17) SIGCHLD     18) SIGCONT     19) SIGSTOP     20) SIGTSTP
21) SIGTTIN     22) SIGTTOU     23) SIGURG      24) SIGXCPU     25) SIGXFSZ
26) SIGVTALRM   27) SIGPROF     28) SIGWINCH    29) SIGIO       30) SIGPWR
31) SIGSYS      34) SIGRTMIN    35) SIGRTMIN+1  36) SIGRTMIN+2  37) SIGRTMIN+3
38) SIGRTMIN+4  39) SIGRTMIN+5  40) SIGRTMIN+6  41) SIGRTMIN+7  42) SIGRTMIN+8
43) SIGRTMIN+9  44) SIGRTMIN+10 45) SIGRTMIN+11 46) SIGRTMIN+12 47) SIGRTMIN+13
48) SIGRTMIN+14 49) SIGRTMIN+15 50) SIGRTMAX-14 51) SIGRTMAX-13 52) SIGRTMAX-12
53) SIGRTMAX-11 54) SIGRTMAX-10 55) SIGRTMAX-9  56) SIGRTMAX-8  57) SIGRTMAX-7
58) SIGRTMAX-6  59) SIGRTMAX-5  60) SIGRTMAX-4  61) SIGRTMAX-3  62) SIGRTMAX-2
63) SIGRTMAX-1  64) SIGRTMAX
```


每个信号都是什么意思呢

| 信号数字 | 信号名称 | 含义 |
| --- | --- | --- |
| `1` | `SIGHU` | 根据约定，当发送一个挂起信号时，大多数服务器进程（所有常用的进程）都会进行复位操作并重新加载它们的配置文件。<br>系统对SIGHUP信号的默认处理是终止收到该信号的进程。所以若程序中没有捕捉该信号，当收到该信号时，进程就会退出。 |
| `2` | `SIGINT` | 程序终止(interrupt)信号, 在用户键入INTR字符(通常是Ctrl-C)时发出，用于通知前台进程组终止进程。 |
| `3` | `SIGQUIT` | 和SIGINT类似, 但由QUIT字符(通常是`Ctrl-\`)来控制. 进程在因收到SIGQUIT退出时会产生core文件, 在这个意义上类似于一个程序错误信号。<br> 发送SIGQUIT信号给Java应用之后，会有当前的Thread Dump输出(附录一)，类似于执行`jstack -l pid`（附录二） |
| `4` | `SIGILL` | 执行了非法指令. 通常是因为可执行文件本身出现错误, 或者试图执行数据段. 堆栈溢出时也有可能产生这个信号。 |
| `5` | `SIGTRAP` | 由断点指令或其它trap指令产生. 由debugger使用. |
| `6` | `SIGABRT` | 程序自己发现错误并调用abort函数生成的信号.<br> C语言中abort函数是一个比较严重的函数，当调用它时，会导致程序异常终止，而不会进行一些常规的清除工作，比如释放内存等。 |
| `7` | `SIGBUS` | 访问一个非法内存地址, 包括内存地址对齐(alignment)出错. 比如访问一个四个字长的整数, 但其地址不是4的倍数.它与SIGSEGV的区别在于后者是由于对合法存储地址的非法访问触发的(如访问不属于自己存储空间或只读存储空间)。 |
| `8` | `SIGFPE` | 在发生致命的算术运算错误时发出. 不仅包括浮点运算错误, 还包括溢出及除数为0等其它所有的算术的错误. |
| `9` | `SIGKILL` | 用来立即结束程序的运行. SIGKILL既不能被应用程序捕获，也不能被阻塞或忽略，其动作是立即结束指定进程.应用程序根本无法“感知”SIGKILL信号，它在完全无准备的情况下，就被收到SIGKILL信号的操作系统给干掉了，显然，在这种“暴力”情况下，应用程序完全没有释放当前占用资源的机会。事实上，SIGKILL信号是直接发给init进程的，它收到该信号后，负责终止pid指定的进程。在某些情况下（如进程已经hang死，无法响应正常信号），就可以使用kill -9来结束进程 |
| `10` | `SIGUSR1` | 保留给用户使用的信号,应用程序可以监听该信号 |
| `11` | `SIGSEGV` | 试图访问未分配给自己的内存,或试图往没有写权限的内存地址写数据时发出. |
| `12` | `SIGUSR2` | 保留给用户使用的信号,应用程序可以监听该信号. |
| `13` | `SIGPIPE` | 管道破裂。这个信号通常在进程间通信产生，比如采用FIFO(管道)通信的两个进程，读管道没打开或者意外终止就往管道写，写进程会收到SIGPIPE信号。此外用Socket通信的两个进程，写进程在写Socket的时候，读进程已经终止. |
| `14` | `SIGALRM` | 时钟定时信号, 计算的是实际的时间或时钟时间. alarm函数使用该信号. |
| `15` | `SIGTERM` | 程序结束(terminate)信号, 与SIGKILL不同的是该信号可以被阻塞和处理。通常用来要求程序自己正常退出，kill命令缺省产生这个信号。如果进程终止不了，我们才会尝试SIGKILL. |
| `16` | `SIGSTKFLT` | 协处理器堆栈错误（Linux专用）. |
| `17` | `SIGCHLD` | 子进程结束时, 父进程会收到这个信号. |
| `18` | `SIGCONT` | 让一个停止(stopped)的进程继续执行. 本信号不能被阻塞. |
| `19` | `SIGSTOP` | 停止(stopped)进程的执行. 注意它和terminate以及interrupt的区别: 该进程还未结束, 只是暂停执行. 本信号不能被阻塞, 处理或忽略. |
| `20` | `SIGTSTP` | 停止进程的运行, 但该信号可以被处理和忽略. 用户键入SUSP字符时(通常是Ctrl-Z)发出这个信号.此信号导致任务中断，但任务并没有结束，它还在进程中，但状态是维持挂起状态，我们可以使用fg或者bg来继续前台或者后台的任务（fg重新启动前台被中断的任务，bg后台执行被中断的任务） |
| `21` | `SIGTTIN` | 当后台作业要从用户终端读数据时, 该作业中的所有进程会收到SIGTTIN信号. |
| `22` | `SIGTTOU` | 似于SIGTTIN, 但在写终端(或修改终端模式)时收到. |
| `23` | `SIGURG` | 有紧急数据或`out-of-band`（参见附录三）数据到达socket时产生. |
| `24` | `SIGXCPU` | 超过CPU时间资源限制,内核就向进程发一个SIGXCPU 信号. 这个限制可以由getrlimit/setrlimit(函数)来读取/改变. |
| `25` | `SIGXFSZ` | 超过文件大小资源限制.当某个进程写文件，单个文件大小超出限制，这时内核会向它发送SIGXFSZ。SIGXFSZ信号的默认动作是：终止进程+生成coredump文件 |
| `26` | `SIGVTALRM` | 虚拟时钟信号. 类似于SIGALRM, 但是计算的是该进程占用的CPU时间. |
| `27` | `SIGPROF` | 类似于SIGALRM/SIGVTALRM, 但包括该进程用的CPU时间以及系统调用的时间. |
| `28` | `SIGWINCH` | 当Terminal的窗口大小改变的时候，发送给Foreground Group的所有进程. |
| `29` | `SIGIO` | 文件描述符准备就绪, 可以开始进行输入/输出操作.异步IO事件. |
| `30` | `SIGPWR` | 电源失效/重启动. |
| `31` | `SIGSYS` | 非法系统调用. |

## 信号类型

Linux系统共定义了64种信号，分为两大类：可靠信号与不可靠信号，前32种信号为不可靠信号，后32种为可靠信号。

* 不可靠信号： 也称为非实时信号，不支持排队，信号可能会丢失, 比如发送多次相同的信号, 进程只能收到一次. 信号值取值区间为1~31；
* 可靠信号： 也称为实时信号，支持排队, 信号不会丢失, 发多少次, 就可以收到多少次. 信号值取值区间为32~64

## Java注册信号量监听

```java
sun.misc.SignalHandler signalHandler = new sun.misc.SignalHandler() {

    @Override
    public void handle(sun.misc.Signal paramSignal) {
        System.out.println("收到信号:" + paramSignal.getName());
    }
};
sun.misc.Signal.handle(new sun.misc.Signal("TERM"), signalHandler);
// sun.misc.Signal.handle(new sun.misc.Signal("USR1"), signalHandler);
sun.misc.Signal.handle(new sun.misc.Signal("USR2"), signalHandler);
```
-----

>更多Linux信号相关可以查阅 [http://akaedu.github.io/book/ch33.html](http://akaedu.github.io/book/ch33.html)


----------------------------------

 附录一

```shell
Full thread dump Java HotSpot(TM) 64-Bit Server VM (24.55-b03 mixed mode):
"Service Thread" daemon prio=10 tid=0x00007fde24094800 nid=0x5130 runnable [0x0000000000000000]
   java.lang.Thread.State: RUNNABLE
"C2 CompilerThread1" daemon prio=10 tid=0x00007fde24092000 nid=0x512f waiting on condition [0x0000000000000000]
   java.lang.Thread.State: RUNNABLE
"C2 CompilerThread0" daemon prio=10 tid=0x00007fde2408f000 nid=0x512e waiting on condition [0x0000000000000000]
   java.lang.Thread.State: RUNNABLE
"Signal Dispatcher" daemon prio=10 tid=0x00007fde24085000 nid=0x512d waiting on condition [0x0000000000000000]
   java.lang.Thread.State: RUNNABLE
"Finalizer" daemon prio=10 tid=0x00007fde2406e000 nid=0x512c in Object.wait() [0x00007fde208f7000]
   java.lang.Thread.State: WAITING (on object monitor)
        at java.lang.Object.wait(Native Method)
        - waiting on <0x00000007d7005568> (a java.lang.ref.ReferenceQueue$Lock)
        at java.lang.ref.ReferenceQueue.remove(ReferenceQueue.java:135)
        - locked <0x00000007d7005568> (a java.lang.ref.ReferenceQueue$Lock)
        at java.lang.ref.ReferenceQueue.remove(ReferenceQueue.java:151)
        at java.lang.ref.Finalizer$FinalizerThread.run(Finalizer.java:189)
"Reference Handler" daemon prio=10 tid=0x00007fde2406a000 nid=0x512b in Object.wait() [0x00007fde209f8000]
   java.lang.Thread.State: WAITING (on object monitor)
        at java.lang.Object.wait(Native Method)
        - waiting on <0x00000007d70050f0> (a java.lang.ref.Reference$Lock)
        at java.lang.Object.wait(Object.java:503)
        at java.lang.ref.Reference$ReferenceHandler.run(Reference.java:133)
        - locked <0x00000007d70050f0> (a java.lang.ref.Reference$Lock)
"main" prio=10 tid=0x00007fde24008800 nid=0x5125 waiting on condition [0x00007fde2a7bd000]
   java.lang.Thread.State: TIMED_WAITING (sleeping)
        at java.lang.Thread.sleep(Native Method)
        at TTT.main(TTT.java:16)
"VM Thread" prio=10 tid=0x00007fde24068000 nid=0x512a runnable 
"GC task thread#0 (ParallelGC)" prio=10 tid=0x00007fde2401e000 nid=0x5126 runnable 
"GC task thread#1 (ParallelGC)" prio=10 tid=0x00007fde24020000 nid=0x5127 runnable 
"GC task thread#2 (ParallelGC)" prio=10 tid=0x00007fde24021800 nid=0x5128 runnable 
"GC task thread#3 (ParallelGC)" prio=10 tid=0x00007fde24023800 nid=0x5129 runnable 
"VM Periodic Task Thread" prio=10 tid=0x00007fde2409f000 nid=0x5131 waiting on condition 
JNI global references: 105
Heap
 PSYoungGen      total 36864K, used 634K [0x00000007d7000000, 0x00000007d9900000, 0x0000000800000000)
  eden space 31744K, 2% used [0x00000007d7000000,0x00000007d709ebf0,0x00000007d8f00000)
  from space 5120K, 0% used [0x00000007d9400000,0x00000007d9400000,0x00000007d9900000)
  to   space 5120K, 0% used [0x00000007d8f00000,0x00000007d8f00000,0x00000007d9400000)
 ParOldGen       total 83968K, used 0K [0x0000000785000000, 0x000000078a200000, 0x00000007d7000000)
  object space 83968K, 0% used [0x0000000785000000,0x0000000785000000,0x000000078a200000)
 PSPermGen       total 21504K, used 2366K [0x000000077fe00000, 0x0000000781300000, 0x0000000785000000)
  object space 21504K, 11% used [0x000000077fe00000,0x000000078004f9f0,0x0000000781300000)
```
----------------------------

 附录二

```shell
Full thread dump Java HotSpot(TM) 64-Bit Server VM (24.55-b03 mixed mode):
"Attach Listener" daemon prio=10 tid=0x00007f4000001000 nid=0x517e runnable [0x0000000000000000]
   java.lang.Thread.State: RUNNABLE
   Locked ownable synchronizers:
        - None
"Service Thread" daemon prio=10 tid=0x00007f4028094800 nid=0x5156 runnable [0x0000000000000000]
   java.lang.Thread.State: RUNNABLE
   Locked ownable synchronizers:
        - None
"C2 CompilerThread1" daemon prio=10 tid=0x00007f4028092000 nid=0x5155 waiting on condition [0x0000000000000000]
   java.lang.Thread.State: RUNNABLE
   Locked ownable synchronizers:
        - None
"C2 CompilerThread0" daemon prio=10 tid=0x00007f402808f000 nid=0x5154 waiting on condition [0x0000000000000000]
   java.lang.Thread.State: RUNNABLE
   Locked ownable synchronizers:
        - None
"Signal Dispatcher" daemon prio=10 tid=0x00007f4028085000 nid=0x5153 runnable [0x0000000000000000]
   java.lang.Thread.State: RUNNABLE
   Locked ownable synchronizers:
        - None
"Finalizer" daemon prio=10 tid=0x00007f402806e000 nid=0x5152 in Object.wait() [0x00007f402c4b7000]
   java.lang.Thread.State: WAITING (on object monitor)
        at java.lang.Object.wait(Native Method)
        - waiting on <0x00000007d7005568> (a java.lang.ref.ReferenceQueue$Lock)
        at java.lang.ref.ReferenceQueue.remove(ReferenceQueue.java:135)
        - locked <0x00000007d7005568> (a java.lang.ref.ReferenceQueue$Lock)
        at java.lang.ref.ReferenceQueue.remove(ReferenceQueue.java:151)
        at java.lang.ref.Finalizer$FinalizerThread.run(Finalizer.java:189)
   Locked ownable synchronizers:
        - None
"Reference Handler" daemon prio=10 tid=0x00007f402806a000 nid=0x5151 in Object.wait() [0x00007f402c5b8000]
   java.lang.Thread.State: WAITING (on object monitor)
        at java.lang.Object.wait(Native Method)
        - waiting on <0x00000007d70050f0> (a java.lang.ref.Reference$Lock)
        at java.lang.Object.wait(Object.java:503)
        at java.lang.ref.Reference$ReferenceHandler.run(Reference.java:133)
        - locked <0x00000007d70050f0> (a java.lang.ref.Reference$Lock)
   Locked ownable synchronizers:
        - None
"main" prio=10 tid=0x00007f4028008800 nid=0x514b waiting on condition [0x00007f402f29c000]
   java.lang.Thread.State: TIMED_WAITING (sleeping)
        at java.lang.Thread.sleep(Native Method)
        at TTT.main(TTT.java:16)
   Locked ownable synchronizers:
        - None
"VM Thread" prio=10 tid=0x00007f4028068000 nid=0x5150 runnable 
"GC task thread#0 (ParallelGC)" prio=10 tid=0x00007f402801e000 nid=0x514c runnable 
"GC task thread#1 (ParallelGC)" prio=10 tid=0x00007f4028020000 nid=0x514d runnable 
"GC task thread#2 (ParallelGC)" prio=10 tid=0x00007f4028021800 nid=0x514e runnable 
"GC task thread#3 (ParallelGC)" prio=10 tid=0x00007f4028023800 nid=0x514f runnable 
"VM Periodic Task Thread" prio=10 tid=0x00007f402809f000 nid=0x5157 waiting on condition 
JNI global references: 105
```

------------------------

附录三


>传输层协议使用带外数据（out-of-band，OOB）来发送一些重要的数据，如果通信一方有重要的数据需要通知对方时，协议能够将这些数据快速地发送到对方。为了发送这些数据，协议一般不使用与普通数据相同的通道，而是使用另外的通道。linux系统的套接字机制支持低层协议发送和接受带外数据。但是TCP协议没有真正意义上的带外数据。为了发送重要协议，TCP提供了一种称为紧急模式（urgent mode）的机制。TCP协议在数据段中设置URG位，表示进入紧急模式。接收方可以对紧急模式采取特殊的处理。很容易看出来，这种方式数据不容易被阻塞，并且可以通过在我们的服务器端程序里面捕捉SIGURG信号来及时接受数据。这正是我们所要求的效果。


>由于TCP协议每次只能发送和接受带外数据一个字节，所以，我们可以通过设置一个数组，利用发送数组下标的办法让服务器程序能够知道自己要监听的端口以及要连接的服务器IP/port。由于限定在1个字节，所以我们最多只能控制255个port的连接，255个内网机器（不过同一子网的机器不会超过255J），同样也只能控制255个监听端口，不过这些已经足够了。


>以下对于带外数据（也称为TCP紧急数据）的讨论，都是基于BSD模型而言的。用户和实现者必须注意，目前有两种互相矛盾的关于RFC 793的解释，也就是在这基础上，带外数据这一概念才被引入的。而且BSD对于带外数据的实现并没有符合RFC 1122定下的主机的要求，为了避免互操作时的问题，应用程序开发者最好不要使用带外数据，除非是与某一既成事实的服务互操作时所必须的。Windows Sockets提供者也必须提供他们的产品对于带外数据实现的语义的文挡（采用BSD方式或者是RFC 1122方式）。规定一个特殊的带外数据语义集已经超出了Windows Sockets规范的讨论范围。


>流套接口的抽象中包括了带外数据这一概念，带外数据是相连的每一对流套接口间一个逻辑上独立的传输通道。带外数据是独立于普通数据传送给用户的，这一抽象要求带外数据设备必须支持每一时刻至少一个带外数据消息被可靠地传送。这一消息可能包含至少一个字节；并且在任何时刻仅有一个带外数据信息等候发送。对于仅支持带内数据的通讯协议来说（例如紧急数据是与普通数据在同一序列中发送的），系统通常把紧急数据从普通数据中分离出来单独存放。这就允许用户可以在顺序接收紧急数据和非顺序接收紧急数据之间作出选择（非顺序接收时可以省去缓存重叠数据的麻烦）。在这种情况下，用户也可以“偷看一眼”紧急数据。


>某一个应用程序也可能喜欢线内处理紧急数据，即把其作为普通数据流的一部分。这可以靠设置套接口选项中的SO_OOBINLINE来实现。在这种情况下，应用程序可能希望确定未读数据中的哪一些是“紧急”的（“紧急”这一术语通常应用于线内带外数据）。为了达到这个目的，在Windows Sockets的实现中就要在数据流保留一个逻辑记号来指出带外数据从哪一点开始发送，一个应用程序可以使用SIOCATMARK ioctlsocket()命令来确定在记号之前是否还有未读入的数据。应用程序可以使用这一记号与其对方进行重新同步。


>(WSAAsyncSelect)函数可以用于处理对带外数据到来的通知。


> 更详细内容参考TCP/IP协议