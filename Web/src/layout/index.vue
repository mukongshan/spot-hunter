<template>
  <el-container class="layout-container">
    <!-- 侧边栏 -->
    <el-aside width="260px" class="sidebar">
      <div class="logo">
        <div class="logo-icon">
          <el-icon :size="24" color="#007aff"><Odometer /></el-icon>
        </div>
        <span class="logo-text">灵境管理后台</span>
      </div>
      <el-menu
        :default-active="activeMenu"
        class="sidebar-menu"
        background-color="transparent"
        text-color="rgba(0, 0, 0, 0.6)"
        active-text-color="#007aff"
        router
      >
        <el-menu-item index="/scenic">
          <el-icon><Location /></el-icon>
          <span>景点管理</span>
        </el-menu-item>
        <el-menu-item index="/tickets">
          <el-icon><Ticket /></el-icon>
          <span>门票策略</span>
        </el-menu-item>
        <el-menu-item index="/orders">
          <el-icon><Document /></el-icon>
          <span>订单流水</span>
        </el-menu-item>
        <el-menu-item index="/notice">
          <el-icon><Bell /></el-icon>
          <span>公告发布</span>
        </el-menu-item>
      </el-menu>
      <div class="sidebar-footer">
        <span class="version">v2.4.0</span>
      </div>
    </el-aside>

    <!-- 主内容区 -->
    <el-container class="main-container">
      <!-- 顶部栏 -->
      <el-header class="header">
        <div class="breadcrumb">
          <h1 class="page-title">{{ currentTitle }}</h1>
        </div>
        <div class="header-right">
          <el-dropdown @command="handleCommand" trigger="click" placement="bottom-end">
            <div class="user-info">
              <el-avatar :src="userStore.user?.avatar" :size="36">
                {{ userStore.user?.nickname?.[0] || 'A' }}
              </el-avatar>
              <span class="username">{{ userStore.user?.nickname || '系统管理员' }}</span>
              <el-icon class="dropdown-icon"><ArrowDown /></el-icon>
            </div>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item command="logout">
                  <el-icon><SwitchButton /></el-icon>
                  退出登录
                </el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
        </div>
      </el-header>

      <!-- 内容区 -->
      <el-main class="main-content">
        <router-view />
      </el-main>
    </el-container>
  </el-container>
</template>

<script setup lang="ts">
import { computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useUserStore } from '@/stores/user'
import { ElMessage } from 'element-plus'
import {
  Odometer,
  Location,
  Ticket,
  Document,
  Bell,
  ArrowDown,
  SwitchButton
} from '@element-plus/icons-vue'

const route = useRoute()
const router = useRouter()
const userStore = useUserStore()

const activeMenu = computed(() => route.path)
const currentTitle = computed(() => {
  const matched = route.matched.find(item => item.meta?.title)
  return matched?.meta?.title as string || '景点管理'
})

const handleCommand = (command: string) => {
  if (command === 'logout') {
    userStore.logout()
    ElMessage.success('已退出登录')
    router.push('/login')
  }
}

onMounted(() => {
  if (userStore.token && !userStore.user) {
    userStore.fetchUserInfo()
  }
})
</script>

<style scoped>
.layout-container {
  height: 100vh;
  background-color: #f5f5f7;
}

.sidebar {
  background: linear-gradient(180deg, #ffffff 0%, #fafafa 100%);
  border-right: 1px solid rgba(0, 0, 0, 0.06);
  display: flex;
  flex-direction: column;
  box-shadow: 1px 0 0 rgba(0, 0, 0, 0.04);
}

.logo {
  height: 72px;
  display: flex;
  align-items: center;
  justify-content: flex-start;
  gap: 12px;
  padding: 0 24px;
  border-bottom: 1px solid rgba(0, 0, 0, 0.06);
}

.logo-icon {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 36px;
  height: 36px;
  background: linear-gradient(135deg, #007aff 0%, #5856d6 100%);
  border-radius: 10px;
  box-shadow: 0 2px 8px rgba(0, 122, 255, 0.3);
}

.logo-text {
  font-size: 18px;
  font-weight: 600;
  color: #1d1d1f;
  letter-spacing: -0.3px;
}

.sidebar-menu {
  flex: 1;
  border: none;
  padding: 16px 12px;
}

.sidebar-menu .el-menu-item {
  height: 44px;
  line-height: 44px;
  margin: 4px 0;
  border-radius: 10px;
  transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
  font-weight: 500;
}

.sidebar-menu .el-menu-item:hover {
  background-color: rgba(0, 0, 0, 0.04);
}

.sidebar-menu .el-menu-item.is-active {
  background: linear-gradient(90deg, rgba(0, 122, 255, 0.1) 0%, rgba(0, 122, 255, 0.05) 100%);
  color: #007aff;
  font-weight: 600;
}

.sidebar-footer {
  height: 56px;
  padding: 0 24px;
  display: flex;
  align-items: center;
  border-top: 1px solid rgba(0, 0, 0, 0.06);
}

.version {
  font-size: 11px;
  color: rgba(0, 0, 0, 0.4);
  font-weight: 500;
  letter-spacing: 0.3px;
}

.main-container {
  display: flex;
  flex-direction: column;
}

.header {
  background: rgba(255, 255, 255, 0.8);
  backdrop-filter: saturate(180%) blur(20px);
  -webkit-backdrop-filter: saturate(180%) blur(20px);
  border-bottom: 1px solid rgba(0, 0, 0, 0.06);
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 32px;
  height: 72px;
  position: sticky;
  top: 0;
  z-index: 100;
}

.breadcrumb {
  display: flex;
  align-items: center;
}

.page-title {
  font-size: 28px;
  font-weight: 600;
  color: #1d1d1f;
  margin: 0;
  letter-spacing: -0.5px;
}

.header-right {
  display: flex;
  align-items: center;
}

.user-info {
  display: flex;
  align-items: center;
  gap: 10px;
  cursor: pointer;
  padding: 6px 12px;
  border-radius: 10px;
  transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
}

.user-info:hover {
  background-color: rgba(0, 0, 0, 0.04);
}

.username {
  font-size: 14px;
  font-weight: 500;
  color: #1d1d1f;
}

.dropdown-icon {
  font-size: 12px;
  color: rgba(0, 0, 0, 0.4);
  transition: transform 0.2s;
}

.user-info:hover .dropdown-icon {
  transform: rotate(180deg);
}

.main-content {
  background-color: #f5f5f7;
  padding: 32px;
  overflow-y: auto;
  min-height: calc(100vh - 72px);
}

/* 响应式 */
@media (max-width: 768px) {
  .sidebar {
    width: 64px !important;
  }
  
  .logo-text,
  .sidebar-menu span,
  .username {
    display: none;
  }
}
</style>
