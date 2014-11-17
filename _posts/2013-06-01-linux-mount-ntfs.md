---
layout: post
title: linux下ntfs硬盘的加载
tags: linux 
---

----

 在linux上是无法识别NTFS格式的分区的，我们可以通过 ntfs-3g这个软件来实现识别NTFS格式的分区.

----

下面开始安装ntfs-3g：


首先在 http://www.tuxera.com/community/ntfs-3g-download/  下载ntfs-3g的最新版本(笔者下载的是ntfs-3g_ntfsprogs-2013.1.13.tgz)解压安装

    tar zxvf  ntfs-3g_ntfsprogs-2013.1.13.tgz
    ./configure
    make
    sudo make install
    
 这样ntfs-3g就安装完成了，然后开始挂载nfts硬盘，先查看硬盘上存在的分区
 
 	#fdisk -l
    --笔者硬盘分区情况如下:
    Disk /dev/sda: 1000.2 GB, 1000204886016 bytes
    255 heads, 63 sectors/track, 121601 cylinders
    Units = cylinders of 16065 * 512 = 8225280 bytes
    Sector size (logical/physical): 512 bytes / 4096 bytes
    I/O size (minimum/optimal): 4096 bytes / 4096 bytes
    Disk identifier: 0x13c8a6e7
    
       Device Boot      Start         End      Blocks   Id  System
    /dev/sda1   *           1          26      204800    7  HPFS/NTFS
    Partition 1 does not end on cylinder boundary.
    /dev/sda2              26        6553    52428800    7  HPFS/NTFS
    /dev/sda3            6553      119052   903646208    f  W95 Ext'd (LBA)
    /dev/sda4          119052      121602    20481752   12  Compaq diagnostics
    /dev/sda5            6553       13080    52428800    7  HPFS/NTFS
    /dev/sda6           13081       23524    83886080    7  HPFS/NTFS
    /dev/sda7           23524       63043   317440000    7  HPFS/NTFS
    /dev/sda8           63044      102563   317440000    7  HPFS/NTFS
    /dev/sda9          102563      102589      204800   83  Linux
    /dev/sda10         102589      103864    10240000   83  Linux
    /dev/sda11         103864      105011     9216000   82  Linux swap / Solaris
    /dev/sda12         105011      105649     5120000   83  Linux
    /dev/sda13         105649      119052   107661312   83  Linux
    
/dev/sda2是笔者windos 7上面的c盘，现在我们将它挂载在/mnt/win/c下

	#mount -t ntfs-3g /dev/sda2 /mnt/win/c
    
 好了，我们查看一下 /mnt/win/c下有什么文件
 
     #ll /mnt/win/c
    总用量 6217117
    drwxrwxrwx. 1 root root       4096 1月   7 09:19 360SANDBOX
    drwxrwxrwx. 1 root root       4096 10月 19 09:49 Boot
    -rwxrwxrwx. 1 root root     383786 11月 21 2010 bootmgr
    -rwxrwxrwx. 1 root root       8192 2月  25 2011 BOOTSECT.BAK
    -rwxrwxrwx. 1 root root         90 12月 29 16:14 desktop.ini
    lrwxrwxrwx. 2 root root         60 7月  14 2009 Documents and Settings -> /mnt/win/c/Users
    -rwxrwxrwx. 1 root root     171136 7月  30 2009 grldr
    -rwxrwxrwx. 1 root root 6365659136 3月   8 23:49 hiberfil.sys
    drwxrwxrwx. 1 root root          0 12月 29 00:54 Intel
    drwxrwxrwx. 1 root root       4096 1月  17 12:47 Links
    drwxrwxrwx. 1 root root      12288 2月  15 19:34 ProgramData
    drwxrwxrwx. 1 root root       8192 1月   9 11:18 Program Files
    drwxrwxrwx. 1 root root      12288 3月   4 13:17 Program Files (x86)
    drwxrwxrwx. 1 root root          0 12月 29 01:20 Recovery
    drwxrwxrwx. 1 root root          0 7月  14 2009 $Recycle.Bin
    drwxrwxrwx. 1 root root      24576 12月 29 10:28 System Volume Information
    drwxrwxrwx. 1 root root       4096 12月 29 11:06 Users
    drwxrwxrwx. 1 root root      28672 3月   8 23:49 Windows
    
挂载成功！之后我们就可以在linux下访问windows系统的文件了。
取消挂载的命令为

	#umount /mnt/wind/c
