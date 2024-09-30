DROP TABLE IF EXISTS media_genre;
DROP TABLE IF EXISTS score;
DROP TABLE IF EXISTS spoken_language;
DROP TABLE IF EXISTS crew_member;
DROP TABLE IF EXISTS cast_member;
DROP TABLE IF EXISTS promotional_media;
DROP TABLE IF EXISTS release;
DROP TABLE IF EXISTS media_in_collection;
DROP TABLE IF EXISTS media_production_country;
DROP TABLE IF EXISTS media_production_company;
DROP TABLE IF EXISTS related_media;
DROP TABLE IF EXISTS movie;
DROP TABLE IF EXISTS series;
DROP TABLE IF EXISTS season;
DROP TABLE IF EXISTS episode;
DROP TABLE IF EXISTS media;
DROP TABLE IF EXISTS person;
DROP TABLE IF EXISTS production_company;
DROP TABLE IF EXISTS country;
DROP TABLE IF EXISTS "language";
DROP TABLE IF EXISTS job_category;
DROP TABLE IF EXISTS "collection";

CREATE TABLE country (
    country_id  INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    imdb_country_code   VARCHAR(4)  NULL,
    iso_code            VARCHAR(3) NULL,
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

CREATE TABLE media (
    media_id    INTEGER         PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    "type"      VARCHAR(50)     NOT NULL,
    plot        TEXT            NULL,
    runtime     INTEGER         NULL,
    box_office  INTEGER         NULL,
    budget      INTEGER         NULL,
    imdb_id     VARCHAR(10)     NULL,
    website     VARCHAR(255)    NULL,
    awards      VARCHAR(255)    NULL
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

CREATE TABLE media_genre (
    "name"      VARCHAR(50) NOT NULL,
    media_id    INTEGER     NOT NULL REFERENCES media(media_id),
    PRIMARY KEY (media_id, "name")
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

CREATE TABLE release (
    release_id      INTEGER     PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    title           TEXT        NOT NULL,
    release_date    DATE        NULL,
    "type"          VARCHAR(64) NULL,
    country_id      INTEGER     NULL REFERENCES country(country_id), -- Region
    media_id        INTEGER     NOT NULL REFERENCES media(media_id) 
);

CREATE TABLE spoken_language (
    spoken_language_id  INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    release_id          INTEGER NOT NULL REFERENCES release(release_id),
    language_id         INTEGER NOT NULL REFERENCES "language"(language_id)
);

CREATE TABLE promotional_media (
    promotional_media_id    INTEGER         PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    release_id              INTEGER         NOT NULL REFERENCES release(release_id),
    "type"                  VARCHAR(50)     NOT NULL,
    "uri"                   VARCHAR(255)    NOT NULL
);

CREATE TABLE person (
    person_id       INTEGER     PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    "name"          VARCHAR(50) NOT NULL,
    birth_date      DATE        NULL,
    death_date      DATE        NULL,
    "description"   TEXT        NULL,
    score           DECIMAL     NOT NULL DEFAULT 0,
    imdb_id         VARCHAR(10) NULL
);

CREATE TABLE crew_member (
    crew_member_id  INTEGER     PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    "role"          VARCHAR(50) NULL,
    person_id       INTEGER     NOT NULL REFERENCES person(person_id),
    media_id        INTEGER     NOT NULL REFERENCES media(media_id),
    job_category_id INTEGER     NOT NULL REFERENCES job_category(job_category_id)
);

CREATE TABLE cast_member (
    cast_member_id  INTEGER     PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    "role"          VARCHAR(50) NULL,
    "character"     VARCHAR(50) NOT NULL,
    person_id       INTEGER     NOT NULL REFERENCES person(person_id),
    media_id        INTEGER     NOT NULL REFERENCES media(media_id)
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
