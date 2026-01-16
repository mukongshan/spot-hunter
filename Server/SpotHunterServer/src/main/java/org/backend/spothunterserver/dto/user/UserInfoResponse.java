package org.backend.spothunterserver.dto.user;

import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;@Getter
@Setter
public class UserInfoResponse {
    private Long id;
    private String username;
    private String nickname;
    private String avatar;
    private String role;
    private String phone;
    private String email;
    private LocalDateTime createTime;
}
