-- Indexing

DO $$
BEGIN
    -- User-Related Foreign Keys
    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'idx_search_history_user_id') THEN
        CREATE INDEX idx_search_history_user_id ON search_history(user_id);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'idx_bookmark_user_id') THEN
        CREATE INDEX idx_bookmark_user_id ON bookmark(user_id);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'idx_completed_user_id') THEN
        CREATE INDEX idx_completed_user_id ON completed(user_id);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'idx_user_score_user_id') THEN
        CREATE INDEX idx_user_score_user_id ON user_score(user_id);
    END IF;

    -- Media-Related Foreign Keys
    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'idx_bookmark_media_id') THEN
        CREATE INDEX idx_bookmark_media_id ON bookmark(media_id);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'idx_completed_media_id') THEN
        CREATE INDEX idx_completed_media_id ON completed(media_id);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'idx_user_score_media_id') THEN
        CREATE INDEX idx_user_score_media_id ON user_score(media_id);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'idx_season_series_id') THEN
        CREATE INDEX idx_season_series_id ON season(series_id);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'idx_episode_season_id') THEN
        CREATE INDEX idx_episode_season_id ON episode(season_id);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'idx_media_genre_media_id') THEN
        CREATE INDEX idx_media_genre_media_id ON media_genre(media_id);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'idx_media_production_country_media_id') THEN
        CREATE INDEX idx_media_production_country_media_id ON media_production_country(media_id);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'idx_score_media_id') THEN
        CREATE INDEX idx_score_media_id ON score(media_id);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'idx_media_in_collection_media_id') THEN
        CREATE INDEX idx_media_in_collection_media_id ON media_in_collection(media_id);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'idx_related_media_primary_id') THEN
        CREATE INDEX idx_related_media_primary_id ON related_media(primary_id);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'idx_related_media_related_id') THEN
        CREATE INDEX idx_related_media_related_id ON related_media(related_id);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'idx_media_imdb_id') THEN
        CREATE INDEX idx_media_imdb_id ON media(imdb_id);
    END IF;

    -- Person-Related Foreign Keys
    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'idx_crew_member_person_id') THEN
        CREATE INDEX idx_crew_member_person_id ON crew_member(person_id);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'idx_cast_member_person_id') THEN
        CREATE INDEX idx_cast_member_person_id ON cast_member(person_id);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'idx_person_name') THEN
        CREATE INDEX idx_person_name ON person(name);
    END IF;

    -- Commonly Queried Columns
    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'idx_user_username') THEN
        CREATE INDEX idx_user_username ON "user"(username);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'idx_user_email') THEN
        CREATE INDEX idx_user_email ON "user"(email);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'idx_completed_completed_date') THEN
        CREATE INDEX idx_completed_completed_date ON completed(completed_date);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'idx_user_score_score_value') THEN
        CREATE INDEX idx_user_score_score_value ON user_score(score_value);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'idx_search_history_type') THEN
        CREATE INDEX idx_search_history_type ON search_history(type);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'idx_media_in_collection_collection_id') THEN
        CREATE INDEX idx_media_in_collection_collection_id ON media_in_collection(collection_id);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'idx_wi_words') THEN
        CREATE INDEX idx_wi_words ON wi(word);
    END IF;

    -- Composite Indexes
    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'idx_media_production_country_media_country') THEN
        CREATE INDEX idx_media_production_country_media_country ON media_production_country(media_id, country_id);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'idx_media_country') THEN
        CREATE INDEX idx_media_country ON media_production_country(country_id, media_id);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'idx_media_in_collection_collection_media') THEN
        CREATE INDEX idx_media_in_collection_collection_media ON media_in_collection(collection_id, media_id);
    END IF;
END $$;

-- ============================================================
-- D1 Test follow_person function
-- ============================================================

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

-- ============================================================
-- D1 unfollow_person function
-- ============================================================

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

-- ============================================================
-- D1 bookmark_media function
-- ============================================================

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

-- ============================================================
-- D1 move_bookmark_to_completed function
-- ============================================================

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

-- ============================================================
-- D1 unbookmark media whithout completing it
-- ============================================================

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

-- ============================================================
-- D2 Test simple_search function
-- ============================================================

CREATE OR REPLACE FUNCTION simple_search
  (query varchar(100), user_id integer)
RETURNS TABLE (media_id INTEGER, title TEXT)
AS $$
BEGIN
    -- SEARCH HISTORY
    IF user_id != -1 THEN
        INSERT INTO search_history (user_id, type, query)
        VALUES (user_id, 'simple_search', query);
    END IF;

    -- RESULT
    RETURN QUERY
    WITH 
        search_result AS (
            SELECT me.media_id, me.imdb_id
            FROM media AS me
            JOIN title AS ti USING (media_id)
            WHERE ti."name" LIKE '%' || query || '%' 
            OR me.plot LIKE '%' || query || '%'
        )
    SELECT DISTINCT t.media_id, t."name"
    FROM search_result AS sr
    JOIN title AS t USING (media_id)
    JOIN title_title_type USING (title_id)
    JOIN title_type AS tt USING (title_type_id)
    WHERE tt."name" = 'original';
END;
$$
LANGUAGE 'plpgsql';

-- ============================================================
-- D3 rate function
-- ============================================================

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

CREATE OR REPLACE FUNCTION rate(p_userid INT, p_media_id INTEGER, p_score NUMERIC, p_review_text TEXT)
RETURNS VOID AS $$
BEGIN

    -- Insert new score into user_score
    INSERT INTO user_score (user_id, media_id, score_value, review_text)
    VALUES (p_userid, p_media_id, p_score, p_review_text);

    -- Update the score table with the new average rating
    -- Check if the movie already has a score entry
    SELECT * FROM score WHERE media_id = p_media_id;
    IF FOUND THEN
        -- Update the existing average score and vote count in the score table
        UPDATE score
        SET value = (SELECT AVG(score_value) FROM user_score WHERE media_id = p_media_id),
            vote_count = (SELECT COUNT(*) FROM user_score WHERE media_id = p_media_id),
            "at" = CURRENT_TIMESTAMP
        WHERE media_id = p_media_id
        AND source = 'userrating';
    ELSE
        -- Insert a new average score into the score table if none exists
        INSERT INTO score (source, value, vote_count, media_id)
        VALUES (
            'userrating',
            (SELECT AVG(score_value) FROM user_score WHERE media_id = p_media_id),
            (SELECT COUNT(*) FROM user_score WHERE media_id = p_media_id),
            p_media_id,
			p_review_text
        );
    END IF;

    -- Display the updated average rating
    RAISE NOTICE 'Average Rating: %', (
        SELECT AVG(CAST(score_value AS NUMERIC)) 
        FROM user_score 
        WHERE media_id = p_media_id
    );
END;
$$ LANGUAGE plpgsql;

-- ============================================================
-- D4 Test structured_string_search function
-- ============================================================

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
            SELECT DISTINCT m.media_id, m.imdb_id
            FROM media AS m
            JOIN title AS t USING (media_id)
            LEFT JOIN crew_member cr ON m.media_id = cr.media_id
            LEFT JOIN cast_member ca ON m.media_id = ca.media_id
            LEFT JOIN person p ON ca.person_id = p.person_id OR cr.person_id = p.person_id
            WHERE (p_title IS NULL OR t."name" ILIKE '%' || p_title || '%')
                AND (p_plot IS NULL OR m.plot ILIKE '%' || p_plot || '%')
                AND (p_character IS NULL OR ca."character" ILIKE '%' || p_character || '%')
                AND (p_user_id IS NULL OR p."name" ILIKE '%' || p_person || '%')
        )
    SELECT DISTINCT t.media_id, t."name"
    FROM search_result AS sr
    JOIN title AS t USING (media_id)
    JOIN title_title_type USING (title_id)
    JOIN title_type AS tt USING (title_type_id)
    WHERE tt."name" = 'original';
END;
$$
LANGUAGE 'plpgsql';

-- ============================================================
-- D5 With a query find actors, movies casted, roles played and their crew job info
-- ============================================================

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

-- ============================================================
-- D6 VIEW
-- ============================================================

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

-- ============================================================
-- D6 Function to find the most frequent co-actors of a given actor
-- ============================================================

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

-- ============================================================
-- D7 calculate_name_rating function
-- ============================================================

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

-- ============================================================
-- D8 List Actors by Popularity
-- ============================================================

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

-- ============================================================
-- D8 List Co-Actors by Popularity for a Given Actor
-- ============================================================

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

-- ============================================================
-- D9 SImiliar Movies Search Functions
-- ============================================================

CREATE OR REPLACE FUNCTION get_similar_movies(input_media_id INTEGER)
RETURNS TABLE (
	media_id INTEGER,
	count INTEGER,
	title TEXT
) AS $$

DECLARE
	input_media RECORD;
BEGIN

  --get title id and country of input_media_id
	SELECT DISTINCT m.media_id, t.name, mpc.country_id INTO input_media
	FROM media m
	JOIN title t USING (media_id)
	LEFT JOIN media_production_country mpc USING(media_id)
	WHERE m.media_id = input_media_id;
	
	CREATE TEMPORARY TABLE search_result (
		media_id INTEGER,
		total_count INTEGER
		) ON COMMIT DROP;
	
	
	INSERT INTO search_result (media_id, total_count)
	SELECT com_res.media_id, SUM(com_res.count)::INTEGER AS total_count
	FROM (
		SELECT *  FROM get_count_of_movies_with_same_actors(input_media_id) 
		UNION ALL
		SELECT *  FROM get_movies_from_the_same_country(input_media.country_id)
		UNION ALL
		SELECT * FROM get_movies_with_same_genre(input_media_id)
		UNION ALL
		SELECT *  FROM get_movies_with_similar_titles(input_media.name,3)
		UNION ALL
		SELECT *  FROM get_movies_with_similar_crew(input_media_id)
	) AS com_res
	GROUP BY com_res.media_id
	ORDER BY total_count DESC;
	
	RETURN query
	SELECT DISTINCT sr.media_id, sr.total_count, t.name
	FROM search_result sr
	JOIN title t USING (media_id)
	JOIN title_title_type ttt USING (title_id)
	WHERE ttt.title_type_id = 8
	ORDER BY sr.total_count DESC;
END;
$$ LANGUAGE plpgsql;


--get_count_of_movies_with_same_actors
	
CREATE OR REPLACE FUNCTION get_count_of_movies_with_same_actors(input_media_id INTEGER)
RETURNS TABLE(
	media_id INTEGER,
	count INTEGER
) AS $$
DECLARE
	actor INTEGER;
	actors INTEGER[];
BEGIN
	SELECT ARRAY_AGG(DISTINCT cm.person_id) INTO actors
	FROM cast_member cm
	WHERE cm.media_id = input_media_id;
	
	CREATE TEMPORARY TABLE similar_cast (
	media_id INTEGER,
	"count" INTEGER
	) ON COMMIT DROP;
	
	FOREACH actor IN ARRAY COALESCE(actors, '{}')
	LOOP
		INSERT INTO similar_cast(media_id, "count")
		SELECT cm.media_id, 1
		FROM cast_member cm
		WHERE cm.person_id = actor
		GROUP BY cm.media_id;
	END LOOP;
	
	RETURN query
	SELECT s.media_id, count(s.media_id)::INTEGER
	FROM similar_cast s
	JOIN media USING (media_id)
	WHERE media.type = 'tvSeries' OR media.type ='movie'
	GROUP BY s.media_id
	ORDER BY "count" DESC;

END;
$$ LANGUAGE plpgsql;


--find_movies_from_the_same_country()

CREATE OR REPLACE FUNCTION get_movies_from_the_same_country(in_country_id INTEGER)
RETURNS TABLE (
	media_id INTEGER,
	"count" INTEGER
)AS $$
BEGIN
	RETURN query
	SELECT mpc.media_id, count(mpc.media_id)::INTEGER
	FROM media_production_country mpc
	JOIN media USING (media_id)
	WHERE (media.type = 'tvSeries' OR media.type ='movie')
	AND mpc.country_id = in_country_id
	GROUP BY mpc.media_id
	ORDER BY "count" DESC;
END;
$$ LANGUAGE plpgsql;

--find_movies_with_similar_titles()

CREATE OR REPLACE FUNCTION get_movies_with_similar_titles(input_title TEXT, min_lenght INTEGER)
RETURNS TABLE (
	media_id INTEGER,
	"count" INTEGER
)AS $$
DECLARE
	word TEXT;
	title_words TEXT[];
BEGIN
	CREATE TEMPORARY TABLE similar_title (
		media_id INTEGER,
		"count" INTEGER
		) ON COMMIT DROP;
	
	title_words := string_to_array(input_title, ' ');
	
	FOREACH word IN ARRAY COALESCE(title_words, '{}')
	LOOP
		IF LENGTH(word) > min_lenght THEN
			INSERT INTO similar_title
			SELECT DISTINCT t.media_id, 1 AS "count"
			FROM title t
			WHERE t.name ILIKE '%' ||word|| '%';
			RAISE NOTICE 'Word: % (Length: %)', word, LENGTH(word);
		END IF;
	END LOOP;
	
	RETURN query
	SELECT s.media_id, count(s."count")::INTEGER as count
	FROM similar_title s
	JOIN media USING (media_id)
	WHERE media.type = 'tvSeries' OR media.type ='movie'
	GROUP BY s.media_id
	ORDER BY count DESC;
END;
$$ LANGUAGE plpgsql;

--find_movies_with_similar_crew()

CREATE OR REPLACE FUNCTION get_movies_with_similar_crew(input_media_id INTEGER)
RETURNS TABLE(
	media_id INTEGER,
	count INTEGER
) AS $$
DECLARE
	"member" INTEGER;
	members INTEGER[];
BEGIN
	SELECT ARRAY_AGG(DISTINCT cm.person_id) INTO members
	FROM crew_member cm
	WHERE cm.media_id = input_media_id;
	
	CREATE TEMPORARY TABLE crew_members_other_movies (
	media_id INTEGER,
	person_id INTEGER,
	"count" INTEGER
	) ON COMMIT DROP;
	
	FOREACH "member" IN ARRAY COALESCE(members, '{}')
	LOOP
		INSERT INTO crew_members_other_movies(media_id, person_id, "count")
		SELECT cm.media_id, cm.person_id, 1
		FROM crew_member cm
		WHERE cm.person_id = "member"
		GROUP BY cm.media_id, cm.person_id;
	END LOOP;
	
	RETURN query
	SELECT s.media_id, count(s.media_id)::INTEGER
	FROM crew_members_other_movies s
	JOIN media USING (media_id)
	WHERE media.type = 'tvSeries' OR media.type ='movie'
	GROUP BY s.media_id
	ORDER BY count DESC;
END;
$$ LANGUAGE plpgsql;


--get_movies_with_same_genre()

CREATE OR REPLACE FUNCTION get_movies_with_same_genre(input_media_id INTEGER) 
RETURNS TABLE (
	media_id INTEGER,
	count INTEGER
)AS $$
DECLARE	
	genre INTEGER;
	genres INTEGER[];
BEGIN

	SELECT ARRAY_AGG(DISTINCT mg.genre_id) INTO genres
	FROM media_genre mg
	WHERE mg.media_id = input_media_id;
	
	CREATE TEMPORARY TABLE movies_with_same_genres (
	media_id INTEGER,
	"count" INTEGER
	) ON COMMIT DROP;
	
	FOREACH genre IN ARRAY COALESCE(genres, '{}')
	LOOP
		INSERT INTO movies_with_same_genres(media_id, "count")
		SELECT mg.media_id, 1
		FROM media_genre mg
		WHERE mg.genre_id = genre
		GROUP BY mg.media_id;
	END LOOP;
	
	RETURN query
	SELECT s.media_id, count(s.media_id)::INTEGER
	FROM movies_with_same_genres s
	JOIN media USING (media_id)
	WHERE media.type = 'tvSeries' OR media.type ='movie'
	GROUP BY s.media_id
	ORDER BY count DESC;
	
END;
$$ LANGUAGE plpgsql;

-- ============================================================
-- D10 Frequent person words
-- ============================================================

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

-- ============================================================
-- D11 Function to find titles to match the exact-match querying.
-- ============================================================

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
    WHERE tt."name" = 'original';
END;
$$ LANGUAGE plpgsql;

-- ============================================================
-- D12 Function to best match querying, ranking and ordering the media.
-- ============================================================

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
    GROUP BY m.media_id, t.title
    ORDER BY match_count DESC;
END;
$$ LANGUAGE plpgsql;

-- ============================================================
-- D13 Function for word_to_words_querying, ranking and ordering the words
-- ============================================================

CREATE OR REPLACE FUNCTION word_to_words_query(
    keywords TEXT[]
)
RETURNS TABLE (word TEXT, frequency INTEGER) AS $$
BEGIN
    RETURN QUERY
    -- Select matching titles based on the keyword query
    WITH matched_titles AS (
        SELECT m.media_id, m.imdb_id
        FROM title AS t
        JOIN media m ON t.media_id = m.media_id
        WHERE t."name" ILIKE ANY (ARRAY(SELECT '%' || kw || '%' FROM unnest(keywords) AS kw))
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

-- ============================================================
-- End of functions and procedures
-- ============================================================
