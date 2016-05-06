---
layout: post
title: 终端控制VirtualBox虚拟机
tags: linux
---

终端控制VirtualBox虚拟机

----- 


* 查询虚拟机

        vboxmanage list vms

* 查询运行的虚拟机
    
        vboxmanage list runningvms

* 启动虚拟机

        vboxmanage startvm hadoop1 --type gui #界面方式启动
        vboxmanage startvm hadoop1 --type headless #后台无界面启动

* 控制虚拟机

        vboxmanage controlvm hadoop1 acpipowerbutton # 关闭虚拟机，等价于点击系统关闭按钮
        vboxmanage controlvm hadoop1 poweroff  # 关闭虚拟机，等价于直接关闭电源，非正常关机
        vboxmanage controlvm hadoop1 pause  # 暂停虚拟机的运行
        vboxmanage controlvm hadoop1 resume   # 恢复暂停的虚拟机
        vboxmanage controlvm hadoop1 savestate   # 保存当前虚拟机的运行状态