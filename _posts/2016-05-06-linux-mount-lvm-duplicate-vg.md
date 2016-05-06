---
layout: post
title: 解决linux挂载其他硬盘lvm分区时VG重复问题
tags: linux
---

解决linux挂载其他硬盘lvm分区时VG重复问题

----- 

问题：

    [root@w ~]# vgscan
      Reading all physical volumes.  This may take a while...
      WARNING: Duplicate VG name vg_w: Existing nMjHCd-6EUR-66l4-y27E-n5is-i1Q4-ddqest (created here) takes precedence over Bju7iV-coBV-RZLb-SZX6-ol3Z-fO1A-bvSTw6
      WARNING: Duplicate VG name vg_w: Existing nMjHCd-6EUR-66l4-y27E-n5is-i1Q4-ddqest (created here) takes precedence over Bju7iV-coBV-RZLb-SZX6-ol3Z-fO1A-bvSTw6
      Found volume group "vg_w" using metadata type lvm2
      Found volume group "vg_w" using metadata type lvm2
      
解决过程：

* 通过`vgdisplay`查看lvm的`VG UUID`

        [root@w ~]# vgdisplay vg_w
        WARNING: Duplicate VG name vg_w: Existing nMjHCd-6EUR-66l4-y27E-n5is-i1Q4-ddqest (created here) takes precedence over Bju7iV-coBV-RZLb-SZX6-ol3Z-fO1A-bvSTw6
        --- Volume group ---
        VG Name               vg_w
        System ID
        Format                lvm2
        Metadata Areas        1
        Metadata Sequence No  3
        VG Access             read/write
        VG Status             resizable
        MAX LV                0
        Cur LV                2
        Open LV               2
        Max PV                0
        Cur PV                1
        Act PV                1
        VG Size               7.51 GiB
        PE Size               4.00 MiB
        Total PE              1922
        Alloc PE / Size       1922 / 7.51 GiB
        Free  PE / Size       0 / 0
        VG UUID               nMjHCd-6EUR-66l4-y27E-n5is-i1Q4-ddqest

说明当前操作系统使用的`vg_w`的 `VG UUID` 是 `nMjHCd-6EUR-66l4-y27E-n5is-i1Q4-ddqest`，而`VG UUID`为`Bju7iV-coBV-RZLb-SZX6-ol3Z-fO1A-bvSTw6`是另一块硬盘的LVM分区。

* 将第二块硬盘的VG名字重命名

        [root@w ~]# vgrename Bju7iV-coBV-RZLb-SZX6-ol3Z-fO1A-bvSTw6 vg_w1
        WARNING: Duplicate VG name vg_w: Existing nMjHCd-6EUR-66l4-y27E-n5is-i1Q4-ddqest (created here) takes precedence over Bju7iV-coBV-RZLb-SZX6-ol3Z-fO1A-bvSTw6
        WARNING: Duplicate VG name vg_w: Existing nMjHCd-6EUR-66l4-y27E-n5is-i1Q4-ddqest (created here) takes precedence over Bju7iV-coBV-RZLb-SZX6-ol3Z-fO1A-bvSTw6
        WARNING: Duplicate VG name vg_w: nMjHCd-6EUR-66l4-y27E-n5is-i1Q4-ddqest (created here) takes precedence over Bju7iV-coBV-RZLb-SZX6-ol3Z-fO1A-bvSTw6
        Volume group "vg_w" successfully renamed to "vg_w1"

* 通过vgdisplay查看VG信息

        [root@w ~]# vgdisplay
        --- Volume group ---
        VG Name               vg_w1
        System ID
        Format                lvm2
        Metadata Areas        1
        Metadata Sequence No  6
        VG Access             read/write
        VG Status             resizable
        MAX LV                0
        Cur LV                2
        Open LV               0
        Max PV                0
        Cur PV                1
        Act PV                1
        VG Size               7.51 GiB
        PE Size               4.00 MiB
        Total PE              1922
        Alloc PE / Size       1922 / 7.51 GiB
        Free  PE / Size       0 / 0
        VG UUID               Bju7iV-coBV-RZLb-SZX6-ol3Z-fO1A-bvSTw6
        
        --- Volume group ---
        VG Name               vg_w
        System ID
        Format                lvm2
        Metadata Areas        1
        Metadata Sequence No  3
        VG Access             read/write
        VG Status             resizable
        MAX LV                0
        Cur LV                2
        Open LV               2
        Max PV                0
        Cur PV                1
        Act PV                1
        VG Size               7.51 GiB
        PE Size               4.00 MiB
        Total PE              1922
        Alloc PE / Size       1922 / 7.51 GiB
        Free  PE / Size       0 / 0
        VG UUID               nMjHCd-6EUR-66l4-y27E-n5is-i1Q4-ddqest

* 激活VG
    
        [root@w ~]# lvscan
        inactive          '/dev/vg_w1/lv_root' [6.71 GiB] inherit
        inactive          '/dev/vg_w1/lv_swap' [816.00 MiB] inherit
        ACTIVE            '/dev/vg_w/lv_root' [6.71 GiB] inherit
        ACTIVE            '/dev/vg_w/lv_swap' [816.00 MiB] inherit
        [root@w ~]# vgchange -ay /dev/vg_w1
        2 logical volume(s) in volume group "vg_w1" now active
        [root@w ~]# lvscan
        ACTIVE            '/dev/vg_w1/lv_root' [6.71 GiB] inherit
        ACTIVE            '/dev/vg_w1/lv_swap' [816.00 MiB] inherit
        ACTIVE            '/dev/vg_w/lv_root' [6.71 GiB] inherit
        ACTIVE            '/dev/vg_w/lv_swap' [816.00 MiB] inherit

* 挂载lvm文件系统

        [root@w ~]# mount /dev/vg_w1/lv_root  /mnt

* 相关命令
    * `vgscan`：扫描所有VG
    * `vgdisplay`:显示VG信息
    * `lvscan`:扫描LVM逻辑卷
    * `vgchange -ay /dev/vg_w1`:激活VG
    * `vgchange -an /dev/vg_w1`:取消激活VG
    * `vgrename`：修改VG名称
