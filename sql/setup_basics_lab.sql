/*****************************************************
 * SNOWFLAKE BASICS LAB - SETUP SCRIPT
 * 
 * This script sets up the complete environment for the
 * Snowflake Basics Lab including:
 * - Database
 * - Schemas  
 * - Warehouse
 * - Stages
 * - Tables (Star Schema)
 * 
 * Estimated execution time: 1-2 minutes
 *****************************************************/

-- Use the SYSADMIN role (has sufficient privileges for this lab)
USE ROLE SYSADMIN;

/*****************************************************
 * STEP 1: CREATE DATABASE
 *****************************************************/

-- Create the database for this lab
CREATE DATABASE IF NOT EXISTS BASICS_LAB_DB
    COMMENT = 'Database for Snowflake Basics Lab - Hands-on exercises';

-- Use the new database
USE DATABASE BASICS_LAB_DB;

/*****************************************************
 * STEP 2: CREATE SCHEMAS
 *****************************************************/

-- Schema for staging data (temporary data from stages)
CREATE SCHEMA IF NOT EXISTS STAGING
    COMMENT = 'Schema for staging data during data loading process';

-- Schema for data warehouse tables (star schema)
CREATE SCHEMA IF NOT EXISTS DWH
    COMMENT = 'Schema for data warehouse tables (star schema)';

-- Schema for analytical views and transformations
CREATE SCHEMA IF NOT EXISTS ANALYTICS
    COMMENT = 'Schema for analytical views and transformed data';

/*****************************************************
 * STEP 3: CREATE WAREHOUSE
 *****************************************************/

-- Create a warehouse for this lab
-- Size: X-SMALL (suitable for learning and testing)
CREATE WAREHOUSE IF NOT EXISTS BASICS_LAB_WH
    WITH 
    WAREHOUSE_SIZE = 'X-SMALL'
    AUTO_SUSPEND = 300          -- Automatically suspend after 5 minutes of inactivity
    AUTO_RESUME = TRUE          -- Automatically start on new query
    INITIALLY_SUSPENDED = FALSE -- Available immediately
    COMMENT = 'Warehouse for Snowflake Basics Lab exercises';

-- Use the warehouse
USE WAREHOUSE BASICS_LAB_WH;

/*****************************************************
 * STEP 4: CREATE STAGES
 *****************************************************/

-- Use the STAGING schema for stages
USE SCHEMA STAGING;

-- Stage for CSV files
CREATE STAGE IF NOT EXISTS CSV_STAGE
    FILE_FORMAT = (
        TYPE = 'CSV'
        FIELD_DELIMITER = ','
        SKIP_HEADER = 1
        FIELD_OPTIONALLY_ENCLOSED_BY = '"'
        TRIM_SPACE = TRUE
        ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE
        EMPTY_FIELD_AS_NULL = TRUE
        DATE_FORMAT = 'YYYY-MM-DD'
    )
    COMMENT = 'Internal stage for CSV data files';

-- Stage for JSON files
CREATE STAGE IF NOT EXISTS JSON_STAGE
    FILE_FORMAT = (
        TYPE = 'JSON'
        STRIP_OUTER_ARRAY = TRUE
        STRIP_NULL_VALUES = FALSE
    )
    COMMENT = 'Internal stage for JSON data files';

/*****************************************************
 * STEP 5: CREATE DIMENSION TABLES (STAR SCHEMA)
 *****************************************************/

-- Use the DWH schema for our star schema
USE SCHEMA DWH;

-- Dimension: DATE (Time Dimension)
-- Contains calendar information for time-based analyses
CREATE TABLE IF NOT EXISTS DIM_DATE (
    date_key        INTEGER PRIMARY KEY,    -- Surrogate key: YYYYMMDD format
    full_date       DATE NOT NULL,           -- Full date
    year            INTEGER NOT NULL,        -- Year (e.g., 2024)
    quarter         INTEGER NOT NULL,        -- Quarter (1-4)
    month           INTEGER NOT NULL,        -- Month (1-12)
    month_name      VARCHAR(20),             -- Month name (e.g., 'January')
    day_of_month    INTEGER NOT NULL,        -- Day of month (1-31)
    day_of_week     INTEGER NOT NULL,        -- Day of week (1=Sunday, 7=Saturday)
    day_name        VARCHAR(20),             -- Day name (e.g., 'Monday')
    week_of_year    INTEGER,                 -- Week number (1-53)
    is_weekend      BOOLEAN,                 -- TRUE if weekend, FALSE otherwise
    is_holiday      BOOLEAN DEFAULT FALSE,   -- TRUE if holiday
    COMMENT         = 'Date dimension for time-based analyses'
);

-- Dimension: PRODUCT
-- Contains product information
CREATE TABLE IF NOT EXISTS DIM_PRODUCT (
    product_key     INTEGER PRIMARY KEY,     -- Surrogate key
    product_id      VARCHAR(50) NOT NULL,    -- Business key
    product_name    VARCHAR(200) NOT NULL,   -- Product name
    category        VARCHAR(100),            -- Product category
    subcategory     VARCHAR(100),            -- Product subcategory
    brand           VARCHAR(100),            -- Brand
    unit_price      NUMBER(10,2),            -- Price per unit
    unit_cost       NUMBER(10,2),            -- Cost per unit
    COMMENT         = 'Product dimension with product details'
);

-- Dimension: CUSTOMER
-- Contains customer information
CREATE TABLE IF NOT EXISTS DIM_CUSTOMER (
    customer_key    INTEGER PRIMARY KEY,     -- Surrogate key
    customer_id     VARCHAR(50) NOT NULL,    -- Business key
    first_name      VARCHAR(100),            -- First name
    last_name       VARCHAR(100),            -- Last name
    email           VARCHAR(200),            -- Email address
    city            VARCHAR(100),            -- City
    country         VARCHAR(100),            -- Country
    customer_segment VARCHAR(50),            -- Segment (e.g., 'Premium', 'Regular')
    registration_date DATE,                  -- Registration date
    COMMENT         = 'Customer dimension with customer information'
);

-- Dimension: STORE
-- Contains store/location information
CREATE TABLE IF NOT EXISTS DIM_STORE (
    store_key       INTEGER PRIMARY KEY,     -- Surrogate key
    store_id        VARCHAR(50) NOT NULL,    -- Business key
    store_name      VARCHAR(200),            -- Store name
    city            VARCHAR(100),            -- City
    state           VARCHAR(100),            -- Province/State
    country         VARCHAR(100),            -- Country
    region          VARCHAR(100),            -- Region
    store_type      VARCHAR(50),             -- Store type (e.g., 'Retail', 'Online')
    opening_date    DATE,                    -- Opening date
    COMMENT         = 'Store dimension with location information'
);

/*****************************************************
 * STEP 6: CREATE FACT TABLE (STAR SCHEMA)
 *****************************************************/

-- Fact: SALES (Sales transactions)
-- Central table with measurable business events
CREATE TABLE IF NOT EXISTS FACT_SALES (
    sales_key       INTEGER AUTOINCREMENT PRIMARY KEY,  -- Surrogate key
    date_key        INTEGER NOT NULL,        -- Foreign key to DIM_DATE
    product_key     INTEGER NOT NULL,        -- Foreign key to DIM_PRODUCT
    customer_key    INTEGER NOT NULL,        -- Foreign key to DIM_CUSTOMER
    store_key       INTEGER NOT NULL,        -- Foreign key to DIM_STORE
    quantity        INTEGER NOT NULL,        -- Number of items sold
    unit_price      NUMBER(10,2),            -- Sales price per unit
    unit_cost       NUMBER(10,2),            -- Cost price per unit
    discount_amount NUMBER(10,2) DEFAULT 0,  -- Discount amount
    sales_amount    NUMBER(12,2),            -- Total sales amount
    cost_amount     NUMBER(12,2),            -- Total cost
    profit_amount   NUMBER(12,2),            -- Profit (sales - cost)
    COMMENT         = 'Sales fact table with transaction measurements',
    -- Foreign key constraints (optional in Snowflake, mainly for documentation)
    CONSTRAINT fk_date FOREIGN KEY (date_key) REFERENCES DIM_DATE(date_key),
    CONSTRAINT fk_product FOREIGN KEY (product_key) REFERENCES DIM_PRODUCT(product_key),
    CONSTRAINT fk_customer FOREIGN KEY (customer_key) REFERENCES DIM_CUSTOMER(customer_key),
    CONSTRAINT fk_store FOREIGN KEY (store_key) REFERENCES DIM_STORE(store_key)
);

/*****************************************************
 * STEP 7: CREATE JSON TABLE
 *****************************************************/

-- Table for semi-structured data (JSON)
CREATE TABLE IF NOT EXISTS PRODUCTS_JSON (
    product_data VARIANT,           -- VARIANT type can store JSON, XML, Avro, etc.
    loaded_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    COMMENT = 'Table with JSON product data for semi-structured data exercises'
);

/*****************************************************
 * STEP 8: VERIFICATION
 *****************************************************/

-- Show all created objects
SHOW DATABASES LIKE 'BASICS_LAB_DB';
SHOW SCHEMAS IN DATABASE BASICS_LAB_DB;
SHOW WAREHOUSES LIKE 'BASICS_LAB_WH';
SHOW STAGES IN SCHEMA BASICS_LAB_DB.STAGING;
SHOW TABLES IN SCHEMA BASICS_LAB_DB.DWH;

/*****************************************************
 * SETUP COMPLETE!
 * 
 * Next steps:
 * 1. Upload CSV files to CSV_STAGE
 * 2. Upload JSON file to JSON_STAGE
 * 3. Open exercises.sql and start the exercises
 *****************************************************/

-- Information message
SELECT 'Setup complete! You can now upload data to the stages.' AS status_message;
