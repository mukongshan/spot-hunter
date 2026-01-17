package org.backend.spothunterserver;

import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

public class VerifyPasswordHash {
    public static void main(String[] args) {
        BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();
        String password = "123456";
        String hash = "$2a$10$ougo0z0lqVyujLfigKG0nudebhj9Nql9nZkzkIUX5cs0nX.eyjMsa";
        boolean matches = encoder.matches(password, hash);
        System.out.println("Password: " + password);
        System.out.println("Hash: " + hash);
        System.out.println("Verification: " + matches);
        if (matches) {
            System.out.println("✓ 密码验证成功！");
        } else {
            System.out.println("✗ 密码验证失败！");
        }
    }
}
