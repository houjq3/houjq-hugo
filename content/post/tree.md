---
title: "Tree"
date: 2018-07-18T08:45:35+08:00
categories:
- category
- subcategory
tags:
- tag1
- tag2
keywords:
- tech
#thumbnailImage: //example.com/image.jpg
draft: true
---

<!--more-->



```
D:\idea
│  idea-start.bat				// 启动脚本
│  
├─ideaIU-2018.1.5.win			// idea主目录
└─IntelliJIDEALicenseServer		// 远程服务器授权主目录
```



idea-start.bat 命令

```bash
@echo off
start /b "LicenseServer" "%~dp0IntelliJIDEALicenseServer\IntelliJIDEALicenseServer_windows_amd64.exe" -p 1017
start /b "natapp" "%~dp0IntelliJIDEALicenseServer\natapp.exe"
start "idea" "%~dp0ideaIU-2018.1.5.win\bin\idea64.exe"
```

