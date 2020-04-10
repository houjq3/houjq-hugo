---
title: "Chrome插件EditThisCookie"
slug: "edit-this-cookie"
date: 2020-04-10T15:03:56+08:00
categories:
- 工具
tags:
- Chrome
- EditThisCookie
keywords:
- Chrome
- EditThisCookie
- 插件
thumbnailImagePosition: left
thumbnailImage: https://houjq.oss-cn-hongkong.aliyuncs.com/hugo/img/20200410151511.png
showSocial: false
draft: false
---
EditThisCookie作为Chrome的一个插件，可以十分方便的用来查看当前域的Cookie以及实时编辑Cookie。在调试网页甚至测试网站验证连接十分有用。
<!--more-->

下面说一下如何使用edit this cookie，编辑以及操作cookie。

## 下载安装

- 可以翻墙的同事登陆Chrome浏览器的网上商城，搜索 `EditThisCookie` 下载安装
- 也可以下载附件，并将其拖入Chrome浏览器安装。

## 操作手册

1. 当安装完成后，在你的浏览器的右上角会出现一个甜饼的图标
2. 左击它可以显示当前所在页面的cookie列表
3. 当然最简单的就是在你要调试cookie的页面，右击选项菜单EditThisCookie，即可打开cookie编辑页面
 ![image-20200410150716616](https://houjq.oss-cn-hongkong.aliyuncs.com/hugo/img/20200410150720.png)

4. 点击进入editthiscookie 编辑cookie页面后。如图所示：

5. 点击最上面的垃圾箱，可以删除全部的cookie。

6. 点击一个cookie后，可以进行单个cookie的删除，内容一般都可以修改，可以修改cookie的名称
![image-20200410150735481](https://houjq.oss-cn-hongkong.aliyuncs.com/hugo/img/20200410150736.png)

### 新建cookie

在EditThisCookie管理cookie页面。点击 +：然后填写相关信息即可创建一个新的cookie
![image-20200410150752666](https://houjq.oss-cn-hongkong.aliyuncs.com/hugo/img/20200410150802.png)

### 阻止Cookie

点击进入一个cookie后，点击禁止符号：然后根据条件填写过滤条件,设置后，点击添加规则即可。那么之后这个cookie不回再被这个页面“引用”。
![image-20200410150820755](https://houjq.oss-cn-hongkong.aliyuncs.com/hugo/img/20200410150822.png)

### 恢复Cookie

点击EditThisCookie 右上面的扳手设置符号。

![image-20200410150835992](https://houjq.oss-cn-hongkong.aliyuncs.com/hugo/img/20200410150837.png)

![image-20200410150844195](https://houjq.oss-cn-hongkong.aliyuncs.com/hugo/img/20200410150845.png)

### 导入和导出cookie

如果想保留cookie，那么可以在EditThisCookie页面选择导入和导出

> 注意：格式为Json 格式。

 ![image-20200410150915242](https://houjq.oss-cn-hongkong.aliyuncs.com/hugo/img/20200410150916.png)

### 其他选项

在EditThisCookie的选项中可以详细查看，以上几个是最常用的。

## 总结

最近在进行lua_nginx开发时，通过lua-resty-cookie操作cookie时，利用EditThisCookie获取和设置cookie确实非常方便。此插件可以说的上是，前端看了流泪，测试看了沉默——对于前端来说，可以进行cookie模拟（如登陆），方面开发调试；对于测试来说，可以通过修改cookie进行黑盒测试。