---
title: "Spring"
date: 2018-07-20T15:17:16+08:00
draft: true
---



```
@MapperScan 对resteasy无效
```



```
context-path: /sdk/log ##  /中心/服务
```


```
mvn package 执行 mybatis-generator-maven-plugin
```
https://github.com/yangtao309/zuul-route-jdbc-spring-cloud-starter

https://github.com/zuihou/zuihou-admin-cloud



http://cloud.spring.io/spring-cloud-static/Finchley.RELEASE/single/spring-cloud.html







建议放到 `top-boot-starter-pebcore`

```
<dependency>
    <groupId>log4j</groupId>
    <artifactId>log4j</artifactId>
    <version>1.2.16</version>
</dependency>
<dependency>
    <groupId>org.glassfish</groupId>
    <artifactId>javax.json</artifactId>
    <version>1.0.4</version>
</dependency>
```



zuul 限流demo

https://github.com/marcosbarbero/spring-cloud-zuul-ratelimit



回退 fallback

```
{
   "result": null,
   "retCode": "503",
   "retMsg": "Service Unavailable",
   "detail_msg": "Load balancer does not have available server for client: user-springmvc-microservice",
   "user_msg": null,
   "prompt_msg": null,
   "object": null,
   "list": null,
   "uuid": null,
   "optTime": 0,
   "sOperTime": null,
   "result4Boolean": false
}
```

```
{
   "result": null,
   "retCode": "404",
   "retMsg": "Not Found",
   "detail_msg": "No message available",
   "user_msg": null,
   "prompt_msg": null,
   "object": null,
   "list": null,
   "uuid": null,
   "optTime": 0,
   "sOperTime": null,
   "result4Boolean": false
}
```



暴露端口

```
management:
  endpoints:
    web:
      exposure:
        include: ["health", "info", "routes", "filters"]
```





|      |              |          |                        |       |      |
| :--: | :----------: | -------- | :--------------------- | :---: | :--: |
|  1   | 基础服务搭建 | 网关搭建 | 通用权限校验过滤器     | houjq |      |
|  2   | 基础服务搭建 | 网关搭建 | 日志记录               | houjq |      |
|  3   | 基础服务搭建 | 网关搭建 | 登录及校验             | houjq |      |
|  4   | 基础服务搭建 | 网关搭建 | 断路fallback           | houjq | 完成 |
|  5   | 基础服务搭建 | 网关搭建 | 限流                   | houjq |      |
|  6   | 基础服务搭建 | 网关搭建 | jdbc动态路由           | houjq | 完成 |
|  7   | 基础服务搭建 | 网关搭建 | Cookie和敏感header处理 | houjq | 完成 |
|  8   | 基础服务搭建 | 网关搭建 | 字符编码处理过滤器     | houjq | 完成 |



### 学习资料

Spring Boot 2.0正式发布，新特性解读：

http://www.infoq.com/cn/articles/spring-boot-2.0-new-feature?utm_source=infoq&utm_medium=popular_widget&utm_campaign=popular_content_list&utm_content=homepage



翟永超博客：

http://blog.didispace.com/



小马哥spring boot和spring cloud系列 

链接：https://pan.baidu.com/s/1tXEt8HLZ-qUTmLsg9ES1jA 密码：c6u5 



官方在线文档：

http://cloud.spring.io/spring-cloud-static/Finchley.RELEASE/single/spring-cloud.html



SpringBoot2.x课程全套介绍和高手系列知识点

http://edu.51cto.com/center/course/lesson/index?id=264846