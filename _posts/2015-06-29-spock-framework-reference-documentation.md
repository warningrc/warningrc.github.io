---
layout: post
title: Spock参考文档
tags: java spock
origin: https://book.warningrc.com/spock/
---
<style>
h1,h2,h3,h4{font-family: "Open Sans","DejaVu Sans",sans-serif;font-weight: 300;font-style: normal; color: #ba3925;text-rendering: optimizeLegibility; margin-top: 1em; margin-bottom: .5em;}
h1{color: rgba(0,0,0,.85);}
blockquote{color: #998;font-style: italic;}
</style>

>Spock is a testing and specification framework for Java and Groovy applications.
>What makes it stand out from the crowd is its beautiful and highly expressive specification language.

-----------------
## 介绍(Introduction)
`Spock`是一个`Java`或`Groovy`语言的单元测试框架. 由于拥有漂亮的,极富表现力的语言规范使它从大众的眼中脱颖而出.由于Spock是一个JUnit的Runner,因此它和很多IDE,构建工具,持续集成服务完美兼容. Spock的设计灵感来自于JUnit, jMock, RSpec, Groovy, Scala, Vulcans等一些优秀迷人的框架.

>Spock is a testing and specification framework for Java and Groovy applications. What makes it stand out from the crowd is its beautiful and highly expressive specification language. Thanks to its JUnit runner, Spock is compatible with most IDEs, build tools, and continuous integration servers. Spock is inspired from JUnit, jMock, RSpec, Groovy, Scala, Vulcans, and other fascinating life forms.

## 开始使用Spock(Getting Started)
---
Spock很容易上手,此章节将引导你使用Spock

>It’s really easy to get started with Spock. This section shows you how.


### Spock Web控制台(Spock Web Console)
Spock Web控制台是一个可以让你快速查看,编辑,运行甚至发布Spock specifications的web站点.这是不用你做任何付出就能玩转Spock的一个非常完美的地方.赶紧去运行一下([Hello, Spock!](http://webconsole.spockframework.org/edit/9001))吧.
>[Spock Web Console](http://webconsole.spockframework.org/) is a website that allows you to instantly view, edit, run, and even publish Spock specifications. It is the perfect place to toy around with Spock without making any commitments. So why not run [Hello, Spock!](http://webconsole.spockframework.org/edit/9001) right away?

### Spock示例项目(Spock Example Project)
想要在你的本地环境尝试一下Spock,需要从 https://github.com/spockframework/spock-example 克隆或者下载zip压缩包形式的Spock示例项目.它不需要你做任何设置就可以使用Ant,Gradle或者Maven运行.使用一个简单的命令就可以使用Gradle启动或者在Eclipse和IDEA中运行.具体可以查看README文件中的详细介绍.
>To try Spock in your local environment, clone or download/unzip the https://github.com/spockframework/spock-example [Spock Example Project]. It comes with fully working Ant, Gradle, and Maven builds that require no further setup. The Gradle build even bootstraps Gradle itself and gets you up and running in Eclipse or IDEA with a single command. See the README for detailed instructions.



## Spock入门(Spock Primer)

本章节假定你有一些Groovy和单元测试的基础.如果你是个Java开发者并且没有接触过Groovy,别担心,Groovy会让你感觉很熟悉.实际上,Groovy的初衷就是成为一个与Java兼容的脚本语言.只要你查阅一下[Groovy的文档](http://groovy-lang.org/documentation.html),你就会喜欢上它.
>This chapter assumes that you have a basic knowledge of Groovy and unit testing. If you are a Java developer but haven’t heard about Groovy, don’t worry - Groovy will feel very familiar to you! In fact, one of Groovy’s main design goals is to be the scripting language alongside Java. So just follow along and consult the [Groovy documentation](http://groovy-lang.org/documentation.html) whenever you feel like it.

本章节的目标是教会你写一些Spock specifications,并激起你使用它的欲望.
>The goals of this chapter are to teach you enough Spock to write real-world Spock specifications, and to whet your appetite for more.

想要学习更多的Groovy知识,可以去http://groovy-lang.org/
>To learn more about Groovy, go to http://groovy-lang.org/.

想要学习更多的单元测试知识,可以去看http://en.wikipedia.org/wiki/Unit_testing.
>To learn more about unit testing, go to http://en.wikipedia.org/wiki/Unit_testing.



----------------------

更多细节参看[https://book.warningrc.com/spock](https://book.warningrc.com/spock/ "Spock参考文档")
