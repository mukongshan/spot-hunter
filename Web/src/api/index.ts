import request from '@/utils/request'

// 用户信息类型
export interface User {
  id: number
  username: string
  nickname: string
  avatar?: string
  role: string
  phone?: string
  email?: string
  createTime?: string
}

// 登录请求参数
export interface LoginParams {
  username: string
  password: string
}

// 登录响应
export interface LoginResponse {
  token: string
  user: User
}

// 景点类型
export interface Scenic {
  id: number
  name: string
  cover?: string
  images?: string[]
  location: string
  description: string
  detail?: string
  openTime: string
  price: number
  rating?: number
  tags?: string[]
  address?: string
  phone?: string
  createTime?: string
  updateTime?: string
}

// 分页响应
export interface PageResponse<T> {
  total: number
  page: number
  size: number
  list: T[]
}

// 公告类型
export interface Notice {
  id: number
  title: string
  content?: string
  summary?: string
  cover?: string
  images?: string[]
  publishTime: string
  author: string
  viewCount?: number
  isTop?: boolean
  status?: string
  createTime?: string
  updateTime?: string
}

// 门票类型
export interface Ticket {
  id: number
  scenicId?: number
  scenicName?: string
  name: string
  type?: string
  description: string
  price: number
  originalPrice?: number
  stock?: number
  dailyLimit?: number
  validityType?: string
  validityDays?: number
  startDate?: string
  endDate?: string
  refundable?: boolean
  refundRule?: string
  tags?: string[]
  status?: string
}

// 订单类型
export interface Order {
  orderId: number
  orderNo: string
  status: string
  totalPrice: number
  payAmount: number
  ticketName: string
  quantity: number
  scenicName?: string
  visitDate?: string
  createTime: string
  payTime?: string
  payExpireTime?: string
  ticketCode?: string // 门票码（后端返回但前端可能不使用）
}

// 认证相关
export const authApi = {
  // 登录
  login(data: LoginParams): Promise<LoginResponse> {
    return request({
      url: '/auth/login',
      method: 'post',
      data
    })
  },
  // 获取当前用户信息
  getCurrentUser(): Promise<User> {
    return request({
      url: '/auth/me',
      method: 'get'
    })
  }
}

// 景点相关
export const scenicApi = {
  // 景点列表
  getList(params?: { page?: number; size?: number; keyword?: string }): Promise<PageResponse<Scenic>> {
    return request({
      url: '/scenic/list',
      method: 'get',
      params
    })
  },
  // 景点详情
  getDetail(id: number): Promise<Scenic> {
    return request({
      url: `/scenic/${id}`,
      method: 'get'
    })
  },
  // 新增景点
  create(data: Partial<Scenic>): Promise<{ id: number; message: string }> {
    return request({
      url: '/admin/scenic',
      method: 'post',
      data
    })
  },
  // 修改景点
  update(id: number, data: Partial<Scenic>): Promise<{ id: number; message: string }> {
    return request({
      url: `/admin/scenic/${id}`,
      method: 'put',
      data
    })
  },
  // 删除景点
  delete(id: number): Promise<{ id: number; message: string }> {
    return request({
      url: `/admin/scenic/${id}`,
      method: 'delete'
    })
  }
}

// 公告相关
export const noticeApi = {
  // 公告列表
  getList(): Promise<Notice[]> {
    return request({
      url: '/notice/list',
      method: 'get'
    }).then((response: any) => response.data || response) // 后端返回 { data: [...] }
  },
  // 公告详情
  getDetail(id: number): Promise<Notice> {
    return request({
      url: `/notice/${id}`,
      method: 'get'
    })
  },
  // 发布公告
  create(data: Partial<Notice>): Promise<{ id: number; message: string }> {
    return request({
      url: '/admin/notice',
      method: 'post',
      data
    })
  },
  // 修改公告
  update(id: number, data: Partial<Notice>): Promise<{ id: number; message: string }> {
    return request({
      url: `/admin/notice/${id}`,
      method: 'put',
      data
    })
  },
  // 删除公告
  delete(id: number): Promise<{ id: number; message: string }> {
    return request({
      url: `/admin/notice/${id}`,
      method: 'delete'
    })
  }
}

// 门票相关
export const ticketApi = {
  // 门票列表
  getList(params?: { scenicId?: number }): Promise<Ticket[]> {
    return request({
      url: '/ticket/list',
      method: 'get',
      params
    }).then((response: any) => response.data || response) // 后端返回 { data: [...] }
  },
  // 门票详情
  getDetail(id: number): Promise<Ticket> {
    return request({
      url: `/ticket/${id}`,
      method: 'get'
    })
  },
  // 新增门票
  create(data: Partial<Ticket>): Promise<{ id: number; message: string }> {
    return request({
      url: '/admin/ticket',
      method: 'post',
      data
    })
  },
  // 修改门票
  update(id: number, data: Partial<Ticket>): Promise<{ id: number; message: string }> {
    return request({
      url: `/admin/ticket/${id}`,
      method: 'put',
      data
    })
  },
  // 删除门票
  delete(id: number): Promise<{ id: number; message: string }> {
    return request({
      url: `/admin/ticket/${id}`,
      method: 'delete'
    })
  }
}

// 订单相关
export const orderApi = {
  // 创建订单
  create(data: {
    ticketId: number
    quantity: number
    visitDate: string
    visitorName: string
    visitorPhone: string
    visitorIdCard?: string
  }): Promise<{
    orderId: number
    orderNo: string
    status: string
    totalPrice: number
    payAmount: number
    ticketName: string
    quantity: number
    visitDate: string
    visitorName: string
    createTime: string
    payExpireTime: string
  }> {
    return request({
      url: '/order/create',
      method: 'post',
      data
    })
  },
  // 我的订单
  getMyOrders(params?: { status?: string; page?: number; size?: number }): Promise<PageResponse<Order>> {
    return request({
      url: '/order/my',
      method: 'get',
      params
    })
  },
  // 订单详情
  getDetail(id: number): Promise<Order> {
    return request({
      url: `/order/${id}`,
      method: 'get'
    })
  },
  // 取消订单
  cancel(id: number): Promise<{ orderId: number; orderNo: string; status: string; message: string }> {
    return request({
      url: `/order/${id}/cancel`,
      method: 'post'
    })
  }
}

// 文件上传
export const uploadApi = {
  // 图片上传
  uploadImage(file: File): Promise<{ url: string; filename: string; size: number; width?: number; height?: number; mimeType: string }> {
    const formData = new FormData()
    formData.append('file', file)
    return request({
      url: '/upload/image',
      method: 'post',
      data: formData
      // 不设置 Content-Type，让浏览器自动设置（包含 boundary）
    })
  }
}

// 首页数据
export interface HomeData {
  banners: Array<{
    id: number
    title: string
    image: string
    link: string
    type: string
  }>
  hotScenic: Array<{
    id: number
    name: string
    cover: string
    location: string
    price: number
    rating: number
  }>
  notices: Array<{
    id: number
    title: string
    summary: string
    publishTime: string
  }>
  recommendTickets: Array<{
    id: number
    name: string
    price: number
    originalPrice: number
    scenicName: string
    scenicCover: string
  }>
}

export const homeApi = {
  getHomeData(): Promise<HomeData> {
    return request({
      url: '/home',
      method: 'get'
    })
  }
}

