package org.backend.spothunterserver.dto.notice;

import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;
import java.util.List;

@Getter
@Setter
public class NoticeListResponse {
    private List<NoticeItem> data;

    @Getter
    @Setter
    public static class NoticeItem {
        private Long id;
        private String title;
        private String summary;
        private String cover;
        private LocalDateTime publishTime;
        private String author;
        private Integer viewCount;
    }
}