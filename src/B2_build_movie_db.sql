DROP TABLE IF EXISTS country CASCADE;
DROP TABLE IF EXISTS "language" CASCADE;
DROP TABLE IF EXISTS job_category CASCADE;
DROP TABLE IF EXISTS media CASCADE;
DROP TABLE IF EXISTS movie CASCADE;
DROP TABLE IF EXISTS series CASCADE;
DROP TABLE IF EXISTS season CASCADE;
DROP TABLE IF EXISTS episode CASCADE;
DROP TABLE IF EXISTS media_genre CASCADE;
DROP TABLE IF EXISTS media_production_country CASCADE;
DROP TABLE IF EXISTS score CASCADE;
DROP TABLE IF EXISTS "collection" CASCADE;
DROP TABLE IF EXISTS media_in_collection CASCADE;
DROP TABLE IF EXISTS related_media CASCADE;
DROP TABLE IF EXISTS release CASCADE;
DROP TABLE IF EXISTS spoken_language CASCADE;
DROP TABLE IF EXISTS promotional_media CASCADE;
DROP TABLE IF EXISTS person CASCADE;
DROP TABLE IF EXISTS crew_member CASCADE;
DROP TABLE IF EXISTS cast_member CASCADE;
DROP TABLE IF EXISTS production_company CASCADE;
DROP TABLE IF EXISTS media_production_company CASCADE;
DROP TABLE IF EXISTS "user" CASCADE;
DROP TABLE IF EXISTS search_history CASCADE;
DROP TABLE IF EXISTS bookmarks CASCADE;
DROP TABLE IF EXISTS completed CASCADE;
DROP TABLE IF EXISTS plan_to_watch CASCADE;
DROP TABLE IF EXISTS user_score CASCADE;

CREATE TABLE country (
    code    VARCHAR(2)  PRIMARY KEY,
    "name"  VARCHAR(50) NOT NULL
);

CREATE TABLE "language" (
    code    VARCHAR(2)  PRIMARY KEY,
    "name"  VARCHAR(50) NOT NULL
);

CREATE TABLE job_category (
    id      INTEGER     PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    "name"  VARCHAR(50) NOT NULL
);

CREATE TABLE media (
    id          INTEGER         PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
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
    "status"        VARCHAR(50) NOT NULL,
    season_number   INTEGER     NOT NULL,
    end_date        DATE        NULL,
    series_id       INTEGER     NOT NULL REFERENCES media(id),
    media_id        INTEGER     NOT NULL REFERENCES media(id)
);

CREATE TABLE episode (
    episode_number  INTEGER NOT NULL,
    season_id       INTEGER NOT NULL REFERENCES media(id),
    media_id        INTEGER NOT NULL REFERENCES media(id)
);

CREATE TABLE media_genre (
    "name"      VARCHAR(50) NOT NULL,
    media_id    INTEGER     NOT NULL REFERENCES media(id),
    PRIMARY KEY (media_id, "name")
);

CREATE TABLE media_production_country (
    id              INTEGER     PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    media_id        INTEGER     NOT NULL REFERENCES media(id),
    country_code    VARCHAR(2)  NOT NULL REFERENCES country(code)
);

CREATE TABLE score (
    id              INTEGER     PRIMARY KEY,
    source          INTEGER     NOT NULL,
    "value"           VARCHAR(20) NOT NULL,
    "at"            TIMESTAMP   NOT NULL,
    FOREIGN KEY (id) REFERENCES media(id)
);

CREATE TABLE "collection" (
    id              INTEGER     PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    "name"          VARCHAR(50) NOT NULL,
    "description"   TEXT        NULL
);

CREATE TABLE media_in_collection (
    collection_id   INTEGER REFERENCES "collection"(id),
    media_id        INTEGER REFERENCES media(id),
    PRIMARY KEY (collection_id, media_id)
);

CREATE TABLE related_media (
    primary_media_id    INTEGER     NOT NULL REFERENCES media(id),
    related_media_id    INTEGER     NOT NULL REFERENCES media(id),
    "type"              VARCHAR(50) NOT NULL,
    PRIMARY KEY (primary_media_id, related_media_id)
);

CREATE TABLE release (
    id              INTEGER     PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    title           VARCHAR(50) NOT NULL,
    release_date    DATE        NULL,
    country_code    VARCHAR(2)  NOT NULL REFERENCES country(code), -- Region
    media_id        INTEGER     NOT NULL REFERENCES media(id)
);

CREATE TABLE spoken_language (
    id              INTEGER     PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    release_id      INTEGER     NOT NULL REFERENCES release(id),
    language_code   VARCHAR(2)  NOT NULL REFERENCES "language"(code)
);

CREATE TABLE promotional_media (
    id          INTEGER         PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    release_id  INTEGER         NOT NULL REFERENCES release(id),
    "type"      VARCHAR(50)     NOT NULL,
    "uri"       VARCHAR(255)    NOT NULL
);

CREATE TABLE person (
    id              INTEGER     PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    "name"          VARCHAR(50) NOT NULL,
    birth_date      DATE        NULL,
    death_date      DATE        NULL,
    "description"   TEXT        NULL,
    score           DECIMAL     NOT NULL DEFAULT 0,
    imdb_id         VARCHAR(10) NULL
);

CREATE TABLE crew_member (
    id              INTEGER     PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    "role"          VARCHAR(50) NULL,
    person_id       INTEGER     NOT NULL REFERENCES person(id),
    media_id        INTEGER     NOT NULL REFERENCES media(id),
    job_category_id INTEGER     NOT NULL REFERENCES job_category(id)
);

CREATE TABLE cast_member (
    "character" VARCHAR(50) NOT NULL,
    PRIMARY KEY (id),
    FOREIGN KEY (person_id) REFERENCES person(id),
    FOREIGN KEY (media_id) REFERENCES media(id),
    FOREIGN KEY (job_category_id) REFERENCES job_category(id)
) INHERITS (crew_member);

CREATE TABLE production_company (
    id              INTEGER     PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    "name"          VARCHAR(50) NOT NULL,
    "description"   TEXT        NULL
);

CREATE TABLE media_production_company (
    media_id                INTEGER     NOT NULL REFERENCES media(id),
    production_company_id   INTEGER     NOT NULL REFERENCES production_company(id),
    "type"                  VARCHAR(20) NOT NULL,
    PRIMARY KEY (media_id, production_company_id)
);
