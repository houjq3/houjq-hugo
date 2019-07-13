---
title: "nodejs在Linux环境上安装部署"
slug: nodejs-build
date: 2018-07-13T11:59:53+08:00
categories:
- nodejs
tags:
- nodejs
- Linux
keywords:
- nodejs
- Linux
thumbnailImagePosition: left
thumbnailImage: https://houjq.oss-cn-hongkong.aliyuncs.com/hugo/img/20190602175852.jpg
showSocial: false
draft: false
---

本文的主要目是介绍nodejs在Linux环境上安装部署。
<!--more-->

1、下载源码：http://nodejs.cn/download/

2、解压源码

```
tar zxvf node-v10.5.0.tar.xz
```

3、 编译安装

```
cd node-v10.5.0
./configure --prefix=$HOME/node/0.10.24
make
make install
```

4、 配置NODE_HOME，进入profile编辑环境变量

```
vi $HOME/.bash_profile
```

设置nodejs环境变量，在 ***export PATH USER LOGNAME MAIL HOSTNAME HISTSIZE HISTCONTROL*** 一行的上面添加如下内容:

```
#set for nodejs
export NODE_HOME=$HOME/node/0.10.24
export PATH=$NODE_HOME/bin:$PATH
```

:wq保存并退出，编译/etc/profile 使配置生效

```
source $HOME/.bash_profile
```

验证是否安装配置成功

```
node -v
```

输出 v0.10.24 表示配置成功

npm模块安装路径

```
$HOME/node/0.10.24/lib/node_modules/
```


![](https://houjq.oss-cn-hongkong.aliyuncs.com/hugo/img/20190602180548.jpg?x-oss-process=style/250_250)