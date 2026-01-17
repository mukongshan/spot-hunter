-- ============================================
-- 初始模拟数据
-- ============================================

-- 用户数据
INSERT INTO `user` (id, username, password, nickname, role, create_time, update_time) VALUES
(1, 'admin', '$2a$10$ougo0z0lqVyujLfigKG0nudebhj9Nql9nZkzkIUX5cs0nX.eyjMsa', 'Admin', 'ADMIN', NOW(), NOW()),
(2, 'user1', '$2a$10$ougo0z0lqVyujLfigKG0nudebhj9Nql9nZkzkIUX5cs0nX.eyjMsa', 'Alice', 'USER', NOW(), NOW()),
(3, 'user2', '$2a$10$ougo0z0lqVyujLfigKG0nudebhj9Nql9nZkzkIUX5cs0nX.eyjMsa', 'Bob', 'USER', NOW(), NOW()),
(4, 'user3', '$2a$10$ougo0z0lqVyujLfigKG0nudebhj9Nql9nZkzkIUX5cs0nX.eyjMsa', 'Charlie', 'USER', NOW(), NOW()),
(5, 'user4', '$2a$10$ougo0z0lqVyujLfigKG0nudebhj9Nql9nZkzkIUX5cs0nX.eyjMsa', 'David', 'USER', NOW(), NOW())
ON DUPLICATE KEY UPDATE 
    username = VALUES(username),
    password = VALUES(password),
    nickname = VALUES(nickname),
    role = VALUES(role),
    update_time = NOW();

-- 景点数据
INSERT INTO `spot` (id, name, cover, location, description, detail, open_time, ticket_info, address, phone, price, rating, review_count, create_time, update_time) VALUES
(1, 'South Gate', 'https://img.example.com/gate.jpg', 'Entry', 'Main entrance of the scenic spot.', 'Details: The south gate is the main entrance...', '08:00-18:00', 'Adult: $100', 'No.1 XX Road, Hangzhou', '0571-88888888', 0.00, 4.5, 120, NOW(), NOW()),
(2, 'Central Lake', 'https://img.example.com/lake.jpg', 'Center', 'A man-made lake for rest and photos.', 'Details: The central lake is located at the heart...', '08:00-18:00', 'Free', 'No.2 XX Road, Hangzhou', '0571-88888889', 0.00, 4.8, 450, NOW(), NOW()),
(3, 'Pine Forest Trail', 'https://img.example.com/pine.jpg', 'North', 'A trail through the pine forest.', 'Details: The trail is 2km long...', '24/7', 'Free', 'No.3 XX Road, Hangzhou', '0571-88888890', 0.00, 4.2, 80, NOW(), NOW())
ON DUPLICATE KEY UPDATE 
    name = VALUES(name),
    cover = VALUES(cover),
    location = VALUES(location),
    description = VALUES(description),
    detail = VALUES(detail),
    open_time = VALUES(open_time),
    ticket_info = VALUES(ticket_info),
    address = VALUES(address),
    phone = VALUES(phone),
    price = VALUES(price),
    rating = VALUES(rating),
    review_count = VALUES(review_count),
    update_time = NOW();

-- 公告数据
INSERT INTO `notice` (id, title, summary, content, cover, author, view_count, is_top, status, publish_time, create_time, update_time) VALUES
(1, 'Spring Festival Opening Notice', 'Notice on adjustment of opening hours during Spring Festival', 'Dear tourists: During the Spring Festival, the scenic spot will keep open...', 'https://img.example.com/notice1.jpg', 'Management', 1500, 1, 'PUBLISHED', NOW(), NOW(), NOW()),
(2, 'Safety Tips', 'Please pay attention to safety', 'Recently there has been a lot of rain and snow, please pay attention to your feet...', 'https://img.example.com/notice2.jpg', 'Safety Office', 800, 0, 'PUBLISHED', NOW(), NOW(), NOW())
ON DUPLICATE KEY UPDATE 
    title = VALUES(title),
    summary = VALUES(summary),
    content = VALUES(content),
    cover = VALUES(cover),
    author = VALUES(author),
    view_count = VALUES(view_count),
    is_top = VALUES(is_top),
    status = VALUES(status),
    update_time = NOW();

-- 门票数据
INSERT INTO `ticket` (id, scenic_id, name, type, description, price, original_price, stock, daily_limit, status, create_time, update_time) VALUES
(1, 1, 'Adult Ticket', 'ADULT', 'For adults', 100.00, 120.00, 999, 500, 'ON_SALE', NOW(), NOW()),
(2, 1, 'Student Ticket', 'STUDENT', 'Need student ID', 50.00, 120.00, 500, 200, 'ON_SALE', NOW(), NOW()),
(3, 1, 'Child Ticket', 'CHILD', 'Children under 1.2m free', 0.00, 0.00, 999, 1000, 'ON_SALE', NOW(), NOW())
ON DUPLICATE KEY UPDATE 
    scenic_id = VALUES(scenic_id),
    name = VALUES(name),
    type = VALUES(type),
    description = VALUES(description),
    price = VALUES(price),
    original_price = VALUES(original_price),
    stock = VALUES(stock),
    daily_limit = VALUES(daily_limit),
    status = VALUES(status),
    update_time = NOW();

-- 订单数据
INSERT INTO `orders` (order_id, order_no, user_id, status, total_price, pay_amount, pay_method, ticket_id, scenic_id, quantity, unit_price, visit_date, visitor_name, visitor_phone, visitor_id_card, create_time) VALUES
(1, 'ORD202601170001', 1, 'PAID', 100.00, 100.00, 'WECHAT', 1, 1, 1, 100.00, '2026-01-20', 'Admin User', '13800138000', '110101199001011234', NOW()),
(2, 'ORD202601170002', 1, 'UNPAID', 50.00, 50.00, 'ALIPAY', 2, 1, 1, 50.00, '2026-01-21', 'Admin User', '13800138000', '110101199001011234', NOW()),
(3, 'ORD202601170003', 2, 'PAID', 100.00, 100.00, 'WECHAT', 1, 1, 1, 100.00, '2026-01-22', 'Alice', '13900139000', '110101199001015678', NOW()),
(4, 'ORD202601170004', 3, 'PAID', 150.00, 150.00, 'ALIPAY', 1, 1, 1, 100.00, '2026-01-23', 'Bob', '13700137000', '110101199001019012', NOW())
ON DUPLICATE KEY UPDATE 
    user_id = VALUES(user_id),
    status = VALUES(status),
    pay_amount = VALUES(pay_amount);

-- 订单门票数据
INSERT INTO `order_ticket` (id, order_id, ticket_code, ticket_no, status, qr_code) VALUES
(1, 1, 'TC12345678', 'TK202601170001', 'UNUSED', 'QR_CODE_DATA_HERE'),
(2, 2, 'TC12345679', 'TK202601170002', 'UNUSED', 'QR_CODE_DATA_HERE'),
(3, 3, 'TC12345680', 'TK202601170003', 'UNUSED', 'QR_CODE_DATA_HERE'),
(4, 4, 'TC12345681', 'TK202601170004', 'UNUSED', 'QR_CODE_DATA_HERE')
ON DUPLICATE KEY UPDATE 
    order_id = VALUES(order_id),
    status = VALUES(status);

