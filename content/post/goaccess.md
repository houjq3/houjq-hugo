---
title: "GoAccess"
slug: "goaccess"
date: 2019-06-21T09:16:16+08:00
categories:
- Nginx
tags:
- Nginx
- OpenResty
- GoAccess
keywords:
- Nginx
- OpenResty
- GoAccess
thumbnailImagePosition: left
thumbnailImage: http://psgf5bfka.bkt.clouddn.com/hugo/img/20190621093249.png
showSocial: false
draft: false
---

GoAccess 是一款开源的且具有交互视图界面的实时 Web 日志分析工具，通过你的 Web 浏览器或者 *nix 系统下的终端程序(terminal)即可访问。

能为系统管理员提供快速且有价值的 HTTP 统计，并以在线可视化服务器的方式呈现。

<!--more-->

## 依赖

```shell
yum install -y glib2 glib2-devel ncurses-devel zlib zlib-devel gcc
yum install -y GeoIP-update GeoIP-devel
yum install -y libmaxminddb libmaxminddb-devel
```

## 安装

将 `goaccess-1.3.tar.gz` 和 `GeoLite2-City.tar.gz` 上传到 `$HOME/openresty/goaccess` 目录下，并解压

```shell
tar zxvf $HOME/openresty/goaccess/goaccess-1.3.tar.gz
tar zxvf $HOME/openresty/goaccess/GeoLite2-City.tar.gz
```

复制 GeoLite2-City.mmdb 库到指定目录下

```shell
cp $HOME/openresty/goaccess/GeoLite2-City_20190618/GeoLite2-City.mmdb $HOME/openresty/goaccess
```

编译安装 goaccess

```shell
cd $HOME/openresty/goaccess/goaccess-1.3
```

```shell

./configure --prefix=$HOME/openresty/goaccess \
            --bindir=$HOME/openresty/main/bin \
            --enable-utf8 \
            --enable-geoip=mmdb \
            --with-openssl
```

```shell
make && make install
```

## log/date/time格式设置

使用开源脚本 `nginx2access.sh`，参数为 `nginx.conf` 的 `log_format`

```shell
sh nginx2goaccess.sh '$remote_addr|$time_local|$uri|$args|$status|$body_bytes_sent|$http_referer|$http_user_agent|$http_cookie|$content_length|$host|$request|$request_body|$http_x_forwarded_for|$upstream_addr|$upstream_response_time|$request_time'

- Generated goaccess config:
time-format %T
date-format %d/%b/%Y
log_format %h|%d:%t %^|%^|%^|%s|%b|%R|%u|%^|%^|%v|%r|%r_body|%^|%^|%^|%T
```

这里有个坑需要注意，生成的 goaccess config中，将 "`%r_body`" 替换为 ”`%^`“，最终结果为

```shell
time-format %T
date-format %d/%b/%Y
log_format %h|%d:%t %^|%^|%^|%s|%b|%R|%u|%^|%^|%v|%r|%r_body|%^|%^|%^|%T
```

## 启停脚本编写

```shell
vi goaccess.sh
```

```shell
#!/bin/bash
source ~/.bash_profile
if [[ -z "$1" ]]; then
    echo "Usage: $0 start|stop"
    exit 1
fi

export LANG=zh_CN.UTF-8
NGXDIR=$(cd `dirname $0`; cd ..; pwd)

if [ $1 = "start" ]; then
    PID=$(ps -ef | grep `cat $NGXDIR/logs/goaccess.pid`)
    if [ -n "$PID" ]; then
        echo " +-+-+-+-+-+-+-+-+ +-+-+ +-+-+-+-+-+-+-+ "
        echo " |g|o|a|c|c|e|s|s| |i|s| |s|t|a|r|t|e|d| "
        echo " +-+-+-+-+-+-+-+-+ +-+-+ +-+-+-+-+-+-+-+ "
    else
        $HOME/openresty/main/bin/goaccess \
        	--log-file=$NGXDIR/logs/access.log \
            --log-format='%h|%d:%t %^|%^|%^|%s|%b|%R|%u|%^|%^|%v|%r|%^|%^|%^|%^|%T' \
            --date-format='%d/%b/%Y' \
            --time-format='%T' \
            --no-global-config \
            --geoip-database=$HOME/openresty/goaccess/GeoLite2-City.mmdb \
            --real-time-html \
            --daemonize \
            --port=7890 \
            --pid-file=$NGXDIR/logs/goaccess.pid \
            --with-output-resolver \
            --agent-list \
            --output=$NGXDIR/html/goaccess.html
    fi   
elif [ $1 = "stop" ]; then
	kill -9 `cat $NGXDIR/logs/goaccess.pid`
    if [ $? -eq 0 ]; then
        echo " +-+-+-+ +-+-+-+-+-+-+-+-+ "
        echo " |b|y|e| |g|o|a|c|c|e|s|s| "
        echo " +-+-+-+ +-+-+-+-+-+-+-+-+ "
        exit 0
    fi
else
	echo "Usage: $0 start|stop"
	exit 1
fi
```

参数说明可使用 `goaccess -help`  或查询 [官网使用手册](https://goaccess.io/man#options)

## 启动goaccess

```
sh goaccess.sh start
```

访问 `http://安全网关管理节点/goaccess.html`，展示实时数据

![FireShot](http://psgf5bfka.bkt.clouddn.com/hugo/img/20190621092130.png)

## 指标汇总

- 所有已分析的请求
- 每日独立访客 - 包括网络机器人
- 请求的文件
- 静态请求
- 未找到的URLs
- 访客主机名和IP地址
- 操作系统
- 浏览器
- 时间分配
- 虚拟主机
- 来源地址URLs
- 推荐网站
- 谷歌搜索关键字
- HTTP状态码
- 地理位置