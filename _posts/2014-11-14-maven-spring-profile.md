---
layout: post
title: 使用Maven管理spring环境的profile定义
tags: java 
---
开发过程中需要针对开发环境，正式环境等进行不同的参数配置，比如开发环境使用H2数据库做简单测试，正是环境使用mysql数据库。如果手动管理这些配置信息会很麻烦，最重要的是可能会因为操作失误导致一些错误。因此需要对不同环境的配置信息进行集中管理。

spring 3.1版本提供了profile配置机制，同时maven对profile也有支持，我们将使用mavne + spring 的profile管理不同环境的配置数据。

----

在spring配置文件中配置加载不同配置文件

	<?xml version="1.0" encoding="UTF-8"?>
	<beans xmlns="http://www.springframework.org/schema/beans"
		xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:p="http://www.springframework.org/schema/p"
		xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans-3.2.xsd">
		<!-- 本地测试环境 -->
		<beans profile="localtest">
			<bean id="config"
				class="org.springframework.beans.factory.config.PropertiesFactoryBean"
				p:locations="classpath*:/config/*.localtest.properties" />
		</beans>
		<!-- 正式环境 -->
		<beans profile="pro">
			<bean id="config"
				class="org.springframework.beans.factory.config.PropertiesFactoryBean"
				p:locations="classpath*:/config/*.pro.properties" />
		</beans>
	</beans>


建立 `web.xml`文件

	<?xml version="1.0" encoding="UTF-8"?>
	<web-app xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
		xmlns="http://java.sun.com/xml/ns/javaee" xmlns:web="http://java.sun.com/xml/ns/javaee/web-app_2_5.xsd"
		xsi:schemaLocation="http://java.sun.com/xml/ns/javaee http://java.sun.com/xml/ns/javaee/web-app_2_5.xsd"
		metadata-complete="true" version="2.5">
		<context-param>
			<param-name>spring.profiles.active</param-name>
			<param-value>${profiles.active}</param-value><!--环境配置信息 -->
		</context-param>
		<context-param>
			<param-name>contextConfigLocation</param-name>
			<param-value>
				classpath:config/application.xml
			</param-value>
		</context-param>
		<listener>
			<listener-class>org.springframework.web.context.ContextLoaderListener</listener-class>
		</listener>
		<welcome-file-list>
			<welcome-file>index.html</welcome-file>
			<welcome-file>index.jsp</welcome-file>
		</welcome-file-list>
	</web-app>


将`web.xml`文件移动到 `src/main/build`目录下,在`maven`的pom文件中加入如下配置

	<profiles>
		<!-- 本地测试环境 -->
		<profile>
			<id>localtest</id>
			<properties>
				<profiles.active>localtest</profiles.active>
			</properties>
			<activation>
				<!-- 默认启用的是本地测试环境 -->
				<activeByDefault>true</activeByDefault>
			</activation>
		</profile>
		<!-- 部署环境 -->
		<profile>
			<id>pro</id>
			<properties>
				<profiles.active>pro</profiles.active>
			</properties>
		</profile>
	</profiles>

	....//其他配置信息


	<build>
		<plugins>
			<!-- 根据环境动态生成web.xml文件 -->
			<plugin>
				<groupId>org.apache.maven.plugins</groupId>
				<artifactId>maven-resources-plugin</artifactId>
				<version>2.5</version>
				<executions>
					<execution>
						<id>copy-resources</id>
						<phase>compile</phase>
						<goals>
							<goal>copy-resources</goal>
						</goals>
						<configuration>
							<encoding>UTF-8</encoding>
							<outputDirectory>src/main/webapp/WEB-INF/</outputDirectory>
							<resources>
								<resource>
									<filtering>true</filtering>
									<directory>src/main/build/</directory>
									<includes>
										<include>web.xml</include>
									</includes>
								</resource>
							</resources>
						</configuration>
					</execution>
				</executions>
			</plugin>
		</plugins>
	</build>



通过上述配置,在执行maven命令时加入`-P ${profiles.profile.id}`便可进行不同环境的配置管理.例如打包项目命令:

	mvn  clean package -P localtest  //打包本地测试项目
	mvn  clean package -P pro  //打包正是环境项目