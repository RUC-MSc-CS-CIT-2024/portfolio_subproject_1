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

