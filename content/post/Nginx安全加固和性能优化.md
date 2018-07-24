---
title: Nginx安全加固和性能优化
slug: nginx-optimize
date: 2018-07-06T21:43:31+08:00
categories:
- Nginx
tags:
- Nginx
- 安全加固
- 性能优化
- OpenResty
keywords:
- Nginx
- 安全加固
- 性能优化
- OpenResty
thumbnailImagePosition: left
thumbnailImage: /thumbnail/201807/nginx.jpg
showSocial: false
draft: false
---
本文的主要目是介绍如何通过优化 Nginx 配置，提高 Nginx Web 服务器的安全性和用户访问效率。 
<!--more-->

#### nginx.conf 

```

http {
    ## 用户的IP地址$binary_remote_addr作为Key
    limit_conn_zone $binary_remote_addr zone=TotalConnLimitZone:10m ;
    ## 每个IP地址最多有50个并发，连接超过50个连接直接返回错误
    limit_conn TotalConnLimitZone 50;
   
    ## 用户的IP 地址$binary_remote_addr作为Key，每个IP地址每秒处理10个请求
    ## 你想用程序每秒几百次的刷我，没戏，再快了就不处理了，直接返回错误给你
    limit_req_zone $binary_remote_addr zone=ConnLimitZone:10m rate=10r/s;
    
    ## 当服务器因为频率过高拒绝或者延迟处理请求时可以记下相应级别的日志。 
    ## 延迟记录的日志级别比拒绝的低一个级别，默认error
    #limit_req_log_level notice;
    ## 拒绝请求的响应状态码，默认503
    #limit_req_status 555; 
    
    ## 通过关闭慢连接来抵御一些DDOS攻击
    ## 读取客户端请求的超时时间
    client_body_timeout 10s;
    ## 读取客户端请求头的超时时间
    client_header_timeout 10s;
    ## ngx.req.get_body_data()读取不到求体？强制在内存中保存请求体
    client_body_buffer_size 10m;
    client_max_body_size 10m;
    ## 客户端请求的http头部缓冲区大小
    client_header_buffer_size 16k;
    ## 客户端请求的一些比较大的头文件到缓冲区的最大值
    large_client_header_buffers 4 16k;
    
    ## 本机全网段，白名单
    allow 10.209.197.0/24;
    ## 配置IP白名单
    include ip_list/ip_white.conf;
    ## 配置IP黑名单
    include ip_list/ip_black.conf;
    
    ## 引入Naxsi核心规则库
    include naxsi/naxsi_core.rules;
    ## 引入Naxsi自定义规则库
    include naxsi/main_rule.rules;
    
    upstream proxy {
        server 10.209.197.10:8080;
    }
    
    server {
        ## 清除HTTP响应头Server字段
        more_clear_headers 'Server';
        ## 避免点击劫持
        add_header X-Frame-Options "SAMEORIGIN"; 
        ## 防XSS攻击
        add_header X-XSS-Protection "1; mode=block";    
        ## 禁止嗅探文件类型，特别注意Web应用没有返回Content-Type，
        ## 那么IE9、IE11将拒绝加载相关资源（图形验证码）
        add_header X-Content-Type-Options nosniff;
        ## 修复不安全策略缓存控制
        add_header Cache-Control no-store;
        ## 禁掉Last-Modified，有ETag就够了
        add_header Last-Modified "";
        
        ## 获取真实IP
        set_real_ip_from 10.209.197.0/24;
        set_real_ip_from 127.0.0.1;
        real_ip_header X-Forwarded-For;
        real_ip_recursive on;
        
        ## 禁用不安全的HTTP方法
        if ($request_method !~ ^(GET|HEAD|POST)$ ) {
            return 405;
        }
        ## 修复http头攻击漏洞
        if ( $host != 'houjq.com' ) {
            rewrite ^/(.*)$ http://houjq.com/$1 permanent;
        }
        
        root /html;
        index index.html;
        
        ## 静态资源
        location ~* \.(js|css|flash|media|jpg|png|gif|dll|cab|CAB|ico|vbs|json|ttf|woff|eot)$ {
            expires  30d;
        }
		
        ## 静态页面
        location ~* \.html$ {
            expires  1s;
        }
        
        location / {
            ## 最多5个排队，由于每秒处理10个请求+5个排队
            ## 你一秒最多发送15个请求过来，再多就直接返回错误给你了
            limit_req zone=ConnLimitZone burst=5 nodelay;
            
            ## 定义Naxsi规则白名单
            include naxsi/white_rule.rules;
            ## 定义Naxsi规则
            include naxsi/check_rule.rules;
            
            ## 反向代理
            proxy_intercept_errors on;
            proxy_connect_timeout 60s;
            proxy_send_timeout 90s;
            proxy_read_timeout 120s;
            proxy_buffer_size 256k;
            proxy_buffers 4 256k;
            proxy_busy_buffers_size 256k;
            proxy_temp_file_write_size 256k;
            proxy_max_temp_file_size 128m;		
            proxy_next_upstream error timeout invalid_header http_500 http_503 http_404;
            proxy_http_version 1.1;
            proxy_redirect off;
            proxy_set_header Host $host:$server_port;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Frame-Options SAMEORIGIN;
            proxy_pass http://proxy;  
        }
        
        ## Naxsi拒绝访问
        location /RequestDenied {
            return 403;
        }
        
        ## 性能统计
        location /nginx_status {
            ## 只允许同网段内网访问
            allow 10.209.197.0/24;
            deny all;
            stub_status on;    
            access_log off;  
        }

    }
    
} 
```



> **IP白名单配置 ip_white.conf**

```nginx
allow 127.0.0.0/24;
allow 10.209.0.0/16;
```



> **IP黑名单配置 ip_black.conf**

```nginx
deny  192.168.1.1;
deny  all;
```



> **Naxsi自定义规则 main_rule.rules**

```nginx
# 拦截参数中有冒号":"的GET请求，规则id为1316（不要和naxsi_core.rule中的id重复）
MainRule id:1316 s:DROP str:: "mz:ARGS";
```

*参考：<https://github.com/nbs-system/naxsi/wiki/rules-bnf>* 



> **Naxsi白名单配置 white_rule.rules**

```nginx
# 针对/bar的URL的参数：
BasicRule wl:1000 "mz:$URL:/bar|ARGS";
# 针对以/foo开头的参数的配置白名单
BasicRule wl:1000 "mz:$URL_X:^/foo|ARGS";
```

*参考：<https://github.com/nbs-system/naxsi/wiki/whitelists-examples>*



![](/pay.jpg)