package org.backend.spothunterserver.repository;

import org.backend.spothunterserver.entity.OrderTicket;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface OrderTicketRepository extends JpaRepository<OrderTicket, Long> {
    List<OrderTicket> findByOrderId(Long orderId);
}