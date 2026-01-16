package org.backend.spothunterserver.dto.ticket;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

@Getter
@Setter
public class TicketCreateRequest {
    @NotNull(message = "景点ID不能为空")
    private Long scenicId;

    @NotBlank(message = "门票名称不能为空")
    private String name;

    private String type;
    private String description;

    @NotNull(message = "价格不能为空")
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
}