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

-- Structured string search

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
  INSERT INTO search_history (p_user_id, type, query)
  VALUES (user_id, 'structured_string_search', 
          FORMAT('title: %s, plot: %s, character: %s, person: %s', p_title, p_plot, p_character, p_person));

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
  WHERE "type" = 'original';
END;
$$
LANGUAGE 'plpgsql';
