# 部署指南
- 环境安装
- 应用配置
- 部署流程
- 监控配置
- 自动化部署

## 1. 基础环境安装
### 1.1 JDK安装
```bash
# 下载JDK 17
wget https://download.oracle.com/java/17/latest/jdk-17_linux-x64_bin.tar.gz

# 解压并配置环境变量
tar -zxvf jdk-17_linux-x64_bin.tar.gz
echo "export JAVA_HOME=/path/to/jdk-17" >> ~/.bashrc
echo "export PATH=$JAVA_HOME/bin:$PATH" >> ~/.bashrc
source ~/.bashrc
```

### 1.2 MySQL安装
```bash
# CentOS/RHEL
sudo yum install mysql-server mysql-client

# Ubuntu/Debian
sudo apt install mysql-server mysql-client

# 配置MySQL
sudo mysql_secure_installation
```

### 1.3 Redis安装
```bash
# CentOS/RHEL
sudo yum install redis

# Ubuntu/Debian
sudo apt install redis-server

# 配置Redis
sudo vim /etc/redis/redis.conf
# 修改bind地址和密码
```

### 1.4 RabbitMQ安装
```bash
# CentOS/RHEL
sudo yum install rabbitmq-server

# Ubuntu/Debian
sudo apt install rabbitmq-server

# 启用管理插件
sudo rabbitmq-plugins enable rabbitmq_management
```

## 2. 应用配置
### 2.1 数据库配置
```properties
# application.properties
spring.datasource.url=jdbc:mysql://localhost:3306/binance_trading
spring.datasource.username=your_username
spring.datasource.password=your_password
```

### 2.2 Redis配置
```properties
spring.redis.host=localhost
spring.redis.port=6379
spring.redis.password=your_password
```

### 2.3 RabbitMQ配置
```properties
spring.rabbitmq.host=localhost
spring.rabbitmq.port=5672
spring.rabbitmq.username=your_username
spring.rabbitmq.password=your_password
```

## 3. 应用部署
### 3.1 后端部署
```bash
# 编译打包
mvn clean package -DskipTests

# 运行应用
nohup java -jar app.jar --spring.profiles.active=prod > app.log 2>&1 &
```

### 3.2 前端部署
```bash
# 安装依赖
npm install

# 构建生产环境
npm run build

# 使用nginx部署
sudo cp -r dist/* /var/www/html/
```

## 4. 服务管理
### 4.1 服务启动脚本
```bash
#!/bin/bash
# start.sh
echo "Starting MySQL..."
sudo systemctl start mysqld

echo "Starting Redis..."
sudo systemctl start redis

echo "Starting RabbitMQ..."
sudo systemctl start rabbitmq-server

echo "Starting Application..."
nohup java -jar app.jar > app.log 2>&1 &
```

### 4.2 服务停止脚本
```bash
#!/bin/bash
# stop.sh
echo "Stopping Application..."
pkill -f app.jar

echo "Stopping RabbitMQ..."
sudo systemctl stop rabbitmq-server

echo "Stopping Redis..."
sudo systemctl stop redis

echo "Stopping MySQL..."
sudo systemctl stop mysqld
```

## 5. 监控配置
### 5.1 JVM监控
```properties
# 开启JMX监控
java -Dcom.sun.management.jmxremote
     -Dcom.sun.management.jmxremote.port=9010
     -Dcom.sun.management.jmxremote.ssl=false
     -Dcom.sun.management.jmxremote.authenticate=false
     -jar app.jar
```

### 5.2 应用日志
```properties
# logback-spring.xml
<appender name="FILE" class="ch.qos.logback.core.rolling.RollingFileAppender">
    <file>logs/app.log</file>
    <rollingPolicy class="ch.qos.logback.core.rolling.TimeBasedRollingPolicy">
        <fileNamePattern>logs/app.%d{yyyy-MM-dd}.log</fileNamePattern>
        <maxHistory>30</maxHistory>
    </rollingPolicy>
</appender>
```

## 6. Docker开发环境（可选）
### 6.1 Docker配置文件
```dockerfile:Dockerfile
# 后端服务Dockerfile
FROM openjdk:17-slim
WORKDIR /app
COPY target/*.jar app.jar
ENTRYPOINT ["java","-jar","app.jar"]
```

### 6.2 开发环境快速启动
```bash
# 启动开发环境
docker-compose -f docker-compose.yml up -d

# 查看服务状态
docker-compose ps

# 查看服务日志
docker-compose logs -f backend-dev

# 停止开发环境
docker-compose down
```

### 6.3 开发环境配置
```properties
# application-dev.properties
spring.datasource.url=jdbc:mysql://mysql-dev:3306/binance_trading
spring.datasource.username=root
spring.datasource.password=root

spring.redis.host=redis-dev
spring.redis.port=6379
spring.redis.password=your_redis_password

spring.rabbitmq.host=rabbitmq-dev
spring.rabbitmq.port=5672
spring.rabbitmq.username=user
spring.rabbitmq.password=password
```

### 6.4 开发环境使用说明
1. 开发环境优势
   - 快速搭建完整开发环境
   - 环境一致性保证
   - 无需本地安装中间件
   - 便于团队协作

2. 使用建议
   - 仅用于开发和测试环境
   - 生产环境推荐使用单机部署
   - 数据持久化通过volumes实现
   - 便于环境隔离和清理

3. 注意事项
   - 开发环境数据定期备份
   - 合理配置资源限制
   - 注意网络安全配置
   - 及时清理无用容器和镜像 

## 7. 自动化部署配置
### 7.1 GitHub配置
1. 配置Secrets
   - DOCKER_HUB_USERNAME: Docker Hub用户名
   - DOCKER_HUB_TOKEN: Docker Hub访问令牌
   - DEV_SERVER_HOST: 开发服务器地址
   - DEV_SERVER_USER: 服务器用户名
   - DEV_SERVER_SSH_KEY: SSH私钥

2. 分支保护
   - 开启main分支保护
   - 要求PR审查
   - 要求CI检查通过

### 7.2 自动部署流程
1. 代码提交触发
   - 推送到main/develop分支
   - 创建Pull Request
   
2. 自动化步骤
   - 代码构建和测试
   - Docker镜像构建
   - 推送到Docker Hub
   - 部署到开发环境
   
3. 部署验证
   - 自动健康检查
   - 自动回滚机制
   - 部署日志记录

### 7.3 手动部署命令
```bash
# 手动触发部署
cd /opt/binance-trading
./scripts/deploy.sh

# 查看部署日志
tail -f /var/log/deploy.log

# 手动回滚
./scripts/deploy.sh rollback
```

### 7.4 监控和告警
1. 部署状态监控
   - GitHub Actions状态
   - 服务健康状态
   - 部署日志监控

2. 告警配置
   - 部署失败告警
   - 回滚触发告警
   - 服务异常告警 