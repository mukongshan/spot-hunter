package org.backend.spothunterserver.dto.scenic;

import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Getter
@Setter
public class ScenicDetailResponse {
    private Long id;
    private String name;
    private String cover;
    private List<String> images;
    private String location;
    private String description;
    private String detail;
    private String openTime;
    private String ticketInfo;
    private String address;
    private String phone;
    private BigDecimal rating;
    private Integer reviewCount;
    private List<String> tags;
    private List<String> attractions;
    private List<String> services;
    private String recommendHours;
    private String bestSeason;
    private LocalDateTime createTime;
    private LocalDateTime updateTime;
}