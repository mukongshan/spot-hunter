package org.backend.spothunterserver.service;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.backend.spothunterserver.dto.scenic.*;
import org.backend.spothunterserver.entity.Spot;
import org.backend.spothunterserver.repository.SpotRepository;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class SpotService {

    private final SpotRepository spotRepository;
    private final ObjectMapper objectMapper;

    public SpotService(SpotRepository spotRepository, ObjectMapper objectMapper) {
        this.spotRepository = spotRepository;
        this.objectMapper = objectMapper;
    }

    public ScenicListResponse getScenicList(Integer page, Integer size, String keyword) {
        if (page == null || page < 1) page = 1;
        if (size == null || size < 1) size = 10;

        Pageable pageable = PageRequest.of(page - 1, size);
        Page<Spot> spotPage = spotRepository.findByNameOrLocationOrDescriptionContaining(
                keyword != null ? keyword.trim() : null, pageable);

        ScenicListResponse response = new ScenicListResponse();
        response.setTotal(spotPage.getTotalElements());
        response.setPage(page);
        response.setSize(size);

        List<ScenicListResponse.ScenicItem> items = spotPage.getContent().stream()
                .map(this::convertToScenicItem)
                .collect(Collectors.toList());
        response.setList(items);

        return response;
    }

    public ScenicDetailResponse getScenicDetail(Long id) {
        Spot spot = spotRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("景点不存在"));

        return convertToScenicDetail(spot);
    }

    @Transactional
    public ScenicOperationResponse createScenic(ScenicCreateRequest request) {
        Spot spot = new Spot();
        spot.setName(request.getName());
        spot.setCover(request.getCover());
        spot.setImages(convertListToJson(request.getImages()));
        spot.setLocation(request.getLocation());
        spot.setDescription(request.getDescription());
        spot.setDetail(request.getDetail());
        spot.setOpenTime(request.getOpenTime());
        spot.setAddress(request.getAddress());
        spot.setPhone(request.getPhone());
        spot.setPrice(request.getPrice() != null ? request.getPrice() : java.math.BigDecimal.ZERO);
        spot.setTags(convertListToJson(request.getTags()));

        Spot saved = spotRepository.save(spot);

        ScenicOperationResponse response = new ScenicOperationResponse();
        response.setId(saved.getId());
        response.setMessage("景点创建成功");
        return response;
    }

    @Transactional
    public ScenicOperationResponse updateScenic(Long id, ScenicUpdateRequest request) {
        Spot spot = spotRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("景点不存在"));

        if (request.getName() != null) spot.setName(request.getName());
        if (request.getCover() != null) spot.setCover(request.getCover());
        if (request.getImages() != null) spot.setImages(convertListToJson(request.getImages()));
        if (request.getLocation() != null) spot.setLocation(request.getLocation());
        if (request.getDescription() != null) spot.setDescription(request.getDescription());
        if (request.getDetail() != null) spot.setDetail(request.getDetail());
        if (request.getOpenTime() != null) spot.setOpenTime(request.getOpenTime());
        if (request.getAddress() != null) spot.setAddress(request.getAddress());
        if (request.getPhone() != null) spot.setPhone(request.getPhone());
        if (request.getPrice() != null) spot.setPrice(request.getPrice());
        if (request.getTags() != null) spot.setTags(convertListToJson(request.getTags()));

        spotRepository.save(spot);

        ScenicOperationResponse response = new ScenicOperationResponse();
        response.setId(id);
        response.setMessage("景点更新成功");
        return response;
    }

    @Transactional
    public ScenicOperationResponse deleteScenic(Long id) {
        Spot spot = spotRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("景点不存在"));

        spotRepository.delete(spot);

        ScenicOperationResponse response = new ScenicOperationResponse();
        response.setId(id);
        response.setMessage("景点删除成功");
        return response;
    }

    private ScenicListResponse.ScenicItem convertToScenicItem(Spot spot) {
        ScenicListResponse.ScenicItem item = new ScenicListResponse.ScenicItem();
        item.setId(spot.getId());
        item.setName(spot.getName());
        item.setCover(spot.getCover());
        item.setLocation(spot.getLocation());
        item.setDescription(spot.getDescription());
        item.setOpenTime(spot.getOpenTime());
        item.setPrice(spot.getPrice());
        item.setRating(spot.getRating());
        item.setTags(convertJsonToList(spot.getTags()));
        return item;
    }

    private ScenicDetailResponse convertToScenicDetail(Spot spot) {
        ScenicDetailResponse detail = new ScenicDetailResponse();
        detail.setId(spot.getId());
        detail.setName(spot.getName());
        detail.setCover(spot.getCover());
        detail.setImages(convertJsonToList(spot.getImages()));
        detail.setLocation(spot.getLocation());
        detail.setDescription(spot.getDescription());
        detail.setDetail(spot.getDetail());
        detail.setOpenTime(spot.getOpenTime());
        detail.setTicketInfo(spot.getTicketInfo());
        detail.setAddress(spot.getAddress());
        detail.setPhone(spot.getPhone());
        detail.setRating(spot.getRating());
        detail.setReviewCount(spot.getReviewCount());
        detail.setTags(convertJsonToList(spot.getTags()));
        detail.setAttractions(convertJsonToList(spot.getAttractions()));
        detail.setServices(convertJsonToList(spot.getServices()));
        detail.setRecommendHours(spot.getRecommendHours());
        detail.setBestSeason(spot.getBestSeason());
        detail.setCreateTime(spot.getCreateTime());
        detail.setUpdateTime(spot.getUpdateTime());
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