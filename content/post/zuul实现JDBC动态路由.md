---
title: "Zuul实现JDBC动态路由"
slug: "zuul-jdbc"
date: 2018-08-16T12:18:24+08:00
categories:
- spring cloud
- zuul
tags:
- spring cloud
- zuul
keywords:
- spring cloud
- zuul
- jdbc
- 动态路由
thumbnailImagePosition: left
thumbnailImage: https://houjq.oss-cn-hongkong.aliyuncs.com/hugo/img/20190602175908.jpg
showSocial: false
draft: false
---

Zuul 是Netflix 提供的一个开源组件,致力于在云平台上提供动态路由，监控，弹性，安全等边缘服务的框架。 
<!--more-->

# zuul实现JDBC动态路由

Zuul 是Netflix 提供的一个开源组件,致力于在云平台上提供动态路由，监控，弹性，安全等边缘服务的框架。 

## 动态路由

动态路由需要达到可持久化配置，动态刷新的效果。如架构图所示，不仅要能满足从spring的配置文件properties加载路由信息，**还需要从数据库加载我们的配置**。另外一点是，路由信息在容器启动时就已经加载进入了内存，我们希望配置完成后，实施发布，动态刷新内存中的路由信息，达到不停机维护路由信息的效果。

## 使用说明

### Maven依赖

对应的spring cloud版本需要使用 `Finchley.RELEASE`，maven依赖

```xml
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-netflix-zuul</artifactId>
    <exclusions>
        <exclusion>
            <artifactId>guava</artifactId>
            <groupId>com.google.guava</groupId>
        </exclusion>
        <exclusion>
            <artifactId>HdrHistogram</artifactId>
            <groupId>org.hdrhistogram</groupId>
        </exclusion>
    </exclusions>
</dependency>
```

### 启动类

```java
@EnableZuulProxyStore // 用 @EnableZuulProxyStore 替换 @EnableZuulProxy
@SpringCloudApplication
@EnableFeignClients
@EnableSwagger2
public class TopCloudGatewayApplication
```

### application.yml

```yaml
spring:
  application:
    name: top-cloud-gateway
  datasource:
    url: jdbc:mysql://127.0.0.1:3306/hotel?useUnicode=true&characterEncoding=utf-8
    username: root
    password: root
    driver-class-name: com.mysql.jdbc.Driver
    type: org.apache.commons.dbcp.BasicDataSource
zuul:
  ignored-services: '*'
  ignored-headers: Cookie, Set-Cookie, Authorization, Header1
  sensitive-headers: Pragma, Cache-Control, X-Frame-Options, X-Content-Type-Options, X-XSS-Protection, Expires
  prefix: /sitech-api # 为zuul设置一个公共的前缀
  store:
    jdbc:
      enabled: true # 是否开启jdbc动态路由
      table: gateway_api_define # 默认表名
  routes:
    exs2:
      path: /exs2/**
      service-id: exs2
    books:
      path: /book/**
      url: http://localhost:8090
```

### 建表

```sql
CREATE TABLE `gateway_api_define` (
  `id` varchar(50) NOT NULL,
  `path` varchar(255) NOT NULL,
  `service_id` varchar(50) DEFAULT NULL,
  `url` varchar(500) DEFAULT NULL,
  `strip_prefix` int(11) DEFAULT NULL,
  `retryable` tinyint(1) DEFAULT NULL,
  `sensitive_headers` varchar(255) DEFAULT NULL,
  `enabled` tinyint(1) NOT NULL,
  `api_name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO `gateway_api_define` VALUES ('1', '/user/**', 'user-springmvc-microservice', '', 0, 0, NULL, 1, '用户微服务');
```

## 代码设计

### 核心代码

- JdbcZuulStoreAutoConfiguration，核心类，路由定位器，最重要

```java
@Configuration
public class JdbcZuulStoreAutoConfiguration extends ZuulProxyAutoConfiguration {

    @Autowired(required = false)
    private Registration registration;
    @Autowired
    private DiscoveryClient discovery;
    @Autowired
    private ServiceRouteMapper serviceRouteMapper;
    @Autowired
    private JdbcTemplate jdbcTemplate;
    @Value(value = "${zuul.store.jdbc.table}")
    private String table;

    // 除了routeLocator之外均继承父类ZuulProxyAutoConfiguration
    @Bean
    @ConditionalOnMissingBean(StoreRefreshableRouteLocator.class)
    @ConditionalOnProperty(value = "zuul.store.jdbc.enabled", havingValue = "true", matchIfMissing = false)
    public StoreRefreshableRouteLocator routeLocator() {
        ZuulRouteStore zuulRouteStore = StringUtils.isBlank(table) ? 
            new JdbcZuulRouteStore(jdbcTemplate) : new JdbcZuulRouteStore(jdbcTemplate, table);
        StoreRefreshableRouteLocator routeLocator = new StoreRefreshableRouteLocator(
            this.server.getServlet().getServletPrefix(), this.discovery,
            this.zuulProperties, this.serviceRouteMapper,  registration, zuulRouteStore);
        return routeLocator;
    }


}
```

- StoreRefreshableRouteLocator，重写发现路由信息 

```java
public class StoreRefreshableRouteLocator extends DiscoveryClientRouteLocator {
    private final ZuulRouteStore store;
    private DiscoveryClient discovery;
    private ZuulProperties properties;

    public StoreRefreshableRouteLocator(String servletPath, DiscoveryClient discovery,
                                        ZuulProperties properties, 
                                        ServiceRouteMapper serviceRouteMapper, 
                                        ServiceInstance localServiceInstance, 
                                        ZuulRouteStore store) {
        super(servletPath, discovery, properties, serviceRouteMapper, localServiceInstance);
        this.store = store;
        this.discovery = discovery;
        this.properties = properties;
    }

    /**
     * 路由定位器和其他组件的交互，是最终把定位的Routes以list的方式提供出去,核心实现
     */
    @Override
    protected LinkedHashMap<String, ZuulProperties.ZuulRoute> locateRoutes() {
        LinkedHashMap<String, ZuulProperties.ZuulRoute> routesMap = new LinkedHashMap<>();
        // 加载静态路由信息
        routesMap.putAll(super.locateRoutes());
        // 加载动态路由信息
        for (ZuulProperties.ZuulRoute route : store.findAll()) {
            String path = route.getPath();
            // Prepend with slash if not already present.
            if (!path.startsWith("/")) {
                path = "/" + path;
            }
            if (StringUtils.hasText(this.properties.getPrefix())) {
                path = this.properties.getPrefix() + path;
                if (!path.startsWith("/")) {
                    path = "/" + path;
                }
            }
            routesMap.put(path, route);
        }
        return routesMap;
    }
}
```

- JdbcZuulRouteStore，从数据库中加载路由信息

```java
public class JdbcZuulRouteStore implements ZuulRouteStore {
    private static final ZuulRouteRowMapper ZUUL_ROUTE_MAPPER = new ZuulRouteRowMapper();
    private static final String DEFAULT_TABLE_NAME = "gateway_api_define";
    private final JdbcTemplate jdbcTemplate;
    private final String table;

    public JdbcZuulRouteStore(JdbcTemplate jdbcTemplate) {
        this(jdbcTemplate, DEFAULT_TABLE_NAME);
    }

    public JdbcZuulRouteStore(JdbcTemplate jdbcTemplate, String table) {
        Assert.notNull(jdbcTemplate, "Parameter 'jdbcTemplate' can not be null.");
        Assert.hasLength(table, "Parameter 'table' can not be empty.");
        this.jdbcTemplate = jdbcTemplate;
        this.table = table;
    }

    @Override
    public List<ZuulProperties.ZuulRoute> findAll() {
        final String sql = "select * from " + table + " where enabled = true ";
        return jdbcTemplate.query(sql, ZUUL_ROUTE_MAPPER);
    }

    private static class ZuulRouteRowMapper implements RowMapper<ZuulProperties.ZuulRoute> {
        @Override
        public ZuulProperties.ZuulRoute mapRow(ResultSet rs, int rowNum) throws SQLException {
            final String rsSensitiveHeaders = rs.getString("sensitive_headers");
            Set<String> sensitiveHeaders = Sets.newHashSet();
            if (StringUtils.isNotEmpty(rsSensitiveHeaders)) {
                String[] arr = rsSensitiveHeaders.split(",");
                for (String key : arr) {
                    sensitiveHeaders.add(key);
                }
            }

            ZuulProperties.ZuulRoute route = new ZuulProperties.ZuulRoute(
                    rs.getString("id"),
                    rs.getString("path"),
                    rs.getString("service_id"),
                    rs.getString("url"),
                    rs.getBoolean("strip_prefix"),
                    rs.getBoolean("retryable"),
                    sensitiveHeaders
            );

            route.setCustomSensitiveHeaders(route.getSensitiveHeaders() != null && 
                                            route.getSensitiveHeaders().size() > 0);
            return route;
        }
    }
}
```

- EnableZuulProxyStore，实现自定义注解

```
@EnableCircuitBreaker
@EnableDiscoveryClient
@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.TYPE)
@Import(JdbcZuulStoreAutoConfiguration.class)
public @interface EnableZuulProxyStore {
}
```

### 类图

![zuul动态路由](https://houjq.oss-cn-hongkong.aliyuncs.com/hugo/img/20190602175911.jpg)

### 架构图

![架构图](https://houjq.oss-cn-hongkong.aliyuncs.com/hugo/img/20190602175909.jpg)