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
        ELSE o.website END),
    awards = (CASE
		WHEN o.awards= 'N/A' THEN NULL 
        ELSE o.awards END),
    poster = (CASE
		WHEN o.poster= 'N/A' THEN NULL 
        ELSE o.poster END)
FROM original.omdb_data AS o
WHERE media.imdb_id = o.tconst;