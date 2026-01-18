package org.backend.spothunterserver.dto.scenic;

import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;
import java.util.List;

@Getter
@Setter
public class ScenicListResponse {
    private Long total;
    private Integer page;
    private Integer size;
    private List<ScenicItem> list;

    @Getter
    @Setter
    public static class ScenicItem {
        private Long id;
        private String name;
        private String cover;
        private String location;
        private String description;
        private String openTime;
        private BigDecimal price;
        private BigDecimal rating;
        private List<String> tags;
    }
}