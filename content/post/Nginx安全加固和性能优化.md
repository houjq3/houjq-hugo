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

```nginx
#user  nobody;
worker_processes  auto;
## 最大不超过ulimit -n
#worker_rlimit_nofile 65535;

#error_log  logs/error.log  error;

#pid        logs/nginx.pid;;

events {
    multi_accept  on;
    ## 生产环境建议和worker_rlimit_nofile一样大
    worker_connections  1024;
}

http {
    include       mime.types;
    default_type  application/octet-stream;

    log_format  main  '$remote_addr|$time_local|$uri|$args|$status|$body_bytes_sent|'
                      '$http_referer|$http_user_agent|$http_cookie|$content_length|'
                      '$host|$request|$request_body|$http_x_forwarded_for|'
                      '$upstream_addr|$upstream_response_time|$request_time';
    
    access_log  logs/access.log  main;
	
    charset utf-8;
    tcp_nopush on;
    
    ## 通过关闭慢连接来抵御一些DDOS攻击
    # 设置客户端的响应超时时间
    send_timeout 3s;
    ## 超时时间之后会关闭这个连接
    keepalive_timeout 75s;
    ## 读取客户端请求体的超时时间
    client_body_timeout 10s; 
    ## 读取客户端请求头的超时时间
    client_header_timeout 10s;
    
    ## proxy开启对http1.1
    proxy_http_version 1.1;
    ## proxy模式的缓冲优化
    proxy_buffer_size 128k;
    proxy_buffers 4 256k;
    proxy_busy_buffers_size 256k;
    ## proxy模式的文件优化
    proxy_temp_file_write_size 256k;
    proxy_max_temp_file_size 128m;
    ## 在客户端停止响应之后,允许服务器关闭连接,释放socket关联的内存
    reset_timedout_connection on;
    
    ## 客户端请求的http头部缓冲区大小
    client_header_buffer_size 2k;
    ## 客户端请求的一些比较大的头文件到缓冲区的最大值
    large_client_header_buffers 4 4k; 
    ## ngx.req.get_body_data()读取不到求体？强制在内存中保存请求体
    client_body_buffer_size 10m;
    client_max_body_size 10m;

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
    #limit_req_status 403; 
    
    ## 开启gzip提高页面加载速度
    gzip  on;
    gzip_min_length   5k;
    gzip_buffers      16 64k;
    gzip_http_version 1.1;
    gzip_comp_level   6;
    gzip_types        text/plain application/javascript application/x-javascript text/css application/xml text/javascript application/x-httpd-php image/jpeg image/gif image/png application/vnd.ms-fontobject font/ttf font/opentype font/x-woff image/svg+xml;
    gzip_vary         on;
    gzip_disable      msie6;
    gzip_proxied      any;
    
    ## 本机全网段，白名单
    allow 10.209.197.0/24;
    ## 配置IP白名单
    include ip_list/ip_white.conf;
    ## 配置IP黑名单
    include ip_list/ip_black.conf;
    
    ## 引入Naxsi核心规则库
    include naxsi/naxsi_core.rules;
    ## 引入Naxsi自定义规则
    include naxsi/naxsi_main.rules;
    ## 引入Naxsi规则白名单
    include naxsi/naxsi_white.rules;
            
    upstream nodes {
        server 10.209.197.10:8080;
    }
    
    server {
        server_name localhost;
        listen 80;
        #listen 443 ssl;
        
        ## 要让https和http并存，不能在配置文件中使用ssl on;
        #ssl on; 
        #ssl_certificate   cert/a.pem;
        #ssl_certificate_key  cert/a.key;
        #ssl_session_timeout 5m;
        #ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE:ECDH:AES:HIGH:!NULL:!aNULL:!MD5:!ADH:!RC4;
        #ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
        #ssl_prefer_server_ciphers on;
        
        ## 隐藏版本号
        server_tokens  off;       
        ## 清除不安全的HTTP响应头
        more_clear_headers “X-Powered-By”;
        more_clear_headers “Server”;
        more_clear_headers “ETag”;
        more_clear_headers “Connection”;
        more_clear_headers “Date”;
        more_clear_headers “Accept-Ranges”;
        more_clear_headers “Last-Modified”;

        ## 避免点击劫持
        add_header X-Frame-Options "SAMEORIGIN"; 
        ## 防XSS攻击
        add_header X-XSS-Protection "1; mode=block";    
        ## 禁止嗅探文件类型，特别注意Web应用没有返回Content-Type，
        ## 那么IE9、IE11将拒绝加载相关资源（图形验证码）
        #add_header X-Content-Type-Options nosniff;
        add_header Strict-Transport-Security "max-age=31536000; includeSubDomains";            
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
        if ( $host !~* 'houjq.com' ) {
            rewrite ^/(.*)$ http://houjq.com/$1 permanent;
        }
        
        root /html;
        index index.html;
        
        ## 静态资源
        location ~* \.(js|css|flash|media|jpg|png|gif|dll|cab|CAB|ico|vbs|json|ttf|woff|eot|map)$ {
            # 缓存30天
            add_header Cache-Control "max-age=2592000";
        }
		
        ## 静态页面
        location ~* \.html$ {
            # 不缓存
            add_header Cache-Control "no-cache";
        }
        
        location / {
            ## 最多5个排队，由于每秒处理10个请求+5个排队
            ## 你一秒最多发送15个请求过来，再多就直接返回错误给你了
            limit_req zone=ConnLimitZone burst=5 nodelay;
            
            ## 定义Naxsi规则
            include naxsi/check_rule.rules;
            
            ## 反向代理
            proxy_set_header Host $host:$server_port;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_pass http://nodes;  
        }
		
        ## Naxsi拒绝访问
        location /RequestDenied {
            return 403;
        }
        
        ## 性能统计
        location /nginx_status {
            ## 只允许内网访问
            internal;
            stub_status on;    
            access_log off;  
        }
        
        ## 拒绝所有爬虫（影响SEO，慎用）
        #location /robots.txt {
        #    return 200 'User-agent: *\nDisallow: /';
        #}
        
        ## 当只允许https访问时，当用http访问时nginx会报出497错误码
        #error_page 497  https:/www.houjq.com$request_uri;
        error_page  500 502 503 504  /50x.html;

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



> **Naxsi自定义规则 naxsi_main.rules**

```nginx
# 拦截参数中有冒号":"的GET请求，规则id为1316（不要和naxsi_core.rule中的id重复）
MainRule id:1316 s:DROP str:: "mz:ARGS";
```

*参考：<https://github.com/nbs-system/naxsi/wiki/rules-bnf>* 



> **Naxsi规则白名单 naxsi_white.rules**

```nginx
# 针对/bar的URL的参数：
MainRule wl:1000 "mz:$URL:/bar|ARGS";
# 针对以/foo开头的参数的配置白名单
MainRule wl:1000 "mz:$URL_X:^/foo|ARGS";
```

*参考：<https://github.com/nbs-system/naxsi/wiki/whitelists-bnf>*



> **Naxsi规则校验 naxsi_check.rules**

```nginx
#LearningMode;
SecRulesEnabled;
DeniedUrl "/RequestDenied";
CheckRule "$SQL >= 8" BLOCK;
CheckRule "$RFI >= 8" BLOCK;
CheckRule "$TRAVERSAL >= 4" BLOCK;
CheckRule "$XSS >= 8" BLOCK;
```

*参考：<https://github.com/nbs-system/naxsi/wiki/checkrules-bnf>*



![](/pay.jpg)