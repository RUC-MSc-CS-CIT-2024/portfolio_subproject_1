CREATE TABLE "User" (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE "SearchHistory" (
    search_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES "User"(user_id) ON DELETE CASCADE,
    status VARCHAR(50),
    note TEXT
);

CREATE TABLE "Bookmarks" (
    bookmark_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES "User"(user_id) ON DELETE CASCADE,
    media_id INT REFERENCES "Media"(media_id) ON DELETE CASCADE, -- TODO: Change this to the actual media_id when the table is created.
    note TEXT
);

CREATE TABLE "Completed" (
    completed_id SERIAL PRIMARY KEY,
    bookmark_id INT REFERENCES "Bookmarks"(bookmark_id) ON DELETE CASCADE,
    completed_date DATE NOT NULL,
    rewatchability INT CHECK (rewatchability >= 1 AND rewatchability <= 10)
);

CREATE TABLE "PlanToWatch" (
    plan_id SERIAL PRIMARY KEY,
    bookmark_id INT REFERENCES "Bookmarks"(bookmark_id) ON DELETE CASCADE
);

CREATE TABLE "UserScore" (
    score_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES "User"(user_id) ON DELETE CASCADE,
    media_id INT REFERENCES "Media"(media_id) ON DELETE CASCADE, -- TODO: Change this to the actual media_id when the table is created.
    score_value INT CHECK (score_value >= 1 AND score_value <= 10),
    review_text TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
