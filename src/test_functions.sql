-- test_functions.sql
-- This script tests all functions and procedures created in functions.sql
-- It demonstrates that each function works as intended.
-- It is designed to be re-run multiple times without errors.

-- ============================================================
-- D1 Basic Framework Functionality
-- Test create_user function
-- ============================================================

-- Delete 'testuser' if it already exists
DELETE FROM "user" WHERE username = 'testuser' OR email = 'testuser@example.com';

-- Display users before creation
SELECT * FROM "user";

-- Call the function to create a new user
SELECT create_user('testuser', 'Password123!', 'testuser@example.com');

-- Display users after creation
SELECT * FROM "user";

-- ============================================================
-- D1 Test login_user function
-- ============================================================

-- Test login_user function with correct credentials
SELECT login_user('testuser', 'Password123!');

-- Note: Removed tests where we expect it to fail.

-- ============================================================
-- D1 Test update_user_password function
-- ============================================================

-- Display user info before password update
SELECT * FROM "user" WHERE username = 'testuser';

-- Call the function to update the password
SELECT update_user_password((SELECT user_id FROM "user" WHERE username = 'testuser'), 'NewPassword123!');

-- Display user info after password update
SELECT * FROM "user" WHERE username = 'testuser';

-- Verify that the new password works
SELECT login_user('testuser', 'NewPassword123!');

-- ============================================================
-- D1 Test update_user_credentials function
-- ============================================================

-- Display user info before updating credentials
SELECT * FROM "user" WHERE username = 'testuser';

-- Update username
SELECT update_user_credentials((SELECT user_id FROM "user" WHERE username = 'testuser'), 'newtestuser', NULL);

-- Display user info after updating username
SELECT * FROM "user" WHERE username = 'newtestuser';

-- Update email
SELECT update_user_credentials((SELECT user_id FROM "user" WHERE username = 'newtestuser'), NULL, 'newemail@example.com');

-- Display user info after updating email
SELECT * FROM "user" WHERE username = 'newtestuser';

-- Update both username and email
SELECT update_user_credentials((SELECT user_id FROM "user" WHERE username = 'newtestuser'), 'finaltestuser', 'finalemail@example.com');

-- Display user info after updating both
SELECT * FROM "user" WHERE username = 'finaltestuser';

-- ============================================================
-- D1 Test delete_user function
-- ============================================================

-- Display users before deletion
SELECT * FROM "user";

-- Delete the user
SELECT delete_user((SELECT user_id FROM "user" WHERE username = 'finaltestuser'));

-- Display users after deletion
SELECT * FROM "user";

-- ============================================================
-- D1 Prepare data for following tests
-- ============================================================

-- Delete 'user1' if it already exists
DELETE FROM "user" WHERE username = 'user1' OR email = 'user1@example.com';

-- Create a user for following tests
SELECT create_user('user1', 'User1Pass!', 'user1@example.com');

-- ============================================================
-- D1 Test follow_person function
-- ============================================================

-- Ensure that the user is not already following the person
DELETE FROM "following"
WHERE user_id = (SELECT user_id FROM "user" WHERE username = 'user1')
  AND person_id = (SELECT person_id FROM person LIMIT 1);

-- Display following relationships before following
SELECT * FROM "following" WHERE user_id = (SELECT user_id FROM "user" WHERE username = 'user1');

-- Follow a person
SELECT follow_person(
    (SELECT user_id FROM "user" WHERE username = 'user1'), 
    (SELECT person_id FROM person LIMIT 1)
);

-- Display following relationships after following
SELECT * FROM "following" WHERE user_id = (SELECT user_id FROM "user" WHERE username = 'user1');

-- ============================================================
-- D1 Test unfollow_person function
-- ============================================================

-- Ensure that the user is following the person
-- (The previous test followed the person.)

-- Unfollow the person
SELECT unfollow_person(
    (SELECT user_id FROM "user" WHERE username = 'user1'), 
    (SELECT person_id FROM person LIMIT 1)
);

-- Display following relationships after unfollowing
SELECT * FROM "following" WHERE user_id = (SELECT user_id FROM "user" WHERE username = 'user1');

-- ============================================================
-- D1 Test bookmark_media function
-- ============================================================

-- Ensure that the bookmark does not already exist
DELETE FROM bookmark
WHERE user_id = (SELECT user_id FROM "user" WHERE username = 'user1')
  AND media_id = (SELECT media_id FROM release LIMIT 1);

-- Display bookmarks before bookmarking
SELECT * FROM bookmark WHERE user_id = (SELECT user_id FROM "user" WHERE username = 'user1');

-- Bookmark media
SELECT bookmark_media(
    (SELECT user_id FROM "user" WHERE username = 'user1'), 
    (SELECT media_id FROM release LIMIT 1), 
    'Must watch later!'
);

-- Display bookmarks after bookmarking
SELECT * FROM bookmark WHERE user_id = (SELECT user_id FROM "user" WHERE username = 'user1');

-- ============================================================
-- D1 Test move_bookmark_to_completed function
-- ============================================================

-- Ensure that the completed entry does not already exist
DELETE FROM completed
WHERE user_id = (SELECT user_id FROM "user" WHERE username = 'user1')
  AND media_id = (SELECT media_id FROM release LIMIT 1);

-- Display completed list before moving bookmark
SELECT * FROM completed WHERE user_id = (SELECT user_id FROM "user" WHERE username = 'user1');

-- Move bookmark to completed
SELECT move_bookmark_to_completed(
    (SELECT user_id FROM "user" WHERE username = 'user1'), 
    (SELECT media_id FROM release LIMIT 1), 
    5, 
    'Great movie!'
);

-- Display bookmarks after moving to completed
SELECT * FROM bookmark WHERE user_id = (SELECT user_id FROM "user" WHERE username = 'user1');

-- Display completed list after moving bookmark
SELECT * FROM completed WHERE user_id = (SELECT user_id FROM "user" WHERE username = 'user1');

-- ============================================================
-- D1 Test unbookmark_media function
-- ============================================================

-- Ensure the bookmark does not already exist
DELETE FROM bookmark
WHERE user_id = (SELECT user_id FROM "user" WHERE username = 'user1')
  AND media_id = (SELECT media_id FROM release OFFSET 1 LIMIT 1);

SELECT bookmark_media(
    (SELECT user_id FROM "user" WHERE username = 'user1'), 
    (SELECT media_id FROM release OFFSET 1 LIMIT 1), 
    'Will unbookmark soon'
);

-- Display bookmarks before unbookmarking
SELECT * FROM bookmark WHERE user_id = (SELECT user_id FROM "user" WHERE username = 'user1');

-- Unbookmark media
SELECT unbookmark_media(
    (SELECT user_id FROM "user" WHERE username = 'user1'), 
    (SELECT media_id FROM release OFFSET 1 LIMIT 1)
);

-- Display bookmarks after unbookmarking
SELECT * FROM bookmark WHERE user_id = (SELECT user_id FROM "user" WHERE username = 'user1');

-- ============================================================
-- D2 Test simple_search function
-- ============================================================

-- Perform a simple search
SELECT * FROM simple_search('apple', 1);

-- ============================================================
-- D3 Test rate function
-- ============================================================

-- Delete 'john_doe' and 'jane_smith' if they already exist
DELETE FROM "user" WHERE username IN ('john_doe', 'jane_smith') OR email IN ('john_doe@example.com', 'jane_smith@example.com');

-- Create users for rating tests
SELECT create_user('john_doe', 'JohnPass123!', 'john_doe@example.com');
SELECT create_user('jane_smith', 'JanePass123!', 'jane_smith@example.com');

-- Ensure that user scores do not already exist
DELETE FROM user_score
WHERE user_id = (SELECT user_id FROM "user" WHERE username = 'john_doe')
  AND media_id = (SELECT media_id FROM media WHERE imdb_id = 'tt1375666');

DELETE FROM user_score
WHERE user_id = (SELECT user_id FROM "user" WHERE username = 'jane_smith')
  AND media_id = (SELECT media_id FROM media WHERE imdb_id = 'tt1375666');

-- john_doe rates 'tt1375666' with 8.0
SELECT rate(
    (SELECT user_id FROM "user" WHERE username = 'john_doe'), 
    'tt1375666', 8.0, 'Nice movie'
);

-- john_doe updates rating to 9.0
SELECT rate(
    (SELECT user_id FROM "user" WHERE username = 'john_doe'), 
    'tt1375666', 9.0, 'Super nice'
);

-- jane_smith rates 'tt1375666' with 7.0
SELECT rate(
    (SELECT user_id FROM "user" WHERE username = 'jane_smith'), 
    'tt1375666', 7.0, 'Okay'
);

-- Display user scores for 'tt1375666'
SELECT * FROM user_score WHERE media_id = (SELECT media_id FROM media WHERE imdb_id = 'tt1375666') LIMIT 10;

-- Display updated average rating
SELECT * FROM score WHERE media_id = (SELECT media_id FROM media WHERE imdb_id = 'tt1375666') AND source = 'userrating' LIMIT 10;

-- ============================================================
-- D4 Test structured_string_search function
-- ============================================================

-- Perform a structured string search
SELECT * FROM structured_string_search(
    'Wlad Badeea',      -- title
    'Four siblings',    -- plot
    NULL,               -- character
    'Emarat Rezk',      -- person
    (SELECT user_id FROM "user" WHERE username = 'user1')
) LIMIT 10;

-- ============================================================
-- D5 Test structured_string_search_name function
-- ============================================================

-- Perform a structured string search by name
SELECT * FROM structured_string_search_name('Jennifer', (SELECT user_id FROM "user" WHERE username = 'user1')) LIMIT 10;

-- ============================================================
-- D6 Test get_frequent_coplaying_actors function
-- ============================================================

-- Get frequent co-actors of 'Jennifer Aniston'
SELECT * FROM get_frequent_coplaying_actors('Jennifer Aniston') LIMIT 10;

-- ============================================================
-- D7 Test calculate_name_rating function
-- ============================================================

-- Calculate name ratings
SELECT calculate_name_rating();

-- Display top 10 persons by name_rating
SELECT person_id, name, name_rating FROM person ORDER BY name_rating DESC NULLS LAST LIMIT 10;

-- ============================================================
-- D8 Test list_actors_by_popularity function
-- ============================================================

-- List actors by popularity for a sample media
SELECT * FROM list_actors_by_popularity(36) LIMIT 10;

-- ============================================================
-- D8 Test list_co_actors_by_popularity function
-- ============================================================

-- List co-actors by popularity for a sample actor
SELECT * FROM list_co_actors_by_popularity(64) LIMIT 10;

-- ============================================================
-- D9 SImiliar Movies Search Functions
-- ============================================================

SELECT * FROM get_count_of_movies_with_same_actors(7);
SELECT * FROM find_movies_from_the_same_country(173);
SELECT * FROM find_movie_similar_titles('Escape from prison',3);
SELECT * FROM find_movies_with_similar_crew(15647);
SELECT * FROM get_movies_with_same_genre(6565);
SIMPLE SEARCH TEST
SELECT * FROM get_similar_movies(6565);

-- ============================================================
-- D10 Test person_words function
-- ============================================================

-- Get words associated with 'Jennifer Aniston'
SELECT * FROM person_words('Jennifer Aniston', 8) LIMIT 10;

-- ============================================================
-- D11 Test exact_match_titles function
-- ============================================================

-- Perform exact match title search
SELECT * FROM exact_match_titles(ARRAY['apple', 'mads', 'mikkelsen']) LIMIT 10;

-- Display titles for returned media_ids
SELECT "name" FROM title WHERE media_id IN (SELECT media_id FROM exact_match_titles(ARRAY['apple', 'mads', 'mikkelsen'])) LIMIT 10;

-- ============================================================
-- D12 Test best_match_titles function
-- ============================================================

-- Perform best match title search
SELECT * FROM best_match_titles(ARRAY['apple', 'mads', 'mikkelsen']) LIMIT 10;

-- Display titles for returned media_ids
SELECT "name" FROM title WHERE media_id IN (SELECT media_id FROM best_match_titles(ARRAY['apple', 'mads', 'mikkelsen'])) LIMIT 10;

-- ============================================================
-- D13 Test word_to_words_query function
-- ============================================================

-- Get related words for the keywords
SELECT * FROM word_to_words_query(ARRAY['apple', 'mads', 'mikkelsen']) LIMIT 10;

-- ============================================================
-- End of tests
-- ============================================================
