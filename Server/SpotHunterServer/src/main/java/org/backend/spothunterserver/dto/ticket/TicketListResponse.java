package org.backend.spothunterserver.dto.ticket;

import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

@Getter
@Setter
public class TicketListResponse {
    private List<TicketItem> data;

    @Getter
    @Setter
    public static class TicketItem {
        private Long id;
        private String name;
        private String description;
        private BigDecimal price;
        private BigDecimal originalPrice;
        private Integer stock;
        private Integer dailyLimit;
        private String validityType;
        private Integer validityDays;
        private LocalDate startDate;
        private LocalDate endDate;
        private Boolean refundable;
        private String refundRule;
        private List<String> tags;
    }
}