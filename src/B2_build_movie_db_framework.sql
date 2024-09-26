CREATE TABLE "user" (
    user_id INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE search_history (
    search_id INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    user_id INTEGER REFERENCES "user"(user_id) ON DELETE CASCADE,
    status VARCHAR(50),
    note TEXT
);

CREATE TABLE bookmarks (
    bookmark_id INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    user_id INTEGER REFERENCES "user"(user_id) ON DELETE CASCADE,
    media_id INTEGER REFERENCES media(id) ON DELETE CASCADE,
    note TEXT
);

CREATE TABLE completed (
    completed_id INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    bookmark_id INTEGER REFERENCES bookmarks(bookmark_id) ON DELETE CASCADE,
    completed_date DATE NOT NULL,
    rewatchability INTEGER CHECK (rewatchability >= 1 AND rewatchability <= 10)
);

CREATE TABLE plan_to_watch (
    plan_id INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    bookmark_id INTEGER REFERENCES bookmarks(bookmark_id) ON DELETE CASCADE
);

CREATE TABLE user_score (
    score_id INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    user_id INTEGER REFERENCES "user"(user_id) ON DELETE CASCADE,
    media_id INTEGER REFERENCES media(id) ON DELETE CASCADE,
    score_value INTEGER CHECK (score_value >= 1 AND score_value <= 10),
    review_text TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
