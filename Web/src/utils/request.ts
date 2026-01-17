import axios from 'axios'
import type { AxiosInstance, InternalAxiosRequestConfig, AxiosResponse } from 'axios'
import { ElMessage } from 'element-plus'
import { useUserStore } from '@/stores/user'

// 定义统一响应格式
export interface ApiResponse<T = any> {
  code: number
  msg: string
  data: T
}

// 创建axios实例
const service: AxiosInstance = axios.create({
  baseURL: '/api',
  timeout: 10000
})

// 请求拦截器
service.interceptors.request.use(
  (config: InternalAxiosRequestConfig) => {
    const userStore = useUserStore()
    if (userStore.token && config.headers) {
      config.headers.Authorization = `Bearer ${userStore.token}`
    }
    // 如果是 FormData，让浏览器自动设置 Content-Type（包含 boundary）
    if (config.data instanceof FormData && config.headers) {
      delete config.headers['Content-Type']
    }
    return config
  },
  (error) => {
    console.error('请求错误:', error)
    return Promise.reject(error)
  }
)

// 响应拦截器
service.interceptors.response.use(
  (response: AxiosResponse<ApiResponse>) => {
    const res = response.data
    
    // 如果返回的状态码不是0，则视为错误
    if (res.code !== 0) {
      ElMessage.error(res.msg || '请求失败')
      
      // 1001: 认证失败，需要重新登录
      if (res.code === 1001) {
        const userStore = useUserStore()
        userStore.logout()
        // 可以在这里跳转到登录页
        window.location.href = '/login'
      }
      
      return Promise.reject(new Error(res.msg || '请求失败'))
    } else {
      return res.data
    }
  },
  (error) => {
    console.error('响应错误:', error)
    
    // 处理HTTP错误响应（如400, 500等）
    if (error.response && error.response.data) {
      const res = error.response.data
      // 如果后端返回了统一格式的错误响应
      if (res.code !== undefined && res.msg) {
        ElMessage.error(res.msg || '请求失败')
        return Promise.reject(new Error(res.msg || '请求失败'))
      }
    }
    
    ElMessage.error(error.message || '网络错误')
    return Promise.reject(error)
  }
)

export default service
