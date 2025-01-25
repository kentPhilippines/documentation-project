# 项目概述
- 项目简介
- 技术栈
- 快速开始

## 1.1 项目简介
- 项目名称：Binance Quantitative Trading System (BQTS)
- 项目目标：构建一个稳定、高效的币安量化交易系统，支持多策略交易和风险控制
- 核心功能：
  - 用户管理和权限控制
  - 实时行情数据获取和处理
  - 多策略交易引擎
  - 风险控制系统
  - 交易监控和报告
  - 回测系统
  - 资金管理
  - 个人中心

## 1.2 技术栈概览
- 后端技术栈：
  - Java 17
  - Spring Boot 3.x
  - Spring Cloud
  - MySQL 8.0 (单机部署)
  - Redis (单机部署)
  - RabbitMQ (单机部署)
  - WebSocket
- 前端技术栈：
  - Vue 3
  - Element Plus
  - ECharts
  - TradingView
- 开发环境要求：
  - JDK 17+
  - Maven 3.8+
  - Node.js 16+
  - MySQL 8.0
  - Redis 6.x
  - RabbitMQ 3.x
- 可选开发环境：
  - Docker 20.10+
  - Docker Compose 2.x

## 1.3 快速开始
- 环境准备：
  - 安装JDK、Maven、Node.js
  - 安装并配置MySQL
  - 安装并配置Redis
  - 安装并配置RabbitMQ
  - 配置币安API密钥
- 安装步骤：
  - 克隆项目代码
  - 执行数据库初始化脚本
  - 修改application.properties配置文件
  - 编译打包项目
- 运行命令：
  - 后端启动：`java -jar app.jar`
  - 前端启动：`npm run serve`
- 可选Docker开发环境：
  - 安装Docker和Docker Compose
  - 执行`docker-compose up -d`
  - 访问`http://localhost:8080`

## 4. 开发规范
### 4.1 代码规范
- 命名规范
  - 类名：大驼峰命名
  - 方法名：小驼峰命名
  - 常量：全大写下划线分隔
- 注释规范
  - 类注释：包含作者、日期、功能说明
  - 方法注释：参数说明、返回值、异常说明
- 代码格式
  - 使用4空格缩进
  - 最大行宽120字符
  - 类成员顺序：常量、字段、构造器、方法

### 4.2 Git规范
- 分支管理
  - main：主分支
  - develop：开发分支
  - feature/*：功能分支
  - hotfix/*：紧急修复分支
- 提交规范
  - feat: 新功能
  - fix: 修复bug
  - docs: 文档更新
  - style: 代码格式调整
  - refactor: 重构 