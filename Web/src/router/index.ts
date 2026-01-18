import { createRouter, createWebHistory } from 'vue-router'
import type { RouteRecordRaw } from 'vue-router'
import { useUserStore } from '@/stores/user'

const routes: RouteRecordRaw[] = [
  {
    path: '/login',
    name: 'Login',
    component: () => import('@/views/Login.vue'),
    meta: { title: '登录' }
  },
  {
    path: '/',
    component: () => import('@/layout/index.vue'),
    redirect: '/scenic',
    meta: { requiresAuth: true },
    children: [
      {
        path: 'scenic',
        name: 'Scenic',
        component: () => import('@/views/Scenic/index.vue'),
        meta: { title: '景点管理', icon: 'Location' }
      },
      {
        path: 'tickets',
        name: 'Tickets',
        component: () => import('@/views/Tickets/index.vue'),
        meta: { title: '门票策略', icon: 'Ticket' }
      },
      {
        path: 'orders',
        name: 'Orders',
        component: () => import('@/views/Orders/index.vue'),
        meta: { title: '订单流水', icon: 'Document' }
      },
      {
        path: 'notice',
        name: 'Notice',
        component: () => import('@/views/Notice/index.vue'),
        meta: { title: '公告发布', icon: 'Bell' }
      }
    ]
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

// 路由守卫
router.beforeEach((to, from, next) => {
  const userStore = useUserStore()
  
  if (to.meta.requiresAuth && !userStore.token) {
    next('/login')
  } else if (to.path === '/login' && userStore.token) {
    next('/')
  } else {
    next()
  }
})

export default router

