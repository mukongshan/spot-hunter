package org.backend.spothunterserver.service;

import org.backend.spothunterserver.config.JwtUtil;
import org.backend.spothunterserver.dto.user.UserInfoResponse;
import org.backend.spothunterserver.dto.user.UserLoginRequest;
import org.backend.spothunterserver.dto.user.UserLoginResponse;
import org.backend.spothunterserver.entity.User;
import org.backend.spothunterserver.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class UserService {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private JwtUtil jwtUtil;

    public UserLoginResponse login(UserLoginRequest request) {
        String username = request.getUsername().trim();
        String password = request.getPassword();

        User user = userRepository.findByUsernameIgnoreCase(username)
                .orElseThrow(() -> new IllegalArgumentException("用户名或密码错误"));

        if (!passwordEncoder.matches(password, user.getPassword())) {
            throw new IllegalArgumentException("用户名或密码错误");
        }

        String token = jwtUtil.generateToken(user.getId(), user.getUsername(), user.getRole());

        UserLoginResponse response = new UserLoginResponse();
        response.setToken(token);

        UserLoginResponse.UserInfo userInfo = new UserLoginResponse.UserInfo();
        userInfo.setId(user.getId());
        userInfo.setUsername(user.getUsername());
        userInfo.setNickname(user.getNickname() != null ? user.getNickname() : user.getUsername());
        userInfo.setAvatar(user.getAvatar());
        userInfo.setRole(user.getRole());
        userInfo.setPhone(user.getPhone());

        response.setUser(userInfo);
        return response;
    }

    public UserInfoResponse getCurrentUserInfo(String username) {
        User user = userRepository.findByUsernameIgnoreCase(username)
                .orElseThrow(() -> new IllegalArgumentException("用户不存在"));

        UserInfoResponse response = new UserInfoResponse();
        response.setId(user.getId());
        response.setUsername(user.getUsername());
        response.setNickname(user.getNickname());
        response.setAvatar(user.getAvatar());
        response.setRole(user.getRole());
        response.setPhone(user.getPhone());
        response.setEmail(user.getEmail());
        response.setCreateTime(user.getCreateTime());

        return response;
    }
}