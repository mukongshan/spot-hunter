package org.backend.spothunterserver.controller;

import org.backend.spothunterserver.dto.common.ApiResponse;
import org.backend.spothunterserver.dto.notice.*;
import org.backend.spothunterserver.service.NoticeService;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/admin/notice")
public class AdminNoticeController {

    private final NoticeService noticeService;

    public AdminNoticeController(NoticeService noticeService) {
        this.noticeService = noticeService;
    }

    @PostMapping
    public ApiResponse<NoticeOperationResponse> createNotice(@RequestBody NoticeCreateRequest request) {
        NoticeOperationResponse response = noticeService.createNotice(request);
        return ApiResponse.success(response);
    }

    @PutMapping("/{id}")
    public ApiResponse<NoticeOperationResponse> updateNotice(
            @PathVariable Long id,
            @RequestBody NoticeUpdateRequest request) {
        NoticeOperationResponse response = noticeService.updateNotice(id, request);
        return ApiResponse.success(response);
    }

    @DeleteMapping("/{id}")
    public ApiResponse<NoticeOperationResponse> deleteNotice(@PathVariable Long id) {
        NoticeOperationResponse response = noticeService.deleteNotice(id);
        return ApiResponse.success(response);
    }
}