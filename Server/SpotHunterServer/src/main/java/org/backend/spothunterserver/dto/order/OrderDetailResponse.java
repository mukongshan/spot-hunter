package org.backend.spothunterserver.dto.order;

import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Getter
@Setter
public class OrderDetailResponse {
    private Long orderId;
    private String orderNo;
    private Long userId;
    private String username;
    private String status;
    private BigDecimal totalPrice;
    private BigDecimal payAmount;
    private String payMethod;
    private Long ticketId;
    private String ticketName;
    private Long scenicId;
    private String scenicName;
    private Integer quantity;
    private BigDecimal unitPrice;
    private LocalDate visitDate;
    private String visitorName;
    private String visitorPhone;
    private String visitorIdCard;
    private LocalDateTime createTime;
    private LocalDateTime payTime;
    private LocalDateTime payExpireTime;
    private LocalDateTime cancelTime;
    private LocalDateTime refundTime;
    private List<TicketInfo> tickets;
    private Boolean refundable;
    private Boolean cancelable;
    
    @Getter
    @Setter
    public static class TicketInfo {
        private String ticketCode;
        private String ticketNo;
        private String status;
        private String qrCode;
        private LocalDateTime useTime;
    }
}