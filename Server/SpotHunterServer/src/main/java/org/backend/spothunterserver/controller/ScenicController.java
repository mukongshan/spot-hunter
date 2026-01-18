package org.backend.spothunterserver.controller;

import org.backend.spothunterserver.dto.common.ApiResponse;
import org.backend.spothunterserver.dto.scenic.*;
import org.backend.spothunterserver.service.SpotService;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/scenic")
public class ScenicController {

    private final SpotService spotService;

    public ScenicController(SpotService spotService) {
        this.spotService = spotService;
    }

    @GetMapping("/list")
    public ApiResponse<ScenicListResponse> getScenicList(
            @RequestParam(required = false, defaultValue = "1") Integer page,
            @RequestParam(required = false, defaultValue = "10") Integer size,
            @RequestParam(required = false) String keyword) {
        ScenicListResponse response = spotService.getScenicList(page, size, keyword);
        return ApiResponse.success(response);
    }

    @GetMapping("/{id}")
    public ApiResponse<ScenicDetailResponse> getScenicDetail(@PathVariable Long id) {
        ScenicDetailResponse response = spotService.getScenicDetail(id);
        return ApiResponse.success(response);
    }
}