CREATE TABLE country (
    code    VARCHAR(2)  PRIMARY KEY,
    "name"  VARCHAR(50)
);

CREATE TABLE "language" (
    code    VARCHAR(2)  PRIMARY KEY,
    "name"  VARCHAR(50)
);

CREATE TABLE media_genre (
    "name"      VARCHAR(50),
    media_id    INTEGER REFERENCES media(id),
    PRIMARY KEY (media_id, "name")
);

CREATE TYPE media (
    id          INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    plot        TEXT,
    runtime     INTEGER,
    box_office  INTEGER,
    budget      INTEGER,
    imdb_id     VARCHAR(10),
    website     VARCHAR(255),
    awards      VARCHAR(255),
);

CREATE TABLE movie INHERITS (media);

CREATE TABLE series INHERITS (media);

CREATE TABLE season (
    status          VARCHAR(50),
    season_number   INTEGER,
    end_date        DATE,
    series_id       INTEGER REFERENCES series(id),
) INHERITS (media);

CREATE TABLE episode (
    episode_number  INTEGER,
    season_id       INTEGER REFERENCES season(id),
) INHERITS (media);

CREATE TABLE media_production_country (
    id              INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    media_id        INTEGER REFERENCES media(id),
    country_code    VARCHAR(2) REFERENCES country(code)
);

CREATE TABLE score (
    id          INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    media_id    INTEGER REFERENCES media(id),
    score       DECIMAL,
    source      VARCHAR(50),
    "timestamp" DATETIME2
);

CREATE TABLE "collection" (
    id              INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    "name"          VARCHAR(50),
    "description"   TEXT
);

CREATE TABLE media_in_collection (
    collection_id   INTEGER REFERENCES "collection"(id),
    media_id        INTEGER REFERENCES media(id)
);

CREATE TABLE related_media (
    primary_media_id    INTEGER REFERENCES media(id),
    related_media_id    INTEGER REFERENCES media(id),
    "type"              VARCHAR(50),
    PRIMARY KEY (primary_media_id, related_media_id)
);

CREATE TABLE release (
    id              INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    title           VARCHAR(50),
    release_date    DATE,
    country         VARCHAR(2),
    country_code    VARCHAR(2) REFERENCES country(code), -- Region
    media_id        INTEGER REFERENCES media(id)
);

CREATE TABLE spoken_language (
    id              INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    release_id      INTEGER REFERENCES release(id),
    language_code   VARCHAR(2) REFERENCES "language"(code)
);

CREATE TABLE promotional_media (
    id          INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    release_id  INTEGER REFERENCES release(id),
    "type"      VARCHAR(50),
    "uri"       VARCHAR(255)
);

CREATE TABLE person (
    id              INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    firstname       VARCHAR(50),
    lastname        VARCHAR(50),
    birth_date      DATE,
    death_date      DATE,
    "description"   TEXT,
    score           DECIMAL,
    imdb_id         VARCHAR(10)
);

CREATE TABLE crew_member (
    id              INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    person_id       INTEGER REFERENCES person(id),
    media_id        INTEGER REFERENCES media(id),
    "character"     VARCHAR(50),
    job             VARCHAR(50),
    job_category    VARCHAR(50)
);

CREATE TABLE production_company (
    id              INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    "name"          VARCHAR(50),
    "description"   TEXT
);

CREATE TABLE media_production_company (
    media_id                INTEGER REFERENCES media(id),
    production_company_id   INTEGER REFERENCES production_company(id),
    "type"                  VARCHAR(20),
    PRIMARY KEY (media_id, production_company_id)
);