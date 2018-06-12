---
layout: post
title: Eclipse Memory Analysis Tools简单使用说明
tags: mat java
---


#### 打开dump文件

菜单 > File > Open Heap Dump

第一次打开文件MAT进行分析处理会比较慢。

![](http://p8ia113oq.bkt.clouddn.com/d921cba4113492e5e56e2623d58de65f.png)

打开以后会展示如下效果

![](http://p8ia113oq.bkt.clouddn.com/ad869e9e2eee26549c010239bb1ce9f8.png)

#### 上图中的几个主要信息：

* `Details`: 堆内存大小(`Size`)、类的数量(`Classes`)、对象的数量(`Objects`)、类加载器的数量(`Class Loader`)。
* `Biggest Objects by Retained Size`:堆内存中最大的对象及占用内存大小。当鼠标移动到饼图的某个区域后在窗口的左面会显示出一些详细信息(包含类的信息、静态变量、类变量、类结构等)。
  - `List objects -> with outgoing references`:查看此对象引用的外部对象.
  - `List objects -> with incoming references`:查看引用此对象的外部对象.
  - `Path To GC Roots`: 查看对象的GC Root路径。
    - `exclude xxx references`:排除一些软引用、弱引用、虚引用.如果只有强引用存在，GC就一直无法回收对象，进而导致内存泄露。
* `Actions`:列出一下常用的操作。
  - `Histogram`:列出每个类的对象数量和占用内存大小,默认使用`Shallow Heap`排序。
  - `Dominator Tree`:列出堆中占用比较大的类型，按照内存占用大小排序。
  - `Top Consumers`:按照类、类加载器和包等信息进行分组展示出最大的对象。
  - `Duplicate Classes`:列出被多个类加载器重复加载的类列表。
* `Reports`:一些统计报表
  - `Leak Suspects`:泄漏分析报告。报告中尝试找出可能导致内存泄露的地方，并对找到的可以地方做了详细描述。
  - `Top Components`
* `Step By Step`:按照帮助一步一步的操作。
* 点击齿轮(![](http://p8ia113oq.bkt.clouddn.com/df89cd39ed3afdb2765c2be50f5a1cc2.png))图标可以查看线程相关信息。如下图：
![](http://p8ia113oq.bkt.clouddn.com/e9db50a5ce9bc50005030fbf4b91e04b.png)

--------

#### 几个概念：

* `Shallow Heap`:对象本身占用的内存大小，不包含其引用的对象。对象本身占用的内存大小根据其本身的类型和成员变量的数量决定。数组的大小根据元素的类型(基本数据类型、对象类型)和数组的长度决定。Java的对象的成员变量保存的都是引用，所以导致在堆内存中真正占用内存大的都是基本数据类型的数组(byte[]/char[]/int[]),所以在`Histogram`中占用内存比较大的数据就出现下图所示的那样。
![](http://p8ia113oq.bkt.clouddn.com/9e95c20f831bd0931dbcc0ba10943712.png)

* `Retained Heap`:该项代表因为当前对象被回收而减少引用进而被回收的所有对象所占用的内存大小。通俗点讲就是该对象所引用的所有对象(包含被递归引用的对象)占用的内存大小。


--------

`Histogram`信息如下图：

![](http://p8ia113oq.bkt.clouddn.com/6c9bee4635895ce412cd5b4eadbb1973.png)

`Dominator Tree`信息如下图：

![](http://p8ia113oq.bkt.clouddn.com/c2d01143321c61daa3b1508d48897295.png)

`Top Consumers`信息如下图：

![](http://p8ia113oq.bkt.clouddn.com/805626d8f0c05ef640e69c80e48d1c47.png)

`Duplicate Classes`信息如下图:
![](http://p8ia113oq.bkt.clouddn.com/e01a00730d82463a1ba84abd548a6cf4.png)

------

dupm内存命令

    jmap -dump:format=b,file=xxx.bin <pid>
