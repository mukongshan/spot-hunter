package org.backend.spothunterserver.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "ticket")
@Getter
@Setter
public class Ticket {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "scenic_id", nullable = false)
    private Long scenicId; // 关联景点ID

    @Column(nullable = false, length = 100)
    private String name; // 门票名称

    @Column(length = 50)
    private String type; // 门票类型：ADULT, STUDENT, CHILD

    @Column(columnDefinition = "TEXT")
    private String description; // 描述

    @Column(nullable = false, columnDefinition = "DECIMAL(10,2)")
    private BigDecimal price; // 价格

    @Column(name = "original_price", columnDefinition = "DECIMAL(10,2)")
    private BigDecimal originalPrice; // 原价

    @Column
    private Integer stock = 0; // 库存

    @Column(name = "daily_limit")
    private Integer dailyLimit; // 每日限购

    @Column(name = "sold_today")
    private Integer soldToday = 0; // 今日已售

    @Column(name = "validity_type", length = 50)
    private String validityType; // 有效期类型：FIXED_DATE, FLEXIBLE

    @Column(name = "validity_days")
    private Integer validityDays; // 有效期天数

    @Column(name = "start_date")
    private LocalDate startDate; // 开始日期

    @Column(name = "end_date")
    private LocalDate endDate; // 结束日期

    @Column(columnDefinition = "TEXT")
    private String usageRule; // 使用规则

    @Column
    private Boolean refundable = true; // 是否可退

    @Column(columnDefinition = "TEXT")
    private String refundRule; // 退款规则

    @Column(columnDefinition = "TEXT")
    private String changeRule; // 改签规则

    @Column(columnDefinition = "TEXT")
    private String tags; // JSON格式存储标签

    @Column(length = 20)
    private String status = "ON_SALE"; // 状态：ON_SALE, SOLD_OUT, OFFLINE

    @Column(name = "create_time", nullable = false, updatable = false)
    private LocalDateTime createTime;

    @Column(name = "update_time")
    private LocalDateTime updateTime;

    @PrePersist
    public void prePersist() {
        LocalDateTime now = LocalDateTime.now();
        if (createTime == null) {
            createTime = now;
        }
        updateTime = now;
    }

    @PreUpdate
    public void preUpdate() {
        updateTime = LocalDateTime.now();
    }
}