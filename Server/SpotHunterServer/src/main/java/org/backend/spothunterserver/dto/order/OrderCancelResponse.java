package org.backend.spothunterserver.dto.order;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class OrderCancelResponse {
    private Long orderId;
    private String orderNo;
    private String status;
    private String message;
}