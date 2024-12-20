-- Drop all indexes
DROP INDEX IF EXISTS idx_search_history_user_id;
DROP INDEX IF EXISTS idx_bookmark_user_id;
DROP INDEX IF EXISTS idx_completed_user_id;
DROP INDEX IF EXISTS idx_user_score_user_id;
DROP INDEX IF EXISTS idx_user_username;
DROP INDEX IF EXISTS idx_user_email;
DROP INDEX IF EXISTS idx_bookmark_media_id;
DROP INDEX IF EXISTS idx_completed_media_id;
DROP INDEX IF EXISTS idx_user_score_media_id;
DROP INDEX IF EXISTS idx_season_series_id;
DROP INDEX IF EXISTS idx_episode_season_id;
DROP INDEX IF EXISTS idx_media_genre_media_id;
DROP INDEX IF EXISTS idx_media_production_country_media_id;
DROP INDEX IF EXISTS idx_score_media_id;
DROP INDEX IF EXISTS idx_media_in_collection_media_id;
DROP INDEX IF EXISTS idx_related_media_primary_id;
DROP INDEX IF EXISTS idx_related_media_related_id;
DROP INDEX IF EXISTS idx_media_imdb_id;
DROP INDEX IF EXISTS idx_title_name;
DROP INDEX IF EXISTS idx_title_type_name;
DROP INDEX IF EXISTS idx_crew_member_person_id;
DROP INDEX IF EXISTS idx_cast_member_person_id;
DROP INDEX IF EXISTS idx_person_name;
DROP INDEX IF EXISTS idx_cast_member_character;
DROP INDEX IF EXISTS idx_completed_completed_date;
DROP INDEX IF EXISTS idx_user_score_score_value;
DROP INDEX IF EXISTS idx_search_history_type;
DROP INDEX IF EXISTS idx_media_in_collection_collection_id;
DROP INDEX IF EXISTS idx_wi_words;
DROP INDEX IF EXISTS idx_media_production_country_media_country;
DROP INDEX IF EXISTS idx_media_country;
DROP INDEX IF EXISTS idx_media_in_collection_collection_media;

-- Drop all functions
DROP FUNCTION IF EXISTS follow_person(INT, INT);
DROP FUNCTION IF EXISTS unfollow_person(INT, INT);
DROP FUNCTION IF EXISTS bookmark_media(INT, INT, TEXT);
DROP FUNCTION IF EXISTS move_bookmark_to_completed(INT, INT, INT, TEXT);
DROP FUNCTION IF EXISTS unbookmark_media(INT, INT);
DROP FUNCTION IF EXISTS simple_search(VARCHAR, INTEGER);
DROP FUNCTION IF EXISTS rate(INT, VARCHAR, NUMERIC, TEXT);
DROP FUNCTION IF EXISTS rate(INT, INTEGER, NUMERIC, TEXT);
DROP FUNCTION IF EXISTS structured_string_search(VARCHAR, VARCHAR, VARCHAR, VARCHAR, INTEGER);
DROP FUNCTION IF EXISTS structured_string_search_name(VARCHAR, INTEGER);
DROP FUNCTION IF EXISTS get_frequent_coplaying_actors(VARCHAR);
DROP FUNCTION IF EXISTS calculate_name_rating();
DROP FUNCTION IF EXISTS list_actors_by_popularity(INT);
DROP FUNCTION IF EXISTS list_co_actors_by_popularity(INT);
DROP FUNCTION IF EXISTS get_similar_movies(INTEGER);
DROP FUNCTION IF EXISTS get_count_of_movies_with_same_actors(INTEGER);
DROP FUNCTION IF EXISTS get_movies_from_the_same_country(INTEGER);
DROP FUNCTION IF EXISTS get_movies_with_similar_titles(TEXT, INTEGER);
DROP FUNCTION IF EXISTS get_movies_with_similar_crew(INTEGER);
DROP FUNCTION IF EXISTS get_movies_with_same_genre(INTEGER);
DROP FUNCTION IF EXISTS person_words(VARCHAR, INT);
DROP FUNCTION IF EXISTS exact_match_titles(TEXT[]);
DROP FUNCTION IF EXISTS exact_match_titles(TEXT[], INTEGER);
DROP FUNCTION IF EXISTS best_match_titles(TEXT[]);
DROP FUNCTION IF EXISTS best_match_titles(TEXT[], INTEGER);
DROP FUNCTION IF EXISTS word_to_words_query(TEXT[]);

-- Drop all views
DROP VIEW IF EXISTS actor_media_view;
