import { defineStore } from 'pinia'
import { ref } from 'vue'
import { authApi } from '@/api'
import type { User } from '@/api'
import { ElMessage } from 'element-plus'

export const useUserStore = defineStore('user', () => {
  const token = ref<string>(localStorage.getItem('token') || '')
  const user = ref<User | null>(null)

  // 登录
  const login = async (username: string, password: string) => {
    try {
      const response = await authApi.login({ username, password })
      token.value = response.token
      user.value = response.user
      localStorage.setItem('token', response.token)
      return true
    } catch (error: any) {
      ElMessage.error(error.message || '登录失败')
      return false
    }
  }

  // 获取用户信息
  const fetchUserInfo = async () => {
    try {
      if (!token.value) return
      const userInfo = await authApi.getCurrentUser()
      user.value = userInfo
      return userInfo
    } catch (error) {
      console.error('获取用户信息失败:', error)
      logout()
    }
  }

  // 登出
  const logout = () => {
    token.value = ''
    user.value = null
    localStorage.removeItem('token')
  }

  return {
    token,
    user,
    login,
    fetchUserInfo,
    logout
  }
})

