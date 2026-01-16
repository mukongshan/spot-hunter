package org.backend.spothunterserver.dto.scenic;

import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;
import java.util.List;

@Getter
@Setter
public class ScenicUpdateRequest {
    private String name;
    private String cover;
    private List<String> images;
    private String location;
    private String description;
    private String detail;
    private String openTime;
    private String address;
    private String phone;
    private BigDecimal price;
    private List<String> tags;
}