package org.backend.spothunterserver.dto.user;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record UserRegisterRequest(
        @NotBlank(message = "用户名不能为空")
        @Size(min = 3, max = 20, message = "用户名长度必须在 3~20 之间")
        String username,

        @NotBlank(message = "密码不能为空")
        @Size(min = 6, message = "密码长度不能少于 6 位")
        String password

        // 如需邮箱/手机号注册，可继续添加：
        // @Email String email
        // @NotBlank String phone
) {}