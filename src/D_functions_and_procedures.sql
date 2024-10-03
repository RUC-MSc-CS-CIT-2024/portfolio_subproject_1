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

--D3 Rating function
CREATE OR REPLACE FUNCTION rate(p_userid INT, p_imdb_id VARCHAR, p_score NUMERIC)
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
            created_at = CURRENT_TIMESTAMP
        WHERE user_id = p_userid AND media_id = v_media_id;
    ELSE
        -- Insert new score into user_score
        INSERT INTO user_score (user_id, media_id, score_value)
        VALUES (p_userid, v_media_id, p_score);
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
            v_media_id
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
-- Insert Sample Data
INSERT INTO media (type, plot, runtime, imdb_id) 
VALUES 
('Movie', 'A mind-bending thriller about dreams and reality.', 148, 'tt1375666');

INSERT INTO "user" (username, password, email) VALUES 
('john_doe', 'password123', 'john@example.com'),
('jane_doe', 'password456', 'jane@example.com')
ON CONFLICT (username) DO NOTHING;

-- Test Rating Functionality
DO $$
DECLARE
    john_id INTEGER;
    jane_id INTEGER;
BEGIN
    -- Retrieve user IDs for john_doe and jane_doe
    SELECT user_id INTO john_id FROM "user" WHERE username = 'john_doe';
    SELECT user_id INTO jane_id FROM "user" WHERE username = 'jane_doe';

    -- Perform ratings using the rate() function
    PERFORM rate(john_id, 'tt1375666', 8.0); 
    PERFORM rate(john_id, 'tt1375666', 9.0); 
    PERFORM rate(jane_id, 'tt1375666', 7.0); 
END $$;

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
-- Copy the 'wi' table from the 'original' schema to the 'public' schema
CREATE TABLE public.wi AS
SELECT *
FROM original.wi;

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
RETURNS TABLE (media_id INTEGER) AS $$
BEGIN
    RETURN QUERY
    SELECT m.media_id
    FROM media m
    JOIN (
        SELECT tconst
        FROM wi
        WHERE word = ANY(keywords)
        GROUP BY tconst
        HAVING COUNT(DISTINCT word) = array_length(keywords, 1)
    ) w ON m.imdb_id = w.tconst;
END;
$$ LANGUAGE plpgsql;

-- D11 TEST 
SELECT * FROM exact_match_titles(ARRAY['apple','mads','mikkelsen']);
SELECT title FROM release WHERE media_id=47460;


-- D12 Function to best match querying, ranking and ordering the media.
CREATE OR REPLACE FUNCTION best_match_titles(
    keywords TEXT[]
)
RETURNS TABLE (media_id INTEGER, match_count INTEGER) AS $$
BEGIN
    RETURN QUERY
    SELECT m.media_id, COUNT(DISTINCT wi.word)::INTEGER AS match_count
    FROM media m
    JOIN wi ON m.imdb_id = wi.tconst
    WHERE wi.word = ANY(keywords)
    GROUP BY m.media_id
    ORDER BY match_count DESC;
END;
$$ LANGUAGE plpgsql;

-- D12 TEST
SELECT * FROM best_match_titles(ARRAY['apple', 'mads', 'mikkelsen']);
SELECT title FROM release WHERE media_id=47460;