---
title: "利用Nginx搭建RTMP流媒体服务器"
slug: "nginx-rtpm"
date: 2020-04-09T22:15:12+08:00
categories:
- Nginx
tags:
- Nginx
- RTMP
keywords:
- Nginx
- RTMP
thumbnailImagePosition: left
thumbnailImage: https://houjq.oss-cn-hongkong.aliyuncs.com/hugo/img/20200409224656.png
showSocial: false
draft: false
---

将视频流实时上传给服务器进行解析，使用RTMP直播服务器。因此将搭建RTMP服务器的过程分享给大家。
<!--more-->

## 搭建RTMP流媒体服务器

### 准备

- openresty-1.13.6.1.tar.gz
- openssl-1.0.2k.tar.gz
- pcre-8.41.tar.gz
- zlib-1.2.11.tar.gz
- nginx-rtmp-module-1.2.1.tar.gz
- nginx_mod_h264_streaming-2.2.7.tar.gz

### 安装

1. 解压

2. 进入 `nginx_mod_h264_streaming-2.2.7/src` 目录，修改 `ngx_http_streaming_module.c`，注释掉

```c++
if (r->zero_in_uri)
{
return NGX_DECLINED;
}
```

这一段。否则会报错【ngx_http_streaming_module.c:158: 错误：’ngx_http_request_t’ 没有名为 ‘zero_in_uri’ 的成员】之类的错误。

3. 执行openresty安装命令

```shell
./configure --prefix=/data/cms/video/openresty/openresty11361 \
 --add-module=/data/cms/video/openresty/third/nginx-rtmp-module-1.2.1 \
 --add-module=/data/cms/video/openresty/third/nginx_mod_h264_streaming-2.2.7 \
 --with-pcre=/data/cms/video/openresty/setupfile/pcre-8.41 \
 --with-openssl=/data/cms/video/openresty/setupfile/openssl-1.0.2k \
 --with-zlib=/data/cms/video/openresty/setupfile/zlib-1.2.11 \
 --with-http_v2_module \
 --with-http_sub_module \
 --with-http_stub_status_module \
 --with-http_realip_module \
 --with-cc-opt=-O2 \
 --with-file-aio \
 --with-http_flv_module \
 --with-http_mp4_module \
 --with-luajit
```

4. 执行 `make && make install`

5. 执行 `bin/openresty` 启动

## 点播

### 准备

- jwplayer播放器
- 视频文件test.mp4

### nginx.conf配置

![](https://houjq.oss-cn-hongkong.aliyuncs.com/hugo/img/20200409222733.png)

### 资源上传

1. 将test.mp4上传到/data/cms/video/openresty/data目录下
2. 将jwplayer播放器上传到nginx/html目录下

### 播放器的设定

![img](https://houjq.oss-cn-hongkong.aliyuncs.com/hugo/img/20200409222947.png)

### 测试

打开浏览器，输入http://ip:51002 /demo1.html（需要允许FLASH插件）

![img](https://houjq.oss-cn-hongkong.aliyuncs.com/hugo/img/20200409222955.png)

## 直播

### 准备

- 第三方推流工具OBS
- jwplayer播放器

### nginx.conf配置

![img](https://houjq.oss-cn-hongkong.aliyuncs.com/hugo/img/20200409223004.png)

### OBS安装配置

关于OBS的介绍说明参见：https://help.aliyun.com/document_detail/45212.html

![img](https://houjq.oss-cn-hongkong.aliyuncs.com/hugo/img/20200409223048.png)

![img](https://houjq.oss-cn-hongkong.aliyuncs.com/hugo/img/20200409223059.png)

![img](https://houjq.oss-cn-hongkong.aliyuncs.com/hugo/img/20200409223121.png)

![img](https://houjq.oss-cn-hongkong.aliyuncs.com/hugo/img/20200409223127.png)

![img](https://houjq.oss-cn-hongkong.aliyuncs.com/hugo/img/20200409223137.png)

![img](https://houjq.oss-cn-hongkong.aliyuncs.com/hugo/img/20200409223143.png)

## 播放器的设定

![img](https://houjq.oss-cn-hongkong.aliyuncs.com/hugo/img/20200409223150.png)

## 测试

1. 推流（直播）

![img](https://houjq.oss-cn-hongkong.aliyuncs.com/hugo/img/20200409223154.png)

2. 拉流（观看）

![img](https://houjq.oss-cn-hongkong.aliyuncs.com/hugo/img/20200409223200.png)

#    回看

## 准备

- VLC media player（jwplayer不支持ts播放）
- 第三方推流工具OBS

## nginx.conf配置

![img](https://houjq.oss-cn-hongkong.aliyuncs.com/hugo/img/20200409223207.png)

## 测试

1. 打开OBS直播一段时间，`/data/cms/video/openresty/data/hls/123456` 将由出现一个 `index.m3u8` 和若干  `ts后缀的文件`

![img](https://houjq.oss-cn-hongkong.aliyuncs.com/hugo/img/20200409223213.png)

2. 打开VLC，在URL输入要回看的ts视频地址，点击播放

![img](https://houjq.oss-cn-hongkong.aliyuncs.com/hugo/img/20200409223217.png)

![img](https://houjq.oss-cn-hongkong.aliyuncs.com/hugo/img/20200409223224.png)