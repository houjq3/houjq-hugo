---
title: "Siege"
slug: siege
date: 2018-07-23T17:21:26+08:00
categories:
- test
tags:
- 测试工具
- Siege
keywords:
- 测试工具
- Siege
thumbnailImagePosition: left
thumbnailImage: /thumbnail/201807/dog.png
showSocial: false
draft: false
---
​	Siege是一个压力测试和评测工具，设计用于WEB开发这评估应用在压力下的承受能力。
<!--more-->

​	可以根据配置对一个WEB站点进行多用户的并发访问，记录每个用户所有请求过程的相应时间，并在一定数量的并发访问下重复进行。

### 下载地址 ###

[http://www.joedog.org/pub/siege/](http://www.joedog.org/pub/siege/)



### 安装 ###

./configure --prefix=/netapp/siege

make

make install



### 新增配置文件 ###

[netapp@kf-35 bin]$ vi test.url

```markdown
http://172.21.2.67:9004/main/index.action   #可以增加多个url地址的测试
```

 

### 测试方法 ###

`siege -c 20 -r 2 -f test.url`



#### 参数说明

*-c 20 并发20个用户*

*-r 2 重复循环2次*

*-f test.url 任务列表：URL列表*

如：

```bash
./siege -c 500 -r 20 -f test.url
./siege -c 500 -r 20 -f test.url
./siege -c 500 -t 3M -f test.url #并发500测试3分钟
```

 

### **参数介绍**

```
-C,或–config 在屏幕上打印显示出当前的配置,配置是包括在他的配置文件$HOME/.siegerc中,可以编辑里面的参数,这样每次siege 都会按照它运行.
-v 运行时能看到详细的运行信息
-c n,或–concurrent=n 模拟有n个用户在同时访问,n不要设得太大,因为越大,siege 消耗本地机器的资源越多
-i,–internet 随机访问urls.txt中的url列表项,以此模拟真实的访问情况(随机性),当urls.txt存在是有效
-d n,–delay=n hit每个url之间的延迟,在0-n之间
-r n,–reps=n 重复运行测试n次,不能与 -t同时存在
-t n,–time=n 持续运行siege ‘n’秒(如10S),分钟(10M),小时(10H)
-l 运行结束,将统计数据保存到日志文件中siege .log,一般位于/usr/local/var/siege .log中,也可在.siegerc中自定义
-R SIEGERC,–rc=SIEGERC 指定用特定的siege 配置文件来运行,默认的为$HOME/.siegerc
-f FILE, –file=FILE 指定用特定的urls文件运行siege ,默认为urls.txt,位于siege 安装目录下的etc/urls.txt
-u URL,–url=URL 测试指定的一个URL,对它进行”siege “,此选项会忽略有关urls文件的设定
```

  

### **结果说明**

```
** SIEGE 2.72
** Preparing 300 concurrent users for battle.
The server is now under siege.. done.
 
Transactions: 30000 hits //完成30000次处理
Availability: 100.00 % //100.00 % 成功率
Elapsed time: 68.59 secs //总共使用时间
Data transferred: 817.76 MB //共数据传输 817.76 MB
Response time: 0.04 secs //响应时间，显示网络连接的速度
Transaction rate: 437.38 trans/sec //平均每秒完成 437.38 次处理
Throughput: 11.92 MB/sec //平均每秒传送数据
Concurrency: 17.53 //实际最高并发连接数
Successful transactions: 30000 //成功处理次数
Failed transactions: 0 //失败处理次数
Longest transaction: 3.12 //每次传输所花最长时间
Shortest transaction: 0.00 //每次传输所花最短时间
```

