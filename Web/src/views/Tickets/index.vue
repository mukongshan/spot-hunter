<template>
  <div class="tickets-page">
    <div class="page-header">
      <div class="header-left">
        <h2 class="page-title">门票策略</h2>
        <p class="page-desc">管理和配置景区门票信息</p>
      </div>
      <el-button type="primary" size="large" @click="handleAdd">
        <el-icon><Plus /></el-icon>
        新增门票
      </el-button>
    </div>

    <el-row :gutter="20">
      <el-col :span="8" v-for="ticket in ticketList" :key="ticket.id">
        <el-card class="ticket-card" :class="getCardClass(ticket.id)" shadow="hover">
          <div class="ticket-header">
            <h3 class="ticket-name">{{ ticket.name }}</h3>
            <el-button
              type="text"
              :icon="Edit"
              @click="handleEdit(ticket)"
              class="edit-btn"
            />
          </div>
          <p class="ticket-desc">{{ ticket.description }}</p>
          <div class="ticket-footer">
            <div class="ticket-price">
              <span class="price">¥{{ ticket.price }}</span>
              <span class="unit">/ {{ ticket.type === 'FAMILY' ? '每组' : '每人' }}</span>
              <span v-if="ticket.originalPrice" class="original-price">
                ¥{{ ticket.originalPrice }}
              </span>
            </div>
          </div>
          <div class="ticket-tags" v-if="ticket.tags && ticket.tags.length">
            <el-tag
              v-for="tag in ticket.tags"
              :key="tag"
              size="small"
              style="margin-right: 8px;"
            >
              {{ tag }}
            </el-tag>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 编辑对话框 -->
    <el-dialog
      v-model="dialogVisible"
      :title="dialogTitle"
      width="600px"
      @close="handleDialogClose"
    >
      <el-form
        ref="formRef"
        :model="formData"
        :rules="formRules"
        label-width="100px"
      >
        <el-form-item label="门票名称" prop="name">
          <el-input v-model="formData.name" placeholder="如：成人票、学生票" />
        </el-form-item>
        <el-form-item label="所属景点" prop="scenicId">
          <el-select v-model="formData.scenicId" placeholder="请选择景点" style="width: 100%">
            <el-option
              v-for="scenic in scenicList"
              :key="scenic.id"
              :label="scenic.name"
              :value="scenic.id"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="门票类型" prop="type">
          <el-select v-model="formData.type" placeholder="请选择类型" style="width: 100%">
            <el-option label="成人票" value="ADULT" />
            <el-option label="学生票" value="STUDENT" />
            <el-option label="儿童票" value="CHILD" />
            <el-option label="老年票" value="ELDERLY" />
            <el-option label="家庭票" value="FAMILY" />
          </el-select>
        </el-form-item>
        <el-form-item label="描述" prop="description">
          <el-input
            v-model="formData.description"
            type="textarea"
            :rows="3"
            placeholder="请输入门票描述"
          />
        </el-form-item>
        <el-form-item label="售价" prop="price">
          <el-input-number v-model="formData.price" :min="0" :precision="2" style="width: 100%" />
        </el-form-item>
        <el-form-item label="原价" prop="originalPrice">
          <el-input-number v-model="formData.originalPrice" :min="0" :precision="2" style="width: 100%" />
        </el-form-item>
        <el-form-item label="库存" prop="stock">
          <el-input-number v-model="formData.stock" :min="0" style="width: 100%" />
        </el-form-item>
        <el-form-item label="每日限购" prop="dailyLimit">
          <el-input-number v-model="formData.dailyLimit" :min="0" style="width: 100%" />
        </el-form-item>
        <el-form-item label="可退款">
          <el-switch v-model="formData.refundable" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSubmit" :loading="submitLoading">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import type { FormInstance, FormRules } from 'element-plus'
import { Plus, Edit } from '@element-plus/icons-vue'
import { ticketApi, scenicApi } from '@/api'
import type { Ticket, Scenic } from '@/api'

const dialogVisible = ref(false)
const dialogTitle = ref('新增门票')
const submitLoading = ref(false)
const formRef = ref<FormInstance>()
const ticketList = ref<Ticket[]>([])
const scenicList = ref<Scenic[]>([])

const formData = reactive<Partial<Ticket>>({
  name: '',
  scenicId: undefined,
  type: 'ADULT',
  description: '',
  price: 0,
  originalPrice: 0,
  stock: 0,
  dailyLimit: 0,
  refundable: true
})

const formRules: FormRules = {
  name: [{ required: true, message: '请输入门票名称', trigger: 'blur' }],
  scenicId: [{ required: true, message: '请选择所属景点', trigger: 'change' }],
  price: [{ required: true, message: '请输入售价', trigger: 'blur' }]
}

const getCardClass = (id: number) => {
  const classes = ['card-indigo', 'card-blue', 'card-amber']
  return classes[id % 3] || 'card-indigo'
}

const fetchTickets = async () => {
  try {
    const data = await ticketApi.getList()
    ticketList.value = data
  } catch (error) {
    console.error('获取门票列表失败:', error)
  }
}

const fetchScenics = async () => {
  try {
    const response = await scenicApi.getList({ page: 1, size: 100 })
    scenicList.value = response.list
  } catch (error) {
    console.error('获取景点列表失败:', error)
  }
}

const handleAdd = () => {
  dialogTitle.value = '新增门票'
  Object.assign(formData, {
    name: '',
    scenicId: undefined,
    type: 'ADULT',
    description: '',
    price: 0,
    originalPrice: 0,
    stock: 0,
    dailyLimit: 0,
    refundable: true
  })
  dialogVisible.value = true
}

const handleEdit = (ticket: Ticket) => {
  dialogTitle.value = '编辑门票'
  Object.assign(formData, { ...ticket })
  dialogVisible.value = true
}

const handleSubmit = async () => {
  if (!formRef.value) return
  await formRef.value.validate(async (valid) => {
    if (valid) {
      submitLoading.value = true
      try {
        if (formData.id) {
          await ticketApi.update(formData.id, formData)
          ElMessage.success('更新成功')
        } else {
          await ticketApi.create(formData)
          ElMessage.success('创建成功')
        }
        dialogVisible.value = false
        fetchTickets()
      } catch (error) {
        console.error('提交失败:', error)
      } finally {
        submitLoading.value = false
      }
    }
  })
}

const handleDialogClose = () => {
  formRef.value?.resetFields()
}

onMounted(() => {
  fetchTickets()
  fetchScenics()
})
</script>

<style scoped>
.tickets-page {
  padding: 0;
  max-width: 1400px;
  margin: 0 auto;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
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

.ticket-card {
  margin-bottom: 24px;
  border-left: 4px solid;
  border-radius: 16px;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  padding: 24px;
}

.ticket-card:hover {
  box-shadow: 0 12px 32px rgba(0, 0, 0, 0.12), 0 2px 8px rgba(0, 0, 0, 0.08);
  transform: translateY(-4px);
}

.card-indigo {
  border-left-color: #007aff;
}

.card-blue {
  border-left-color: #5856d6;
}

.card-amber {
  border-left-color: #ff9500;
}

.ticket-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}

.ticket-name {
  font-size: 20px;
  font-weight: 600;
  margin: 0;
  color: #1d1d1f;
  letter-spacing: -0.3px;
}

.edit-btn {
  color: rgba(0, 0, 0, 0.4);
  font-size: 18px;
  transition: color 0.2s;
}

.edit-btn:hover {
  color: #007aff;
}

.ticket-desc {
  font-size: 15px;
  color: rgba(0, 0, 0, 0.5);
  margin: 0 0 20px 0;
  min-height: 48px;
  line-height: 1.6;
}

.ticket-footer {
  margin-bottom: 16px;
}

.ticket-price {
  display: flex;
  align-items: baseline;
  gap: 8px;
}

.price {
  font-size: 32px;
  font-weight: 600;
  color: #007aff;
  letter-spacing: -1px;
}

.unit {
  font-size: 14px;
  color: rgba(0, 0, 0, 0.4);
}

.original-price {
  font-size: 14px;
  color: rgba(0, 0, 0, 0.4);
  text-decoration: line-through;
}

.ticket-tags {
  margin-top: 16px;
  padding-top: 16px;
  border-top: 1px solid rgba(0, 0, 0, 0.06);
}
</style>
