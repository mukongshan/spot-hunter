package org.backend.spothunterserver.service;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.backend.spothunterserver.dto.notice.*;
import org.backend.spothunterserver.entity.Notice;
import org.backend.spothunterserver.repository.NoticeRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class NoticeService {

    private final NoticeRepository noticeRepository;
    private final ObjectMapper objectMapper;

    public NoticeService(NoticeRepository noticeRepository, ObjectMapper objectMapper) {
        this.noticeRepository = noticeRepository;
        this.objectMapper = objectMapper;
    }

    public NoticeListResponse getNoticeList() {
        List<Notice> notices = noticeRepository.findAllPublished();
        NoticeListResponse response = new NoticeListResponse();

        List<NoticeListResponse.NoticeItem> items = notices.stream()
                .map(this::convertToNoticeItem)
                .collect(Collectors.toList());
        response.setData(items);

        return response;
    }

    public NoticeDetailResponse getNoticeDetail(Long id) {
        Notice notice = noticeRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("公告不存在"));

        // 增加浏览量
        notice.setViewCount(notice.getViewCount() + 1);
        noticeRepository.save(notice);

        return convertToNoticeDetail(notice);
    }

    @Transactional
    public NoticeOperationResponse createNotice(NoticeCreateRequest request) {
        Notice notice = new Notice();
        notice.setTitle(request.getTitle());
        notice.setSummary(request.getSummary());
        notice.setContent(request.getContent());
        notice.setCover(request.getCover());
        notice.setImages(convertListToJson(request.getImages()));
        notice.setAuthor(request.getAuthor() != null ? request.getAuthor() : "景区管理处");
        notice.setStatus("PUBLISHED");

        Notice saved = noticeRepository.save(notice);

        NoticeOperationResponse response = new NoticeOperationResponse();
        response.setId(saved.getId());
        response.setMessage("公告发布成功");
        return response;
    }

    @Transactional
    public NoticeOperationResponse updateNotice(Long id, NoticeUpdateRequest request) {
        Notice notice = noticeRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("公告不存在"));

        if (request.getTitle() != null) notice.setTitle(request.getTitle());
        if (request.getSummary() != null) notice.setSummary(request.getSummary());
        if (request.getContent() != null) notice.setContent(request.getContent());
        if (request.getCover() != null) notice.setCover(request.getCover());
        if (request.getImages() != null) notice.setImages(convertListToJson(request.getImages()));
        if (request.getAuthor() != null) notice.setAuthor(request.getAuthor());
        if (request.getIsTop() != null) notice.setIsTop(request.getIsTop());
        if (request.getStatus() != null) notice.setStatus(request.getStatus());

        noticeRepository.save(notice);

        NoticeOperationResponse response = new NoticeOperationResponse();
        response.setId(id);
        response.setMessage("公告修改成功");
        return response;
    }

    @Transactional
    public NoticeOperationResponse deleteNotice(Long id) {
        Notice notice = noticeRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("公告不存在"));

        noticeRepository.delete(notice);

        NoticeOperationResponse response = new NoticeOperationResponse();
        response.setId(id);
        response.setMessage("公告删除成功");
        return response;
    }

    private NoticeListResponse.NoticeItem convertToNoticeItem(Notice notice) {
        NoticeListResponse.NoticeItem item = new NoticeListResponse.NoticeItem();
        item.setId(notice.getId());
        item.setTitle(notice.getTitle());
        item.setSummary(notice.getSummary());
        item.setCover(notice.getCover());
        item.setPublishTime(notice.getPublishTime());
        item.setAuthor(notice.getAuthor());
        item.setViewCount(notice.getViewCount());
        return item;
    }

    private NoticeDetailResponse convertToNoticeDetail(Notice notice) {
        NoticeDetailResponse detail = new NoticeDetailResponse();
        detail.setId(notice.getId());
        detail.setTitle(notice.getTitle());
        detail.setContent(notice.getContent());
        detail.setCover(notice.getCover());
        detail.setImages(convertJsonToList(notice.getImages()));
        detail.setPublishTime(notice.getPublishTime());
        detail.setAuthor(notice.getAuthor());
        detail.setViewCount(notice.getViewCount());
        detail.setIsTop(notice.getIsTop());
        detail.setStatus(notice.getStatus());
        detail.setCreateTime(notice.getCreateTime());
        detail.setUpdateTime(notice.getUpdateTime());
        return detail;
    }

    private String convertListToJson(List<String> list) {
        if (list == null || list.isEmpty()) {
            return "[]";
        }
        try {
            return objectMapper.writeValueAsString(list);
        } catch (Exception e) {
            return "[]";
        }
    }

    private List<String> convertJsonToList(String json) {
        if (json == null || json.trim().isEmpty() || "[]".equals(json.trim())) {
            return new ArrayList<>();
        }
        try {
            return objectMapper.readValue(json, new TypeReference<List<String>>() {});
        } catch (Exception e) {
            return new ArrayList<>();
        }
    }
}