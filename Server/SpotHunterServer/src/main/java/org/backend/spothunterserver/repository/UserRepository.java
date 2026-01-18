package org.backend.spothunterserver.repository;

import java.util.Optional;
import org.backend.spothunterserver.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;

public interface UserRepository extends JpaRepository<User, Long> {

    Optional<User> findByUsernameIgnoreCase(String username);
    boolean existsByUsername(String username);
}

