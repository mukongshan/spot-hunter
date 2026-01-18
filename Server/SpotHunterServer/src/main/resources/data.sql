INSERT INTO spot (id, name, intro, image, latitude, longitude, score) VALUES
    (1, '景区南大门', '景区主入口，游客打卡起点。', 'https://img.example.com/gate.jpg', 30.2541, 120.2132, 10),
    (2, '中心湖', '人工湖畔，可休息拍照。', 'https://img.example.com/lake.jpg', 30.2555, 120.2145, 20),
    (3, '松树林步道', '穿越松林的步道，空气清新。', 'https://img.example.com/pine.jpg', 30.2561, 120.2121, 15),
    (4, '观景台', '视野最佳的高台，可眺望全景。', 'https://img.example.com/view.jpg', 30.2538, 120.2156, 25),
    (5, '游客中心', '提供补给与咨询的服务点。', 'https://img.example.com/service.jpg', 30.2526, 120.2141, 10)
ON DUPLICATE KEY UPDATE
    name = VALUES(name),
    intro = VALUES(intro),
    image = VALUES(image),
    latitude = VALUES(latitude),
    longitude = VALUES(longitude),
    score = VALUES(score);

