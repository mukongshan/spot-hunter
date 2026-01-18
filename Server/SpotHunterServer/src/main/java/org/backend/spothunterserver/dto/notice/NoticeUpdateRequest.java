package org.backend.spothunterserver.dto.notice;

import lombok.Getter;
import lombok.Setter;

import java.util.List;

@Getter
@Setter
public class NoticeUpdateRequest {
    private String title;
    private String summary;
    private String content;
    private String cover;
    private List<String> images;
    private String author;
    private Boolean isTop;
    private String status;
}