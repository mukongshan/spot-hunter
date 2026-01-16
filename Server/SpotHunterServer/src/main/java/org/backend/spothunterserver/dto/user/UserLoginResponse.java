package org.backend.spothunterserver.dto.user;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class UserLoginResponse {
    private String token;
    private UserInfo user;    @Getter
    @Setter
    public static class UserInfo {
        private Long id;
        private String username;
        private String nickname;
        private String avatar;
        private String role;
        private String phone;
    }
}
