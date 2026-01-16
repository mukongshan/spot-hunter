package org.backend.spothunterserver.dto.order;

import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Getter
@Setter
public class OrderCreateResponse {
    private Long orderId;
    private String orderNo;
    private String status;
    private BigDecimal totalPrice;
    private BigDecimal payAmount;
    private String ticketName;
    private Integer quantity;
    private LocalDate visitDate;
    private String visitorName;
    private LocalDateTime createTime;
    private LocalDateTime payExpireTime;
}