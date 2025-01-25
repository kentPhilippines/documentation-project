# 模块设计
- 用户认证模块
- 行情数据模块
- 交易引擎模块
- 策略引擎模块
- 数据存储模块
- 监控告警模块

## 1. 用户认证模块
### 1.1 技术实现
- 认证框架：Spring Security + JWT
- 数据存储：MySQL + Redis
- 密码加密：BCrypt + AES(钱包密钥加密)
- 第三方认证：OAuth2.0
- 安全机制：2FA + 风控验证

### 1.2 数据模型
```java
// 用户基础信息
@Entity
@Table(name = "users")
public class User {
    @Id
    private Long id;
    private String username;
    private String email;
    private String password;    // BCrypt加密
    private String phoneNumber;
    private Boolean enabled;
    private String twoFactorSecret;
    
    @OneToMany(mappedBy = "user")
    private List<UserWallet> wallets;
    
    @OneToMany(mappedBy = "user")
    private List<UserApiKey> apiKeys;
}

// 用户钱包
@Entity
@Table(name = "user_wallets")
public class UserWallet {
    @Id
    private Long id;
    
    @ManyToOne
    private User user;
    
    private String walletName;        // 钱包名称
    private String walletType;        // 钱包类型：SPOT, MARGIN, FUTURES
    private String encryptedKey;      // AES加密的密钥
    private String walletAddress;     // 钱包地址
    private Boolean isDefault;        // 是否默认钱包
    private WalletStatus status;      // 钱包状态
    
    @OneToMany(mappedBy = "wallet")
    private List<WalletBalance> balances;
}

// 钱包余额
@Entity
@Table(name = "wallet_balances")
public class WalletBalance {
    @Id
    private Long id;
    
    @ManyToOne
    private UserWallet wallet;
    
    private String asset;      // 资产类型
    private BigDecimal free;   // 可用余额
    private BigDecimal locked; // 锁定余额
}

// API密钥管理
@Entity
@Table(name = "user_api_keys")
public class UserApiKey {
    @Id
    private Long id;
    
    @ManyToOne
    private User user;
    
    private String apiKey;
    private String encryptedSecret;
    private String description;
    private Set<String> permissions;
    private Boolean enabled;
}
```

### 1.3 核心功能
```java
@Service
public class UserWalletService {
    // 创建新钱包
    public UserWallet createWallet(Long userId, WalletCreateRequest request) {
        // 验证用户
        // 生成钱包密钥
        // 加密存储
        // 初始化钱包
    }
    
    // 导入已有钱包
    public UserWallet importWallet(Long userId, WalletImportRequest request) {
        // 验证钱包格式
        // 加密私钥
        // 存储钱包信息
    }
    
    // 钱包余额更新
    public void updateWalletBalance(Long walletId, BalanceUpdateRequest request) {
        // 验证请求
        // 更新余额
        // 记录变更历史
    }
    
    // 设置默认钱包
    public void setDefaultWallet(Long userId, Long walletId) {
        // 更新默认钱包状态
    }
}

@Service
public class WalletSecurityService {
    // 钱包密钥加密
    private String encryptWalletKey(String privateKey, String userSecret) {
        // AES加密实现
    }
    
    // 钱包密钥解密
    private String decryptWalletKey(String encryptedKey, String userSecret) {
        // AES解密实现
    }
    
    // 钱包操作安全验证
    public boolean verifyWalletOperation(Long userId, WalletOperation operation) {
        // 2FA验证
        // 风控检查
        // 操作限额检查
    }
}

@Service
public class WalletTransactionService {
    // 钱包间转账
    public TransactionResult transfer(WalletTransferRequest request) {
        // 验证钱包状态
        // 检查余额
        // 执行转账
        // 记录交易历史
    }
    
    // 获取交易历史
    public List<Transaction> getTransactionHistory(Long walletId, 
                                                 TransactionQuery query) {
        // 查询交易记录
        // 过滤和排序
    }
}
```

### 1.4 安全措施
- 钱包密钥保护
  - AES加密存储
  - 密钥分片存储
  - 内存级别保护
- 操作安全
  - 大额操作二次验证
  - 异常操作检测
  - 操作审计日志
- 访问控制
  - IP白名单
  - 设备绑定
  - 操作权限分级

### 1.5 钱包类型支持
- 现货钱包（Spot）
  - 支持所有币种
  - 充提功能
  - 交易功能
- 杠杆钱包（Margin）
  - 借贷功能
  - 风险控制
  - 强制平仓机制
- 合约钱包（Futures）
  - 永续合约
  - 交割合约
  - 风险保证金

## 2. 行情数据模块
### 2.1 技术实现
- WebSocket客户端：Java-WebSocket
- 消息队列：RabbitMQ
- 数据存储：InfluxDB
- 缓存：Redis Cluster

### 2.2 核心功能
- 行情数据采集
  ```java
  @Component
  public class BinanceWebSocketClient {
      // 处理市场深度数据
      @SubscribeMarketDepth
      public void handleDepthEvent(DepthEvent event) {
          // 深度数据处理逻辑
      }
      
      // 处理K线数据
      @SubscribeKline
      public void handleKlineEvent(KlineEvent event) {
          // K线数据处理逻辑
      }
  }
  ```
- 数据分发服务
  ```java
  @Service
  public class MarketDataService {
      // 推送实时行情
      public void broadcastMarketData(MarketData data) {
          // 行情广播逻辑
      }
  }
  ```

## 3. 交易引擎模块
### 3.1 技术实现
- 核心引擎：Disruptor队列
- 订单匹配：红黑树算法
- 持久化：MySQL + Redis
- 分布式锁：Redisson

### 3.2 核心功能
- 订单处理
  ```java
  @Service
  public class OrderExecutionService {
      // 订单执行
      public OrderResult executeOrder(Order order) {
          // 订单执行逻辑
      }
      
      // 仓位管理
      public void updatePosition(String symbol, BigDecimal quantity) {
          // 仓位更新逻辑
      }
  }
  ```
- 风险控制
  ```java
  @Component
  public class RiskControlService {
      // 订单风控检查
      public RiskCheckResult checkOrderRisk(Order order) {
          // 风控检查逻辑
      }
  }
  ```

## 4. 策略引擎模块
### 4.1 技术实现
- 策略框架：自研策略框架
- 指标计算：TA-Lib
- 回测引擎：自研回测系统
- 性能优化：LMAX Disruptor

### 4.2 核心功能
- 策略执行
  ```java
  public abstract class BaseStrategy {
      // 策略初始化
      public abstract void init();
      
      // 策略执行
      public abstract Signal execute(MarketData data);
      
      // 风险管理
      protected RiskControl riskControl;
  }
  
  // 示例策略实现
  public class MACrossStrategy extends BaseStrategy {
      private final int shortPeriod;
      private final int longPeriod;
      
      @Override
      public Signal execute(MarketData data) {
          // 策略逻辑实现
      }
  }
  ```
- 回测系统
  ```java
  @Service
  public class BackTestService {
      // 执行回测
      public BackTestResult runBackTest(
          Strategy strategy,
          BackTestConfig config
      ) {
          // 回测执行逻辑
      }
  }
  ```

## 5. 数据存储模块
### 5.1 技术实现
- 关系型数据库：MySQL集群
- 时序数据库：InfluxDB
- 缓存系统：Redis Cluster
- 消息队列：RabbitMQ

### 5.2 核心功能
- 数据访问层
  ```java
  @Repository
  public interface OrderRepository extends JpaRepository<Order, Long> {
      // 订单查询方法
  }
  
  @Repository
  public interface MarketDataRepository {
      // 行情数据存储
      void saveMarketData(MarketData data);
      
      // 查询历史数据
      List<MarketData> queryHistory(String symbol, TimeRange range);
  }
  ```
- 缓存管理
  ```java
  @Service
  public class CacheService {
      // 缓存预热
      public void warmUpCache() {
          // 缓存预热逻辑
      }
      
      // 缓存更新
      public void updateCache(String key, Object value) {
          // 缓存更新逻辑
      }
  }
  ```

## 6. 监控告警模块
### 6.1 技术实现
- 监控系统：Prometheus + Grafana
- 日志系统：ELK Stack
- 告警系统：自研告警系统
- 链路追踪：SkyWalking

### 6.2 核心功能
- 系统监控
  ```java
  @Component
  public class MonitoringService {
      // 性能指标收集
      @Scheduled(fixedRate = 60000)
      public void collectMetrics() {
          // 指标收集逻辑
      }
      
      // 告警触发
      public void triggerAlert(AlertType type, String message) {
          // 告警逻辑
      }
  }
  ```
- 日志管理
  ```java
  @Aspect
  @Component
  public class OperationLogAspect {
      // 操作日志记录
      @Around("@annotation(OperationLog)")
      public Object logOperation(ProceedingJoinPoint point) {
          // 日志记录逻辑
      }
  }
  ```

## 7. 消息推送模块
### 7.1 技术实现
- WebSocket服务：Spring WebSocket
- 消息队列：RabbitMQ
- 推送网关：自研推送网关
- 离线消息：Redis

### 7.2 核心功能
- 实时推送
  ```java
  @Service
  public class NotificationService {
      // 推送消息
      public void pushMessage(String userId, Message message) {
          // 消息推送逻辑
      }
      
      // 离线消息处理
      public void handleOfflineMessage(String userId) {
          // 离线消息处理逻辑
      }
  }
  ``` 