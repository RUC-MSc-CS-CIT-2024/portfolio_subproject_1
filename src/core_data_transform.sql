-- This assumes that the original data has been imported into the database
-- and that the new tables have been created based on the schema in the
-- B2_build_movie_db.sql file. The following queries will transform the
-- data from the original tables into the new tables.

CREATE SCHEMA IF NOT EXISTS original;

ALTER TABLE public.title_basics SET SCHEMA original;
ALTER TABLE public.title_ratings SET SCHEMA original;
ALTER TABLE public.title_crew SET SCHEMA original;
ALTER TABLE public.title_principals SET SCHEMA original;
ALTER TABLE public.title_akas SET SCHEMA original;
ALTER TABLE public.title_episode SET SCHEMA original;
ALTER TABLE public.name_basics SET SCHEMA original;
ALTER TABLE public.omdb_data SET SCHEMA original;

-- Countries

INSERT INTO countries (code, name) 
SELECT DISTINCT region, '' FROM original.title_akas;

-- Languages

INSERT INTO "language" (code, name)
SELECT DISTINCT "language", '' FROM original.title_akas;

-- Media

DO $$
DECLARE
    new_media_id INTEGER;
    new_season_id INTEGER;
    new_episode_id INTEGER;
    current_title RECORD;
    current_genre VARCHAR(50);
    current_season RECORD;
    current_episode RECORD;
BEGIN
    FOR current_title IN 
        SELECT *
        FROM original.title_basics
        NATURAL JOIN original.title_ratings 
        WHERE titletype != 'tvEpisode'
    LOOP
        INSERT INTO media ("type", runtime, imdb_id)
        VALUES (current_title.titletype, current_title.runtimeminutes, current_title.tconst)
        RETURNING media_id INTO new_media_id;

        -- Insert all genres for media
        FOREACH current_genre IN ARRAY string_to_array(current_title.genres, ',')
        LOOP
            INSERT INTO media_genre (media_id, "name")
            VALUES (new_media_id, current_genre);
        END LOOP;

        -- Insert release for media
        INSERT INTO "release" (title, release_date, media_id, country_code)
        SELECT title, TO_DATE(current_title.startyear, 'YYYY'), new_media_id, NULLIF(region, '')
        FROM original.title_akas
        WHERE titleid = current_title.tconst;

        -- If tv series insert seasons and episodes
        IF current_title.titletype = 'tvSeries' THEN
            -- Insert seasons for media
            FOR current_season IN
                SELECT COALESCE(seasonnumber, 1) AS seasonnumber, TO_DATE(MAX(startyear)::TEXT, 'YYYY') AS start_date
                FROM original.title_basics
                NATURAL JOIN original.title_episode
                WHERE parenttconst = current_title.tconst
                GROUP BY seasonnumber
            LOOP
                -- Create media record for season
                INSERT INTO media ("type")
                VALUES ('tvSeason')
                RETURNING media_id INTO new_season_id; 

                -- Insert season data for new media record
                INSERT INTO season (media_id, status, season_number, end_date, series_id)
                VALUES (new_season_id, 'unknown', current_season.seasonnumber, current_season.start_date, new_media_id);

                -- Create title for season ('{series_title} - Season {season_number}')
                INSERT INTO "release" (title, release_date, media_id)
                VALUES (FORMAT('%s - Season %s', current_title.primarytitle, current_season.seasonnumber), current_season.start_date, new_season_id);

                -- Insert Episodes for season
                FOR current_episode IN
                    SELECT *
                    FROM original.title_basics
                    NATURAL JOIN original.title_episode
                    WHERE parenttconst = current_title.tconst
                    AND seasonnumber = current_season.seasonnumber
                LOOP
                    -- Create media record for episode
                    INSERT INTO media ("type", runtime, imdb_id)
                    VALUES (current_episode.titletype, current_episode.runtimeminutes, current_episode.tconst)
                    RETURNING media_id INTO new_episode_id;

                    -- Insert episode data for new media record
                    INSERT INTO episode (media_id, episode_number, season_id)
                    VALUES (new_episode_id, current_episode.episodenumber, new_season_id);

                    -- Insert genres for episode
                    FOREACH current_genre IN ARRAY string_to_array(current_episode.genres, ',')
                    LOOP
                        INSERT INTO media_genre (media_id, "name")
                        VALUES (new_episode_id, current_genre);
                    END LOOP;

                    -- Insert titles for episode
                    INSERT INTO "release" (title, release_date, media_id, country_code)
                    SELECT title, TO_DATE(current_title.startyear, 'YYYY'), new_episode_id, NULLIF(region, '')
                    FROM original.title_akas
                    WHERE titleid = current_episode.tconst;
                END LOOP;
            END LOOP;
        END IF;
    END LOOP;
END $$;
