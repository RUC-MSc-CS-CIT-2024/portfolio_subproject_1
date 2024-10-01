-- UPDATING MEDIA TABLE WITH DATA FROM OMDB

UPDATE media
SET plot = (CASE
	    WHEN o.plot = 'N/A' THEN NULL
	    WHEN o.plot = '' THEN NULL
        ELSE o.plot END),
    box_office = CAST(CASE 
        WHEN REPLACE(TRIM('$' FROM o.boxoffice), ',', '') = 'N/A' THEN NULL 
        ELSE REPLACE(TRIM('$' FROM o.boxoffice), ',', '') 
        END AS INTEGER),
    website = (CASE
		WHEN o.website= 'N/A' THEN NULL
		WHEN o.website= '' THEN NULL 
        ELSE o.website END),
    awards = (CASE
		WHEN o.awards= 'N/A' THEN NULL
		WHEN o.awards= '' THEN NULL 
        ELSE o.awards END)
FROM original.omdb_data AS o
WHERE media.imdb_id = o.tconst;

--UPDATE Released
--UPDATE age rating information

UPDATE release
SET rated = (CASE
	    WHEN o.rated = 'N/A' THEN NULL
	    WHEN o.rated = '' THEN NULL
        ELSE o.rated END)
FROM original.omdb_data o JOIN media
ON media.imdb_id = o.tconst
WHERE release.media_id = media.media_id;

--Update release_date with the correct dates from omdb
--Insert additional releases and create new releases if the dates are different
WITH updated AS (
    UPDATE release
    SET release_date = o.released::date
    FROM original.omdb_data o
    JOIN media ON media.imdb_id = o.tconst
    WHERE release.media_id = media.media_id
        AND DATE_PART('year', release.release_date::date) = DATE_PART('year', o.released::date)
        AND o.released != 'N/A' 
        AND o.released != ''
    RETURNING release.media_id
)
INSERT INTO release (title, release_date, country_id, media_id, rated)
    SELECT o.title, o.released::date, null, media.media_id, o.rated
    FROM original.omdb_data o
    JOIN media ON media.imdb_id = o.tconst
    LEFT JOIN updated u ON u.media_id = media.media_id
    WHERE o.released IS NOT NULL
        AND o.released != 'N/A' 
        AND o.released != ''
        AND media.media_id != u.media_id;

-- Updating countty codes to release
/*
Maybe we should discuss it before I start

*/
WITH omdb_country AS (
	SELECT tconst, unnest(string_to_array(country, ', ')) as country
	FROM original.omdb_data o
	WHERE o.country !='N/A'
		AND o.country != ''
		AND o.country IS NOT NULL),
country_merge AS (
	SELECT tconst, country
	FROM omdb_country o
	JOIN country c ON o.country = c.name),
other_countries AS (
    SELECT o.country
    FROM omdb_country o
    LEFT JOIN country_merge cm ON o.tconst = cm.tconst AND o.country = cm.country
    WHERE cm.country IS NULL)


--PROMOTIONAL MEDIA

/*
***IDEA***
What if we create a table and have types in there?

related_media_category(categoryname, parentcategory)

We can have then images, websites, videos without parentcat
and subcategories like poster, actor, director, premiere for images
and etc... 
*/

--insert posters
INSERT INTO promotional_media(release_id, "type", uri)
SELECT r.release_id, 'poster', o.poster
FROM release r 
JOIN media m ON r.media_id = m.media_id
JOIN original.omdb_data o ON m.imdb_id = o.tconst
WHERE o.poster != 'N/A'
    AND o.poster != ''
    AND o.poster IS NOT NULL;

--insert websites
INSERT INTO promotional_media(release_id, "type", uri)
SELECT r.release_id, 'website', o.website
FROM release r 
JOIN media m ON r.media_id = m.media_id
JOIN original.omdb_data o ON m.imdb_id = o.tconst
WHERE o.website != 'N/A'
    AND o.website != ''
    AND o.website IS NOT NULL;

--PRODUCTION COMPANY

INSERT INTO production_company ("name", "description")
SELECT DISTINCT unnest(string_to_array(o.production, ', ')), null
FROM original.omdb_data as o;


--MEDIA PROD COMP


TRUNCATE TABLE media_production_company CASCADE;

WITH prod_comps AS (
SELECT tconst, unnest(string_to_array(o.production, ', ')) AS comp
FROM original.omdb_data as o
WHERE o.production != 'N/A'
AND o.production != ''
AND o.production IS NOT NULL

)
INSERT INTO media_production_company (media_id, production_company_id, type)
SELECT m.media_id, p.production_company_id, m.type
FROM media m
JOIN prod_comps o ON o.tconst = m.imdb_id
JOIN production_company p ON p.name = o.comp;


--SCORE 
-- Using ratings from omdb_data as it has rottentomatoes
-- imdb score and metacatscore in omdb_data are the same

--extracting data from JSON 
--Changing source names
--Fixing values
--collecting vote counts for imdb
WITH json_extract AS (
    SELECT
        o.tconst,
        m.media_id,
        CASE
            WHEN json_data->>'Source' = 'Internet Movie Database' THEN 'IMDb'
            WHEN json_data->>'Source' = 'Rotten Tomatoes' THEN 'RT'
            WHEN json_data->>'Source' = 'Metacritic' THEN 'MC'
            ELSE NULL
        END AS source,
        CASE
            WHEN json_data->>'Source' = 'Internet Movie Database' 
                THEN REPLACE(json_data->>'Value', '/10', '')
            WHEN json_data->>'Source' = 'Rotten Tomatoes'
                THEN REPLACE(json_data->>'Value', '%', '')
            WHEN json_data->>'Source' = 'Metacritic'
                THEN REPLACE(json_data->>'Value', '/100', '')
            ELSE NULL
        END AS value,
        CASE
            WHEN o.imdbvotes = 'N/A' OR o.imdbvotes = '' THEN 0
            WHEN json_data->>'Source' = 'Internet Movie Database'
                THEN REPLACE(o.imdbvotes, ',', '')::INTEGER
            WHEN jsonb_array_length(o.ratings::jsonb) = 0
                AND (o.imdbvotes != 'N/A' OR o.imdbvotes != '')
                THEN REPLACE(o.imdbvotes,',','')::INTEGER
            ELSE 0
        END AS imdbvotes
    FROM original.omdb_data o
    JOIN media m ON m.imdb_id = o.tconst
    LEFT JOIN LATERAL jsonb_array_elements(o.ratings::jsonb) AS json_data ON TRUE
),  

--updating score with the data from JSON and saving ids of updated rows
--UPDATE happens only if the vote count is higher than the one in IMDB_DB
imdb_score_update AS (
    UPDATE score s
    SET 
        value = j.value,
        vote_count = j.imdbvotes
    FROM json_extract j
    WHERE j.media_id = s.media_id
      AND j.source = 'IMDb'
      AND s.vote_count < j.imdbvotes
    RETURNING s.media_id, s.source, 'updated' AS status
)

--insertion of Metacat data and Rotten tomatoes data as well as adding new data if it is not in score yet
--using imdb_score_update status to check if it was not updated
INSERT INTO score (source, value, vote_count, at, media_id)
SELECT j.source, j.value, j.imdbvotes, CURRENT_TIMESTAMP, j.media_id
FROM json_extract j
LEFT JOIN imdb_score_update u ON u.media_id = j.media_id AND u.source = j.source
LEFT JOIN score s ON j.media_id = s.media_id
-- Insert IMDb ratings which are not in IMDB_DB
WHERE (j.media_id != s.media_id
        AND j.source = 'IMDb')
-- Insert Other ratings
    OR (u.status IS NULL 
        AND j.source != 'IMDb');