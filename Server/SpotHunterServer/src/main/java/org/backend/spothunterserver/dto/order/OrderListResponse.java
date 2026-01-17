package org.backend.spothunterserver.dto.order;

import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Getter
@Setter
public class OrderListResponse {
    private Long total;
    private Integer page;
    private Integer size;
    private List<OrderItem> list;

    @Getter
    @Setter
    public static class OrderItem {
        private Long orderId;
        private String orderNo;
        private Long userId;
        private String username;
        private String nickname;
        private String status;
        private BigDecimal totalPrice;
        private BigDecimal payAmount;
        private String ticketName;
        private Integer quantity;
        private String scenicName;
        private LocalDate visitDate;
        private LocalDateTime createTime;
        private LocalDateTime payExpireTime;
        private LocalDateTime payTime;
        private String ticketCode;
    }
}