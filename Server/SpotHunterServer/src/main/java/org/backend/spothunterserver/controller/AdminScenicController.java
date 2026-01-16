package org.backend.spothunterserver.controller;

import org.backend.spothunterserver.dto.common.ApiResponse;
import org.backend.spothunterserver.dto.scenic.*;
import org.backend.spothunterserver.service.SpotService;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/admin/scenic")
public class AdminScenicController {

    private final SpotService spotService;

    public AdminScenicController(SpotService spotService) {
        this.spotService = spotService;
    }

    @PostMapping
    public ApiResponse<ScenicOperationResponse> createScenic(@RequestBody ScenicCreateRequest request) {
        ScenicOperationResponse response = spotService.createScenic(request);
        return ApiResponse.success(response);
    }

    @PutMapping("/{id}")
    public ApiResponse<ScenicOperationResponse> updateScenic(
            @PathVariable Long id,
            @RequestBody ScenicUpdateRequest request) {
        ScenicOperationResponse response = spotService.updateScenic(id, request);
        return ApiResponse.success(response);
    }

    @DeleteMapping("/{id}")
    public ApiResponse<ScenicOperationResponse> deleteScenic(@PathVariable Long id) {
        ScenicOperationResponse response = spotService.deleteScenic(id);
        return ApiResponse.success(response);
    }
}