package org.backend.spothunterserver.repository;

import org.backend.spothunterserver.entity.Spot;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface SpotRepository extends JpaRepository<Spot, Long> {
    @Query("SELECT s FROM Spot s WHERE " +
            "(:keyword IS NULL OR :keyword = '' OR " +
            "s.name LIKE %:keyword% OR s.location LIKE %:keyword% OR s.description LIKE %:keyword%)")
    Page<Spot> findByNameOrLocationOrDescriptionContaining(
            @Param("keyword") String keyword,
            Pageable pageable
    );
}