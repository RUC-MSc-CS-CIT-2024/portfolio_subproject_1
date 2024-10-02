
TRUNCATE TABLE person CASCADE;
TRUNCATE TABLE cast_member CASCADE;
TRUNCATE TABLE crew_member CASCADE;
TRUNCATE TABLE job_category CASCADE;

INSERT INTO person (name, birth_date, death_date, "description", imdb_id)
SELECT 
    LEFT(primaryname, 50) AS name,  -- Truncate name to 50 characters to prevent errors
    CASE WHEN birthyear = '' THEN NULL ELSE TO_DATE(birthyear, 'YYYY') END AS birth_date,
    CASE WHEN deathyear = '' THEN NULL ELSE TO_DATE(deathyear, 'YYYY') END AS death_date,
    primaryprofession AS description,
    nconst AS imdb_id
FROM original.name_basics;

WITH job_roles AS (
    SELECT DISTINCT category
    FROM original.title_principals
)
INSERT INTO job_category (name)
SELECT category
FROM job_roles;

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
WHERE t.category IN ('director', 'producer', 'writer');

INSERT INTO cast_member (person_id, media_id, "character", role)
SELECT 
    p.person_id, 
    m.media_id, 
    t.characters AS "character",
    t.category AS role
FROM original.title_principals t
JOIN media m ON t.tconst = m.imdb_id
JOIN person p ON p.imdb_id = t.nconst
WHERE t.category IN ('actor', 'actress');
