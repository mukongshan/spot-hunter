package org.backend.spothunterserver.dto.order;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDate;

@Getter
@Setter
public class OrderCreateRequest {
    @NotNull(message = "门票ID不能为空")
    private Long ticketId;

    @NotNull(message = "购买数量不能为空")
    @Min(value = 1, message = "购买数量至少为1")
    private Integer quantity;

    @NotNull(message = "游玩日期不能为空")
    private LocalDate visitDate;

    @NotBlank(message = "游客姓名不能为空")
    private String visitorName;

    @NotBlank(message = "游客电话不能为空")
    private String visitorPhone;

    private String visitorIdCard;
}