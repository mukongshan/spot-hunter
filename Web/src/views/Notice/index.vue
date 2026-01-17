<template>
  <div class="notice-page">
    <div class="page-header">
      <div class="header-left">
        <h2 class="page-title">公告发布</h2>
        <p class="page-desc">发布和管理景区公告信息</p>
      </div>
    </div>

    <!-- 发布公告卡片 -->
    <el-card class="publish-card" shadow="never">
      <template #header>
        <div class="card-header">
          <h3 class="card-title">发布新公告</h3>
        </div>
      </template>
      <el-form
        ref="formRef"
        :model="formData"
        :rules="formRules"
        label-width="100px"
      >
        <el-form-item label="公告标题" prop="title">
          <el-input v-model="formData.title" placeholder="请输入公告标题" size="large" />
        </el-form-item>
        <el-form-item label="摘要">
          <el-input
            v-model="formData.summary"
            type="textarea"
            :rows="2"
            placeholder="请输入公告摘要"
          />
        </el-form-item>
        <el-form-item label="公告内容" prop="content">
          <el-input
            v-model="formData.content"
            type="textarea"
            :rows="8"
            placeholder="请输入公告正文内容，支持Markdown格式"
          />
        </el-form-item>
        <el-form-item label="封面图">
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
        <el-form-item>
          <el-checkbox v-model="formData.isTop">置顶显示</el-checkbox>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" size="large" @click="handlePublish" :loading="submitLoading">
            确认发布
          </el-button>
          <el-button size="large" @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- 公告列表 -->
    <el-card class="list-card" shadow="never">
      <template #header>
        <div class="card-header">
          <span class="card-title">公告列表</span>
        </div>
      </template>
      <el-table :data="noticeList" v-loading="loading" stripe style="width: 100%">
        <el-table-column type="index" label="序号" width="80" align="center" />
        <el-table-column prop="title" label="标题" min-width="200" />
        <el-table-column prop="author" label="发布人" width="120" />
        <el-table-column prop="publishTime" label="发布时间" width="180" />
        <el-table-column label="操作" width="180" fixed="right" align="center">
          <template #default="{ row }">
            <el-button type="primary" link @click="handleEdit(row)">编辑</el-button>
            <el-button type="danger" link @click="handleDelete(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import type { FormInstance, FormRules } from 'element-plus'
import { Plus } from '@element-plus/icons-vue'
import { noticeApi, uploadApi } from '@/api'
import type { Notice } from '@/api'
import { normalizeImageUrl } from '@/utils/image'

const loading = ref(false)
const submitLoading = ref(false)
const formRef = ref<FormInstance>()
const noticeList = ref<Notice[]>([])

const formData = reactive<Partial<Notice>>({
  title: '',
  summary: '',
  content: '',
  cover: '',
  isTop: false
})

const formRules: FormRules = {
  title: [{ required: true, message: '请输入公告标题', trigger: 'blur' }],
  content: [{ required: true, message: '请输入公告内容', trigger: 'blur' }]
}

const fetchNotices = async () => {
  loading.value = true
  try {
    const data = await noticeApi.getList()
    noticeList.value = data
  } catch (error) {
    console.error('获取公告列表失败:', error)
  } finally {
    loading.value = false
  }
}

const handlePublish = async () => {
  if (!formRef.value) return
  await formRef.value.validate(async (valid) => {
    if (valid) {
      submitLoading.value = true
      try {
        await noticeApi.create({
          ...formData,
          author: '系统管理员',
          status: 'PUBLISHED'
        })
        ElMessage.success('发布成功')
        handleReset()
        fetchNotices()
      } catch (error) {
        console.error('发布失败:', error)
      } finally {
        submitLoading.value = false
      }
    }
  })
}

const handleEdit = (row: Notice) => {
  Object.assign(formData, {
    id: row.id,
    title: row.title,
    summary: row.summary || '',
    content: row.content,
    cover: row.cover,
    isTop: row.isTop || false
  })
  // 可以打开编辑对话框
}

const handleDelete = async (row: Notice) => {
  try {
    await ElMessageBox.confirm('确定要删除该公告吗？', '提示', {
      type: 'warning'
    })
    await noticeApi.delete(row.id)
    ElMessage.success('删除成功')
    fetchNotices()
  } catch (error: any) {
    if (error !== 'cancel') {
      console.error('删除失败:', error)
    }
  }
}

const handleReset = () => {
  Object.assign(formData, {
    title: '',
    summary: '',
    content: '',
    cover: '',
    isTop: false
  })
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

onMounted(() => {
  fetchNotices()
})
</script>

<style scoped>
.notice-page {
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

.publish-card {
  margin-bottom: 24px;
  border-radius: 16px;
  padding: 32px;
}

.list-card {
  margin-top: 24px;
  border-radius: 16px;
  padding: 24px;
}

.card-header {
  font-weight: 600;
  color: #1d1d1f;
}

.card-title {
  font-size: 18px;
  font-weight: 600;
  color: #1d1d1f;
  margin: 0;
  letter-spacing: -0.3px;
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
  width: 360px;
  height: 216px;
  object-fit: cover;
  display: block;
  border-radius: 12px;
}

.cover-uploader-icon {
  font-size: 32px;
  color: rgba(0, 0, 0, 0.3);
  width: 360px;
  height: 216px;
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
