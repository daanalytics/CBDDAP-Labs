/*****************************************************
 * SNOWFLAKE BASICS LAB - CLEANUP SCRIPT
 * 
 * This script removes all objects created
 * during the Snowflake Basics Lab.
 * 
 * ⚠️  WARNING ⚠️
 * This script will delete ALL data and objects from the lab!
 * Use this only if you:
 * 1. Have completed the lab
 * 2. No longer need the data
 * 3. Want to clean up the environment
 * 
 * This action CANNOT be undone!
 *****************************************************/

-- Use the SYSADMIN role
USE ROLE SYSADMIN;

/*****************************************************
 * STEP 1: CONFIRMATION
 *****************************************************/

-- Show what will be deleted
SELECT '⚠️  WARNING: You are about to delete the following objects:' as message;

SHOW DATABASES LIKE 'BASICS_LAB_DB';
SHOW WAREHOUSES LIKE 'BASICS_LAB_WH';

-- Wait before proceeding...
SELECT 'If you are sure you want to continue, execute the rest of this script.' as message;

/*****************************************************
 * STEP 2: DELETE TABLES (OPTIONAL)
 * 
 * If you only want to clear tables without
 * deleting the database, you can use this section.
 *****************************************************/

/*
-- Uncomment this section if you only want to delete tables:

USE DATABASE BASICS_LAB_DB;
USE SCHEMA DWH;

DROP TABLE IF EXISTS FACT_SALES;
DROP TABLE IF EXISTS DIM_DATE;
DROP TABLE IF EXISTS DIM_PRODUCT;
DROP TABLE IF EXISTS DIM_CUSTOMER;
DROP TABLE IF EXISTS DIM_STORE;
DROP TABLE IF EXISTS PRODUCTS_JSON;

SELECT 'Tables have been deleted' as status;
*/

/*****************************************************
 * STEP 3: DELETE STAGES (OPTIONAL)
 *****************************************************/

/*
-- Uncomment this section if you only want to delete stages:

USE DATABASE BASICS_LAB_DB;
USE SCHEMA STAGING;

DROP STAGE IF EXISTS CSV_STAGE;
DROP STAGE IF EXISTS JSON_STAGE;

SELECT 'Stages have been deleted' as status;
*/

/*****************************************************
 * STEP 4: DELETE SCHEMAS (OPTIONAL)
 *****************************************************/

/*
-- Uncomment this section if you only want to delete schemas:

USE DATABASE BASICS_LAB_DB;

DROP SCHEMA IF EXISTS ANALYTICS CASCADE;
DROP SCHEMA IF EXISTS DWH CASCADE;
DROP SCHEMA IF EXISTS STAGING CASCADE;

SELECT 'Schemas have been deleted' as status;
*/

/*****************************************************
 * STEP 5: DELETE DATABASE
 * 
 * This deletes the entire database including
 * all schemas, tables, and stages.
 *****************************************************/

DROP DATABASE IF EXISTS BASICS_LAB_DB;

SELECT 'Database BASICS_LAB_DB has been deleted' as status;

/*****************************************************
 * STEP 6: DELETE WAREHOUSE
 *****************************************************/

DROP WAREHOUSE IF EXISTS BASICS_LAB_WH;

SELECT 'Warehouse BASICS_LAB_WH has been deleted' as status;

/*****************************************************
 * STEP 7: VERIFICATION
 *****************************************************/

-- Check if everything is deleted
SHOW DATABASES LIKE 'BASICS_LAB_DB';
SHOW WAREHOUSES LIKE 'BASICS_LAB_WH';

-- If these queries show no results, cleanup was successful!

/*****************************************************
 * CLEANUP COMPLETE!
 * 
 * All objects from the Snowflake Basics Lab have
 * been removed from your Snowflake account.
 * 
 * You can restart the lab by:
 * 1. Executing setup_basics_lab.sql
 * 2. Re-uploading the data files
 * 3. Redoing the exercises
 *****************************************************/

SELECT '✅ Cleanup complete! All lab objects have been deleted.' as status;
