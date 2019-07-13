---
title: maven中scope标签详解
slug: maven-scope
date: 2018-07-11T18:32:31+08:00
categories:
- Maven
tags:
- Maven
keywords:
- Maven
- scope标签详解
thumbnailImagePosition: left
thumbnailImage: https://houjq.oss-cn-hongkong.aliyuncs.com/hugo/img/20190602175850.jpg
showSocial: false
draft: false
---
本文的主要目是介绍maven中scope标签详解。 
<!--more-->

## **scope的分类**

- **compile：**默认值 他表示被依赖项目需要参与当前项目的编译，还有后续的测试，运行周期也参与其中，是一个比较强的依赖。打包的时候通常需要包含进去
- **test：**依赖项目仅仅参与测试相关的工作，包括测试代码的编译和执行，不会被打包，例如：junit
- **runtime：**表示被依赖项目无需参与项目的编译，不过后期的测试和运行周期需要其参与。与compile相比，跳过了编译而已。例如JDBC驱动，适用运行和测试阶段
- **provided：**打包的时候可以不用包进去，别的设施会提供。事实上该依赖理论上可以参与编译，测试，运行等周期。相当于compile，但是打包阶段做了exclude操作
- **system：**从参与度来说，和provided相同，不过被依赖项不会从maven仓库下载，而是从本地文件系统拿。需要添加systemPath的属性来定义路径



## **scope的依赖传递**

A依赖B，B依赖C。当前项目为A，只当B在A项目中的scope，那么c在A中的scope是如何得知呢？

当C是test或者provided时，C直接被丢弃，A不依赖C；（排除传递依赖）

否则A依赖C，C的scope继承与B的scope



![](https://houjq.oss-cn-hongkong.aliyuncs.com/hugo/img/20190602180548.jpg?x-oss-process=style/250_250)