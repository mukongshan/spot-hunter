package org.backend.spothunterserver.dto.notice;

import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;
import java.util.List;

@Getter
@Setter
public class NoticeDetailResponse {
    private Long id;
    private String title;
    private String content;
    private String cover;
    private List<String> images;
    private LocalDateTime publishTime;
    private String author;
    private Integer viewCount;
    private Boolean isTop;
    private String status;
    private LocalDateTime createTime;
    private LocalDateTime updateTime;
}