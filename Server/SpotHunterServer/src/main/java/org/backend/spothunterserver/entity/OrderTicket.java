package org.backend.spothunterserver.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;

@Entity
@Table(name = "order_ticket")
@Getter
@Setter
public class OrderTicket {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "order_id", nullable = false)
    private Long orderId; // 订单ID

    @Column(name = "ticket_code", length = 50)
    private String ticketCode; // 门票码

    @Column(name = "ticket_no", nullable = false, unique = true, length = 50)
    private String ticketNo; // 门票号

    @Column(length = 20)
    private String status; // 状态：UNUSED, USED, REFUNDED

    @Column(columnDefinition = "TEXT")
    private String qrCode; // 二维码

    @Column(name = "use_time")
    private LocalDateTime useTime; // 使用时间

    @PrePersist
    public void prePersist() {
        if (ticketNo == null) {
            ticketNo = "TK" + System.currentTimeMillis() + String.format("%04d", (int)(Math.random() * 10000));
        }
        if (status == null) {
            status = "UNUSED";
        }
    }
}