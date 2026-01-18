package org.backend.spothunterserver.controller;

import org.backend.spothunterserver.dto.common.ApiResponse;
import org.backend.spothunterserver.dto.ticket.TicketDetailResponse;
import org.backend.spothunterserver.dto.ticket.TicketListResponse;
import org.backend.spothunterserver.service.TicketService;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/ticket")
public class TicketController {

    private final TicketService ticketService;

    public TicketController(TicketService ticketService) {
        this.ticketService = ticketService;
    }

    @GetMapping("/list")
    public ApiResponse<TicketListResponse> getTicketList(@RequestParam(required = false) Long scenicId) {
        TicketListResponse response = ticketService.getTicketList(scenicId);
        return ApiResponse.success(response);
    }

    @GetMapping("/{id}")
    public ApiResponse<TicketDetailResponse> getTicketDetail(@PathVariable Long id) {
        TicketDetailResponse response = ticketService.getTicketDetail(id);
        return ApiResponse.success(response);
    }
}