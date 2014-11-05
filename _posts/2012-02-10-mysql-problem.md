---
layout: post
title: mysql问题记录
tags: mysql
---

使用MySQL过程中遇到的一些问题记录

----

## 允许远程连接 

Mysql为了安全性，在默认情况下用户只允许在本地登录，可是在有些情况下，还是需要使用用户进行远程连接。

11. 为用户授权，需要使用`GRANT`命令，命令格式为：`GRANT 权限 ON 数据库对象 TO 用户`
	* 示例：
		* 允许root用户在任何地方进行远程登录，并具有所有库任何操作权限，具体操作如下：
			* 进行授权操作：`GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'youpassword' WITH GRANT OPTION;`
			* 重载授权表：`FLUSH PRIVILEGES;`
		* 允许root用户在一个特定的IP进行远程登录，并具有所有库任何操作权限，具体操作如下：
			* 进行授权操作：`GRANT ALL PRIVILEGES ON *.* TO root@"172.16.16.152" IDENTIFIED BY "youpassword" WITH GRANT OPTION;`
			* 重载授权表：`FLUSH PRIVILEGES;`
		* 允许root用户在一个特定的IP进行远程登录，并具有`test`数据库中所有表的特定操作权限，具体操作如下：
			* 进行授权操作：`GRANT SELECT，INSERT，UPDATE，DELETE ON test.* TO root@"127.0.0.1" IDENTIFIED BY "youpassword";`
			* 重载授权表：`FLUSH PRIVILEGES;`
2. 删除用户授权，需要使用`REVOKE`命令，命令格式为：`REVOKE grant 权限 on 数据库对象 to 用户 ON 数据库[.表名] FROM 用户`
	* 示例：
		* 删除某个用户的所有权限
			* 进行删除授权操作:`REVOKE ALL ON *.* FROM test-user;`
			* 从用户表内删除用户:`DELETE FROM user WHERE user="test-user";`
			* 重载授权表：`FLUSH PRIVILEGES;`

3. MYSQL权限详细分类:
	* 全局管理权限：
		* `FILE`: 在MySQL服务器上读写文件。
		* `PROCESS`: 显示或杀死属于其它用户的服务线程。 
		* `RELOAD`: 重载访问控制表，刷新日志等。
		* `SHUTDOWN`: 关闭MySQL服务。
	* 数据库/数据表/数据列权限：
		* `ALTER`: 修改已存在的数据表(例如增加/删除列)和索引。
		* `CREATE`: 建立新的数据库或数据表。 
		* `DELETE`: 删除表的记录。 
		* `DROP`: 删除数据表或数据库。 
		* `INDEX`: 建立或删除索引。
		* `INSERT`: 增加表的记录。
		* `SELECT`: 显示/搜索表的记录。
		* `UPDATE`: 修改表中已存在的记录。
	* 特别的权限： 
		* `ALL`: 允许做任何事(和root一样)。 
		* `USAGE`: 只允许登录--其它什么也不允许做。

## 远程连接出现 Lost connection to MySQL server at 'reading initial communication packet'的错误 ##
在`my.cnf`文件的`mysqld`段中做如下修改：

* 添加`skip-name-resolve`
* 删除`bind-address=127.0.0.1`
