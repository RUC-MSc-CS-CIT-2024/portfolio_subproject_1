-- This assumes that the original data has been imported into the database
-- and that the new tables have been created based on the schema in the
-- B2_build_movie_db.sql file. The following queries will transform the
-- data from the original tables into the new tables.

CREATE SCHEMA IF NOT EXISTS original;

DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'title_basics') THEN
        ALTER TABLE public.title_basics SET SCHEMA original;
    END IF;

    IF EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'title_ratings') THEN
        ALTER TABLE public.title_ratings SET SCHEMA original;
    END IF;

    IF EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'title_crew') THEN
        ALTER TABLE public.title_crew SET SCHEMA original;
    END IF;

    IF EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'title_principals') THEN
        ALTER TABLE public.title_principals SET SCHEMA original;
    END IF;

    IF EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'title_akas') THEN
        ALTER TABLE public.title_akas SET SCHEMA original;
    END IF;

    IF EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'title_episode') THEN
        ALTER TABLE public.title_episode SET SCHEMA original;
    END IF;

    IF EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'name_basics') THEN
        ALTER TABLE public.name_basics SET SCHEMA original;
    END IF;

    IF EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'omdb_data') THEN
        ALTER TABLE public.omdb_data SET SCHEMA original;
    END IF;

    IF EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'wi') THEN
        ALTER TABLE public.wi SET SCHEMA original;
    END IF;
END $$;

-- Countries

INSERT INTO country (code, name) 
SELECT DISTINCT region, '' FROM original.title_akas;

-- Languages

INSERT INTO "language" (code, name)
SELECT DISTINCT "language", '' FROM original.title_akas;

-- Media

INSERT INTO media ("type", runtime, imdb_id)
SELECT titletype, runtimeminutes, tconst
FROM original.title_basics
NATURAL JOIN original.title_ratings;

-- Insert all genres for media
WITH
    title_with_id AS (
        SELECT *
        FROM original.title_basics AS t
        JOIN media AS m ON m.imdb_id = t.tconst
    ),
    split_genres AS (
        SELECT media_id, unnest(string_to_array(genres, ',')) AS genre
        FROM title_with_id
    )
INSERT INTO media_genre (media_id, "name")
SELECT media_id, genre
FROM split_genres; 

-- Insert release for media
WITH
    titleaka_with_id AS (
        SELECT ta.title, t.startyear, m.media_id, region
        FROM original.title_akas AS ta
        JOIN media AS m ON m.imdb_id = ta.titleid
        JOIN original.title_basics AS t ON t.tconst = ta.titleid
    )
INSERT INTO "release" (title, release_date, media_id, country_code)
SELECT title, TO_DATE(startyear, 'YYYY'), media_id, NULLIF(region, '') 
FROM titleaka_with_id;

-- Seasons

DO $$
DECLARE
    new_season_id INTEGER;
    current_season RECORD;
BEGIN
    -- Insert seasons for media
    FOR current_season IN
        SELECT 
            e.parenttconst,
            e.seasonnumber AS season_number,
            TO_DATE(MIN(t.startyear)::TEXT, 'YYYY') AS start_date,  
            s.primarytitle AS show_title,
            m.media_id
        FROM original.title_basics AS t
        NATURAL JOIN original.title_episode AS e
        JOIN original.title_basics AS s ON e.parenttconst = s.tconst
        JOIN media AS m ON m.imdb_id = s.tconst
        GROUP BY e.seasonnumber, e.parenttconst, s.primarytitle, m.media_id
    LOOP
        -- Create media record for season
        INSERT INTO media ("type")
        VALUES ('tvSeason')
        RETURNING media_id INTO new_season_id; 
        
        -- Insert season data for new media record
        INSERT INTO season (media_id, "status", season_number, series_id)
        VALUES (new_season_id, 'unknown', current_season.season_number, current_season.media_id);

        -- Create title for season ('{series_title} - Season {season_number}')
        INSERT INTO "release" (title, release_date, media_id)
        VALUES (
            FORMAT('%s - Season %s', current_season.show_title, current_season.season_number), 
            current_season.start_date, 
            new_season_id);
    END LOOP;
END $$;

-- Episodes

INSERT INTO episode (media_id, episode_number, season_id)
SELECT m.media_id, e.episodenumber, s.media_id
FROM original.title_episode AS e
JOIN media AS m ON m.imdb_id = e.tconst
JOIN media AS ps ON e.parenttconst = ps.imdb_id
JOIN season AS s ON s.season_number = e.seasonnumber AND s.series_id = ps.media_id;
