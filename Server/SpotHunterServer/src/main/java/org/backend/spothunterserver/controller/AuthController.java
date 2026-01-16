package org.backend.spothunterserver.controller;

import org.backend.spothunterserver.dto.common.ApiResponse;
import org.backend.spothunterserver.dto.user.UserInfoResponse;
import org.backend.spothunterserver.dto.user.UserLoginRequest;
import org.backend.spothunterserver.dto.user.UserLoginResponse;
import org.backend.spothunterserver.service.UserService;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final UserService userService;

    public AuthController(UserService userService) {
        this.userService = userService;
    }

    @PostMapping("/login")
    public ApiResponse<UserLoginResponse> login(@RequestBody UserLoginRequest request) {
        UserLoginResponse response = userService.login(request);
        return ApiResponse.success(response);
    }

    @GetMapping("/me")
    public ApiResponse<UserInfoResponse> getCurrentUser() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String username = authentication.getName();
        UserInfoResponse userInfo = userService.getCurrentUserInfo(username);
        return ApiResponse.success(userInfo);
    }
}