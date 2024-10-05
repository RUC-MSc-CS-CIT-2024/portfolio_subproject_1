-- This script contains all the functions and procedures that are part of the project.
-- Enable the pgcrypto extension
CREATE EXTENSION IF NOT EXISTS pgcrypto;
-- Indexing

-- User-Related Foreign Keys
CREATE INDEX idx_search_history_user_id ON search_history(user_id);
CREATE INDEX idx_bookmark_user_id ON bookmark(user_id);
CREATE INDEX idx_completed_user_id ON completed(user_id);
CREATE INDEX idx_user_score_user_id ON user_score(user_id);

-- Media-Related Foreign Keys
CREATE INDEX idx_bookmark_media_id ON bookmark(media_id);
CREATE INDEX idx_completed_media_id ON completed(media_id);
CREATE INDEX idx_user_score_media_id ON user_score(media_id);
CREATE INDEX idx_season_series_id ON season(series_id);
CREATE INDEX idx_episode_season_id ON episode(season_id);
CREATE INDEX idx_media_genre_media_id ON media_genre(media_id);
CREATE INDEX idx_media_production_country_media_id ON media_production_country(media_id);
CREATE INDEX idx_score_media_id ON score(media_id);
CREATE INDEX idx_media_in_collection_media_id ON media_in_collection(media_id);
CREATE INDEX idx_related_media_primary_id ON related_media(primary_id);
CREATE INDEX idx_related_media_related_id ON related_media(related_id);
CREATE INDEX idx_media_imdb_id ON media(imdb_id);

-- Person-Related Foreign Keys
CREATE INDEX idx_crew_member_person_id ON crew_member(person_id);
CREATE INDEX idx_cast_member_person_id ON cast_member(person_id);
CREATE INDEX idx_person_name ON person(name);

-- Commonly Queried Columns
CREATE INDEX idx_user_username ON "user"(username);
CREATE INDEX idx_user_email ON "user"(email);
CREATE INDEX idx_completed_completed_date ON completed(completed_date);
CREATE INDEX idx_user_score_score_value ON user_score(score_value);
CREATE INDEX idx_search_history_type ON search_history(type);
CREATE INDEX idx_media_in_collection_collection_id ON media_in_collection(collection_id);
CREATE INDEX idx_wi_words ON wi(word);

-- Composite Indexes
CREATE INDEX idx_media_production_country_media_country ON media_production_country(media_id, country_id);
CREATE INDEX idx_media_country ON media_production_country(country_id, media_id);
CREATE INDEX idx_media_in_collection_collection_media ON media_in_collection(collection_id, media_id);


-- D1 Basic Framework Functionality.

-- Basic User Signup Function that includes password validation.
CREATE OR REPLACE FUNCTION create_user(p_username VARCHAR, p_password VARCHAR, p_email VARCHAR)
RETURNS VOID AS $$
DECLARE
    -- Validation variables
    v_min_length INT := 8;
    v_has_upper BOOLEAN := FALSE;
    v_has_lower BOOLEAN := FALSE;
    v_has_digit BOOLEAN := FALSE;
    v_has_special BOOLEAN := FALSE;
BEGIN
    -- Check if the username already exists
    IF EXISTS (SELECT 1 FROM "user" WHERE username = p_username) THEN
        RAISE EXCEPTION 'Username % already exists', p_username;

    -- Check if the email already exists
    ELSIF EXISTS (SELECT 1 FROM "user" WHERE email = p_email) THEN
        RAISE EXCEPTION 'Email % already exists', p_email;

    ELSE
        IF LENGTH(p_password) < v_min_length THEN
            RAISE EXCEPTION 'Password must be at least % characters long', v_min_length;
        END IF;

        -- Validate password complexity
        v_has_upper := p_password ~ '[A-Z]';
        v_has_lower := p_password ~ '[a-z]';
        v_has_digit := p_password ~ '[0-9]';
        v_has_special := p_password ~ '[^a-zA-Z0-9]';

        IF NOT v_has_upper THEN
            RAISE EXCEPTION 'Password must contain at least one uppercase letter';
        ELSIF NOT v_has_lower THEN
            RAISE EXCEPTION 'Password must contain at least one lowercase letter';
        ELSIF NOT v_has_digit THEN
            RAISE EXCEPTION 'Password must contain at least one digit';
        ELSIF NOT v_has_special THEN
            RAISE EXCEPTION 'Password must contain at least one special character';
        END IF;

        -- Insert the new user with a hashed password using crypt
        INSERT INTO "user" (username, password, email)
        VALUES (p_username, crypt(p_password, gen_salt('bf')), p_email);
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Execute the create_user function directly
SELECT create_user('ManseChampanse', 'SuperManse123!', 'ManseChampanse@hotmail.com');
-- Verify that the user has been created
SELECT * FROM "user" WHERE username = 'ManseChampanse';


-- Basic User Login Function with hashing and validation.
CREATE OR REPLACE FUNCTION login_user(p_username_or_email VARCHAR, p_password VARCHAR)
RETURNS BOOLEAN AS $$
DECLARE
    v_stored_password VARCHAR;
    v_user_id INT;
BEGIN
    SELECT password, user_id
    INTO v_stored_password, v_user_id
    FROM "user"
    WHERE username = p_username_or_email OR email = p_username_or_email;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Invalid username/email or password';
    END IF;

    -- Validate the provided password with the stored hashed password
    IF crypt(p_password, v_stored_password) = v_stored_password THEN
        -- Password matches, login successful
        RETURN TRUE;
    ELSE
        -- Password does not match
        RAISE EXCEPTION 'Invalid username/email or password';
    END IF;
END;
$$ LANGUAGE plpgsql;
-- Test the login_user function with correct credentials
SELECT login_user('ManseChampanse', 'SuperManse123!');
-- Test the login_user function with an incorrect password
SELECT login_user('ManseChampanse', 'WrongPassword!');


-- Basic User Password Update Function with password validation.
CREATE OR REPLACE FUNCTION update_user_password(p_user_id INT, p_new_password VARCHAR)
RETURNS VOID AS $$
DECLARE
    v_min_length INT := 8;
    v_has_upper BOOLEAN := FALSE;
    v_has_lower BOOLEAN := FALSE;
    v_has_digit BOOLEAN := FALSE;
    v_has_special BOOLEAN := FALSE;
BEGIN
    IF LENGTH(p_new_password) < v_min_length THEN
        RAISE EXCEPTION 'Password must be at least % characters long', v_min_length;
    END IF;

    v_has_upper := p_new_password ~ '[A-Z]';
    v_has_lower := p_new_password ~ '[a-z]';
    v_has_digit := p_new_password ~ '[0-9]';
    v_has_special := p_new_password ~ '[^a-zA-Z0-9]';

    IF NOT v_has_upper THEN
        RAISE EXCEPTION 'Password must contain at least one uppercase letter';
    ELSIF NOT v_has_lower THEN
        RAISE EXCEPTION 'Password must contain at least one lowercase letter';
    ELSIF NOT v_has_digit THEN
        RAISE EXCEPTION 'Password must contain at least one digit';
    ELSIF NOT v_has_special THEN
        RAISE EXCEPTION 'Password must contain at least one special character';
    END IF;

    -- Update the password securely with crypt
    UPDATE "user"
    SET password = crypt(p_new_password, gen_salt('bf'))
    WHERE user_id = p_user_id;
    
    -- Check if update was successful
    IF NOT FOUND THEN
        RAISE EXCEPTION 'User ID % not found', p_user_id;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Test the update_user_password function with a valid user ID and password
SELECT update_user_password(1, 'NewStrongPass1!');

-- Basic User Email Update Function with email validation.
CREATE OR REPLACE FUNCTION update_user_credentials(p_user_id INT, p_new_username VARCHAR DEFAULT NULL, p_new_email VARCHAR DEFAULT NULL)
RETURNS VOID AS $$
BEGIN
    IF p_new_username IS NOT NULL THEN
        IF EXISTS (SELECT 1 FROM "user" WHERE username = p_new_username AND user_id != p_user_id) THEN
            RAISE EXCEPTION 'Username % already exists', p_new_username;
        ELSE
            UPDATE "user" SET username = p_new_username WHERE user_id = p_user_id;
        END IF;
    END IF;

    IF p_new_email IS NOT NULL THEN
        IF EXISTS (SELECT 1 FROM "user" WHERE email = p_new_email AND user_id != p_user_id) THEN
            RAISE EXCEPTION 'Email % already exists', p_new_email;
        ELSE
            UPDATE "user" SET email = p_new_email WHERE user_id = p_user_id;
        END IF;
    END IF;

    -- Check if any update was applied
    IF NOT FOUND THEN
        RAISE EXCEPTION 'User ID % not found or no changes applied', p_user_id;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Update only the username
SELECT update_user_credentials(1, 'NewUsername', NULL);

-- Update only the email
SELECT update_user_credentials(1, NULL, 'newemail@example.com');

-- Update both username and email
SELECT update_user_credentials(1, 'AnotherUsername', 'anotheremail@example.com');

-- Basic User Deletion Function with validation.
CREATE OR REPLACE FUNCTION delete_user(p_user_id INT)
RETURNS VOID AS $$
BEGIN
    -- Check if the user exists before deletion
    IF EXISTS (SELECT 1 FROM "user" WHERE user_id = p_user_id) THEN
        -- Delete the user (related records will be deleted automatically via ON DELETE CASCADE)
        DELETE FROM "user" WHERE user_id = p_user_id;
    ELSE
        RAISE EXCEPTION 'User ID % not found', p_user_id;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Test the delete_user function with an existing user ID
SELECT delete_user(1);

-- followed function
CREATE OR REPLACE FUNCTION follow_person(p_follower_id INT, p_person_id INT)
RETURNS VOID AS $$
BEGIN
    -- Check if the person exists in the person table
    IF NOT EXISTS (
        SELECT 1 FROM person WHERE person_id = p_person_id
    ) THEN
        RAISE EXCEPTION 'Person with ID % does not exist', p_person_id;
    END IF;

    -- Check if the user is already following the person
    IF EXISTS (
        SELECT 1 FROM "following" 
        WHERE user_id = p_follower_id AND person_id = p_person_id
    ) THEN
        RAISE EXCEPTION 'User % is already following person %', p_follower_id, p_person_id;
    END IF;

    INSERT INTO "following" (user_id, person_id, followed_since)
    VALUES (p_follower_id, p_person_id, CURRENT_TIMESTAMP);
END;
$$ LANGUAGE plpgsql;

-- Test the follow_person function with valid user and person IDs
SELECT follow_person(1, 1056); 

-- unfollowed function
CREATE OR REPLACE FUNCTION unfollow_person(p_follower_id INT, p_person_id INT)
RETURNS VOID AS $$
BEGIN
    -- Check if the user is currently following the person
    IF NOT EXISTS (
        SELECT 1 FROM "following"
        WHERE user_id = p_follower_id AND person_id = p_person_id
    ) THEN
        RAISE EXCEPTION 'User % is not following person %', p_follower_id, p_person_id;
    END IF;

    -- Remove the follow record
    DELETE FROM "following"
    WHERE user_id = p_follower_id AND person_id = p_person_id;
END;
$$ LANGUAGE plpgsql;

-- Test the unfollow_person function with valid user and person IDs
SELECT unfollow_person(1, 1056);

-- Bookmark media function
CREATE OR REPLACE FUNCTION bookmark_media(p_user_id INT, p_media_id INT, p_note TEXT DEFAULT NULL)
RETURNS VOID AS $$
BEGIN
    -- Check if the user has already bookmarked this media
    IF EXISTS (
        SELECT 1 FROM bookmark 
        WHERE user_id = p_user_id AND media_id = p_media_id
    ) THEN
        RAISE EXCEPTION 'User % has already bookmarked media %', p_user_id, p_media_id;
    END IF;

    INSERT INTO bookmark (user_id, media_id, note)
    VALUES (p_user_id, p_media_id, p_note);
END;
$$ LANGUAGE plpgsql;

-- Test the bookmark_media function with valid user and media IDs
SELECT bookmark_media(1, 1023, 'Great Series, must watch later!');
SELECT bookmark_media(1, 3299, 'Meh! Was decent I suppose...');

-- Move bookmark to completed function
CREATE OR REPLACE FUNCTION move_bookmark_to_completed(
    p_user_id INT,
    p_media_id INT,
    p_rewatchability INT,
    p_note TEXT DEFAULT NULL
)
RETURNS VOID AS $$
BEGIN
    -- Check if the media is bookmarked by the user
    IF NOT EXISTS (
        SELECT 1 FROM bookmark
        WHERE user_id = p_user_id AND media_id = p_media_id
    ) THEN
        RAISE EXCEPTION 'Media % is not bookmarked by user %', p_media_id, p_user_id;
    END IF;

    -- Check for valid rewatchability score
    IF p_rewatchability < 1 OR p_rewatchability > 5 THEN
        RAISE EXCEPTION 'Rewatchability must be between 1 and 5';
    END IF;

    -- Move the media from bookmark to completed
    INSERT INTO completed (user_id, media_id, completed_date, rewatchability, note)
    VALUES (p_user_id, p_media_id, CURRENT_DATE, p_rewatchability, p_note);

    -- Remove the media from bookmarks
    DELETE FROM bookmark
    WHERE user_id = p_user_id AND media_id = p_media_id;
END;
$$ LANGUAGE plpgsql;
-- Test the move_bookmark_to_completed function with valid user and media IDs
SELECT move_bookmark_to_completed(1, 1023, 5, 'Amazing movie!');



-- unbookmark media whithout completing it
CREATE OR REPLACE FUNCTION unbookmark_media(p_user_id INT, p_media_id INT)
RETURNS VOID AS $$
BEGIN
    -- Check if the media is bookmarked by the user
    IF NOT EXISTS (
        SELECT 1 FROM bookmark
        WHERE user_id = p_user_id AND media_id = p_media_id
    ) THEN
        RAISE EXCEPTION 'Media % is not bookmarked by user %', p_media_id, p_user_id;
    END IF;

    -- Remove the bookmark
    DELETE FROM bookmark
    WHERE user_id = p_user_id AND media_id = p_media_id;
END;
$$ LANGUAGE plpgsql;
-- Test the unbookmark_media function with valid user and media IDs
SELECT unbookmark_media(1, 3299);

--D2 SIMPLE SEARCH
CREATE OR REPLACE FUNCTION simple_search
  (query varchar(100), user_id integer)
RETURNS TABLE (media_id INTEGER, title TEXT)
AS $$
BEGIN
  -- SEARCH HISTORY
  INSERT INTO search_history (user_id, type, query)
  VALUES (user_id, 'simple_search', query);

  -- RESULT
  RETURN QUERY
  SELECT me.media_id, re.title
  FROM media me 
  JOIN "release" re USING (media_id)
  WHERE re.title LIKE '%' || query || '%' 
     OR me.plot LIKE '%' || query || '%';
END;
$$
LANGUAGE 'plpgsql';

--D2 TEST
SELECT * FROM simple_search('apple',1);


--D3 Rating function
CREATE OR REPLACE FUNCTION rate(p_userid INT, p_imdb_id VARCHAR, p_score NUMERIC, p_review_text TEXT)
RETURNS VOID AS $$
DECLARE
    v_media_id INTEGER;
    v_existing_user_score RECORD;
BEGIN
    -- Get media ID from IMDb ID
    SELECT media_id INTO v_media_id FROM media WHERE imdb_id = p_imdb_id;

    -- Check if the user has already rated this media in user_score
    SELECT * INTO v_existing_user_score 
    FROM user_score 
    WHERE user_id = p_userid AND media_id = v_media_id;

    IF FOUND THEN
        -- Update user's existing score
        UPDATE user_score
        SET score_value = p_score,
            review_text = p_review_text,
            created_at = CURRENT_TIMESTAMP
        WHERE user_id = p_userid AND media_id = v_media_id;
    ELSE
        -- Insert new score into user_score
        INSERT INTO user_score (user_id, media_id, score_value, review_text)
        VALUES (p_userid, v_media_id, p_score, p_review_text);
    END IF;

    -- Update the score table with the new average rating
    -- Check if the movie already has a score entry
    IF EXISTS (SELECT 1 FROM score WHERE media_id = v_media_id) THEN
        -- Update the existing average score and vote count in the score table
        UPDATE score
        SET value = (SELECT AVG(score_value) FROM user_score WHERE media_id = v_media_id),
            vote_count = (SELECT COUNT(*) FROM user_score WHERE media_id = v_media_id),
            "at" = CURRENT_TIMESTAMP
        WHERE media_id = v_media_id
        AND source = 'userrating';
    ELSE
        -- Insert a new average score into the score table if none exists
        INSERT INTO score (source, value, vote_count, media_id)
        VALUES (
            'userrating',
            (SELECT AVG(score_value) FROM user_score WHERE media_id = v_media_id),
            (SELECT COUNT(*) FROM user_score WHERE media_id = v_media_id),
            v_media_id,
			p_review_text
        );
    END IF;

    -- Display the updated average rating
    RAISE NOTICE 'Average Rating: %', (
        SELECT AVG(CAST(score_value AS NUMERIC)) 
        FROM user_score 
        WHERE media_id = v_media_id
    );
END;
$$ LANGUAGE plpgsql;

-- D3 TEST
DO $$
DECLARE
    john_id INTEGER;
    jane_id INTEGER;
BEGIN
    -- Retrieve user IDs for john_doe and jane_doe
    SELECT user_id INTO john_id FROM "user" WHERE username = 'john_doe';
    SELECT user_id INTO jane_id FROM "user" WHERE username = 'jane_smith';

    -- Perform ratings using the rate() function
    PERFORM rate(john_id, 'tt1375666', 8.0, 'nice'); 
    PERFORM rate(john_id, 'tt1375666', 9.0, 'super nice'); 
    PERFORM rate(jane_id, 'tt1375666', 7.0, 'okay');
	PERFORM rate(jane_id, 'tt13729548', 2.0, 'bad');
END $$;


-- D4 Structured string search
CREATE OR REPLACE FUNCTION structured_string_search (
  p_title VARCHAR(100), 
  p_plot VARCHAR(100), 
  p_character VARCHAR(100), 
  p_person VARCHAR(100),
  p_user_id INTEGER
)
RETURNS TABLE (media_id INTEGER, title TEXT)
AS $$
BEGIN
  -- SEARCH HISTORY
  INSERT INTO search_history (user_id, "type", query)
  VALUES (p_user_id, 'structured_string_search', 
          FORMAT('title: "%s", plot: "%s", character: "%s", person: "%s"', p_title, p_plot, p_character, p_person));

  -- RESULT
  RETURN QUERY
  WITH
    search_result AS (
        SELECT DISTINCT m.media_id, m.imdb_id, m."type" AS media_type
        FROM media AS m
        JOIN "release" r USING (media_id)
        LEFT JOIN crew_member cr ON m.media_id = cr.media_id
        LEFT JOIN cast_member ca ON m.media_id = ca.media_id
        LEFT JOIN person p ON ca.person_id = p.person_id OR cr.person_id = p.person_id
        WHERE (r.title ILIKE '%' || p_title || '%' OR r.title IS NULL)
            AND (m.plot ILIKE '%' || p_plot || '%' OR m.plot IS NULL)
            AND (ca."character" ILIKE '%' || p_character || '%' OR ca."character" IS NULL)
            AND (p."name" ILIKE '%' || p_person || '%' OR p."name" IS NULL)
    )
  SELECT DISTINCT imdb_id, title, media_type
  FROM search_result
  JOIN "release" USING (media_id)
  WHERE title_type = 'original';
END;
$$
LANGUAGE 'plpgsql';


--D5
--With a query find actors, movies casted, roles played and their crew job info

CREATE OR REPLACE FUNCTION structured_string_search_name(
    query VARCHAR(150),
    user_id INTEGER
)
RETURNS TABLE (person_id INTEGER, "name" VARCHAR(150), filmography json)
AS $$
BEGIN

    INSERT INTO search_history (user_id, type, query)
    VALUES (user_id, 'structured_string_search_name', query);

    RETURN QUERY
    SELECT p.person_id, 
		p.name, 
		json_agg(json_build_object('media_id', "cast".media_id, 'character', REPLACE(REPLACE("cast".character,'[',''),']',''),'crew_role',jc.name))
    FROM person p
    LEFT JOIN cast_member "cast" USING (person_id)
    LEFT JOIN crew_member crew USING (person_id, media_id)
	LEFT JOIN job_category jc ON crew.job_category_id = jc.job_category_id
    WHERE p.name ILIKE '%'||query||'%'
	GROUP BY p.person_id,p.name
	ORDER BY p.person_id;

END;
$$
language plpgsql;

--TEST
SELECT * FROM structured_string_search_name('Jennifer',1);

-- D6 View to simplify queries for actors and their associated media
CREATE OR REPLACE VIEW actor_media_view AS
SELECT 
    p.person_id,
    p."name" AS actor_name,
    p.imdb_id,
    cm.media_id,
    cm."role",
    cm."character"
FROM 
    person p
JOIN 
    cast_member cm ON p.person_id = cm.person_id;

-- D6 Function to find the most frequent co-actors of a given actor
CREATE OR REPLACE FUNCTION get_frequent_coplaying_actors(actor_name_input VARCHAR)
RETURNS TABLE (
    coactor_name VARCHAR,
    coactor_imdb_id VARCHAR,
    frequency INT
)
AS
$$
BEGIN
		-- Query to return the frequent co-stars
    RETURN QUERY
    SELECT 
        cm2.actor_name AS coactor_name,
        cm2.imdb_id AS coactor_imdb_id,
        COUNT(DISTINCT cm1.media_id)::INTEGER AS frequency
    FROM 
        actor_media_view cm1
    JOIN 
        actor_media_view cm2 ON cm1.media_id = cm2.media_id
    WHERE 
        cm1.actor_name = actor_name_input
        AND cm1.person_id != cm2.person_id
        AND cm2.actor_name != actor_name_input
    GROUP BY 
        cm2.actor_name, cm2.imdb_id
    ORDER BY 
        frequency DESC;
END;
$$ LANGUAGE plpgsql;

-- D6 TEST
SELECT * FROM get_frequent_coplaying_actors('Jennifer Aniston');

-- D7
CREATE OR REPLACE FUNCTION calculate_name_rating() RETURNS VOID AS $$
BEGIN
    UPDATE person
    SET name_rating = sub.weighted_rating
    FROM (
        SELECT
            p.person_id,
            -- NOTE: Here we use NULLIF to prevent division by zero.
            SUM(CAST(sc.value AS DECIMAL) * sc.vote_count) / NULLIF(SUM(sc.vote_count), 0) AS weighted_rating
        FROM person p
        LEFT JOIN cast_member cm ON p.person_id = cm.person_id
        LEFT JOIN score sc ON cm.media_id = sc.media_id
        LEFT JOIN crew_member cr ON p.person_id = cr.person_id
        WHERE cm.media_id IS NOT NULL OR cr.media_id IS NOT NULL
        GROUP BY p.person_id
    ) AS sub
    WHERE person.person_id = sub.person_id;
END;
$$ LANGUAGE plpgsql;
-- D7 Test Name Rating Calculation
DO $$
BEGIN
    PERFORM calculate_name_rating();
END $$;

-- D8 List Actors by Popularity
CREATE OR REPLACE FUNCTION list_actors_by_popularity(p_media_id INT)
RETURNS TABLE (actor_id INT, actor_name TEXT, actor_rating DECIMAL(3, 2)) AS $$
BEGIN
    RETURN QUERY
    SELECT p.person_id, 
           p."name"::TEXT,
           p.name_rating
    FROM person p
    INNER JOIN cast_member cm ON p.person_id = cm.person_id
    WHERE cm.media_id = p_media_id
    ORDER BY p.name_rating DESC;
END;
$$ LANGUAGE plpgsql;
-- Test with a sample media ID
SELECT * FROM list_actors_by_popularity(36);

-- D8 List Co-Actors by Popularity for a Given Actor
CREATE OR REPLACE FUNCTION list_co_actors_by_popularity(p_actor_id INT)
RETURNS TABLE (co_actor_id INT, co_actor_name TEXT, co_actor_rating DECIMAL(6, 2)) AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT p2.person_id, 
                    p2."name"::TEXT,
                    p2.name_rating
    FROM cast_member cm1
    INNER JOIN cast_member cm2 ON cm1.media_id = cm2.media_id  
    INNER JOIN person p2 ON cm2.person_id = p2.person_id
    WHERE cm1.person_id = p_actor_id 
      AND cm2.person_id != p_actor_id
      AND p2.name_rating IS NOT NULL
    ORDER BY p2.name_rating DESC;
END;
$$ LANGUAGE plpgsql;
-- Test with a sample actor ID
SELECT * FROM list_co_actors_by_popularity(64);


-- D10 Frequent person words
-- Create the function 'person_words' to retrieve words associated with a person's titles
CREATE OR REPLACE FUNCTION person_words(
    p_person_name VARCHAR,
    p_max_length INT DEFAULT 10  -- Optional parameter to limit the number of results returned
)
RETURNS TABLE (word TEXT, frequency INT) AS $$
BEGIN
    RETURN QUERY
    SELECT wi.word, COUNT(*)::INTEGER AS frequency 
    FROM wi 
    JOIN media m ON wi.tconst = m.imdb_id
    JOIN cast_member cm ON m.media_id = cm.media_id
    JOIN person p ON cm.person_id = p.person_id
    WHERE p.name ILIKE '%' || TRIM(p_person_name) || '%'
    GROUP BY wi.word
    ORDER BY frequency DESC
    LIMIT p_max_length;
END;
$$ LANGUAGE plpgsql;

-- D10 TEST
SELECT * FROM person_words('Jennifer Aniston', 8);


-- D11 Function to find titles to match the exact-match querying 
CREATE OR REPLACE FUNCTION exact_match_titles(
    keywords TEXT[]
)
RETURNS TABLE (media_id INTEGER, title TEXT) AS $$
BEGIN
    RETURN QUERY
    -- Find matching media IDs based on keywords in the wi table
    WITH
        imdb_ids_with_word AS (
            SELECT tconst AS imdb_id
            FROM wi
            WHERE word = ANY(keywords)
            GROUP BY tconst
            HAVING COUNT(DISTINCT word) = array_length(keywords, 1)
        )
    SELECT m.media_id, t."name" AS title
    FROM media m
    JOIN imdb_ids_with_word USING(imdb_id)
    JOIN title AS t USING(media_id)
    JOIN title_title_type USING(title_id)
    JOIN title_type AS tt using(title_type_id)
    WHERE ttt.title_type = 'original';
    WHERE tt."name" = 'original';
END;
$$ LANGUAGE plpgsql;

-- D11 TEST
SELECT * FROM exact_match_titles(ARRAY['apple', 'mads', 'mikkelsen']);

-- D12 Function to best match querying, ranking and ordering the media.
CREATE OR REPLACE FUNCTION best_match_titles(
    keywords TEXT[]
)
RETURNS TABLE (media_id INTEGER, title TEXT, match_count INTEGER) AS $$
BEGIN
    RETURN QUERY
    WITH
        original_titles AS (
            SELECT DISTINCT m.media_id, t."name" AS title
            FROM media m
            JOIN title AS t USING(media_id)
            JOIN title_title_type USING(title_id)
            JOIN title_type AS tt USING(title_type_id)
            WHERE tt."name" = 'original'
        )
    SELECT m.media_id, t.title, COUNT(DISTINCT wi.word)::INTEGER AS match_count
    FROM media AS m
    JOIN wi ON m.imdb_id = wi.tconst
    JOIN original_titles AS t USING(media_id)
    WHERE wi.word = ANY(keywords)
    GROUP BY m.media_id, r.title
    ORDER BY match_count DESC;
END;
$$ LANGUAGE plpgsql;

-- D12 TEST
SELECT * FROM best_match_titles(ARRAY['apple', 'mads', 'mikkelsen']);


-- D13 Function for word_to_words_querying, ranking and ordering the words
CREATE OR REPLACE FUNCTION word_to_words_query(
    keywords TEXT[]
)
RETURNS TABLE (word TEXT, frequency INTEGER) AS $$
BEGIN
    RETURN QUERY
    -- Select matching titles based on the keyword query
    WITH matched_titles AS (
        SELECT m.media_id, m.imdb_id
        FROM release r
        JOIN media m ON r.media_id = m.media_id
        WHERE r.title ILIKE ANY (ARRAY(SELECT '%' || kw || '%' FROM unnest(keywords) AS kw))
    ),
    
    -- Select all words from the wi table associated with the matched titles
    word_frequencies AS (
        SELECT wi.word, COUNT(*)::INTEGER AS frequency
        FROM wi
        JOIN matched_titles mt ON wi.tconst = mt.imdb_id
        GROUP BY wi.word
    )
    
    -- Return the words and their frequencies, ordered by frequency
    SELECT wf.word, wf.frequency
    FROM word_frequencies wf
    ORDER BY wf.frequency DESC;
END;
$$ LANGUAGE plpgsql;

-- D13 TEST
SELECT * FROM word_to_words_query(ARRAY['apple', 'mads', 'mikkelsen']);