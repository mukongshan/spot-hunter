package org.backend.spothunterserver.service;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.backend.spothunterserver.dto.ticket.*;
import org.backend.spothunterserver.entity.Spot;
import org.backend.spothunterserver.entity.Ticket;
import org.backend.spothunterserver.repository.SpotRepository;
import org.backend.spothunterserver.repository.TicketRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class TicketService {

    private final TicketRepository ticketRepository;
    private final SpotRepository spotRepository;
    private final ObjectMapper objectMapper;

    public TicketService(TicketRepository ticketRepository, SpotRepository spotRepository, ObjectMapper objectMapper) {
        this.ticketRepository = ticketRepository;
        this.spotRepository = spotRepository;
        this.objectMapper = objectMapper;
    }

    public TicketListResponse getTicketList(Long scenicId) {
        List<Ticket> tickets;
        if (scenicId != null) {
            tickets = ticketRepository.findByScenicIdAndStatus(scenicId, "ON_SALE");
        } else {
            tickets = ticketRepository.findAll().stream()
                    .filter(t -> "ON_SALE".equals(t.getStatus()))
                    .collect(Collectors.toList());
        }

        TicketListResponse response = new TicketListResponse();
        List<TicketListResponse.TicketItem> items = tickets.stream()
                .map(this::convertToTicketItem)
                .collect(Collectors.toList());
        response.setData(items);

        return response;
    }

    public TicketDetailResponse getTicketDetail(Long id) {
        Ticket ticket = ticketRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("门票不存在"));

        TicketDetailResponse response = convertToTicketDetail(ticket);
        
        // 获取景点名称
        if (ticket.getScenicId() != null) {
            Spot spot = spotRepository.findById(ticket.getScenicId()).orElse(null);
            if (spot != null) {
                response.setScenicName(spot.getName());
            }
        }

        return response;
    }

    @Transactional
    public TicketOperationResponse createTicket(TicketCreateRequest request) {
        Ticket ticket = new Ticket();
        ticket.setScenicId(request.getScenicId());
        ticket.setName(request.getName());
        ticket.setType(request.getType());
        ticket.setDescription(request.getDescription());
        ticket.setPrice(request.getPrice());
        ticket.setOriginalPrice(request.getOriginalPrice());
        ticket.setStock(request.getStock() != null ? request.getStock() : 0);
        ticket.setDailyLimit(request.getDailyLimit());
        ticket.setValidityType(request.getValidityType() != null ? request.getValidityType() : "FIXED_DATE");
        ticket.setValidityDays(request.getValidityDays());
        ticket.setStartDate(request.getStartDate());
        ticket.setEndDate(request.getEndDate());
        ticket.setUsageRule(request.getUsageRule());
        ticket.setRefundable(request.getRefundable() != null ? request.getRefundable() : true);
        ticket.setRefundRule(request.getRefundRule());
        ticket.setChangeRule(request.getChangeRule());
        ticket.setTags(convertListToJson(request.getTags()));
        ticket.setStatus("ON_SALE");

        Ticket saved = ticketRepository.save(ticket);

        TicketOperationResponse response = new TicketOperationResponse();
        response.setId(saved.getId());
        response.setMessage("门票新增成功");
        return response;
    }

    @Transactional
    public TicketOperationResponse updateTicket(Long id, TicketUpdateRequest request) {
        Ticket ticket = ticketRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("门票不存在"));

        if (request.getName() != null) ticket.setName(request.getName());
        if (request.getType() != null) ticket.setType(request.getType());
        if (request.getDescription() != null) ticket.setDescription(request.getDescription());
        if (request.getPrice() != null) ticket.setPrice(request.getPrice());
        if (request.getOriginalPrice() != null) ticket.setOriginalPrice(request.getOriginalPrice());
        if (request.getStock() != null) ticket.setStock(request.getStock());
        if (request.getDailyLimit() != null) ticket.setDailyLimit(request.getDailyLimit());
        if (request.getValidityType() != null) ticket.setValidityType(request.getValidityType());
        if (request.getValidityDays() != null) ticket.setValidityDays(request.getValidityDays());
        if (request.getStartDate() != null) ticket.setStartDate(request.getStartDate());
        if (request.getEndDate() != null) ticket.setEndDate(request.getEndDate());
        if (request.getUsageRule() != null) ticket.setUsageRule(request.getUsageRule());
        if (request.getRefundable() != null) ticket.setRefundable(request.getRefundable());
        if (request.getRefundRule() != null) ticket.setRefundRule(request.getRefundRule());
        if (request.getChangeRule() != null) ticket.setChangeRule(request.getChangeRule());
        if (request.getTags() != null) ticket.setTags(convertListToJson(request.getTags()));
        if (request.getStatus() != null) ticket.setStatus(request.getStatus());

        ticketRepository.save(ticket);

        TicketOperationResponse response = new TicketOperationResponse();
        response.setId(id);
        response.setMessage("门票修改成功");
        return response;
    }

    @Transactional
    public TicketOperationResponse deleteTicket(Long id) {
        Ticket ticket = ticketRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("门票不存在"));

        ticketRepository.delete(ticket);

        TicketOperationResponse response = new TicketOperationResponse();
        response.setId(id);
        response.setMessage("门票删除成功");
        return response;
    }

    private TicketListResponse.TicketItem convertToTicketItem(Ticket ticket) {
        TicketListResponse.TicketItem item = new TicketListResponse.TicketItem();
        item.setId(ticket.getId());
        item.setName(ticket.getName());
        item.setDescription(ticket.getDescription());
        item.setPrice(ticket.getPrice());
        item.setOriginalPrice(ticket.getOriginalPrice());
        item.setStock(ticket.getStock());
        item.setDailyLimit(ticket.getDailyLimit());
        item.setValidityType(ticket.getValidityType());
        item.setValidityDays(ticket.getValidityDays());
        item.setStartDate(ticket.getStartDate());
        item.setEndDate(ticket.getEndDate());
        item.setRefundable(ticket.getRefundable());
        item.setRefundRule(ticket.getRefundRule());
        item.setTags(convertJsonToList(ticket.getTags()));
        return item;
    }

    private TicketDetailResponse convertToTicketDetail(Ticket ticket) {
        TicketDetailResponse detail = new TicketDetailResponse();
        detail.setId(ticket.getId());
        detail.setScenicId(ticket.getScenicId());
        detail.setName(ticket.getName());
        detail.setType(ticket.getType());
        detail.setDescription(ticket.getDescription());
        detail.setPrice(ticket.getPrice());
        detail.setOriginalPrice(ticket.getOriginalPrice());
        detail.setStock(ticket.getStock());
        detail.setDailyLimit(ticket.getDailyLimit());
        detail.setSoldToday(ticket.getSoldToday());
        detail.setValidityType(ticket.getValidityType());
        detail.setValidityDays(ticket.getValidityDays());
        detail.setStartDate(ticket.getStartDate());
        detail.setEndDate(ticket.getEndDate());
        detail.setUsageRule(ticket.getUsageRule());
        detail.setRefundable(ticket.getRefundable());
        detail.setRefundRule(ticket.getRefundRule());
        detail.setChangeRule(ticket.getChangeRule());
        detail.setTags(convertJsonToList(ticket.getTags()));
        detail.setStatus(ticket.getStatus());
        detail.setCreateTime(ticket.getCreateTime());
        detail.setUpdateTime(ticket.getUpdateTime());
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