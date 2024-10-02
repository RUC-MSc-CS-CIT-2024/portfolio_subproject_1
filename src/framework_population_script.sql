-- Truncate tables to allow rerun of the script
TRUNCATE TABLE "user" CASCADE;
TRUNCATE TABLE search_history CASCADE;
TRUNCATE TABLE bookmark CASCADE;
TRUNCATE TABLE completed CASCADE;
TRUNCATE TABLE user_score CASCADE;

-- Insert sample data using DO blocks
DO $$
BEGIN
    -- Inserting users
    INSERT INTO "user" (username, password, email) VALUES 
    ('john_doe', 'password123', 'john@example.com'),
    ('jane_smith', 'password456', 'jane@example.com'),
    ('mike_jones', 'password789', 'mike@example.com');
    
    -- Search history for users
    PERFORM * FROM "user";  -- Ensuring users are available before referencing them
    
    -- Insert search history dynamically for each user
    INSERT INTO search_history (user_id, type, query) VALUES
    ((SELECT user_id FROM "user" WHERE username = 'john_doe'), 'movie', 'Inception'),
    ((SELECT user_id FROM "user" WHERE username = 'jane_smith'), 'series', 'Breaking Bad'),
    ((SELECT user_id FROM "user" WHERE username = 'mike_jones'), 'movie', 'The Matrix'),
    ((SELECT user_id FROM "user" WHERE username = 'john_doe'), 'movie', 'Interstellar'),
    ((SELECT user_id FROM "user" WHERE username = 'jane_smith'), 'movie', 'The Godfather');
    
    -- Inserting bookmarks for each user
    INSERT INTO bookmark (user_id, media_id, note) VALUES
    ((SELECT user_id FROM "user" WHERE username = 'john_doe'), 101, 'Watch later'),
    ((SELECT user_id FROM "user" WHERE username = 'jane_smith'), 102, 'Recommended by friend'),
    ((SELECT user_id FROM "user" WHERE username = 'mike_jones'), 103, 'Interesting plot'),
    ((SELECT user_id FROM "user" WHERE username = 'john_doe'), 104, 'Need to check reviews first');
    
    -- Inserting completed media for each user
    INSERT INTO completed (user_id, media_id, completed_date, rewatchability, note) VALUES
    ((SELECT user_id FROM "user" WHERE username = 'john_doe'), 201, '2024-01-15', 5, 'Amazing movie, must rewatch!'),
    ((SELECT user_id FROM "user" WHERE username = 'jane_smith'), 202, '2024-02-10', 4, 'Great acting and storyline'),
    ((SELECT user_id FROM "user" WHERE username = 'mike_jones'), 203, '2024-03-12', 3, 'Good, but not memorable'),
    ((SELECT user_id FROM "user" WHERE username = 'john_doe'), 204, '2024-04-20', 5, 'One of my favorites!');
    
    -- Inserting user scores for each user
    INSERT INTO user_score (user_id, media_id, score_value, review_text) VALUES
    ((SELECT user_id FROM "user" WHERE username = 'john_doe'), 301, 9, 'Brilliant storytelling and visuals'),
    ((SELECT user_id FROM "user" WHERE username = 'jane_smith'), 302, 8, 'Excellent performances but slow pacing'),
    ((SELECT user_id FROM "user" WHERE username = 'mike_jones'), 303, 7, 'Good, but could be better'),
    ((SELECT user_id FROM "user" WHERE username = 'john_doe'), 304, 10, 'One of the best movies I have ever seen!'),
    ((SELECT user_id FROM "user" WHERE username = 'jane_smith'), 305, 6, 'Decent, but not my cup of tea');
END $$;
