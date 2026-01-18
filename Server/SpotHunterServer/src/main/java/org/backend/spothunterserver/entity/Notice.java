package org.backend.spothunterserver.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;

@Entity
@Table(name = "notice")
@Getter
@Setter
public class Notice {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 200)
    private String title;

    @Column(columnDefinition = "TEXT")
    private String summary; // 摘要

    @Column(columnDefinition = "TEXT")
    private String content; // 内容

    @Column(length = 500)
    private String cover; // 封面图

    @Column(columnDefinition = "TEXT")
    private String images; // JSON格式存储图片数组

    @Column(length = 100)
    private String author; // 作者

    @Column
    private Integer viewCount = 0; // 浏览量

    @Column
    private Boolean isTop = false; // 是否置顶

    @Column(length = 20)
    private String status = "PUBLISHED"; // 状态：DRAFT, PUBLISHED

    @Column(name = "publish_time")
    private LocalDateTime publishTime; // 发布时间

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
        if (publishTime == null && "PUBLISHED".equals(status)) {
            publishTime = now;
        }
    }

    @PreUpdate
    public void preUpdate() {
        updateTime = LocalDateTime.now();
        if (publishTime == null && "PUBLISHED".equals(status)) {
            publishTime = LocalDateTime.now();
        }
    }
}