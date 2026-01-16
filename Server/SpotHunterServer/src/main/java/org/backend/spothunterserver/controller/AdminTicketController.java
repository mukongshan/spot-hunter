package org.backend.spothunterserver.controller;

import org.backend.spothunterserver.dto.common.ApiResponse;
import org.backend.spothunterserver.dto.ticket.*;
import org.backend.spothunterserver.service.TicketService;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/admin/ticket")
public class AdminTicketController {

    private final TicketService ticketService;

    public AdminTicketController(TicketService ticketService) {
        this.ticketService = ticketService;
    }

    @PostMapping
    public ApiResponse<TicketOperationResponse> createTicket(@RequestBody TicketCreateRequest request) {
        TicketOperationResponse response = ticketService.createTicket(request);
        return ApiResponse.success(response);
    }

    @PutMapping("/{id}")
    public ApiResponse<TicketOperationResponse> updateTicket(
            @PathVariable Long id,
            @RequestBody TicketUpdateRequest request) {
        TicketOperationResponse response = ticketService.updateTicket(id, request);
        return ApiResponse.success(response);
    }

    @DeleteMapping("/{id}")
    public ApiResponse<TicketOperationResponse> deleteTicket(@PathVariable Long id) {
        TicketOperationResponse response = ticketService.deleteTicket(id);
        return ApiResponse.success(response);
    }
}