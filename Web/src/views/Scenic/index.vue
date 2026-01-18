<template>
  <div class="scenic-page">
    <div class="page-header">
      <div class="header-left">
        <h2 class="page-title">景点管理</h2>
        <p class="page-desc">管理景区内的所有景点信息</p>
      </div>
      <el-button type="primary" size="large" @click="handleAdd">
        <el-icon><Plus /></el-icon>
        新增景点
      </el-button>
    </div>

    <!-- 搜索栏 -->
    <el-card class="search-card" shadow="never">
      <el-form :inline="true" :model="searchForm">
        <el-form-item label="景点名称">
          <el-input 
            v-model="searchForm.keyword" 
            placeholder="请输入景点名称" 
            clearable
            style="width: 300px;"
            @keyup.enter="handleSearch"
          >
            <template #prefix>
              <el-icon><Search /></el-icon>
            </template>
          </el-input>
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
        <el-table-column type="index" label="序号" width="80" align="center" />
        <el-table-column label="景点名称" min-width="250">
          <template #default="{ row }">
            <div class="scenic-info">
              <el-image
                :src="normalizeImageUrl(row.cover) || '/placeholder.svg'"
                class="scenic-cover"
                fit="cover"
                :preview-src-list="row.cover ? [normalizeImageUrl(row.cover)] : []"
              />
              <div class="scenic-details">
                <div class="scenic-name">{{ row.name }}</div>
                <div class="scenic-location">
                  <el-icon><Location /></el-icon>
                  {{ row.location }}
                </div>
              </div>
            </div>
          </template>
        </el-table-column>
        <el-table-column prop="openTime" label="开放时间" width="150" />
        <el-table-column label="操作" width="180" fixed="right" align="center">
          <template #default="{ row }">
            <el-button type="primary" link @click="handleEdit(row)">编辑</el-button>
            <el-button type="danger" link @click="handleDelete(row)">删除</el-button>
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

    <!-- 编辑对话框 -->
    <el-dialog
      v-model="dialogVisible"
      :title="dialogTitle"
      width="800px"
      @close="handleDialogClose"
    >
      <el-form
        ref="formRef"
        :model="formData"
        :rules="formRules"
        label-width="100px"
      >
        <el-form-item label="景点名称" prop="name">
          <el-input v-model="formData.name" placeholder="请输入景点名称" />
        </el-form-item>
        <el-form-item label="封面图" prop="cover">
          <el-upload
            class="cover-uploader"
            :auto-upload="false"
            :on-change="handleFileChange"
            :before-upload="beforeUpload"
            :show-file-list="false"
          >
            <img v-if="formData.cover" :src="normalizeImageUrl(formData.cover)" class="cover-image" />
            <el-icon v-else class="cover-uploader-icon"><Plus /></el-icon>
          </el-upload>
          <div class="upload-tip">支持 JPG、PNG 格式，大小不超过 5MB</div>
        </el-form-item>
        <el-form-item label="所属区域" prop="location">
          <el-input v-model="formData.location" placeholder="请输入所属区域" />
        </el-form-item>
        <el-form-item label="开放时间" prop="openTime">
          <div style="display: flex; align-items: center; gap: 12px; width: 100%;">
            <el-time-picker
              v-model="openTimeRange.start"
              format="HH:mm"
              placeholder="开始时间"
              value-format="HH:mm"
              style="flex: 1;"
            />
            <span style="color: #94a3b8;">至</span>
            <el-time-picker
              v-model="openTimeRange.end"
              format="HH:mm"
              placeholder="结束时间"
              value-format="HH:mm"
              style="flex: 1;"
            />
          </div>
        </el-form-item>
        <el-form-item label="门票价格" prop="price">
          <el-input-number v-model="formData.price" :min="0" :precision="2" style="width: 100%" />
        </el-form-item>
        <el-form-item label="简介" prop="description">
          <el-input
            v-model="formData.description"
            type="textarea"
            :rows="3"
            placeholder="请输入景点简介"
          />
        </el-form-item>
        <el-form-item label="详细描述" prop="detail">
          <el-input
            v-model="formData.detail"
            type="textarea"
            :rows="5"
            placeholder="请输入详细描述"
          />
        </el-form-item>
        <el-form-item label="详细地址">
          <el-input v-model="formData.address" placeholder="请输入详细地址" />
        </el-form-item>
        <el-form-item label="联系电话">
          <el-input v-model="formData.phone" placeholder="请输入联系电话" />
        </el-form-item>
        <el-form-item label="标签">
          <el-tag
            v-for="tag in formData.tags"
            :key="tag"
            closable
            @close="handleTagClose(tag)"
            style="margin-right: 8px;"
          >
            {{ tag }}
          </el-tag>
          <el-input
            v-if="tagInputVisible"
            ref="tagInputRef"
            v-model="tagInputValue"
            size="small"
            style="width: 100px;"
            @keyup.enter="handleTagConfirm"
            @blur="handleTagConfirm"
          />
          <el-button v-else size="small" @click="showTagInput">+ 添加标签</el-button>
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
import { ref, reactive, onMounted, computed } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import type { FormInstance, FormRules } from 'element-plus'
import { Plus, Search, Location } from '@element-plus/icons-vue'
import { scenicApi, uploadApi } from '@/api'
import type { Scenic } from '@/api'
import { normalizeImageUrl } from '@/utils/image'

const loading = ref(false)
const submitLoading = ref(false)
const dialogVisible = ref(false)
const dialogTitle = ref('新增景点')
const formRef = ref<FormInstance>()
const tagInputRef = ref()
const tagInputVisible = ref(false)
const tagInputValue = ref('')

const searchForm = reactive({
  keyword: ''
})

const pagination = reactive({
  page: 1,
  size: 10,
  total: 0
})

const tableData = ref<Scenic[]>([])

const formData = reactive<Partial<Scenic>>({
  name: '',
  cover: '',
  location: '',
  openTime: '',
  price: 0,
  description: '',
  detail: '',
  tags: [],
  address: '',
  phone: ''
})

// 开放时间范围
const openTimeRange = reactive({
  start: '',
  end: ''
})

// 将时间范围字符串解析为开始和结束时间
const parseOpenTime = (openTime: string | undefined) => {
  if (!openTime) {
    openTimeRange.start = ''
    openTimeRange.end = ''
    return
  }
  const parts = openTime.split('-')
  if (parts.length === 2) {
    openTimeRange.start = parts[0].trim()
    openTimeRange.end = parts[1].trim()
  } else {
    openTimeRange.start = ''
    openTimeRange.end = ''
  }
}

// 将开始和结束时间组合成时间范围字符串
const formatOpenTime = (): string => {
  if (openTimeRange.start && openTimeRange.end) {
    return `${openTimeRange.start}-${openTimeRange.end}`
  }
  return ''
}

const validateOpenTime = (rule: any, value: any, callback: any) => {
  if (!openTimeRange.start || !openTimeRange.end) {
    callback(new Error('请选择完整的开放时间范围'))
  } else {
    callback()
  }
}

const formRules: FormRules = {
  name: [{ required: true, message: '请输入景点名称', trigger: 'blur' }],
  location: [{ required: true, message: '请输入所属区域', trigger: 'blur' }],
  openTime: [{ validator: validateOpenTime, trigger: 'change' }]
}

const fetchData = async () => {
  loading.value = true
  try {
    const response = await scenicApi.getList({
      page: pagination.page,
      size: pagination.size,
      keyword: searchForm.keyword || undefined
    })
    tableData.value = response.list
    pagination.total = response.total
  } catch (error) {
    console.error('获取景点列表失败:', error)
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
  handleSearch()
}

const handleSizeChange = () => {
  fetchData()
}

const handlePageChange = () => {
  fetchData()
}

const handleAdd = () => {
  dialogTitle.value = '新增景点'
  Object.assign(formData, {
    name: '',
    cover: '',
    location: '',
    openTime: '',
    price: 0,
    description: '',
    detail: '',
    tags: [],
    address: '',
    phone: ''
  })
  parseOpenTime('')
  dialogVisible.value = true
}

const handleEdit = (row: Scenic) => {
  dialogTitle.value = '编辑景点'
  Object.assign(formData, { ...row })
  parseOpenTime(row.openTime)
  dialogVisible.value = true
}

const handleDelete = async (row: Scenic) => {
  try {
    await ElMessageBox.confirm('确定要删除该景点吗？', '提示', {
      type: 'warning'
    })
    await scenicApi.delete(row.id)
    ElMessage.success('删除成功')
    fetchData()
  } catch (error: any) {
    if (error !== 'cancel') {
      console.error('删除失败:', error)
    }
  }
}

const handleSubmit = async () => {
  if (!formRef.value) return
  await formRef.value.validate(async (valid) => {
    if (valid) {
      submitLoading.value = true
      try {
        // 将时间范围组合成字符串
        formData.openTime = formatOpenTime()
        
        if (formData.id) {
          await scenicApi.update(formData.id, formData)
          ElMessage.success('更新成功')
        } else {
          await scenicApi.create(formData)
          ElMessage.success('创建成功')
        }
        dialogVisible.value = false
        fetchData()
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

const beforeUpload = (file: File) => {
  const isImage = file.type.startsWith('image/')
  const isLt5M = file.size / 1024 / 1024 < 5
  if (!isImage) {
    ElMessage.error('只能上传图片文件!')
    return false
  }
  if (!isLt5M) {
    ElMessage.error('图片大小不能超过 5MB!')
    return false
  }
  return false // 阻止自动上传
}

const handleFileChange = async (file: any) => {
  const uploadFile = file.raw
  if (!uploadFile) return
  
  try {
    const result = await uploadApi.uploadImage(uploadFile)
    formData.cover = normalizeImageUrl(result.url)
    ElMessage.success('上传成功')
  } catch (error) {
    ElMessage.error('上传失败')
  }
}

const showTagInput = () => {
  tagInputVisible.value = true
  setTimeout(() => {
    tagInputRef.value?.focus()
  })
}

const handleTagConfirm = () => {
  if (tagInputValue.value && !formData.tags?.includes(tagInputValue.value)) {
    if (!formData.tags) formData.tags = []
    formData.tags.push(tagInputValue.value)
  }
  tagInputVisible.value = false
  tagInputValue.value = ''
}

const handleTagClose = (tag: string) => {
  if (formData.tags) {
    const index = formData.tags.indexOf(tag)
    if (index > -1) {
      formData.tags.splice(index, 1)
    }
  }
}

onMounted(() => {
  fetchData()
})
</script>

<style scoped>
.scenic-page {
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

.search-card {
  margin-bottom: 24px;
  border-radius: 16px;
  padding: 24px;
}

.table-card {
  border-radius: 16px;
  padding: 24px;
}

.scenic-info {
  display: flex;
  align-items: center;
  gap: 16px;
}

.scenic-cover {
  width: 64px;
  height: 64px;
  border-radius: 12px;
  object-fit: cover;
  flex-shrink: 0;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
  transition: transform 0.2s;
}

.scenic-cover:hover {
  transform: scale(1.05);
}

.scenic-details {
  flex: 1;
  min-width: 0;
}

.scenic-name {
  font-weight: 600;
  color: #1d1d1f;
  margin-bottom: 6px;
  font-size: 15px;
}

.scenic-location {
  display: flex;
  align-items: center;
  gap: 4px;
  font-size: 13px;
  color: rgba(0, 0, 0, 0.5);
}

.pagination {
  margin-top: 32px;
  display: flex;
  justify-content: flex-end;
  padding-top: 24px;
  border-top: 1px solid rgba(0, 0, 0, 0.06);
}

.cover-uploader {
  :deep(.el-upload) {
    border: 2px dashed rgba(0, 0, 0, 0.1);
    border-radius: 12px;
    cursor: pointer;
    position: relative;
    overflow: hidden;
    transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    background-color: #fafafa;
  }
  :deep(.el-upload:hover) {
    border-color: #007aff;
    background-color: #f5f5f7;
    box-shadow: 0 4px 12px rgba(0, 122, 255, 0.15);
  }
}

.cover-image {
  width: 240px;
  height: 144px;
  object-fit: cover;
  display: block;
  border-radius: 12px;
}

.cover-uploader-icon {
  font-size: 32px;
  color: rgba(0, 0, 0, 0.3);
  width: 240px;
  height: 144px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.upload-tip {
  font-size: 12px;
  color: rgba(0, 0, 0, 0.4);
  margin-top: 12px;
  font-weight: 400;
}
</style>
