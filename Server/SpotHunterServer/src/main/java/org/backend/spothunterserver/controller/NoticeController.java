package org.backend.spothunterserver.controller;

import org.backend.spothunterserver.dto.common.ApiResponse;
import org.backend.spothunterserver.dto.notice.NoticeDetailResponse;
import org.backend.spothunterserver.dto.notice.NoticeListResponse;
import org.backend.spothunterserver.service.NoticeService;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/notice")
public class NoticeController {

    private final NoticeService noticeService;

    public NoticeController(NoticeService noticeService) {
        this.noticeService = noticeService;
    }

    @GetMapping("/list")
    public ApiResponse<NoticeListResponse> getNoticeList() {
        NoticeListResponse response = noticeService.getNoticeList();
        return ApiResponse.success(response);
    }

    @GetMapping("/{id}")
    public ApiResponse<NoticeDetailResponse> getNoticeDetail(@PathVariable Long id) {
        NoticeDetailResponse response = noticeService.getNoticeDetail(id);
        return ApiResponse.success(response);
    }
}