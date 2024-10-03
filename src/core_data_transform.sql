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

-- remove all data to allow for multiple executions
TRUNCATE TABLE media_genre CASCADE;
TRUNCATE TABLE score CASCADE;
TRUNCATE TABLE spoken_language CASCADE;
TRUNCATE TABLE crew_member CASCADE;
TRUNCATE TABLE cast_member CASCADE;
TRUNCATE TABLE promotional_media CASCADE;
TRUNCATE TABLE release CASCADE;
TRUNCATE TABLE media_in_collection CASCADE;
TRUNCATE TABLE media_production_country CASCADE;
TRUNCATE TABLE media_production_company CASCADE;
TRUNCATE TABLE related_media CASCADE;
TRUNCATE TABLE season CASCADE;
TRUNCATE TABLE episode CASCADE;
TRUNCATE TABLE media CASCADE;
TRUNCATE TABLE person CASCADE;
TRUNCATE TABLE production_company CASCADE;
TRUNCATE TABLE country CASCADE;
TRUNCATE TABLE "language" CASCADE;
TRUNCATE TABLE job_category CASCADE;
TRUNCATE TABLE "collection" CASCADE;

-- Countries

INSERT INTO country (imdb_country_code, iso_code, "name") VALUES
('AD', 'AND', 'Andorra'),
('AE', 'ARE', 'United Arab Emirates'),
('AF', 'AFG', 'Afghanistan'),
('AG', 'ATG', 'Antigua and Barbuda'),
('AL', 'ALB', 'Albania'),
('AM', 'ARM', 'Armenia'),
('AN', 'ANT', 'Netherlands Antilles'),
('AO', 'AGO', 'Angola'),
('AR', 'ARG', 'Argentina'),
('AT', 'AUT', 'Austria'),
('AU', 'AUS', 'Australia'),
('AW', 'ABW', 'Aruba'),
('AZ', 'AZE', 'Azerbaijan'),
('BA', 'BIH', 'Bosnia and Herzegovina'),
('BB', 'BRB', 'Barbados'),
('BD', 'BGD', 'Bangladesh'),
('BE', 'BEL', 'Belgium'),
('BF', 'BFA', 'Burkina Faso'),
('BG', 'BGR', 'Bulgaria'),
('BH', 'BHR', 'Bahrain'),
('BI', 'BDI', 'Burundi'),
('BJ', 'BEN', 'Benin'),
('BN', 'BRN', 'Brunei'),
('BO', 'BOL', 'Bolivia'),
('BR', 'BRA', 'Brazil'),
('BS', 'BHS', 'Bahamas'),
('BT', 'BTN', 'Bhutan'),
('BUMM', 'MMR', 'Burma'),
('BW', 'BWA', 'Botswana'),
('BY', 'BLR', 'Belarus'),
('CA', 'CAN', 'Canada'),
('CD', 'COD', 'Democratic Republic of the Congo'),
('CG', 'COG', 'Republic of the Congo'),
('CH', 'CHE', 'Switzerland'),
('CI', 'CIV', 'Ivory Coast'),
('CL', 'CHL', 'Chile'),
('CM', 'CMR', 'Cameroon'),
('CN', 'CHN', 'China'),
('CO', 'COL', 'Colombia'),
('CR', 'CRI', 'Costa Rica'),
('CSHH', 'CSK', 'Czechoslovakia'),
('CSXX', 'SCG', 'Serbia and Montenegro'),
('CU', 'CUB', 'Cuba'),
('CY', 'CYP', 'Cyprus'),
('CZ', 'CZE', 'Czech Republic'),
('DE', 'DEU', 'Germany'),
('DK', 'DNK', 'Denmark'),
('DM', 'DMA', 'Dominica'),
('DO', 'DOM', 'Dominican Republic'),
('DZ', 'DZA', 'Algeria'),
('EC', 'ECU', 'Ecuador'),
('EE', 'EST', 'Estonia'),
('EG', 'EGY', 'Egypt'),
('EH', 'ESH', 'Western Sahara'),
('ES', 'ESP', 'Spain'),
('ET', 'ETH', 'Ethiopia'),
('FI', 'FIN', 'Finland'),
('FJ', 'FJI', 'Fiji'),
('FO', 'FRO', 'Faroe Islands'),
('FR', 'FRA', 'France'),
('GB', 'GBR', 'United Kingdom'),
('GD', 'GRD', 'Grenada'),
('GE', 'GEO', 'Georgia'),
('GH', 'GHA', 'Ghana'),
('GI', 'GIB', 'Gibraltar'),
('GL', 'GRL', 'Greenland'),
('GR', 'GRC', 'Greece'),
('GT', 'GTM', 'Guatemala'),
('GU', 'GUM', 'Guam'),
('GY', 'GUY', 'Guyana'),
('HK', 'HKG', 'Hong Kong'),
('HN', 'HND', 'Honduras'),
('HR', 'HRV', 'Croatia'),
('HT', 'HTI', 'Haiti'),
('HU', 'HUN', 'Hungary'),
('ID', 'IDN', 'Indonesia'),
('IE', 'IRL', 'Ireland'),
('IL', 'ISR', 'Israel'),
('IM', 'IMN', 'Isle of Man'),
('IN', 'IND', 'India'),
('IQ', 'IRQ', 'Iraq'),
('IR', 'IRN', 'Iran'),
('IS', 'ISL', 'Iceland'),
('IT', 'ITA', 'Italy'),
('JM', 'JAM', 'Jamaica'),
('JO', 'JOR', 'Jordan'),
('JP', 'JPN', 'Japan'),
('KE', 'KEN', 'Kenya'),
('KG', 'KGZ', 'Kyrgyzstan'),
('KH', 'KHM', 'Cambodia'),
('KP', 'PRK', 'North Korea'),
('KR', 'KOR', 'South Korea'),
('KW', 'KWT', 'Kuwait'),
('KZ', 'KAZ', 'Kazakhstan'),
('LA', 'LAO', 'Laos'),
('LB', 'LBN', 'Lebanon'),
('LI', 'LIE', 'Liechtenstein'),
('LK', 'LKA', 'Sri Lanka'),
('LT', 'LTU', 'Lithuania'),
('LU', 'LUX', 'Luxembourg'),
('LV', 'LVA', 'Latvia'),
('LY', 'LBY', 'Libya'),
('MA', 'MAR', 'Morocco'),
('MC', 'MCO', 'Monaco'),
('MD', 'MDA', 'Moldova'),
('ME', 'MNE', 'Montenegro'),
('MG', 'MDG', 'Madagascar'),
('MH', 'MHL', 'Marshall Islands'),
('MK', 'MKD', 'North Macedonia'),
('ML', 'MLI', 'Mali'),
('MM', 'MMR', 'Myanmar'),
('MN', 'MNG', 'Mongolia'),
('MO', 'MAC', 'Macau'),
('MQ', 'MTQ', 'Martinique'),
('MR', 'MRT', 'Mauritania'),
('MT', 'MLT', 'Malta'),
('MU', 'MUS', 'Mauritius'),
('MV', 'MDV', 'Maldives'),
('MW', 'MWI', 'Malawi'),
('MX', 'MEX', 'Mexico'),
('MY', 'MYS', 'Malaysia'),
('MZ', 'MOZ', 'Mozambique'),
('NA', 'NAM', 'Namibia'),
('NE', 'NER', 'Niger'),
('NG', 'NGA', 'Nigeria'),
('NI', 'NIC', 'Nicaragua'),
('NL', 'NLD', 'Netherlands'),
('NO', 'NOR', 'Norway'),
('NP', 'NPL', 'Nepal'),
('NZ', 'NZL', 'New Zealand'),
('OM', 'OMN', 'Oman'),
('PA', 'PAN', 'Panama'),
('PE', 'PER', 'Peru'),
('PH', 'PHL', 'Philippines'),
('PK', 'PAK', 'Pakistan'),
('PL', 'POL', 'Poland'),
('PR', 'PRI', 'Puerto Rico'),
('PS', 'PSE', 'Palestine'),
('PT', 'PRT', 'Portugal'),
('PY', 'PRY', 'Paraguay'),
('QA', 'QAT', 'Qatar'),
('RE', 'REU', 'Réunion'),
('RO', 'ROU', 'Romania'),
('RS', 'SRB', 'Serbia'),
('RU', 'RUS', 'Russia'),
('RW', 'RWA', 'Rwanda'),
('SA', 'SAU', 'Saudi Arabia'),
('SB', 'SLB', 'Solomon Islands'),
('SD', 'SDN', 'Sudan'),
('SE', 'SWE', 'Sweden'),
('SG', 'SGP', 'Singapore'),
('SI', 'SVN', 'Slovenia'),
('SK', 'SVK', 'Slovakia'),
('SL', 'SLE', 'Sierra Leone'),
('SM', 'SMR', 'San Marino'),
('SN', 'SEN', 'Senegal'),
('SO', 'SOM', 'Somalia'),
('SUHH', 'SUN', 'Soviet Union'),
('SV', 'SLV', 'El Salvador'),
('SY', 'SYR', 'Syria'),
('SZ', 'SWZ', 'Eswatini'),
('TH', 'THA', 'Thailand'),
('TJ', 'TJK', 'Tajikistan'),
('TM', 'TKM', 'Turkmenistan'),
('TN', 'TUN', 'Tunisia'),
('TO', 'TON', 'Tonga'),
('TR', 'TUR', 'Turkey'),
('TT', 'TTO', 'Trinidad and Tobago'),
('TW', 'TWN', 'Taiwan'),
('TZ', 'TZA', 'Tanzania'),
('UA', 'UKR', 'Ukraine'),
('UG', 'UGA', 'Uganda'),
('US', 'USA', 'United States'),
('UY', 'URY', 'Uruguay'),
('UZ', 'UZB', 'Uzbekistan'),
('VE', 'VEN', 'Venezuela'),
('VI', 'VIR', 'Virgin Islands'),
('VN', 'VNM', 'Vietnam'),
('YE', 'YEM', 'Yemen'),
('YUCS', 'YUG', 'Yugoslavia'),
('ZA', 'ZAF', 'South Africa'),
('ZM', 'ZMB', 'Zambia'),
('ZW', 'ZWE', 'Zimbabwe'),
(NULL, 'VAT', 'Holy See (Vatican City State)'),
(NULL, 'LSO', 'Lesotho'),
(NULL, 'LBR', 'Liberia'),
(NULL, 'PLW', 'Palau'),
(NULL, 'PNG', 'Papua New Guinea'), 
(NULL, 'LCA', 'Saint Lucia'),
(NULL, 'VCT', 'Saint Vincent and the Grenadines'),
(NULL, 'WSM', 'Samoa'),
(NULL, 'SUR', 'Suriname'),
(NULL, 'SJM', 'Svalbard and Jan Mayen'),   
(NULL, 'TLS', 'Timor-Leste'),
(NULL, 'VUT', 'Vanuatu'),
(NULL, 'BLZ', 'Belize'),
(NULL, 'BMU', 'Bermuda'),
(NULL, 'CPV', 'Cape Verde'),
(NULL, 'CYM', 'Cayman Islands'),
(NULL, 'CAF', 'Central African Republic'),
(NULL, 'DJI', 'Djibouti'),
(NULL, 'GNQ', 'Equatorial Guinea'),
(NULL, 'GIN', 'Guinea'),
(NULL, 'GMB', 'Gambia'),
(NULL, 'GNB', 'Guinea-Bissau'),
(NULL, 'GUF', 'French Guiana'),
(NULL, 'PYF', 'French Polynesia'),
(NULL, 'TCD', 'Chad');

-- Languages

INSERT INTO language (imdb_language_code, iso_code, "name") VALUES
('af', 'afr', 'Afrikaans'),
('ar', 'ara', 'Arabic'),
('bg', 'bul', 'Bulgarian'),
('bn', 'ben', 'Bengali'),
('bs', 'bos', 'Bosnian'),
('ca', 'cat', 'Catalan'),
('cmn', 'cmn', 'Mandarin Chinese'),
('cs', 'ces', 'Czech'),
('cy', 'cym', 'Welsh'),
('da', 'dan', 'Danish'),
('de', 'deu', 'German'),
('el', 'ell', 'Greek'),
('en', 'eng', 'English'),
('es', 'spa', 'Spanish'),
('eu', 'eus', 'Basque'),
('fa', 'fas', 'Persian'),
('fr', 'fra', 'French'),
('ga', 'gle', 'Irish'),
('gd', 'gla', 'Scottish Gaelic'),
('gl', 'glg', 'Galician'),
('gsw', 'gsw', 'Swiss German'),
('gu', 'guj', 'Gujarati'),
('he', 'heb', 'Hebrew'),
('hi', 'hin', 'Hindi'),
('hil', 'hil', 'Hiligaynon'),
('hr', 'hrv', 'Croatian'),
('hu', 'hun', 'Hungarian'),
('id', 'ind', 'Indonesian'),
('it', 'ita', 'Italian'),
('ja', 'jpn', 'Japanese'),
('kk', 'kaz', 'Kazakh'),
('kn', 'kan', 'Kannada'),
('la', 'lat', 'Latin'),
('lb', 'ltz', 'Luxembourgish'),
('lt', 'lit', 'Lithuanian'),
('mi', 'mri', 'Maori'),
('mk', 'mkd', 'Macedonian'),
('ml', 'mal', 'Malayalam'),
('mr', 'mar', 'Marathi'),
('ms', 'msa', 'Malay'),
('nl', 'nld', 'Dutch'),
('ps', 'pus', 'Pashto'),
('pt', 'por', 'Portuguese'),
('qal', 'que', 'Quechua'),
('qbn', 'qub', 'Quechua (Bolivia)'),
('qbp', 'qup', 'Quechua (Peru)'),
('ru', 'rus', 'Russian'),
('sk', 'slk', 'Slovak'),
('sr', 'srp', 'Serbian'),
('sv', 'swe', 'Swedish'),
('ta', 'tam', 'Tamil'),
('te', 'tel', 'Telugu'),
('th', 'tha', 'Thai'),
('tl', 'tgl', 'Tagalog'),
('tn', 'tsn', 'Tswana'),
('tr', 'tur', 'Turkish'),
('uk', 'ukr', 'Ukrainian'),
('ur', 'urd', 'Urdu'),
('wo', 'wol', 'Wolof'),
('xh', 'xho', 'Xhosa'),
('yi', 'yid', 'Yiddish'),
('yue', 'yue', 'Cantonese'),
('zu', 'zul', 'Zulu');

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
        SELECT t.originaltitle, t.primarytitle, ta.title, t.startyear, m.media_id, ta.region, ta.types
        FROM original.title_akas AS ta
        JOIN media AS m ON m.imdb_id = ta.titleid
        JOIN original.title_basics AS t ON t.tconst = ta.titleid
    )
INSERT INTO "release" (title, release_date, media_id, country_id, title_type)
SELECT 
    title, 
    TO_DATE(startyear, 'YYYY'), 
    media_id,
    (CASE
	    WHEN region = '' THEN NULL
        ELSE (SELECT country_id FROM country WHERE imdb_country_code = region) 
    END),
    (CASE
	    WHEN types = '' THEN (CASE
            WHEN originaltitle = title THEN 'original'
            WHEN primarytitle = title THEN 'primary'
            ELSE NULL
        END)
        ELSE SPLIT_PART(types, U&'0002', 1)
    END)
FROM titleaka_with_id;

-- Seasons

DO $$
DECLARE
    new_season_id INTEGER;
    current_season RECORD;
    insert_count INTEGER := 0; -- Initialize the counter
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

        -- Increment the counter
        insert_count := insert_count + 1;
        
        -- Insert season data for new media record
        INSERT INTO season (media_id, "status", season_number, series_id)
        VALUES (new_season_id, 'unknown', current_season.season_number, current_season.media_id);

        -- Increment the counter
        insert_count := insert_count + 1;

        -- Create title for season ('{series_title} - Season {season_number}')
        INSERT INTO "release" (title, release_date, media_id, title_type)
        VALUES (
            FORMAT('%s - Season %s', current_season.show_title, current_season.season_number), 
            current_season.start_date, 
            new_season_id,
            'primary');

        -- Increment the counter
        insert_count := insert_count + 1;
    END LOOP;

    -- Output the number of inserts
    RAISE NOTICE 'INSERT 0 %', insert_count;
END $$;

-- Episodes

INSERT INTO episode (media_id, episode_number, season_id)
SELECT m.media_id, e.episodenumber, s.media_id
FROM original.title_episode AS e
JOIN media AS m ON m.imdb_id = e.tconst
JOIN media AS ps ON e.parenttconst = ps.imdb_id
JOIN season AS s ON s.season_number = e.seasonnumber AND s.series_id = ps.media_id;

WITH
    title_with_rating AS (
        SELECT r.averagerating::TEXT, r.numvotes, m.media_id
        FROM media AS m
        JOIN original.title_ratings AS r ON r.tconst = m.imdb_id
    )
INSERT INTO score (source, "value", media_id, vote_count)
SELECT 'IMDb', averagerating, media_id, numvotes
FROM title_with_rating;
