-- ============================================
-- 创建管理员账号的SQL脚本
-- ============================================
-- 使用方法: 
--   mysql -u root -proot1234 spot_hunter < create_admin_user.sql
--
-- 账号信息:
--   用户名: admin
--   密码: 123456
--   角色: ADMIN
--   昵称: 系统管理员
--
-- 注意: 密码使用BCrypt加密，通过Spring Boot BCryptPasswordEncoder验证
-- ============================================

INSERT INTO `user` (`username`, `password`, `nickname`, `role`, `create_time`, `update_time`)
VALUES (
    'admin',
    '$2a$10$ougo0z0lqVyujLfigKG0nudebhj9Nql9nZkzkIUX5cs0nX.eyjMsa',
    '系统管理员',
    'ADMIN',
    NOW(),
    NOW()
)
ON DUPLICATE KEY UPDATE
    `password` = VALUES(`password`),
    `nickname` = VALUES(`nickname`),
    `role` = VALUES(`role`),
    `update_time` = NOW();

-- 验证插入结果
-- SELECT id, username, nickname, role, create_time FROM user WHERE username = 'admin';
