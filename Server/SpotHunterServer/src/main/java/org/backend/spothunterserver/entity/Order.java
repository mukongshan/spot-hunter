package org.backend.spothunterserver.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "orders")
@Getter
@Setter
public class Order {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "order_id")
    private Long orderId;

    @Column(name = "order_no", nullable = false, unique = true, length = 50)
    private String orderNo; // 订单号

    @Column(name = "user_id", nullable = false)
    private Long userId; // 用户ID

    @Column(nullable = false, length = 20)
    private String status; // 订单状态：UNPAID, PAID, CANCELLED, REFUNDED, USED

    @Column(name = "total_price", nullable = false, columnDefinition = "DECIMAL(10,2)")
    private BigDecimal totalPrice; // 总价

    @Column(name = "pay_amount", nullable = false, columnDefinition = "DECIMAL(10,2)")
    private BigDecimal payAmount; // 实付金额

    @Column(name = "pay_method", length = 20)
    private String payMethod; // 支付方式

    @Column(name = "ticket_id", nullable = false)
    private Long ticketId; // 门票ID

    @Column(name = "scenic_id", nullable = false)
    private Long scenicId; // 景点ID

    @Column(nullable = false)
    private Integer quantity; // 购买数量

    @Column(name = "unit_price", nullable = false, columnDefinition = "DECIMAL(10,2)")
    private BigDecimal unitPrice; // 单价

    @Column(name = "visit_date", nullable = false)
    private LocalDate visitDate; // 游玩日期

    @Column(name = "visitor_name", length = 100)
    private String visitorName; // 游客姓名

    @Column(name = "visitor_phone", length = 20)
    private String visitorPhone; // 游客电话

    @Column(name = "visitor_id_card", length = 50)
    private String visitorIdCard; // 游客身份证

    @Column(name = "create_time", nullable = false, updatable = false)
    private LocalDateTime createTime;

    @Column(name = "pay_time")
    private LocalDateTime payTime; // 支付时间

    @Column(name = "pay_expire_time")
    private LocalDateTime payExpireTime; // 支付过期时间

    @Column(name = "cancel_time")
    private LocalDateTime cancelTime; // 取消时间

    @Column(name = "refund_time")
    private LocalDateTime refundTime; // 退款时间

    @PrePersist
    public void prePersist() {
        LocalDateTime now = LocalDateTime.now();
        if (createTime == null) {
            createTime = now;
        }
        if (orderNo == null) {
            // 生成订单号：ORD + 日期 + 随机数
            orderNo = "ORD" + now.format(java.time.format.DateTimeFormatter.ofPattern("yyyyMMddHHmmss")) + 
                     String.format("%04d", (int)(Math.random() * 10000));
        }
        if (payExpireTime == null && "UNPAID".equals(status)) {
            payExpireTime = now.plusHours(1); // 1小时后过期
        }
    }
}