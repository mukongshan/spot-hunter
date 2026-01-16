package org.backend.spothunterserver.dto.scenic;

import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;
import java.util.List;

@Getter
@Setter
public class ScenicCreateRequest {
    @NotBlank(message = "景点名称不能为空")
    private String name;
    private String cover;
    private List<String> images;
    private String location;
    private String description;
    private String detail;
    private String openTime;
    private String address;
    private String phone;
    private BigDecimal price = BigDecimal.ZERO;
    private List<String> tags;
}