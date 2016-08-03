---
layout: post
title: JVM 类加载过程
tags: java jvm class
---

 类从加载到虚拟机到卸载，它的整个生命周期包括：加载（Loading），验证（Validation），准备（Preparation），解析（Resolution），初始化（Initialization），使用（Using）和卸载（Unloading）。其中，验证、准备和解析部分被称为连接（Linking）。

-----------


### 加载

### 验证

### 准备

### 解析

### 初始化

初始化类，其实就是执行类的初始化方法`<cinit>`,Java虚拟机规范规定了以下几种情况必须对类进行初始化

* 当遇到以下指令时:`new`,`getstatic`,`putstatic`,`invokestatic`
* 对类进行反射调用的时候
* 类的某个子类初始化的时候
* 被指定为虚拟机主类的时候
* 当使用 jdk1.7 动态语言支持时，如果一个 `java.lang.invoke.MethodHandle` 实例最后的解析结果是`REF_getstatic`,`REF_putstatic`,`REF_invokeStatic`的方法句柄，并且这个方法句柄所对应的类没有进行初始化






----- 
