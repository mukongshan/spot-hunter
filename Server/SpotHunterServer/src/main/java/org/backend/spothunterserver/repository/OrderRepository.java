package org.backend.spothunterserver.repository;

import org.backend.spothunterserver.entity.Order;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface OrderRepository extends JpaRepository<Order, Long> {
    Optional<Order> findByOrderNo(String orderNo);
    
    Page<Order> findByUserId(Long userId, Pageable pageable);

    Page<Order> findAll(Pageable pageable);
    
    @Query("SELECT o FROM Order o WHERE o.userId = :userId " +
           "AND (:status IS NULL OR o.status = :status) " +
           "ORDER BY o.createTime DESC")
    Page<Order> findByUserIdAndStatus(@Param("userId") Long userId, 
                                       @Param("status") String status, 
                                       Pageable pageable);
}