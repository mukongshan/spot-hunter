package org.backend.spothunterserver.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "spot")
@Getter
@Setter
public class Spot {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 200)
    private String name;

    @Column(length = 500)
    private String cover; // 封面图

    @Column(columnDefinition = "TEXT")
    private String images; // JSON格式存储图片数组

    @Column(length = 200)
    private String location; // 地点

    @Column(columnDefinition = "TEXT")
    private String description; // 简介

    @Column(columnDefinition = "TEXT")
    private String detail; // 详细描述

    @Column(length = 100)
    private String openTime; // 开放时间

    @Column(length = 500)
    private String ticketInfo; // 门票信息

    @Column(length = 200)
    private String address; // 详细地址

    @Column(length = 50)
    private String phone; // 联系电话

    @Column(columnDefinition = "DECIMAL(10,2) DEFAULT 0")
    private BigDecimal price = BigDecimal.ZERO; // 价格

    @Column(columnDefinition = "DECIMAL(3,2) DEFAULT 0")
    private BigDecimal rating = BigDecimal.ZERO; // 评分

    @Column
    private Integer reviewCount = 0; // 评论数

    @Column(columnDefinition = "TEXT")
    private String tags; // JSON格式存储标签数组

    @Column(columnDefinition = "TEXT")
    private String attractions; // JSON格式存储景点内的景点数组

    @Column(columnDefinition = "TEXT")
    private String services; // JSON格式存储服务数组

    @Column(length = 100)
    private String recommendHours; // 推荐游玩时长

    @Column(length = 100)
    private String bestSeason; // 最佳季节

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