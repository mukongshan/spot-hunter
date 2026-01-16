package org.backend.spothunterserver.controller;

import org.backend.spothunterserver.config.JwtUtil;
import org.backend.spothunterserver.dto.common.ApiResponse;
import org.backend.spothunterserver.dto.order.*;
import org.backend.spothunterserver.service.OrderService;
import org.springframework.web.bind.annotation.*;

import jakarta.servlet.http.HttpServletRequest;

@RestController
@RequestMapping("/api/order")
public class OrderController {

    private final OrderService orderService;
    private final JwtUtil jwtUtil;

    public OrderController(OrderService orderService, JwtUtil jwtUtil) {
        this.orderService = orderService;
        this.jwtUtil = jwtUtil;
    }

    private Long getCurrentUserId(HttpServletRequest request) {
        String authHeader = request.getHeader("Authorization");
        if (authHeader != null && authHeader.startsWith("Bearer ")) {
            String token = authHeader.substring(7);
            return jwtUtil.getUserIdFromToken(token);
        }
        throw new IllegalArgumentException("未登录");
    }

    @PostMapping("/create")
    public ApiResponse<OrderCreateResponse> createOrder(
            @RequestBody OrderCreateRequest request,
            HttpServletRequest httpRequest) {
        Long userId = getCurrentUserId(httpRequest);
        OrderCreateResponse response = orderService.createOrder(request, userId);
        return ApiResponse.success(response);
    }

    @GetMapping("/my")
    public ApiResponse<OrderListResponse> getMyOrders(
            @RequestParam(required = false) String status,
            @RequestParam(required = false, defaultValue = "1") Integer page,
            @RequestParam(required = false, defaultValue = "10") Integer size,
            HttpServletRequest httpRequest) {
        Long userId = getCurrentUserId(httpRequest);
        OrderListResponse response = orderService.getMyOrders(userId, status, page, size);
        return ApiResponse.success(response);
    }

    @GetMapping("/{id}")
    public ApiResponse<OrderDetailResponse> getOrderDetail(
            @PathVariable Long id,
            HttpServletRequest httpRequest) {
        Long userId = getCurrentUserId(httpRequest);
        OrderDetailResponse response = orderService.getOrderDetail(id, userId);
        return ApiResponse.success(response);
    }

    @PostMapping("/{id}/cancel")
    public ApiResponse<OrderCancelResponse> cancelOrder(
            @PathVariable Long id,
            HttpServletRequest httpRequest) {
        Long userId = getCurrentUserId(httpRequest);
        OrderCancelResponse response = orderService.cancelOrder(id, userId);
        return ApiResponse.success(response);
    }
}