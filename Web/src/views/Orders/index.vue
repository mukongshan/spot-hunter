<template>
  <div class="orders-page">
    <div class="page-header">
      <div class="header-left">
        <h2 class="page-title">订单流水</h2>
        <p class="page-desc">查看和管理所有订单信息</p>
      </div>
    </div>

    <!-- 搜索栏 -->
    <el-card class="search-card" shadow="never">
      <el-form :inline="true" :model="searchForm">
        <el-form-item label="订单号/手机号">
          <el-input
            v-model="searchForm.keyword"
            placeholder="请输入订单号或手机号"
            clearable
            style="width: 300px;"
            @keyup.enter="handleSearch"
          >
            <template #prefix>
              <el-icon><Search /></el-icon>
            </template>
          </el-input>
        </el-form-item>
        <el-form-item label="订单状态">
          <el-select v-model="searchForm.status" placeholder="全部状态" clearable style="width: 150px;">
            <el-option label="待支付" value="UNPAID" />
            <el-option label="已支付" value="PAID" />
            <el-option label="已核销" value="USED" />
            <el-option label="已取消" value="CANCELLED" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">搜索</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- 表格 -->
    <el-card shadow="never" class="table-card">
      <el-table :data="tableData" v-loading="loading" stripe style="width: 100%">
        <el-table-column prop="orderNo" label="订单号" width="200">
          <template #default="{ row }">
            <span class="order-no">{{ row.orderNo }}</span>
          </template>
        </el-table-column>
        <el-table-column prop="ticketName" label="购买项目" min-width="200" />
        <el-table-column prop="quantity" label="数量" width="80" align="center" />
        <el-table-column label="金额" width="120" align="right">
          <template #default="{ row }">
            <span class="amount">¥{{ row.totalPrice.toFixed(2) }}</span>
          </template>
        </el-table-column>
        <el-table-column prop="createTime" label="下单时间" width="180" />
        <el-table-column prop="payTime" label="支付时间" width="180" />
        <el-table-column label="状态" width="120" align="center">
          <template #default="{ row }">
            <el-tag :type="getStatusType(row.status)">
              {{ getStatusText(row.status) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="120" fixed="right" align="center">
          <template #default="{ row }">
            <el-button type="primary" link @click="handleViewDetail(row)">详情</el-button>
          </template>
        </el-table-column>
      </el-table>

      <!-- 分页 -->
      <div class="pagination">
        <el-pagination
          v-model:current-page="pagination.page"
          v-model:page-size="pagination.size"
          :total="pagination.total"
          :page-sizes="[10, 20, 50, 100]"
          layout="total, sizes, prev, pager, next, jumper"
          @size-change="handleSizeChange"
          @current-change="handlePageChange"
        />
      </div>
    </el-card>

    <!-- 详情对话框 -->
    <el-dialog v-model="detailVisible" title="订单详情" width="700px">
      <el-descriptions :column="2" border v-if="orderDetail">
        <el-descriptions-item label="订单号">{{ orderDetail.orderNo }}</el-descriptions-item>
        <el-descriptions-item label="订单状态">
          <el-tag :type="getStatusType(orderDetail.status)">
            {{ getStatusText(orderDetail.status) }}
          </el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="购买项目">{{ orderDetail.ticketName }}</el-descriptions-item>
        <el-descriptions-item label="数量">{{ orderDetail.quantity }}</el-descriptions-item>
        <el-descriptions-item label="总金额">¥{{ orderDetail.totalPrice.toFixed(2) }}</el-descriptions-item>
        <el-descriptions-item label="实付金额">¥{{ orderDetail.payAmount.toFixed(2) }}</el-descriptions-item>
        <el-descriptions-item label="下单时间">{{ orderDetail.createTime }}</el-descriptions-item>
        <el-descriptions-item label="支付时间">{{ orderDetail.payTime || '-' }}</el-descriptions-item>
        <el-descriptions-item label="游玩日期" :span="2">
          {{ orderDetail.visitDate || '-' }}
        </el-descriptions-item>
      </el-descriptions>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { Search } from '@element-plus/icons-vue'
import { orderApi } from '@/api'
import type { Order } from '@/api'

const loading = ref(false)
const detailVisible = ref(false)
const orderDetail = ref<Order | null>(null)

const searchForm = reactive({
  keyword: '',
  status: ''
})

const pagination = reactive({
  page: 1,
  size: 10,
  total: 0
})

const tableData = ref<Order[]>([])

const getStatusType = (status: string) => {
  const map: Record<string, string> = {
    UNPAID: 'warning',
    PAID: 'success',
    USED: 'info',
    CANCELLED: 'danger'
  }
  return map[status] || ''
}

const getStatusText = (status: string) => {
  const map: Record<string, string> = {
    UNPAID: '待支付',
    PAID: '已支付',
    USED: '已核销',
    CANCELLED: '已取消'
  }
  return map[status] || status
}

const fetchData = async () => {
  loading.value = true
  try {
    const response = await orderApi.getMyOrders({
      page: pagination.page,
      size: pagination.size,
      status: searchForm.status || undefined
    })
    // 过滤搜索关键词
    let filteredList = response.list
    if (searchForm.keyword) {
      filteredList = filteredList.filter((item: Order) =>
        item.orderNo.includes(searchForm.keyword) ||
        item.ticketName?.includes(searchForm.keyword) ||
        item.scenicName?.includes(searchForm.keyword)
      )
    }
    tableData.value = filteredList
    pagination.total = response.total
  } catch (error) {
    console.error('获取订单列表失败:', error)
  } finally {
    loading.value = false
  }
}

const handleSearch = () => {
  pagination.page = 1
  fetchData()
}

const handleReset = () => {
  searchForm.keyword = ''
  searchForm.status = ''
  handleSearch()
}

const handleSizeChange = () => {
  fetchData()
}

const handlePageChange = () => {
  fetchData()
}

const handleViewDetail = async (row: Order) => {
  try {
    const detail = await orderApi.getDetail(row.orderId)
    orderDetail.value = detail as any
    detailVisible.value = true
  } catch (error) {
    console.error('获取订单详情失败:', error)
  }
}

onMounted(() => {
  fetchData()
})
</script>

<style scoped>
.orders-page {
  padding: 0;
  max-width: 1400px;
  margin: 0 auto;
}

.page-header {
  margin-bottom: 32px;
}

.header-left {
  flex: 1;
}

.page-title {
  font-size: 32px;
  font-weight: 600;
  color: #1d1d1f;
  margin: 0 0 8px 0;
  letter-spacing: -0.5px;
}

.page-desc {
  font-size: 15px;
  color: rgba(0, 0, 0, 0.5);
  margin: 0;
  font-weight: 400;
}

.search-card {
  margin-bottom: 24px;
  border-radius: 16px;
  padding: 24px;
}

.table-card {
  border-radius: 16px;
  padding: 24px;
}

.order-no {
  font-family: 'SF Mono', 'Monaco', 'Menlo', 'Ubuntu Mono', monospace;
  font-size: 13px;
  color: #007aff;
  font-weight: 500;
  letter-spacing: 0.3px;
}

.amount {
  font-weight: 600;
  color: #1d1d1f;
  font-size: 15px;
}

.pagination {
  margin-top: 32px;
  display: flex;
  justify-content: flex-end;
  padding-top: 24px;
  border-top: 1px solid rgba(0, 0, 0, 0.06);
}
</style>
