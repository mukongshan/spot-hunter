package org.backend.spothunterserver.repository;

import org.backend.spothunterserver.entity.Notice;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface NoticeRepository extends JpaRepository<Notice, Long> {
    @Query("SELECT n FROM Notice n WHERE n.status = 'PUBLISHED' ORDER BY n.isTop DESC, n.publishTime DESC")
    List<Notice> findAllPublished();
}