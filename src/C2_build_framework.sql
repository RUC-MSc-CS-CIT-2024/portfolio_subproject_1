DROP TABLE IF EXISTS search_history CASCADE;
DROP TABLE IF EXISTS bookmark CASCADE;
DROP TABLE IF EXISTS completed CASCADE;
DROP TABLE IF EXISTS "following" CASCADE;
DROP TABLE IF EXISTS user_score CASCADE;
DROP TABLE IF EXISTS "user" CASCADE;

CREATE TABLE "user" (
    user_id         INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    username        VARCHAR UNIQUE NOT NULL,
    email           VARCHAR UNIQUE NOT NULL,
    hashed_password VARCHAR NOT NULL,
    salt            VARCHAR NOT NULL
);

CREATE TABLE search_history (
    search_history_id INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    user_id INTEGER REFERENCES "user"(user_id) ON DELETE CASCADE,
    type VARCHAR(50) NOT NULL,
    query TEXT NOT NULL
);

CREATE TABLE bookmark (
    bookmark_id INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    user_id INTEGER REFERENCES "user"(user_id) ON DELETE CASCADE,
    media_id INTEGER,
    note TEXT NULL
);

CREATE TABLE completed (
    completed_id INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    user_id INTEGER REFERENCES "user"(user_id) ON DELETE CASCADE,
    media_id INTEGER,
    completed_date DATE NULL,
    rewatchability INTEGER CHECK (rewatchability >= 1 AND rewatchability <= 5),
    note TEXT NULL
);

CREATE TABLE user_score (
    user_score_id INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    user_id INTEGER REFERENCES "user"(user_id) ON DELETE CASCADE,
    media_id INTEGER,
    score_value INTEGER CHECK (score_value >= 1 AND score_value <= 10),
    review_text TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE "following" (
    following_id INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    user_id INTEGER REFERENCES "user"(user_id) ON DELETE CASCADE,
    person_id INTEGER,
    followed_since TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert sample data using DO blocks
DO $$
DECLARE
    new_user_id INTEGER;
BEGIN
    INSERT INTO "user" (username, password, email) 
    VALUES ('john_doe', 'password123', 'john@example.com')
    RETURNING user_id INTO new_user_id;

    INSERT INTO search_history (user_id, type, query) VALUES
    (new_user_id, 'movie', 'Inception'),
    (new_user_id, 'movie', 'Interstellar');

    INSERT INTO bookmark (user_id, media_id, note) VALUES
    (new_user_id, 101, 'Watch later'),
    (new_user_id, 104, 'Need to check reviews first');

    INSERT INTO completed (user_id, media_id, completed_date, rewatchability, note) VALUES
    (new_user_id, 201, '2024-01-15', 5, 'Amazing movie, must rewatch!'),
    (new_user_id, 204, '2024-04-20', 5, 'One of my favorites!');

    INSERT INTO user_score (user_id, media_id, score_value, review_text) VALUES
    (new_user_id, 301, 9, 'Brilliant storytelling and visuals'),
    (new_user_id, 304, 10, 'One of the best movies I have ever seen!');
END $$;

DO $$
DECLARE
    new_user_id INTEGER;
BEGIN
    INSERT INTO "user" (username, password, email) 
    VALUES ('jane_smith', 'password456', 'jane@example.com')
    RETURNING user_id INTO new_user_id;

    INSERT INTO search_history (user_id, type, query) VALUES
    (new_user_id, 'series', 'Breaking Bad'),
    (new_user_id, 'movie', 'The Godfather');

    INSERT INTO bookmark (user_id, media_id, note) VALUES
    (new_user_id, 102, 'Recommended by friend');

    INSERT INTO completed (user_id, media_id, completed_date, rewatchability, note) VALUES
    (new_user_id, 202, '2024-02-10', 4, 'Great acting and storyline');

    INSERT INTO user_score (user_id, media_id, score_value, review_text) VALUES
    (new_user_id, 302, 8, 'Excellent performances but slow pacing'),
    (new_user_id, 305, 6, 'Decent, but not my cup of tea');
END $$;

DO $$
DECLARE
    new_user_id INTEGER;
BEGIN
    INSERT INTO "user" (username, password, email) 
    VALUES ('mike_jones', 'password789', 'mike@example.com')
    RETURNING user_id INTO new_user_id;

    INSERT INTO search_history (user_id, type, query) VALUES
    (new_user_id, 'movie', 'The Matrix');

    INSERT INTO bookmark (user_id, media_id, note) VALUES
    (new_user_id, 103, 'Interesting plot');

    INSERT INTO completed (user_id, media_id, completed_date, rewatchability, note) VALUES
    (new_user_id, 203, '2024-03-12', 3, 'Good, but not memorable');

    INSERT INTO user_score (user_id, media_id, score_value, review_text) VALUES
    (new_user_id, 303, 7, 'Good, but could be better');
END $$;
