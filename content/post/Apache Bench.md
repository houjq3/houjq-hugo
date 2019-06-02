---
title: "Apache Bench"
slug: ab
date: 2018-07-23T15:11:49+08:00
categories:
- test
tags:
- 测试工具
- Apache Bench
- ab
keywords:
- 测试工具
- Apache Bench
- ab
thumbnailImagePosition: left
thumbnailImage: /thumbnail/201807/SupportApache-small.png
showSocial: false
draft: false
---
​	ab是一种用于测试Apache超文本传输协议（HTTP）服务器的工具。
<!--more-->

​	apache自带ab工具，可以测试apache、IIs、tomcat、nginx等服务器。但是ab没有Jmeter、Loadrunner那样有各种场景设计、各种图形报告和监控，只需一个命令即可，有输出描述，可以简单的进行一些压力测试。

## 1.1 基本用法

ab -n 全部请求数 -c 并发数测试url，例:

```
ab -n 1000 -c 50 <http://www.newdev.gztest.com/>
```

这个命令的意思是启动ab，向http://www.newdev.gztest.com发送1000个请求(-n 1000) ，并每次发送10个请求(-c 50) ------也就是说一次都发过去了。![](/assets/img01.jpg)

## 1.2 结果分析

```markdown
Server Software:         Microsoft-IIS/7.0
Server Hostname:        www.newdev.gztest.com
Server Port:            80
Document Length:        82522 bytes  #请求文档大小

Concurrency Level:      50           #并发数  
Time taken for tests:   92.76140 seconds #全部请求完成耗时
Complete requests:      10000          #全部请求数
Failed requests:        1974           #失败的请求
  (Connect: 0。 Length: 1974。 Exceptions: 0)
Write errors:           0
Total transferred:      827019400 bytes   #总传输大小 
HTML transferred:       825219400 bytes //整个场景中的HTML内容传输量
Requests per second:    108.61 [#/sec] (mean)   #每秒请求数(平均)//大家最关心的指标之一，相当于 LR 中的每秒事务数，后面括号中的 mean 表示这是一个平均值
Time per request:       460.381 [ms] (mean)   #每次并发请求时间(所有并发) //大家最关心的指标之二，相当于 LR 中的平均事务响应时间，后面括号中的 mean 表示这是一个平均值
Time per request:       9.208 [ms] (mean。 across all concurrent requests)   #每一请求时间(并发平均)  //每个请求实际运行时间的平均值
Transfer rate:          8771.39 [Kbytes/sec] received    #传输速率//平均每秒网络上的流量，可以帮助排除是否存在网络流量过大导致响应时间延长的问题
Percentage of the requests served within a certain time (ms)
  50%   2680
  66%   2806
  75%   2889
  80%   2996
  90%  11064
  95%  20161
  98%  21092
  99%  21417
 100%  21483 (longest request)
//整个场景中所有请求的响应情况。在场景中每个请求都有一个响应时间，其中50％的用户响应时间小于2680毫秒，60％的用户响应时间小于2806毫秒，最大的响应时间小于21417毫秒 
由于对于并发请求，cpu实际上并不是同时处理的，而是按照每个请求获得的时间片逐个轮转处理的，所以基本上第一个Time per request时间约等于第二个Time per request时间乘以并发请求数。

Connection Times (ms)    #连接时间
             	     min  mean[+/-sd] median   max
Connect(#连接):        0    0   2.1      0      46
Processing(#处理):    31  458  94.7    438    1078
Waiting(#等待):       15  437  87.5    422     938
Total:         	     31  458  94.7    438    1078

```



## 1.3 其它参数

```markdown
-n requests     全部请求数
-c concurrency  并发数
-t timelimit    最传等待回应时间
-p postfile     POST数据文件
-T content-type POST Content-type
-v verbosity    How much troubleshooting info to print
-w              Print out results in HTML tables
-i              Use HEAD instead of GET
-x attributes   String to insert as table attributes
-y attributes   String to insert as tr attributes
-z attributes   String to insert as td or th attributes
-C attribute    加入cookie， eg. 'Apache=1234. (repeatable)
-H attribute    加入http头， eg. 'Accept-Encoding: gzip'
                Inserted after all normal header lines. (repeatable)
-A attribute    http验证，分隔传递用户名及密码
-P attribute    Add Basic Proxy Authentication， the attributes
                are a colon separated username and password.
-X proxy:port   代理服务器
-V              查看ab版本
-k              Use HTTP KeepAlive feature
-d              Do not show percentiles served table.
-S              Do not show confidence estimators and warnings.
-g filename     Output collected data to gnuplot format file.
-e filename     Output CSV file with percentages served
-h              Display usage information (this message)
```

## 1.4 例子

### 1.4.1 压测方法

可以用1000个请求为前提，分别并发1、5、10、20、50、100、1000等压测。

ab -n1000 -c1 http://10.255.254.11:7777/i/v1/res/numarea/13546321414

| **并发用户数** | **吞吐率(req/s)** | **请求等待时间(ms)** | **请求处理时间(ms)** | **请求带宽(Kbytes/sec)** |
| :------------: | :---------------: | :------------------: | :------------------: | :----------------------: |
|       1        |      306.81       |        3.259         |        3.259         |          175.58          |
|       2        |      632.14       |        3.164         |        1.582         |          361.75          |
|       5        |      1742.08      |         2.87         |        0.574         |          996.94          |
|       10       |      2339.47      |        4.274         |        0.427         |          1338.8          |
|       20       |      4684.92      |        4.269         |        0.213         |         2681.02          |
|       50       |      5852.98      |        8.543         |        0.171         |         3349.46          |
|      100       |      4673.6       |        21.397        |        0.214         |         2674.54          |
|      150       |      4502.31      |        33.316        |        0.222         |         2576.52          |
|      200       |      3956.98      |        50.544        |        0.253         |         2266.71          |
|      500       |      3691.18      |       135.458        |        0.271         |         2112.34          |
|      800       |      1558.03      |        513.47        |        0.642         |          891.61          |
|      1000      |       990.4       |       1009.689       |         1.01         |          566.77          |



### 1.4.2 结果如下

```
ab -c 10000 -n 10000 http://localhost:8701/i/gray/test/v1/pay/test
```

```markdown
Server Software:        TongWeb
Server Hostname:        localhost
Server Port:            8701

Document Path:          /i/gray/test/v1/pay/test
Document Length:        0 bytes

Concurrency Level:      10000
Time taken for tests:   3.533 seconds
Complete requests:      10000
Failed requests:        9128
   (Connect: 0， Receive: 0， Length: 4279， Exceptions: 4849)
Write errors:           0
Total transferred:      1664818 bytes
HTML transferred:       642637 bytes
Requests per second:    2830.42 [#/sec] (mean)
Time per request:       3533.040 [ms] (mean)
Time per request:       0.353 [ms] (mean， across all concurrent requests)
Transfer rate:          460.17 [Kbytes/sec] received

Connection Times (ms)
              min  mean[+/-sd] median   max
Connect:        0  725 890.9    295    3005
Processing:     0  805 904.0    300    3020
Waiting:        0  668 933.8      0    3013
Total:         10 1530 1024.1   1264    3314

Percentage of the requests served within a certain time (ms)
  50%   1264
  66%   2016
  75%   2483
  80%   2816
  90%   3020
  95%   3058
  98%   3219
  99%   3241
 100%   3314 (longest request)
```

![](/pay.jpg)