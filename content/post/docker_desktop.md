---
title: "Windows10家庭版安装Docker Desktop"
slug: "Docker_desktop"
date: 2019-07-26T16:08:27+08:00
categories:
- Docker
tags:
- Docker
- windows
keywords:
- Windows10家庭版
- Docker
- Docker Desktop
thumbnailImagePosition: left
thumbnailImage: https://houjq.oss-cn-hongkong.aliyuncs.com/hugo/img/20190726161257.png
showSocial: false
draft: false
---

现在大部分笔记本预装的都是win10家庭版，而家庭版又不支持Hyper-V，Docker Desktop是无法直接安装的，其实家庭版是可以通过脚本开启Hyper-V来安装Docker Desktop的。

<!--more-->

现在大部分笔记本预装的都是win10家庭版，而家庭版又不支持Hyper-V，Docker Desktop是无法直接安装的，其实家庭版是可以通过脚本开启Hyper-V来安装Docker Desktop的。下面就教大家如何操作。

### 开启Hyper-V

添加方法非常简单，把以下内容保存为.cmd文件，然后以管理员身份打开这个文件。提示重启时保存好文件重启吧，重启完成就能使用功能完整的Hyper-V了。

```bash
pushd "%~dp0"

dir /b %SystemRoot%\servicing\Packages\*Hyper-V*.mum >hyper-v.txt

for /f %%i in ('findstr /i . hyper-v.txt 2^>nul') do dism /online /norestart /add-package:"%SystemRoot%\servicing\Packages\%%i"

del hyper-v.txt

Dism /online /enable-feature /featurename:Microsoft-Hyper-V-All /LimitAccess /ALL
```

### 伪装成专业版绕过安装检测

如图，由于Docker Desktop会在安装的时候检测系统版本，直接安装会显示安装失败。所以需要改下注册表绕过安装检测。

![img](https://houjq.oss-cn-hongkong.aliyuncs.com/hugo/img/20190726160708.png)

直接安装会报错

打开注册表，定位到计算机 `\HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion` ，点击current version，在右侧找到EditionId，右键点击EditionId 选择“修改“，在弹出的对话框中将第二项”数值数据“的内容改为Professional，然后点击确定

![img](https://houjq.oss-cn-hongkong.aliyuncs.com/hugo/img/20190726155811.png)

### 其他事项

在 [官网下载](<https://www.docker.com/products/docker-desktop>) docker-ce-desktop-windows后直接安装，安装时取消勾选window容器。经过测试，linux容器运行正常，切换到windows容器会检测windows版本而无法启动。不过一般也不会用到windows容器。

![img](https://houjq.oss-cn-hongkong.aliyuncs.com/hugo/img/20190726160128.png)

切换windows容器报错



本人安装硬件规格、系统版本与docker版本

![1564126716794](https://houjq.oss-cn-hongkong.aliyuncs.com/hugo/img/20190726155341.png)

