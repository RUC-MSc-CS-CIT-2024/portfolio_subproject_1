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

INSERT INTO production_compnay ("name", "description")
SELECT DISTINCT unnest(string_to_array(o.production, ', ')),
FROM original.omdb_data as o;
