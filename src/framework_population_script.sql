-- Insert sample users
INSERT INTO "user" (username, password, email) VALUES 
('john_doe', 'password123', 'john@example.com'),
('jane_smith', 'password456', 'jane@example.com'),
('mike_jones', 'password789', 'mike@example.com');

-- Insert sample search history
INSERT INTO search_history (user_id, type, query) VALUES
(1, 'movie', 'Inception'),
(2, 'series', 'Breaking Bad'),
(3, 'movie', 'The Matrix'),
(1, 'movie', 'Interstellar'),
(2, 'movie', 'The Godfather');

-- Insert sample bookmarks
INSERT INTO bookmark (user_id, media_id, note) VALUES
(1, 101, 'Watch later'),
(2, 102, 'Recommended by friend'),
(3, 103, 'Interesting plot'),
(1, 104, 'Need to check reviews first');

-- Insert sample completed media
INSERT INTO completed (user_id, media_id, completed_date, rewatchability, note) VALUES
(1, 201, '2024-01-15', 5, 'Amazing movie, must rewatch!'),
(2, 202, '2024-02-10', 4, 'Great acting and storyline'),
(3, 203, '2024-03-12', 3, 'Good, but not memorable'),
(1, 204, '2024-04-20', 5, 'One of my favorites!');

-- Insert sample user scores
INSERT INTO user_score (user_id, media_id, score_value, review_text) VALUES
(1, 301, 9, 'Brilliant storytelling and visuals'),
(2, 302, 8, 'Excellent performances but slow pacing'),
(3, 303, 7, 'Good, but could be better'),
(1, 304, 10, 'One of the best movies I have ever seen!'),
(2, 305, 6, 'Decent, but not my cup of tea');