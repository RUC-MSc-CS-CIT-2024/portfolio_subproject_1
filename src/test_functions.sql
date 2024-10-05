-- test_functions.sql
-- This script tests all functions and procedures created in functions.sql
-- It demonstrates that each function works as intended.

/timing

-- Begin transaction
BEGIN;

-- Test create_user function
-- Attempt to create a new user

-- Display users before creation
SELECT * FROM "user";

-- Call the function
SELECT create_user('testuser', 'Password123!', 'testuser@example.com');

-- Display users after creation
SELECT * FROM "user";
