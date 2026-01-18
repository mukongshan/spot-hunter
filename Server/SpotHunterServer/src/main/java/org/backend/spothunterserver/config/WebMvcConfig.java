package org.backend.spothunterserver.config;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class WebMvcConfig implements WebMvcConfigurer {

    @Value("${file.upload.dir:./uploads}")
    private String uploadDir;

    @Value("${file.upload.url-prefix:/upload}")
    private String urlPrefix;

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        // 配置静态资源映射，使上传的文件可以通过URL访问
        registry.addResourceHandler(urlPrefix + "/**")
                .addResourceLocations("file:" + uploadDir + "/");
    }

    @Bean
    public ObjectMapper objectMapper() {
        return new ObjectMapper();
    }
}