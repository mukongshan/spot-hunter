# 灵境景区管理系统 - Web管理端

基于 Vue3 + TypeScript + Element Plus 开发的景区管理系统管理后台。

## 技术栈

- **Vue 3** - 渐进式 JavaScript 框架
- **TypeScript** - 类型安全的 JavaScript
- **Vite** - 下一代前端构建工具
- **Vue Router** - 官方路由管理器
- **Pinia** - Vue 的状态管理库
- **Element Plus** - 基于 Vue 3 的组件库
- **ECharts** - 数据可视化图表库
- **Axios** - HTTP 客户端

## 功能模块

- ✅ 用户登录/认证
- ✅ 数据监控（仪表盘）
- ✅ 景点管理（列表、新增、编辑、删除）
- ✅ 门票策略管理
- ✅ 订单流水管理
- ✅ 公告发布管理
- ✅ 用户管理

## 项目结构

```
src/
├── api/              # API 接口定义
│   └── index.ts
├── assets/           # 静态资源
├── components/       # 公共组件
├── layout/           # 布局组件
│   └── index.vue
├── router/           # 路由配置
│   └── index.ts
├── stores/           # 状态管理
│   └── user.ts
├── utils/            # 工具函数
│   └── request.ts
├── views/            # 页面组件
│   ├── Dashboard.vue      # 数据监控
│   ├── Login.vue          # 登录页
│   ├── Scenic/            # 景点管理
│   ├── Tickets/           # 门票管理
│   ├── Orders/            # 订单管理
│   ├── Notice/            # 公告管理
│   └── Users/             # 用户管理
├── App.vue           # 根组件
├── main.ts           # 入口文件
└── style.css         # 全局样式
```

## 开发指南

### 安装依赖

```bash
npm install
```

### 启动开发服务器

```bash
npm run dev
```

访问 http://localhost:3000

### 构建生产版本

```bash
npm run build
```

### 预览生产构建

```bash
npm run preview
```

## 环境配置

### API 代理配置

在 `vite.config.ts` 中配置了 API 代理：

```typescript
server: {
  proxy: {
    '/api': {
      target: 'http://localhost:8080',
      changeOrigin: true
    }
  }
}
```

根据实际后端地址修改 `target`。

## 接口说明

所有 API 接口定义在 `src/api/index.ts` 中，包括：

- 认证接口（登录、获取用户信息）
- 景点接口（列表、详情、增删改）
- 公告接口（列表、详情、增删改）
- 门票接口（列表、详情、增删改）
- 订单接口（列表、详情、取消）
- 文件上传接口

接口统一返回格式：

```json
{
  "code": 0,
  "msg": "success",
  "data": {}
}
```

## 状态码说明

- `0`: 成功
- `1001`: 认证失败
- `1002`: 参数错误
- `1003`: 资源不存在
- `1004`: 权限不足
- `2001`: 库存不足
- `2002`: 订单状态异常
- `3001`: 文件上传失败

## 注意事项

1. 登录后 token 会存储在 localStorage 中
2. 所有需要鉴权的接口会自动在请求头中添加 `Authorization: Bearer {token}`
3. 当 token 过期或认证失败时，会自动跳转到登录页
4. 图片上传需要先获取 token，然后调用上传接口

## 开发规范

- 使用 TypeScript 进行类型定义
- 组件使用 `<script setup>` 语法
- 使用 Element Plus 组件库
- API 调用统一使用 `src/api/index.ts` 中定义的方法
- 状态管理使用 Pinia

## License

MIT
