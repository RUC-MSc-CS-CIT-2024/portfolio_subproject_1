DROP TABLE IF EXISTS media_primary_information CASCADE;
DROP TABLE IF EXISTS title_title_type CASCADE;
DROP TABLE IF EXISTS title_title_attribute CASCADE;
DROP TABLE IF EXISTS media_genre CASCADE;
DROP TABLE IF EXISTS score CASCADE;
DROP TABLE IF EXISTS spoken_language CASCADE;
DROP TABLE IF EXISTS crew_member CASCADE;
DROP TABLE IF EXISTS cast_member CASCADE;
DROP TABLE IF EXISTS promotional_media CASCADE;
DROP TABLE IF EXISTS release CASCADE;
DROP TABLE IF EXISTS title CASCADE;
DROP TABLE IF EXISTS media_in_collection CASCADE;
DROP TABLE IF EXISTS media_production_country CASCADE;
DROP TABLE IF EXISTS media_production_company CASCADE;
DROP TABLE IF EXISTS related_media CASCADE;
DROP TABLE IF EXISTS season CASCADE;
DROP TABLE IF EXISTS episode CASCADE;
DROP TABLE IF EXISTS media CASCADE;
DROP TABLE IF EXISTS person CASCADE;
DROP TABLE IF EXISTS production_company CASCADE;
DROP TABLE IF EXISTS country CASCADE;
DROP TABLE IF EXISTS "language" CASCADE;
DROP TABLE IF EXISTS job_category CASCADE;
DROP TABLE IF EXISTS "collection" CASCADE;
DROP TABLE IF EXISTS title_attribute CASCADE;
DROP TABLE IF EXISTS title_type CASCADE;
DROP TABLE IF EXISTS genre CASCADE;

CREATE TABLE country (
    country_id  INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    imdb_country_code   VARCHAR(4)  NULL,
    iso_code            VARCHAR(3)  NULL,
    "name"              VARCHAR(50) NOT NULL
);

CREATE TABLE "language" (
    language_id         INTEGER     PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    imdb_language_code  VARCHAR(4)  NULL,
    iso_code            VARCHAR(3)  NOT NULL,
    "name"              VARCHAR(50) NOT NULL
);

CREATE TABLE job_category (
    job_category_id     INTEGER     PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    "name"  VARCHAR(50) NOT NULL
);

CREATE TABLE title_type (
    title_type_id   INTEGER     PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    "name"          VARCHAR(50)        NOT NULL
);

CREATE TABLE title_attribute (
    title_attribute_id  INTEGER     PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    "name"              TEXT        NOT NULL
);

CREATE TABLE media (
    media_id    INTEGER         PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    "type"      VARCHAR(50)     NOT NULL,
    plot        TEXT            NULL,
    runtime     INTEGER         NULL,
    box_office  INTEGER         NULL,
    budget      INTEGER         NULL,
    imdb_id     VARCHAR(10)     NULL,
    awards      VARCHAR(80)     NULL
);

CREATE TABLE season (
    media_id        INTEGER     PRIMARY KEY,
    "status"        VARCHAR(50) NOT NULL,
    season_number   INTEGER     NULL,
    end_date        DATE        NULL,
    series_id       INTEGER     NOT NULL REFERENCES media(media_id),
    FOREIGN KEY (media_id) REFERENCES media(media_id)
);

CREATE TABLE episode (
    media_id        INTEGER PRIMARY KEY,
    episode_number  INTEGER NULL,
    season_id       INTEGER NOT NULL REFERENCES media(media_id),
    FOREIGN KEY (media_id) REFERENCES media(media_id)
);


CREATE TABLE genre (
    genre_id    INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    "name"      VARCHAR(50) NOT NULL
);

CREATE TABLE media_genre (
    media_id    INTEGER     NOT NULL REFERENCES media(media_id),
    genre_id    INTEGER     NOT NULL REFERENCES genre(genre_id)
);

CREATE TABLE media_production_country (
    media_production_country_id INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    media_id                    INTEGER NOT NULL REFERENCES media(media_id),
    country_id                  INTEGER NOT NULL REFERENCES country(country_id)
);

CREATE TABLE score (
    score_id        INTEGER     PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    source          VARCHAR(20) NOT NULL,
    "value"         VARCHAR(20) NOT NULL,
    vote_count      INTEGER     NOT NULL DEFAULT 0,
    "at"            TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    media_id        INTEGER     NOT NULL REFERENCES media(media_id)
);

CREATE TABLE "collection" (
    collection_id   INTEGER     PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    "name"          VARCHAR(50) NOT NULL,
    "description"   TEXT        NULL
);

CREATE TABLE media_in_collection (
    collection_id   INTEGER REFERENCES "collection"(collection_id),
    media_id        INTEGER REFERENCES media(media_id),
    PRIMARY KEY (collection_id, media_id)
);

CREATE TABLE related_media (
    primary_id    INTEGER     NOT NULL REFERENCES media(media_id),
    related_id    INTEGER     NOT NULL REFERENCES media(media_id),
    "type"        VARCHAR(50) NOT NULL,
    PRIMARY KEY (primary_id, related_id)
);

CREATE TABLE title (
    title_id    INTEGER     PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    "name"      TEXT        NOT NULL,
    country_id  INTEGER     NULL REFERENCES country(country_id),
    language_id INTEGER     NULL REFERENCES "language"(language_id),
    media_id    INTEGER     NOT NULL REFERENCES media(media_id)
);

CREATE TABLE release (
    release_id      INTEGER     PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    release_date    DATE        NULL,
    rated           VARCHAR(80) NULL,
    "type"          VARCHAR(50) NOT NULL,
    country_id      INTEGER     NULL REFERENCES country(country_id),
    media_id        INTEGER     NOT NULL REFERENCES media(media_id),
    title_id        INTEGER     NULL REFERENCES title(title_id)
);

CREATE TABLE title_title_type (
    title_type_id   INTEGER NOT NULL REFERENCES title_type(title_type_id),
    title_id        INTEGER NOT NULL REFERENCES title(title_id)
);

CREATE TABLE title_title_attribute (
    title_attribute_id  INTEGER NOT NULL REFERENCES title_attribute(title_attribute_id),
    title_id            INTEGER NOT NULL REFERENCES title(title_id)
);

CREATE TABLE spoken_language (
    spoken_language_id  INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    release_id          INTEGER NOT NULL REFERENCES release(release_id),
    language_id         INTEGER NOT NULL REFERENCES "language"(language_id)
);

CREATE TABLE promotional_media (
    promotional_media_id    INTEGER         PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    release_id              INTEGER         NOT NULL REFERENCES release(release_id) ON DELETE CASCADE,
    "type"                  VARCHAR(50)     NOT NULL,
    "uri"                   VARCHAR(255)    NOT NULL
);

CREATE TABLE person (
    person_id       INTEGER       PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    "name"          VARCHAR(150)  NOT NULL,
    birth_date      DATE          NULL,
    death_date      DATE          NULL,
    "description"   TEXT          NULL,
    score           DECIMAL       NOT NULL DEFAULT 0,
    imdb_id         VARCHAR(10)   NULL,
    name_rating     DECIMAL(6, 2) NULL
);

CREATE TABLE crew_member (
    crew_member_id  INTEGER      PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    "role"          VARCHAR(150) NULL,
    person_id       INTEGER      NOT NULL REFERENCES person(person_id),
    media_id        INTEGER      NOT NULL REFERENCES media(media_id),
    job_category_id INTEGER      NOT NULL REFERENCES job_category(job_category_id)
);

CREATE TABLE cast_member (
    cast_member_id  INTEGER      PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    "role"          VARCHAR(150) NULL,
    "character"     VARCHAR(150) NOT NULL,
    person_id       INTEGER      NOT NULL REFERENCES person(person_id),
    media_id        INTEGER      NOT NULL REFERENCES media(media_id)
);

CREATE TABLE production_company (
    production_company_id   INTEGER     PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    "name"                  VARCHAR(50) NOT NULL,
    "description"           TEXT        NULL
);

CREATE TABLE media_production_company (
    media_id                INTEGER     NOT NULL REFERENCES media(media_id),
    production_company_id   INTEGER     NOT NULL REFERENCES production_company(production_company_id),
    "type"                  VARCHAR(20) NOT NULL,
    PRIMARY KEY (media_id, production_company_id)
);

CREATE TABLE media_primary_information (
    media_id                    INTEGER PRIMARY KEY,
    title_id                    INTEGER NOT NULL REFERENCES title(title_id),
    release_id                  INTEGER NULL REFERENCES release(release_id),
    promotional_media_id INTEGER NULL REFERENCES promotional_media(promotional_media_id),
    FOREIGN KEY (media_id) REFERENCES media(media_id)
);

---
--- Populate the new tables with data from the original tables
---

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
END $$;

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

-- Title types

INSERT INTO title_type("name")
SELECT DISTINCT unnest(string_to_array("types", '')) 
FROM original.title_akas;

-- Title attributes

INSERT INTO title_attribute("name")
SELECT DISTINCT unnest(string_to_array(attributes, ''))
FROM original.title_akas;

-- Genres

INSERT INTO genre("name")
SELECT DISTINCT unnest(string_to_array(genres, ','))
FROM original.title_basics;

-- Media

INSERT INTO media ("type", runtime, imdb_id)
SELECT titletype, runtimeminutes, tconst
FROM original.title_basics;

-- Insert all genres for media
WITH
    media_genres AS (
        SELECT media_id, unnest(string_to_array(genres, ',')) AS genre_name
        FROM original.title_basics AS t
        JOIN media AS m ON m.imdb_id = t.tconst
    )
INSERT INTO media_genre (media_id, genre_id)
SELECT mg.media_id, g.genre_id
FROM media_genres AS mg
JOIN genre AS g ON g."name" = mg.genre_name; 

-- Insert title for media
WITH
    titles_with_id AS (
        SELECT ta.title, m.media_id, c.country_id, l.language_id, ta.titleid
        FROM original.title_akas AS ta
        JOIN media AS m ON m.imdb_id = ta.titleid
        LEFT JOIN "language" AS l ON l.imdb_language_code = ta."language"
        LEFT JOIN country AS c ON c.imdb_country_code = ta.region
    )
INSERT INTO title ("name", country_id, language_id, media_id)
SELECT title, country_id, language_id, media_id
FROM titles_with_id;

DO $$
DECLARE
    current_title RECORD;
    original_title_id INTEGER := (SELECT title_type_id FROM title_type WHERE "name" = 'original');
BEGIN
    FOR current_title IN
        WITH 
            titles_with_id AS (
                SELECT ta.title, m.media_id, c.country_id, ta."types", ta.attributes, l.language_id, t.primarytitle, t.originaltitle
                FROM original.title_akas AS ta
                JOIN media AS m ON m.imdb_id = ta.titleid
                JOIN original.title_basics AS t ON t.tconst = ta.titleid
                LEFT JOIN "language" AS l ON l.imdb_language_code = ta."language"
                LEFT JOIN country AS c ON c.imdb_country_code = ta.region
            )
        SELECT t.title_id, t."name" AS title, ti.attributes, ti."types", ti.primarytitle, ti.originaltitle
        FROM title AS t
        JOIN media AS m ON m.media_id = t.media_id
        JOIN titles_with_id AS ti
            ON ti.media_id = t.media_id
            AND ti.title = t."name"
            AND COALESCE(cast(ti.country_id AS VARCHAR), 'NA') = COALESCE(cast(t.country_id AS VARCHAR), 'NA')
            AND COALESCE(cast(ti.language_id AS VARCHAR), 'NA') = COALESCE(cast(t.language_id AS VARCHAR), 'NA')
    LOOP
        IF current_title.types != '' THEN
            WITH
                title_types_names AS (
                    SELECT unnest(string_to_array(current_title.types, '')) AS type_name
                ),
                title_type_with_id AS (
                    SELECT tt.title_type_id, tt."name"
                    FROM title_types_names AS ttn
                    JOIN title_type AS tt ON tt."name" = ttn.type_name
                )
            INSERT INTO title_title_type (title_id, title_type_id)
            SELECT current_title.title_id, title_type_id
            FROM title_type_with_id;
        END IF;

        IF current_title.attributes != '' THEN
            WITH
                title_attribute_names AS (
                    SELECT unnest(string_to_array(current_title.attributes, '')) AS attribute_name
                ),
                title_attribute_with_id AS (
                    SELECT ta.title_attribute_id, ta."name"
                    FROM title_attribute_names
                    JOIN title_attribute AS ta ON "name" = attribute_name
                )
            INSERT INTO title_title_attribute (title_id, title_attribute_id)
            SELECT current_title.title_id, title_attribute_id
            FROM title_attribute_with_id;
        END IF;

        IF current_title.originaltitle = current_title.title THEN
            INSERT INTO title_title_type (title_id, title_type_id)
            VALUES (current_title.title_id, original_title_id);
        END IF;
    END LOOP;
END $$;

-- Insert release for media
WITH
    titleaka_with_id AS (
        SELECT t.originaltitle, t.primarytitle, t.startyear, m.media_id
        FROM media AS m
        JOIN original.title_basics AS t ON t.tconst = m.imdb_id
    )
INSERT INTO release (release_date, "type", media_id)
SELECT 
    TO_DATE(startyear, 'YYYY'),
    'original',
    media_id
FROM titleaka_with_id
WHERE startyear != '';
-- Seasons

DO $$
DECLARE
    new_season_id INTEGER;
    new_title_id INTEGER;
    current_season RECORD;
BEGIN
    -- Insert seasons for media
    FOR current_season IN
        SELECT 
            e.parenttconst,
            e.seasonnumber AS season_number,
            CASE 
                WHEN MIN(t.startyear) = '' THEN NULL 
                ELSE TO_DATE(MIN(t.startyear)::TEXT, 'YYYY') 
            END AS "start_date",  
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
        INSERT INTO title ("name", media_id)
        VALUES (
            FORMAT('%s - Season %s', current_season.show_title, current_season.season_number), 
            new_season_id)
        RETURNING title_id INTO new_title_id;

        INSERT INTO title_title_type(title_id, title_type_id)
        VALUES (new_title_id, (SELECT title_type_id FROM title_type WHERE "name" = 'alternative'));

        -- Insert release for season
        INSERT INTO "release" (release_date, "type", media_id)
        VALUES (current_season.start_date, 'original', new_season_id);
    END LOOP;
END $$;

-- Episodes

INSERT INTO episode (media_id, episode_number, season_id)
SELECT m.media_id, e.episodenumber, s.media_id
FROM original.title_episode AS e
JOIN media AS m ON m.imdb_id = e.tconst
JOIN media AS ps ON e.parenttconst = ps.imdb_id
JOIN season AS s ON s.season_number = e.seasonnumber AND s.series_id = ps.media_id;

-- Scores

WITH
    title_with_rating AS (
        SELECT r.averagerating::TEXT, r.numvotes, m.media_id
        FROM media AS m
        JOIN original.title_ratings AS r ON r.tconst = m.imdb_id
    )
INSERT INTO score (source, "value", media_id, vote_count)
SELECT 'IMDb', averagerating, media_id, numvotes
FROM title_with_rating;

-- Insert person data
INSERT INTO person (name, birth_date, death_date, "description", imdb_id)
SELECT 
    primaryname AS name,
    CASE WHEN birthyear = '' THEN NULL ELSE TO_DATE(birthyear, 'YYYY') END AS birth_date,
    CASE WHEN deathyear = '' THEN NULL ELSE TO_DATE(deathyear, 'YYYY') END AS death_date,
    NULL AS description,
    nconst AS imdb_id
FROM original.name_basics;

-- Insert job roles
INSERT INTO job_category (name)
SELECT DISTINCT category
FROM original.title_principals;

-- Insert crew members (excluding 'actor' and 'actress')
INSERT INTO crew_member (person_id, media_id, role, job_category_id)
SELECT 
    p.person_id, 
    m.media_id, 
    t.job AS role,
    jc.job_category_id
FROM original.title_principals t
JOIN media m ON t.tconst = m.imdb_id
JOIN person p ON p.imdb_id = t.nconst
JOIN job_category jc ON jc.name = t.category
WHERE LOWER(t.category) NOT IN ('actor', 'actress');  -- Exclude 'actor' and 'actress'

-- Insert cast members (only 'actor' and 'actress')
INSERT INTO cast_member (person_id, media_id, "character", role)
SELECT 
    p.person_id, 
    m.media_id, 
    unnest(regexp_split_to_array(
        regexp_replace(trim(both '''[]''' from t.characters), ',\s*,?$', '', 'g'), 
        ',\s*(?=(?:[^"]*"[^"]*")*[^"]*$)'
    )) AS "character",
    t.category AS "role"
FROM original.title_principals t
JOIN media m ON t.tconst = m.imdb_id
JOIN person p ON p.imdb_id = t.nconst
WHERE LOWER(t.category) IN ('actor', 'actress');

-- Update media table with data from omdb_data

UPDATE media
SET plot = (CASE
	    WHEN o.plot = 'N/A' THEN NULL
	    WHEN o.plot = '' THEN NULL
        ELSE o.plot END),
    box_office = CAST(CASE 
        WHEN REPLACE(TRIM('$' FROM o.boxoffice), ',', '') = 'N/A' THEN NULL 
        ELSE REPLACE(TRIM('$' FROM o.boxoffice), ',', '') 
        END AS INTEGER),
    awards = (CASE
		WHEN o.awards= 'N/A' THEN NULL
		WHEN o.awards= '' THEN NULL 
        ELSE o.awards END)
FROM original.omdb_data AS o
WHERE media.imdb_id = o.tconst;
 
-- Update release rating

UPDATE release
SET 
    rated = (CASE
	    WHEN o.rated = 'N/A' THEN NULL
	    WHEN o.rated = '' THEN NULL
        ELSE o.rated END)
FROM original.omdb_data AS o 
JOIN media AS m ON m.imdb_id = o.tconst
WHERE release.media_id = m.media_id;

-- Update or create release release_date
WITH 
    omdb_with_release AS (
        SELECT m.media_id, o.released, o.rated
        FROM media AS m
        JOIN original.omdb_data AS o ON m.imdb_id = o.tconst
        WHERE o.released != 'N/A' 
            AND o.released != ''
    ),
    updated AS (
        UPDATE release
        SET release_date = o.released::date
        FROM omdb_with_release AS o
        WHERE release.media_id = o.media_id
            AND DATE_PART('year', release.release_date::date) = DATE_PART('year', o.released::date)
        RETURNING release.media_id
)
INSERT INTO release (release_date, "type", media_id, rated)
SELECT o.released::DATE, 'original', o.media_id, o.rated
FROM omdb_with_release AS o
WHERE o.media_id NOT IN (SELECT u.media_id FROM updated AS u);

-- Create posters
INSERT INTO promotional_media(release_id, "type", uri)
SELECT r.release_id, 'poster', o.poster
FROM release r
JOIN media m ON r.media_id = m.media_id
JOIN original.omdb_data o ON m.imdb_id = o.tconst
WHERE (o.poster != 'N/A'
    AND o.poster != ''
    AND o.poster IS NOT NULL)
    AND r."type" = 'original';

-- Create websites
INSERT INTO promotional_media(release_id, "type", uri)
SELECT r.release_id, 'website', o.website
FROM release r 
JOIN media m ON r.media_id = m.media_id
JOIN original.omdb_data o ON m.imdb_id = o.tconst
WHERE o.website != 'N/A'
    AND o.website != ''
    AND o.website IS NOT NULL;

-- Create primary info
WITH
    primary_title AS (
        SELECT DISTINCT ON (media_id) media_id, title_id 
        FROM title AS t
        JOIN media AS m USING (media_id)
        JOIN original.title_basics AS tb ON m.imdb_id = tb.tconst
        WHERE tb.primarytitle = t."name"
    ),
    primary_release AS (
        SELECT DISTINCT ON (media_id) media_id, release_id 
        FROM release AS r
        WHERE r."type" = 'original'
    ),
    primary_poster AS (
        SELECT DISTINCT ON (pr.media_id) pr.media_id, pm.promotional_media_id
        FROM promotional_media AS pm
        JOIN primary_release AS pr USING (release_id)
        WHERE pm."type" = 'poster'
    )
INSERT INTO media_primary_information(media_id, title_id, release_id, promotional_media_id)
SELECT pt.media_id, pt.title_id, pr.release_id, pp.promotional_media_id
FROM primary_title AS pt
LEFT JOIN primary_release AS pr USING(media_id)
LEFT JOIN primary_poster AS pp USING(media_id);


-- Insert Production companies
INSERT INTO production_company ("name", "description")
SELECT DISTINCT unnest(string_to_array(o.production, ', ')), null
FROM original.omdb_data as o;

WITH 
    prod_comps AS (
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


-- add scores 
WITH 
    json_extract AS (
        SELECT
            o.tconst,
            m.media_id,
            CASE
                WHEN json_data->>'Source' = 'Internet Movie Database' THEN 'imdb'
                WHEN json_data->>'Source' = 'Rotten Tomatoes' THEN 'rottentomatoes'
                WHEN json_data->>'Source' = 'Metacritic' THEN 'metacritic'
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
    imdb_score_update AS (
        --updating score with the data from JSON and saving ids of updated rows
        --UPDATE happens only if the vote count is higher than the one in IMDB_DB
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
INSERT INTO score (source, value, vote_count, at, media_id)
SELECT j.source, j.value, j.imdbvotes, CURRENT_TIMESTAMP, j.media_id
FROM json_extract j
LEFT JOIN imdb_score_update u ON u.media_id = j.media_id AND u.source = j.source
LEFT JOIN score s ON j.media_id = s.media_id
WHERE (j.media_id != s.media_id AND j.source = 'imdb')
    OR (u.status IS NULL AND j.source != 'imdb');

--GET COUNTRIES IN SEPARATE ROWS AND WITHOUT WRONG DATA
WITH omdb_country AS (
	SELECT tconst, unnest(string_to_array(country, ', ')) as country
	FROM original.omdb_data o
	WHERE o.country !='N/A'
		AND o.country != ''
		AND o.country IS NOT NULL),

--MERGING WITH COUNTRIES
country_merge AS (
	SELECT o.tconst, o.country, c.name, c.iso_code, c.country_id
	FROM omdb_country o
	JOIN country c ON o.country = c.name),

--GETTING UNMATCHING COUNTRIES AND THERI IDS
--CONVERTING NAMES TO THE CORRECT SO THEY MATCH COUNTRY TABLE
other_countries AS (
  SELECT o.tconst, 
		CASE  
			WHEN o.country = 'USA' THEN 'United States'
			WHEN o.country = 'Côte d&#x27;Ivoire' THEN 'Ivory Coast'
			WHEN o.country = 'UK' THEN 'United Kingdom'
			WHEN o.country = 'Vatican' THEN 'Holy See (Vatican City State)'
			WHEN o.country = 'Congo' THEN 'Republic of the Congo'
			WHEN o.country = 'Federal Republic of Yugoslavia' THEN 'Yugoslavia'
			WHEN o.country = 'Isle of Man' THEN 'Isle of Man'
			WHEN o.country = 'Korea' THEN 'South Korea'
			WHEN o.country = 'Republic of Macedonia' THEN 'North Macedonia'
			WHEN o.country = 'Macao' THEN 'Macau'
			WHEN o.country = 'Occupied Palestinian Territory' THEN 'Palestine'
			WHEN o.country = 'Republic of North Macedonia' THEN 'Macedonian'
			WHEN o.country = 'Swaziland' THEN 'Eswatini'
			WHEN o.country = 'The Democratic Republic Of Congo' THEN 'Democratic Republic of the Congo'
			WHEN o.country = 'U.S. Virgin Islands' THEN 'Virgin Islands'
			WHEN o.country = 'Myanmar (Burma)' THEN 'Burma'
			END AS country
  FROM omdb_country o
  LEFT JOIN country_merge cm ON o.tconst = cm.tconst AND o.country = cm.country
  WHERE cm.country IS NULL),

--MERGING FIXED COUNTRIES WITH country_id form country TABLE
other_countries_merge AS (
	SELECT o.tconst, o.country, c.name, c.iso_code, c.country_id
	FROM other_countries o
	JOIN country c ON o.country = c.name),
    
--FINAL TABLE WHERE I COMBINED BOTH MERGED TABLES
--THE NUMBER THE OF RECORDS MATCHES THE ONE IN OMDB
final_table_to_insert AS (
	SELECT tconst, country_id, country
	FROM country_merge cm
	FULL JOIN other_countries_merge ocm USING (tconst, country_id, country) )

--INSERTING THE VAUES
INSERT INTO media_production_country(media_id, country_id)
SELECT m.media_id, f.country_id
FROM final_table_to_insert f
LEFT JOIN media m ON f.tconst = m.imdb_id;
