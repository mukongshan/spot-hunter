/**
 * 将后端返回的图片URL转换为前端可用的URL
 * 后端返回: http://localhost:8080/upload/...
 * 前端在开发环境需要直接访问后端（因为后端静态资源映射配置有问题）
 */
export function normalizeImageUrl(url: string | undefined | null): string {
  if (!url) {
    return ''
  }
  
  // 如果已经是 http://localhost:8080/upload 开头，直接返回（开发环境直接访问后端）
  if (url.startsWith('http://localhost:8080/upload') || url.startsWith('http://127.0.0.1:8080/upload')) {
    return url
  }
  
  // 如果已经是相对路径 /upload，尝试转换为绝对路径
  if (url.startsWith('/upload')) {
    // 在开发环境，直接访问后端端口
    return `http://localhost:8080${url}`
  }
  
  // 如果包含 /upload/，提取并转换
  const uploadIndex = url.indexOf('/upload/')
  if (uploadIndex !== -1) {
    const path = url.substring(uploadIndex)
    return `http://localhost:8080${path}`
  }
  
  // 尝试解析为URL对象
  try {
    const urlObj = new URL(url)
    const pathname = urlObj.pathname
    // 如果路径包含 /upload，转换为本地后端URL
    const uploadPos = pathname.indexOf('/upload')
    if (uploadPos !== -1) {
      return `http://localhost:8080${pathname.substring(uploadPos)}`
    }
  } catch (e) {
    // 不是有效的URL，继续处理
  }
  
  // 其他情况保持不变
  return url
}
