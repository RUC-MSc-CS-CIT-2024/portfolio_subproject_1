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
--Insert additional releases 
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
INSERT INTO release (title, release_date, country_code, media_id, rated)
SELECT o.title, o.released::date, null, media.media_id, o.rated
FROM original.omdb_data o
JOIN media ON media.imdb_id = o.tconst
LEFT JOIN updated u ON u.media_id = media.media_id
WHERE o.released IS NOT NULL
AND o.released != 'N/A' 
AND o.released != ''
AND media.media_id != u.media_id;
