# API规范

## 1. 通用规范
### 1.1 请求格式
- 基础URL: `https://api.example.com/v1`
- 请求方法: GET, POST, PUT, DELETE
- Content-Type: application/json
- 字符编码: UTF-8

### 1.2 认证方式
```http
Authorization: Bearer <token>
X-API-Key: <api_key>
```

### 1.3 响应格式
```json
{
    "code": 200,          // 状态码
    "message": "success", // 状态信息
    "data": {            // 响应数据
        // 具体数据结构
    },
    "timestamp": 1234567890 // 时间戳
}
```

## 2. 行情接口
### 2.1 获取K线数据
```http
GET /market/klines
```
参数：
```json
{
    "symbol": "BTCUSDT",    // 交易对
    "interval": "1m",       // K线间隔: 1m,5m,15m,30m,1h,4h,1d
    "limit": 500,          // 数量限制，默认500，最大1000
    "startTime": 1234567890, // 可选，开始时间戳
    "endTime": 1234567890   // 可选，结束时间戳
}
```
响应：
```json
{
    "code": 200,
    "data": [
        [
            1234567890,  // 开盘时间
            "30000.00",  // 开盘价
            "31000.00",  // 最高价
            "29000.00",  // 最低价
            "30500.00",  // 收盘价
            "100.5",     // 成交量
            1234567899   // 收盘时间
        ]
    ]
}
```

### 2.2 获取市场深度
```http
GET /market/depth
```
参数：
```json
{
    "symbol": "BTCUSDT",
    "limit": 100  // 深度档数，默认100
}
```

## 3. 交易接口
### 3.1 下单
```http
POST /trade/order
```
请求体：
```json
{
    "symbol": "BTCUSDT",
    "side": "BUY",        // BUY, SELL
    "type": "LIMIT",      // LIMIT, MARKET
    "timeInForce": "GTC", // GTC, IOC, FOK
    "quantity": "0.001",
    "price": "30000",     // LIMIT订单必需
    "clientOrderId": "myOrder123" // 可选，客户端订单ID
}
```

### 3.2 撤单
```http
DELETE /trade/order
```
参数：
```json
{
    "symbol": "BTCUSDT",
    "orderId": "123456",  // 订单ID和clientOrderId必须填一个
    "clientOrderId": "myOrder123"
}
```

## 4. 账户接口
### 4.1 获取账户信息
```http
GET /account/info
```
响应：
```json
{
    "code": 200,
    "data": {
        "balances": [
            {
                "asset": "BTC",
                "free": "0.1",
                "locked": "0.05"
            }
        ]
    }
}
```

### 4.2 获取订单历史
```http
GET /account/orders
```
参数：
```json
{
    "symbol": "BTCUSDT",
    "startTime": 1234567890,
    "endTime": 1234567899,
    "limit": 500,
    "status": "FILLED" // ALL, FILLED, CANCELED, REJECTED
}
```

## 5. 策略接口
### 5.1 创建策略
```http
POST /strategy
```
请求体：
```json
{
    "name": "MA交叉策略",
    "symbol": "BTCUSDT",
    "parameters": {
        "shortPeriod": 5,
        "longPeriod": 20,
        "quantity": "0.001"
    },
    "riskControl": {
        "maxPositionSize": "0.01",
        "stopLoss": "2%",
        "takeProfit": "5%"
    }
}
```

### 5.2 策略状态管理
```http
PUT /strategy/{strategyId}/status
```
请求体：
```json
{
    "status": "RUNNING" // RUNNING, PAUSED, STOPPED
}
```

## 6. 错误码
| 错误码 | 描述 | 解决方案 |
|--------|------|----------|
| 200 | 成功 | - |
| 400 | 请求参数错误 | 检查请求参数 |
| 401 | 未授权 | 检查认证信息 |
| 403 | 禁止访问 | 检查权限 |
| 429 | 请求过频 | 降低请求频率 |
| 500 | 服务器错误 | 联系技术支持 |

## 7. WebSocket接口
### 7.1 连接
```
ws://api.example.com/ws
```

### 7.2 订阅主题
```json
{
    "method": "SUBSCRIBE",
    "params": [
        "btcusdt@kline_1m",
        "btcusdt@depth"
    ],
    "id": 1
}
```

### 7.3 数据推送格式
```json
{
    "stream": "btcusdt@kline_1m",
    "data": {
        // 具体数据结构
    }
} 