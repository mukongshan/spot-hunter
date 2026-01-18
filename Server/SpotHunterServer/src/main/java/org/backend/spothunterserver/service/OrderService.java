package org.backend.spothunterserver.service;

import org.backend.spothunterserver.dto.order.*;
import org.backend.spothunterserver.entity.Order;
import org.backend.spothunterserver.entity.OrderTicket;
import org.backend.spothunterserver.entity.Ticket;
import org.backend.spothunterserver.entity.Spot;
import org.backend.spothunterserver.entity.User;
import org.backend.spothunterserver.repository.OrderRepository;
import org.backend.spothunterserver.repository.OrderTicketRepository;
import org.backend.spothunterserver.repository.TicketRepository;
import org.backend.spothunterserver.repository.SpotRepository;
import org.backend.spothunterserver.repository.UserRepository;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class OrderService {

    private final OrderRepository orderRepository;
    private final OrderTicketRepository orderTicketRepository;
    private final TicketRepository ticketRepository;
    private final SpotRepository spotRepository;
    private final UserRepository userRepository;

    public OrderService(OrderRepository orderRepository, 
                       OrderTicketRepository orderTicketRepository,
                       TicketRepository ticketRepository,
                       SpotRepository spotRepository,
                       UserRepository userRepository) {
        this.orderRepository = orderRepository;
        this.orderTicketRepository = orderTicketRepository;
        this.ticketRepository = ticketRepository;
        this.spotRepository = spotRepository;
        this.userRepository = userRepository;
    }

    @Transactional
    public OrderCreateResponse createOrder(OrderCreateRequest request, Long userId) {
        // 获取门票信息
        Ticket ticket = ticketRepository.findById(request.getTicketId())
                .orElseThrow(() -> new IllegalArgumentException("门票不存在"));

        // 检查库存
        if (ticket.getStock() < request.getQuantity()) {
            throw new IllegalArgumentException("库存不足");
        }

        // 检查门票状态
        if (!"ON_SALE".equals(ticket.getStatus())) {
            throw new IllegalArgumentException("门票不在售");
        }

        // 获取景点信息
        Spot spot = spotRepository.findById(ticket.getScenicId())
                .orElseThrow(() -> new IllegalArgumentException("景点不存在"));

        // 计算总价
        BigDecimal totalPrice = ticket.getPrice().multiply(new BigDecimal(request.getQuantity()));

        // 创建订单
        Order order = new Order();
        order.setUserId(userId);
        order.setStatus("UNPAID");
        order.setTotalPrice(totalPrice);
        order.setPayAmount(totalPrice);
        order.setTicketId(ticket.getId());
        order.setScenicId(spot.getId());
        order.setQuantity(request.getQuantity());
        order.setUnitPrice(ticket.getPrice());
        order.setVisitDate(request.getVisitDate());
        order.setVisitorName(request.getVisitorName());
        order.setVisitorPhone(request.getVisitorPhone());
        order.setVisitorIdCard(request.getVisitorIdCard());
        order.setPayExpireTime(LocalDateTime.now().plusHours(1));

        Order savedOrder = orderRepository.save(order);

        // 创建订单门票记录
        for (int i = 0; i < request.getQuantity(); i++) {
            OrderTicket orderTicket = new OrderTicket();
            orderTicket.setOrderId(savedOrder.getOrderId());
            orderTicketRepository.save(orderTicket);
        }

        // 减少库存（支付后才真正扣减，这里先预留）
        // ticket.setStock(ticket.getStock() - request.getQuantity());
        // ticketRepository.save(ticket);

        // 构建响应
        OrderCreateResponse response = new OrderCreateResponse();
        response.setOrderId(savedOrder.getOrderId());
        response.setOrderNo(savedOrder.getOrderNo());
        response.setStatus(savedOrder.getStatus());
        response.setTotalPrice(savedOrder.getTotalPrice());
        response.setPayAmount(savedOrder.getPayAmount());
        response.setTicketName(spot.getName() + "-" + ticket.getName());
        response.setQuantity(savedOrder.getQuantity());
        response.setVisitDate(savedOrder.getVisitDate());
        response.setVisitorName(savedOrder.getVisitorName());
        response.setCreateTime(savedOrder.getCreateTime());
        response.setPayExpireTime(savedOrder.getPayExpireTime());

        return response;
    }

    public OrderListResponse getMyOrders(Long userId, String status, Integer page, Integer size) {
        if (page == null || page < 1) page = 1;
        if (size == null || size < 1) size = 10;

        Pageable pageable = PageRequest.of(page - 1, size);
        Page<Order> orderPage;
        
        if (status != null && !status.trim().isEmpty()) {
            orderPage = orderRepository.findByUserIdAndStatus(userId, status, pageable);
        } else {
            orderPage = orderRepository.findByUserId(userId, pageable);
        }

        OrderListResponse response = new OrderListResponse();
        response.setTotal(orderPage.getTotalElements());
        response.setPage(page);
        response.setSize(size);

        List<OrderListResponse.OrderItem> items = orderPage.getContent().stream()
                .map(order -> convertToOrderItem(order))
                .collect(Collectors.toList());
        response.setList(items);

        return response;
    }

    public OrderDetailResponse getOrderDetail(Long orderId, Long userId) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new IllegalArgumentException("订单不存在"));

        // 检查权限：只能查看自己的订单
        if (!order.getUserId().equals(userId)) {
            throw new IllegalArgumentException("无权访问该订单");
        }

        // 获取相关信息
        Ticket ticket = ticketRepository.findById(order.getTicketId())
                .orElseThrow(() -> new IllegalArgumentException("门票不存在"));
        Spot spot = spotRepository.findById(order.getScenicId())
                .orElseThrow(() -> new IllegalArgumentException("景点不存在"));
        User user = userRepository.findById(order.getUserId())
                .orElseThrow(() -> new IllegalArgumentException("用户不存在"));

        // 获取订单门票列表
        List<OrderTicket> orderTickets = orderTicketRepository.findByOrderId(orderId);

        OrderDetailResponse response = new OrderDetailResponse();
        response.setOrderId(order.getOrderId());
        response.setOrderNo(order.getOrderNo());
        response.setUserId(order.getUserId());
        response.setUsername(user.getUsername());
        response.setStatus(order.getStatus());
        response.setTotalPrice(order.getTotalPrice());
        response.setPayAmount(order.getPayAmount());
        response.setPayMethod(order.getPayMethod());
        response.setTicketId(order.getTicketId());
        response.setTicketName(spot.getName() + "-" + ticket.getName());
        response.setScenicId(order.getScenicId());
        response.setScenicName(spot.getName());
        response.setQuantity(order.getQuantity());
        response.setUnitPrice(order.getUnitPrice());
        response.setVisitDate(order.getVisitDate());
        response.setVisitorName(order.getVisitorName());
        response.setVisitorPhone(order.getVisitorPhone());
        response.setVisitorIdCard(order.getVisitorIdCard());
        response.setCreateTime(order.getCreateTime());
        response.setPayTime(order.getPayTime());
        response.setPayExpireTime(order.getPayExpireTime());
        response.setCancelTime(order.getCancelTime());
        response.setRefundTime(order.getRefundTime());

        // 转换门票信息
        List<OrderDetailResponse.TicketInfo> ticketInfos = orderTickets.stream()
                .map(ot -> {
                    OrderDetailResponse.TicketInfo ti = new OrderDetailResponse.TicketInfo();
                    ti.setTicketCode(ot.getTicketCode());
                    ti.setTicketNo(ot.getTicketNo());
                    ti.setStatus(ot.getStatus());
                    ti.setQrCode(ot.getQrCode());
                    ti.setUseTime(ot.getUseTime());
                    return ti;
                })
                .collect(Collectors.toList());
        response.setTickets(ticketInfos);

        // 判断是否可退、可取消
        response.setRefundable("PAID".equals(order.getStatus()) && 
                              order.getVisitDate().isAfter(LocalDate.now()));
        response.setCancelable("UNPAID".equals(order.getStatus()) || 
                              ("PAID".equals(order.getStatus()) && 
                               order.getVisitDate().isAfter(LocalDate.now())));

        return response;
    }

    @Transactional
    public OrderCancelResponse cancelOrder(Long orderId, Long userId) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new IllegalArgumentException("订单不存在"));

        // 检查权限
        if (!order.getUserId().equals(userId)) {
            throw new IllegalArgumentException("无权操作该订单");
        }

        // 检查订单状态
        if (!"UNPAID".equals(order.getStatus()) && 
            !("PAID".equals(order.getStatus()) && order.getVisitDate().isAfter(LocalDate.now()))) {
            throw new IllegalArgumentException("当前订单状态不允许取消");
        }

        order.setStatus("CANCELLED");
        order.setCancelTime(LocalDateTime.now());
        orderRepository.save(order);

        // 如果是已支付订单，需要退款（这里简化处理，实际应该调用支付接口）
        if ("PAID".equals(order.getStatus())) {
            order.setStatus("REFUNDED");
            order.setRefundTime(LocalDateTime.now());
            orderRepository.save(order);
        }

        OrderCancelResponse response = new OrderCancelResponse();
        response.setOrderId(order.getOrderId());
        response.setOrderNo(order.getOrderNo());
        response.setStatus(order.getStatus());
        response.setMessage("订单取消成功");

        return response;
    }

    private OrderListResponse.OrderItem convertToOrderItem(Order order) {
        OrderListResponse.OrderItem item = new OrderListResponse.OrderItem();
        item.setOrderId(order.getOrderId());
        item.setOrderNo(order.getOrderNo());
        item.setStatus(order.getStatus());
        item.setTotalPrice(order.getTotalPrice());
        item.setPayAmount(order.getPayAmount());
        
        // 获取门票和景点名称
        Ticket ticket = ticketRepository.findById(order.getTicketId()).orElse(null);
        Spot spot = spotRepository.findById(order.getScenicId()).orElse(null);
        if (ticket != null && spot != null) {
            item.setTicketName(spot.getName() + "-" + ticket.getName());
            item.setScenicName(spot.getName());
        }
        
        item.setQuantity(order.getQuantity());
        item.setVisitDate(order.getVisitDate());
        item.setCreateTime(order.getCreateTime());
        item.setPayExpireTime(order.getPayExpireTime());
        item.setPayTime(order.getPayTime());
        
        // 获取第一个门票码
        List<OrderTicket> tickets = orderTicketRepository.findByOrderId(order.getOrderId());
        if (!tickets.isEmpty() && tickets.get(0).getTicketCode() != null) {
            item.setTicketCode(tickets.get(0).getTicketCode());
        }
        
        return item;
    }
}