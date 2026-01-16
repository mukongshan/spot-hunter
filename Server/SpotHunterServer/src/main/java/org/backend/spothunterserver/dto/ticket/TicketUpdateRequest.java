package org.backend.spothunterserver.dto.ticket;

import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

@Getter
@Setter
public class TicketUpdateRequest {
    private String name;
    private String type;
    private String description;
    private BigDecimal price;
    private BigDecimal originalPrice;
    private Integer stock;
    private Integer dailyLimit;
    private String validityType;
    private Integer validityDays;
    private LocalDate startDate;
    private LocalDate endDate;
    private String usageRule;
    private Boolean refundable;
    private String refundRule;
    private String changeRule;
    private List<String> tags;
    private String status;
}