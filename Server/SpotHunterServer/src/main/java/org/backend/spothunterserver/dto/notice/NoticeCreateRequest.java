package org.backend.spothunterserver.dto.notice;

import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.Setter;

import java.util.List;

@Getter
@Setter
public class NoticeCreateRequest {
    @NotBlank(message = "标题不能为空")
    private String title;
    private String summary;
    private String content;
    private String cover;
    private List<String> images;
    private String author;
}