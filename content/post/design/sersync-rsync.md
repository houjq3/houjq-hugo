---
title: "sersync+rsync实现图片实时同步"
slug: "sersync-rsync"
date: 2020-04-09T23:34:48+08:00
categories:
- 架构设计
tags:
- sersync
- rsync
keywords:
- sersync
- rsync
thumbnailImagePosition: left
thumbnailImage: https://houjq.oss-cn-hongkong.aliyuncs.com/hugo/img/20200410000406.png
showSocial: false
draft: false
---

FTP推送图片，实时性差、不可靠的缺点，并且随着同步文件量增多，同步耗时变长；而短期内搞出一个分布式文件存储也不现实。

<!--more-->

确定采用sersync+rsync组件实现图片实时同步到资源服务器。

## 介绍

1. `sersync` 是基于 `inotify` 开发的，类似于 `inotify-tools` 的工具

2. `sersync` 可以记录下被监听目录中发生变化的（包括增加、删除、修改）具体某一个文件或者某一个目录的名字，然后使用rsync同步的时候，只同步发生变化的文件或者目录

## 优点

1. `sersync` 可以记录被监听目录中发生变化的（增，删，改）具体某个文件或目录的名字；

2. `rsync` 在同步时，只同步发生变化的文件或目录（每次发生变化的数据相对整个同步目录数据来说很小，rsync在遍历查找对比文件时，速度很快），因此效率很高。

## 部署架构

- 31部署 `sersync`
- 64~71为图片服务器，部署 `rsync`

![img](https://houjq.oss-cn-hongkong.aliyuncs.com/hugo/img/20200409233526.jpg)

## 安装配置

### sersync

1. 解压 `sersync2.5.4_64bit_binary_stable_final.tar.gz`

2. 修改 `confxml.xml`

{{<codeblock "confxml.xml" "xml" "http://underscorejs.org/#compact" "confxml.xml" >}}
<?xml version="1.0" encoding="ISO-8859-1"?>

<head version="2.5">
    <host hostip="x.x.x.31" port="9380"></host>
    <debug start="false"/>
    <fileSystem xfs="false"/>
    <filter start="false">
	<exclude expression="(.*)\.svn"></exclude>
	<exclude expression="(.*)\.gz"></exclude>
	<exclude expression="^info/*"></exclude>
	<exclude expression="^static/*"></exclude>
	<!-- 监控事件的过程中过滤特定文件，和特定文件夹的文件 -->
    </filter>
    <inotify>
	<delete start="true"/>
	<createFolder start="true"/>
	<createFile start="false"/>
	<closeWrite start="true"/>
	<moveFrom start="true"/>
	<moveTo start="true"/>
	<attrib start="false"/>
	<modify start="false"/>
	<!-- 设置要监控的事件 -->
    </inotify>
    <sersync>
    <localpath watch="/applications/mios-market-config-rest/material">
    <!-- 设置要监控的目录 -->
        <remote ip="x.x.x.64" name="market"/>
        <remote ip="x.x.x.65" name="market"/>
        <remote ip="x.x.x.66" name="market"/>
        <remote ip="x.x.x.67" name="market"/>
        <remote ip="x.x.x.68" name="market"/>
        <remote ip="x.x.x.69" name="market"/>
        <remote ip="x.x.x.70" name="market"/>
        <remote ip="x.x.x.71" name="market"/>
    	<!-- 指定远端rsync服务器的地址和模块名 -->
    </localpath>
    <rsync>
        <commonParams params="-artuz"/>
        <auth start="false" users="root" passwordfile="/etc/rsync.pas"/>
        <userDefinedPort start="true" port="9381"/><!-- port=874 -->
        <timeout start="false" time="100"/><!-- timeout=100 -->
        <ssh start="false"/>
    </rsync>
    <failLog path="/sersync/rsync_fail_log.sh" timeToExecute="60"/><!--default every 60mins execute once-->
    <crontab start="false" schedule="1440"><!--600mins-->
    <!-- 是否启用执行完整rsync，并指定执行周期 -->
        <crontabfilter start="false">
    	<!-- 设置完整执行rsync时的过滤条件 -->
        <exclude expression="*.php"></exclude>
        <exclude expression="info/*"></exclude>
        </crontabfilter>
    </crontab>
    <plugin start="false" name="command"/>
    <!-- 设置sersync传输后调用name指定的插件脚本，默认关闭 -->
    </sersync>

</head>
{{</codeblock>}}

3. 启动 `sersync`

```shell
$sersync_home/sersync2 -d -r -o $sersync_home/confxml.xml
```

### Rsync

1. 解压 `rsync-3.1.3.tar.gz`

2. 编译

```shell
./configure --prefix=/heapp/rsync 
make && make install
```

3. 修改 `rsyncd.conf`（免密配置）

{{<codeblock "rsyncd.conf" "apache.conf" "http://underscorejs.org/#compact" "rsyncd.conf" >}}
port = 9381
#uid = nobody
#gid = nobody
use chroot = no
hosts allow=*
#max connections = 0
pid file = /rsync/logs/rsyncd.pid
lock file = /rsync/logs/rsync.lock
log file = /rsync/logs/rsyncd.log

[market]
path = /imgServer/material
comment = market
read only = no
{{</codeblock>}}

4. 启动

```shell
$rsync_home/bin/rsync --daemon --config=$rsync_home/rsyncd.conf
```
