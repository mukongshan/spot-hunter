# 景区打卡小程序 - 核心极简 API 文档 (V1.0)

## 1. 基础约定
*   **服务器地址**: `http://localhost:8080` (部署后替换为服务器 IP)
*   **接口前缀**: `/api`
*   **数据格式**: Content-Type: `application/json`
*   **图片处理**: 为了省事，所有图片字段 (`image`) 请直接存网络图片链接 (例如百度找的图)，不要做文件上传功能。

---

## 2. 模块一：用户系统 (User)
> **逻辑说明**：为了演示方便，不做手机号验证码。用户输入一个名字，后端判断：如果数据库有这个名字，就登录；如果没有，自动注册并登录。

### 2.1 极简登录/注册
*   **接口地址**: `POST /api/user/login`
*   **功能**: 输入用户名，返回用户ID（前端必须保存这个ID，后续所有请求都要带上）。
*   **请求参数 (Body)**:
```json
{
    "username": "测试游客001"
}
```
*   **返回结果**:
```json
{
    "code": 200,
    "msg": "登录成功",
    "data": {
        "id": 101,            // 用户ID (核心)
        "username": "测试游客001",
        "score": 0,           // 当前积分
        "avatar": "https://api.dicebear.com/7.x/avataaars/svg?seed=101" // 后端随机生成一个头像URL返回
    }
}
```

### 2.2 获取用户信息（刷新积分用）
*   **接口地址**: `GET /api/user/info`
*   **功能**: 在“个人中心”页面，刷新查看最新的积分。
*   **请求参数 (Query)**: `?userId=101`
*   **返回结果**:
```json
{
    "code": 200,
    "data": {
        "id": 101,
        "username": "测试游客001",
        "score": 50
    }
}
```

---

## 3. 模块二：地图与景点 (Spot)
> **逻辑说明**：这是“鸿蒙端”地图初始化的核心。后端把数据库里所有的景点一次性扔给前端，前端循环在地图上画 Marker。

### 3.1 获取所有景点列表
*   **接口地址**: `GET /api/spot/list`
*   **功能**: 地图撒点、景点列表展示。
*   **请求参数**: 无
*   **返回结果**:
```json
{
    "code": 200,
    "data": [
        {
            "id": 1,
            "name": "景区南大门",
            "intro": "这是景区的正门，始建于2020年...",
            "image": "https://img.example.com/gate.jpg",
            "latitude": 30.2541,  // 纬度 (高德坐标系)
            "longitude": 120.2132, // 经度
            "score": 10           // 打卡该点可获得的积分
        },
        {
            "id": 2,
            "name": "中心湖",
            "intro": "风景优美的人工湖...",
            "image": "https://img.example.com/lake.jpg",
            "latitude": 30.2555,
            "longitude": 120.2145,
            "score": 20
        }
    ]
}
```

---

## 4. 模块三：打卡核心 (CheckIn)
> **逻辑说明**：这是整个项目唯一的交互难点。

### 4.1 执行打卡
*   **接口地址**: `POST /api/checkin`
*   **功能**: 用户点击“打卡”按钮触发。后端保存记录，并给用户加分。
*   **请求参数 (Body)**:
```json
{
    "userId": 101,       // 谁打的卡
    "spotId": 1,         // 在哪打的卡
    "latitude": 30.2541, // 用户当前的纬度（用于校验）
    "longitude": 120.2132 // 用户当前的经度
}
```
*   **后端处理逻辑 (伪代码)**:
    1. 检查 `userId` 和 `spotId` 是否有效。
    2. (可选-特种兵模式可跳过) 计算用户坐标和景点坐标距离是否小于 100米。
    3. 检查该用户今天是否已经打过这个点的卡（防止刷分）。
    4. 插入一条 `CheckIn` 记录。
    5. 更新 `User` 表，`score = score + spot.score`。
*   **返回结果**:
```json
{
    "code": 200,
    "msg": "打卡成功！积分 +10", // 前端直接把这个msg弹窗显示
    "data": {
        "newScore": 60       // 返回最新积分，前端更新界面
    }
}
```

### 4.2 获取我的打卡记录 (鸿蒙端)
*   **接口地址**: `GET /api/checkin/my-history`
*   **功能**: 个人中心 -> “我的足迹”。
*   **请求参数 (Query)**: `?userId=101`
*   **返回结果**:
```json
{
    "code": 200,
    "data": [
        {
            "id": 55,
            "spotName": "景区南大门",
            "checkTime": "2023-11-21 14:30:00", // 格式化好的时间字符串
            "image": "https://img.example.com/gate.jpg" // 景点图片，方便展示
        }
    ]
}
```

---

## 5. 模块四：Web 后台管理 (Admin)
> **逻辑说明**：给老师演示“我有一个管理后台，能看到数据”。

### 5.1 获取所有打卡记录
*   **接口地址**: `GET /api/admin/checkin/all`
*   **功能**: Web端后台表格展示所有人的打卡流水。
*   **请求参数**: 无 (为了演示，直接返回最近的100条即可)
*   **返回结果**:
```json
{
    "code": 200,
    "data": [
        {
            "id": 55,
            "username": "测试游客001", // 注意：后端要联表查询把用户名带出来
            "spotName": "景区南大门",
            "checkTime": "2023-11-21 14:30:00"
        },
        {
            "id": 54,
            "username": "张三",
            "spotName": "中心湖",
            "checkTime": "2023-11-21 14:28:00"
        }
    ]
}
```

---

## 6. 数据库表结构 (MySQL)

为了让后端同学无脑复制，这是建表 SQL：

```sql
-- 1. 用户表
CREATE TABLE `t_user` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `username` varchar(64) NOT NULL COMMENT '用户名',
  `score` int(11) DEFAULT '0' COMMENT '积分',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 2. 景点表 (后端同学请手动往里 INSERT 5-10条数据)
CREATE TABLE `t_spot` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(64) NOT NULL COMMENT '景点名称',
  `intro` varchar(512) COMMENT '简介',
  `image` varchar(255) COMMENT '图片链接',
  `latitude` decimal(10,6) NOT NULL COMMENT '纬度',
  `longitude` decimal(10,6) NOT NULL COMMENT '经度',
  `score` int(11) DEFAULT '10' COMMENT '打卡获得积分',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 3. 打卡记录表
CREATE TABLE `t_checkin` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) NOT NULL,
  `spot_id` bigint(20) NOT NULL,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

---

## 7. 演示时的“作弊”小贴士 (必读)

1.  **关于位置距离校验**：
    *   后端同学如果在 `POST /checkin` 接口里写不好经纬度距离计算算法，**直接删掉校验逻辑**。
    *   只要请求发过来，就默认用户已经在景点了，直接返回“打卡成功”。
    *   *理由*：演示的时候，老师不会盯着你的代码看有没有算距离，他只看你点击按钮后有没有弹窗。

2.  **关于跨域 (CORS)**：
    *   Web端和鸿蒙模拟器请求后端时，100%会遇到跨域报错。
    *   后端同学请务必在 SpringBoot 的 Controller 类上加上 `@CrossOrigin("*")` 注解。

3.  **关于地图数据**：
    *   统筹/PM 赶紧去高德地图拾取坐标系统（https://lbs.amap.com/tools/picker），找你们学校或者随便一个公园，选5个点，把经纬度复制下来，存到 `t_spot` 表里。
    *   不要用真的景区经纬度，**用你们演示所在的教室/宿舍附近的经纬度**！这样演示时，鸿蒙App上的“定位小蓝点”才会真的出现在景点旁边！

**开工吧！**