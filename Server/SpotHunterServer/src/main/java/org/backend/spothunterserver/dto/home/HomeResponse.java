package org.backend.spothunterserver.dto.home;

import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

@Getter
@Setter
public class HomeResponse {
    private List<Banner> banners;
    private List<HotScenic> hotScenic;
    private List<Notice> notices;
    private List<RecommendTicket> recommendTickets;

    @Getter
    @Setter
    public static class Banner {
        private Long id;
        private String title;
        private String image;
        private String link;
        private String type; // SCENIC, NOTICE
    }

    @Getter
    @Setter
    public static class HotScenic {
        private Long id;
        private String name;
        private String cover;
        private String location;
        private BigDecimal price;
        private BigDecimal rating;
    }

    @Getter
    @Setter
    public static class Notice {
        private Long id;
        private String title;
        private String summary;
        private LocalDate publishTime;
    }

    @Getter
    @Setter
    public static class RecommendTicket {
        private Long id;
        private String name;
        private BigDecimal price;
        private BigDecimal originalPrice;
        private String scenicName;
        private String scenicCover;
    }
}