package org.backend.spothunterserver.controller;

import org.backend.spothunterserver.dto.common.ApiResponse;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.UUID;

@RestController
@RequestMapping("/api/upload")
public class UploadController {

    @Value("${file.upload.dir:./uploads}")
    private String uploadDir;

    @Value("${file.upload.url-prefix:http://localhost:8080/upload}")
    private String urlPrefix;

    @PostMapping("/image")
    public ApiResponse<ImageUploadResponse> uploadImage(@RequestParam("file") MultipartFile file) {
        if (file.isEmpty()) {
            throw new IllegalArgumentException("文件不能为空");
        }

        // 检查文件类型
        String contentType = file.getContentType();
        if (contentType == null || !contentType.startsWith("image/")) {
            throw new IllegalArgumentException("只能上传图片文件");
        }

        // 生成文件名
        String originalFilename = file.getOriginalFilename();
        String extension = "";
        if (originalFilename != null && originalFilename.contains(".")) {
            extension = originalFilename.substring(originalFilename.lastIndexOf("."));
        }
        String filename = UUID.randomUUID().toString() + extension;

        // 创建日期目录
        String dateDir = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyy/MM/dd"));
        Path uploadPath = Paths.get(uploadDir, dateDir);
        
        try {
            Files.createDirectories(uploadPath);
        } catch (IOException e) {
            throw new RuntimeException("创建上传目录失败", e);
        }

        // 保存文件
        Path filePath = uploadPath.resolve(filename);
        try {
            Files.copy(file.getInputStream(), filePath, StandardCopyOption.REPLACE_EXISTING);
        } catch (IOException e) {
            throw new RuntimeException("文件上传失败", e);
        }

        // 构建响应
        String url = urlPrefix + "/" + dateDir + "/" + filename;
        ImageUploadResponse response = new ImageUploadResponse();
        response.setUrl(url);
        response.setFilename(filename);
        response.setSize(file.getSize());
        // 可以添加图片宽高等信息，这里简化处理
        response.setMimeType(contentType);

        return ApiResponse.success(response);
    }

    @lombok.Getter
    @lombok.Setter
    public static class ImageUploadResponse {
        private String url;
        private String filename;
        private Long size;
        private Integer width;
        private Integer height;
        private String mimeType;
    }
}