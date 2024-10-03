DROP TABLE IF EXISTS "user" CASCADE;
DROP TABLE IF EXISTS search_history CASCADE;
DROP TABLE IF EXISTS bookmark CASCADE;
DROP TABLE IF EXISTS completed CASCADE;
DROP TABLE IF EXISTS plan_to_watch CASCADE;
DROP TABLE IF EXISTS user_score CASCADE;

CREATE TABLE "user" (
    user_id INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL
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
