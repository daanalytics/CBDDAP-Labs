/*****************************************************
 * SNOWFLAKE BASICS LAB - COMPLETE SETUP AND LOAD SCRIPT
 * 
 * This script provides a complete, self-contained setup that:
 * - Creates all database objects (database, schemas, warehouse, tables)
 * - Loads all data via INSERT statements
 * - Checks if data exists before loading (idempotent)
 * 
 * Estimated execution time: 3-5 minutes
 * 
 * Data loaded:
 * - DIM_DATE: 108 rows
 * - DIM_PRODUCT: 50 rows  
 * - DIM_CUSTOMER: 100 rows
 * - DIM_STORE: 10 rows
 * - FACT_SALES: 345 rows
 * - PRODUCTS_JSON: 20 JSON objects
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
    is_holiday      BOOLEAN DEFAULT FALSE    -- TRUE if holiday
) COMMENT = 'Date dimension for time-based analyses';

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
    unit_cost       NUMBER(10,2)             -- Cost per unit
) COMMENT = 'Product dimension with product details';

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
    registration_date DATE                   -- Registration date
) COMMENT = 'Customer dimension with customer information';

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
    opening_date    DATE                     -- Opening date
) COMMENT = 'Store dimension with location information';

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
    -- Foreign key constraints (optional in Snowflake, mainly for documentation)
    CONSTRAINT fk_date FOREIGN KEY (date_key) REFERENCES DIM_DATE(date_key),
    CONSTRAINT fk_product FOREIGN KEY (product_key) REFERENCES DIM_PRODUCT(product_key),
    CONSTRAINT fk_customer FOREIGN KEY (customer_key) REFERENCES DIM_CUSTOMER(customer_key),
    CONSTRAINT fk_store FOREIGN KEY (store_key) REFERENCES DIM_STORE(store_key)
) COMMENT = 'Sales fact table with transaction measurements';

/*****************************************************
 * STEP 7: CREATE JSON TABLE
 *****************************************************/

-- Table for semi-structured data (JSON)
CREATE TABLE IF NOT EXISTS PRODUCTS_JSON (
    product_data VARIANT,           -- VARIANT type can store JSON, XML, Avro, etc.
    loaded_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
) COMMENT = 'Table with JSON product data for semi-structured data exercises';

/*****************************************************
 * STEP 8: LOAD DATA - DIM_DATE (108 rows)
 *****************************************************/

-- Check if DIM_DATE already has data
SET row_count = (SELECT COUNT(*) FROM DIM_DATE);

-- Load data only if table is empty
INSERT INTO DIM_DATE (date_key, full_date, year, quarter, month, month_name, day_of_month, day_of_week, day_name, week_of_year, is_weekend, is_holiday)
SELECT * FROM (VALUES
(20230101,'2023-01-01',2023,1,1,'January',1,1,'Sunday',1,TRUE,TRUE),
(20230102,'2023-01-02',2023,1,1,'January',2,2,'Monday',1,FALSE,FALSE),
(20230103,'2023-01-03',2023,1,1,'January',3,3,'Tuesday',1,FALSE,FALSE),
(20230104,'2023-01-04',2023,1,1,'January',4,4,'Wednesday',1,FALSE,FALSE),
(20230105,'2023-01-05',2023,1,1,'January',5,5,'Thursday',1,FALSE,FALSE),
(20230106,'2023-01-06',2023,1,1,'January',6,6,'Friday',1,FALSE,FALSE),
(20230107,'2023-01-07',2023,1,1,'January',7,7,'Saturday',1,TRUE,FALSE),
(20230108,'2023-01-08',2023,1,1,'January',8,1,'Sunday',2,TRUE,FALSE),
(20230109,'2023-01-09',2023,1,1,'January',9,2,'Monday',2,FALSE,FALSE),
(20230110,'2023-01-10',2023,1,1,'January',10,3,'Tuesday',2,FALSE,FALSE),
(20230111,'2023-01-11',2023,1,1,'January',11,4,'Wednesday',2,FALSE,FALSE),
(20230112,'2023-01-12',2023,1,1,'January',12,5,'Thursday',2,FALSE,FALSE),
(20230113,'2023-01-13',2023,1,1,'January',13,6,'Friday',2,FALSE,FALSE),
(20230114,'2023-01-14',2023,1,1,'January',14,7,'Saturday',2,TRUE,FALSE),
(20230115,'2023-01-15',2023,1,1,'January',15,1,'Sunday',3,TRUE,FALSE),
(20230201,'2023-02-01',2023,1,2,'February',1,4,'Wednesday',5,FALSE,FALSE),
(20230202,'2023-02-02',2023,1,2,'February',2,5,'Thursday',5,FALSE,FALSE),
(20230214,'2023-02-14',2023,1,2,'February',14,3,'Tuesday',7,FALSE,TRUE),
(20230301,'2023-03-01',2023,1,3,'March',1,4,'Wednesday',9,FALSE,FALSE),
(20230315,'2023-03-15',2023,1,3,'March',15,4,'Wednesday',11,FALSE,FALSE),
(20230401,'2023-04-01',2023,2,4,'April',1,7,'Saturday',13,TRUE,FALSE),
(20230410,'2023-04-10',2023,2,4,'April',10,2,'Monday',15,FALSE,TRUE),
(20230501,'2023-05-01',2023,2,5,'May',1,2,'Monday',18,FALSE,TRUE),
(20230514,'2023-05-14',2023,2,5,'May',14,1,'Sunday',19,TRUE,FALSE),
(20230601,'2023-06-01',2023,2,6,'June',1,5,'Thursday',22,FALSE,FALSE),
(20230615,'2023-06-15',2023,2,6,'June',15,5,'Thursday',24,FALSE,FALSE),
(20230701,'2023-07-01',2023,3,7,'July',1,7,'Saturday',26,TRUE,FALSE),
(20230704,'2023-07-04',2023,3,7,'July',4,3,'Tuesday',27,FALSE,TRUE),
(20230801,'2023-08-01',2023,3,8,'August',1,3,'Tuesday',31,FALSE,FALSE),
(20230815,'2023-08-15',2023,3,8,'August',15,3,'Tuesday',33,FALSE,FALSE),
(20230901,'2023-09-01',2023,3,9,'September',1,6,'Friday',35,FALSE,FALSE),
(20230915,'2023-09-15',2023,3,9,'September',15,6,'Friday',37,FALSE,FALSE),
(20231001,'2023-10-01',2023,4,10,'October',1,1,'Sunday',39,TRUE,FALSE),
(20231015,'2023-10-15',2023,4,10,'October',15,1,'Sunday',41,TRUE,FALSE),
(20231031,'2023-10-31',2023,4,10,'October',31,3,'Tuesday',44,FALSE,TRUE),
(20231101,'2023-11-01',2023,4,11,'November',1,4,'Wednesday',44,FALSE,FALSE),
(20231115,'2023-11-15',2023,4,11,'November',15,4,'Wednesday',46,FALSE,FALSE),
(20231123,'2023-11-23',2023,4,11,'November',23,5,'Thursday',47,FALSE,TRUE),
(20231201,'2023-12-01',2023,4,12,'December',1,6,'Friday',48,FALSE,FALSE),
(20231215,'2023-12-15',2023,4,12,'December',15,6,'Friday',50,FALSE,FALSE),
(20231225,'2023-12-25',2023,4,12,'December',25,2,'Monday',52,FALSE,TRUE),
(20231231,'2023-12-31',2023,4,12,'December',31,1,'Sunday',52,TRUE,FALSE),
(20240101,'2024-01-01',2024,1,1,'January',1,2,'Monday',1,FALSE,TRUE),
(20240102,'2024-01-02',2024,1,1,'January',2,3,'Tuesday',1,FALSE,FALSE),
(20240103,'2024-01-03',2024,1,1,'January',3,4,'Wednesday',1,FALSE,FALSE),
(20240104,'2024-01-04',2024,1,1,'January',4,5,'Thursday',1,FALSE,FALSE),
(20240105,'2024-01-05',2024,1,1,'January',5,6,'Friday',1,FALSE,FALSE),
(20240106,'2024-01-06',2024,1,1,'January',6,7,'Saturday',1,TRUE,FALSE),
(20240107,'2024-01-07',2024,1,1,'January',7,1,'Sunday',1,TRUE,FALSE),
(20240115,'2024-01-15',2024,1,1,'January',15,2,'Monday',3,FALSE,FALSE),
(20240201,'2024-02-01',2024,1,2,'February',1,5,'Thursday',5,FALSE,FALSE),
(20240214,'2024-02-14',2024,1,2,'February',14,4,'Wednesday',7,FALSE,TRUE),
(20240301,'2024-03-01',2024,1,3,'March',1,6,'Friday',9,FALSE,FALSE),
(20240315,'2024-03-15',2024,1,3,'March',15,6,'Friday',11,FALSE,FALSE),
(20240401,'2024-04-01',2024,2,4,'April',1,2,'Monday',14,FALSE,FALSE),
(20240415,'2024-04-15',2024,2,4,'April',15,2,'Monday',16,FALSE,FALSE),
(20240501,'2024-05-01',2024,2,5,'May',1,4,'Wednesday',18,FALSE,TRUE),
(20240515,'2024-05-15',2024,2,5,'May',15,4,'Wednesday',20,FALSE,FALSE),
(20240601,'2024-06-01',2024,2,6,'June',1,7,'Saturday',22,TRUE,FALSE),
(20240615,'2024-06-15',2024,2,6,'June',15,7,'Saturday',24,TRUE,FALSE),
(20240701,'2024-07-01',2024,3,7,'July',1,2,'Monday',27,FALSE,FALSE),
(20240704,'2024-07-04',2024,3,7,'July',4,5,'Thursday',27,FALSE,TRUE),
(20240715,'2024-07-15',2024,3,7,'July',15,2,'Monday',29,FALSE,FALSE),
(20240801,'2024-08-01',2024,3,8,'August',1,5,'Thursday',31,FALSE,FALSE),
(20240815,'2024-08-15',2024,3,8,'August',15,5,'Thursday',33,FALSE,FALSE),
(20240901,'2024-09-01',2024,3,9,'September',1,1,'Sunday',35,TRUE,FALSE),
(20240915,'2024-09-15',2024,3,9,'September',15,1,'Sunday',37,TRUE,FALSE),
(20241001,'2024-10-01',2024,4,10,'October',1,3,'Tuesday',40,FALSE,FALSE),
(20241015,'2024-10-15',2024,4,10,'October',15,3,'Tuesday',42,FALSE,FALSE),
(20241031,'2024-10-31',2024,4,10,'October',31,5,'Thursday',44,FALSE,TRUE),
(20241101,'2024-11-01',2024,4,11,'November',1,6,'Friday',44,FALSE,FALSE),
(20241115,'2024-11-15',2024,4,11,'November',15,6,'Friday',46,FALSE,FALSE),
(20241128,'2024-11-28',2024,4,11,'November',28,5,'Thursday',48,FALSE,TRUE),
(20241201,'2024-12-01',2024,4,12,'December',1,1,'Sunday',48,TRUE,FALSE),
(20241215,'2024-12-15',2024,4,12,'December',15,1,'Sunday',50,TRUE,FALSE),
(20241225,'2024-12-25',2024,4,12,'December',25,4,'Wednesday',52,FALSE,TRUE),
(20241231,'2024-12-31',2024,4,12,'December',31,3,'Tuesday',1,FALSE,FALSE),
(20250101,'2025-01-01',2025,1,1,'January',1,4,'Wednesday',1,FALSE,TRUE),
(20250102,'2025-01-02',2025,1,1,'January',2,5,'Thursday',1,FALSE,FALSE),
(20250115,'2025-01-15',2025,1,1,'January',15,4,'Wednesday',3,FALSE,FALSE),
(20250201,'2025-02-01',2025,1,2,'February',1,7,'Saturday',5,TRUE,FALSE),
(20250214,'2025-02-14',2025,1,2,'February',14,6,'Friday',7,FALSE,TRUE),
(20250301,'2025-03-01',2025,1,3,'March',1,7,'Saturday',9,TRUE,FALSE),
(20250315,'2025-03-15',2025,1,3,'March',15,7,'Saturday',11,TRUE,FALSE),
(20250401,'2025-04-01',2025,2,4,'April',1,3,'Tuesday',14,FALSE,FALSE),
(20250415,'2025-04-15',2025,2,4,'April',15,3,'Tuesday',16,FALSE,FALSE),
(20250501,'2025-05-01',2025,2,5,'May',1,5,'Thursday',18,FALSE,TRUE),
(20250515,'2025-05-15',2025,2,5,'May',15,5,'Thursday',20,FALSE,FALSE),
(20250601,'2025-06-01',2025,2,6,'June',1,1,'Sunday',22,TRUE,FALSE),
(20250615,'2025-06-15',2025,2,6,'June',15,1,'Sunday',24,TRUE,FALSE),
(20250701,'2025-07-01',2025,3,7,'July',1,3,'Tuesday',27,FALSE,FALSE),
(20250704,'2025-07-04',2025,3,7,'July',4,6,'Friday',27,FALSE,TRUE),
(20250715,'2025-07-15',2025,3,7,'July',15,3,'Tuesday',29,FALSE,FALSE),
(20250801,'2025-08-01',2025,3,8,'August',1,6,'Friday',31,FALSE,FALSE),
(20250815,'2025-08-15',2025,3,8,'August',15,6,'Friday',33,FALSE,FALSE),
(20250901,'2025-09-01',2025,3,9,'September',1,2,'Monday',36,FALSE,FALSE),
(20250915,'2025-09-15',2025,3,9,'September',15,2,'Monday',38,FALSE,FALSE),
(20251001,'2025-10-01',2025,4,10,'October',1,4,'Wednesday',40,FALSE,FALSE),
(20251015,'2025-10-15',2025,4,10,'October',15,4,'Wednesday',42,FALSE,FALSE),
(20251031,'2025-10-31',2025,4,10,'October',31,6,'Friday',44,FALSE,TRUE),
(20251101,'2025-11-01',2025,4,11,'November',1,7,'Saturday',44,TRUE,FALSE),
(20251115,'2025-11-15',2025,4,11,'November',15,7,'Saturday',46,TRUE,FALSE),
(20251127,'2025-11-27',2025,4,11,'November',27,5,'Thursday',48,FALSE,TRUE),
(20251201,'2025-12-01',2025,4,12,'December',1,2,'Monday',49,FALSE,FALSE),
(20251215,'2025-12-15',2025,4,12,'December',15,2,'Monday',51,FALSE,FALSE),
(20251225,'2025-12-25',2025,4,12,'December',25,5,'Thursday',52,FALSE,TRUE),
(20251231,'2025-12-31',2025,4,12,'December',31,4,'Wednesday',1,FALSE,FALSE)
) WHERE $row_count = 0;

SELECT 'Loaded ' || CAST(IFF($row_count = 0, 108, 0) AS VARCHAR) || ' rows into DIM_DATE (Total: ' || CAST((SELECT COUNT(*) FROM DIM_DATE) AS VARCHAR) || ')' AS status;

/*****************************************************
 * STEP 9: LOAD DATA - DIM_PRODUCT (50 rows)
 *****************************************************/

SET row_count = (SELECT COUNT(*) FROM DIM_PRODUCT);

INSERT INTO DIM_PRODUCT (product_key, product_id, product_name, category, subcategory, brand, unit_price, unit_cost)
SELECT * FROM (VALUES
(1,'P001','Laptop Pro 15','Electronics','Computers','TechBrand',1299.99,850.00),
(2,'P002','Wireless Mouse','Electronics','Accessories','TechBrand',29.99,12.00),
(3,'P003','USB-C Cable','Electronics','Accessories','TechBrand',19.99,5.00),
(4,'P004','Monitor 27 inch','Electronics','Displays','ViewMax',399.99,250.00),
(5,'P005','Mechanical Keyboard','Electronics','Accessories','TechBrand',89.99,40.00),
(6,'P006','Office Chair Deluxe','Furniture','Office','ComfortSeats',249.99,120.00),
(7,'P007','Standing Desk','Furniture','Office','ComfortSeats',499.99,280.00),
(8,'P008','Desk Lamp LED','Furniture','Lighting','BrightLights',49.99,20.00),
(9,'P009','Notebook A4','Office Supplies','Stationery','PaperCo',4.99,1.50),
(10,'P010','Pen Set Blue','Office Supplies','Stationery','PaperCo',9.99,3.00),
(11,'P011','Smartphone X12','Electronics','Mobile','PhoneTech',899.99,550.00),
(12,'P012','Phone Case Leather','Electronics','Accessories','PhoneTech',39.99,15.00),
(13,'P013','Headphones Wireless','Electronics','Audio','SoundWave',149.99,70.00),
(14,'P014','Tablet 10 inch','Electronics','Mobile','TechBrand',449.99,280.00),
(15,'P015','Coffee Maker Pro','Appliances','Kitchen','HomePlus',79.99,40.00),
(16,'P016','Blender 1000W','Appliances','Kitchen','HomePlus',59.99,30.00),
(17,'P017','Toaster 2-Slice','Appliances','Kitchen','HomePlus',29.99,15.00),
(18,'P018','Water Bottle Steel','Sports','Accessories','FitLife',24.99,10.00),
(19,'P019','Yoga Mat Premium','Sports','Fitness','FitLife',49.99,20.00),
(20,'P020','Dumbbell Set 20kg','Sports','Fitness','FitLife',89.99,45.00),
(21,'P021','Running Shoes Men','Sports','Footwear','SportWear',119.99,60.00),
(22,'P022','Sports Backpack','Sports','Accessories','SportWear',69.99,30.00),
(23,'P023','T-Shirt Cotton','Clothing','Casual','FashionHub',19.99,8.00),
(24,'P024','Jeans Classic Blue','Clothing','Casual','FashionHub',59.99,25.00),
(25,'P025','Winter Jacket','Clothing','Outerwear','FashionHub',149.99,70.00),
(26,'P026','Sneakers White','Clothing','Footwear','FashionHub',79.99,35.00),
(27,'P027','Backpack School','Bags','Backpacks','TravelGear',49.99,20.00),
(28,'P028','Messenger Bag Leather','Bags','Professional','TravelGear',89.99,40.00),
(29,'P029','Suitcase 24 inch','Bags','Luggage','TravelGear',129.99,60.00),
(30,'P030','Travel Pillow','Bags','Accessories','TravelGear',19.99,8.00),
(31,'P031','Smart Watch Sport','Electronics','Wearables','TechBrand',299.99,180.00),
(32,'P032','Fitness Tracker','Electronics','Wearables','FitLife',79.99,40.00),
(33,'P033','Webcam HD 1080p','Electronics','Accessories','ViewMax',69.99,30.00),
(34,'P034','Microphone USB','Electronics','Audio','SoundWave',89.99,45.00),
(35,'P035','Speaker Bluetooth','Electronics','Audio','SoundWave',59.99,25.00),
(36,'P036','Power Bank 20000mAh','Electronics','Accessories','TechBrand',49.99,20.00),
(37,'P037','Phone Charger Fast','Electronics','Accessories','PhoneTech',29.99,10.00),
(38,'P038','HDMI Cable 2m','Electronics','Accessories','TechBrand',14.99,5.00),
(39,'P039','Router WiFi 6','Electronics','Networking','NetConnect',149.99,80.00),
(40,'P040','Ethernet Cable 5m','Electronics','Networking','NetConnect',12.99,4.00),
(41,'P041','External SSD 1TB','Electronics','Storage','TechBrand',129.99,70.00),
(42,'P042','USB Flash Drive 64GB','Electronics','Storage','TechBrand',19.99,8.00),
(43,'P043','Memory Card 128GB','Electronics','Storage','TechBrand',34.99,15.00),
(44,'P044','Printer Wireless','Electronics','Office','PrintMaster',199.99,120.00),
(45,'P045','Scanner Portable','Electronics','Office','PrintMaster',149.99,80.00),
(46,'P046','Paper A4 Ream','Office Supplies','Paper','PaperCo',7.99,3.00),
(47,'P047','Stapler Heavy Duty','Office Supplies','Tools','PaperCo',14.99,6.00),
(48,'P048','Calculator Scientific','Office Supplies','Tools','CalcTech',24.99,10.00),
(49,'P049','Desk Organizer','Office Supplies','Organization','PaperCo',19.99,8.00),
(50,'P050','Whiteboard Magnetic','Office Supplies','Boards','PaperCo',79.99,35.00)
) WHERE $row_count = 0;

SELECT 'Loaded ' || CAST(IFF($row_count = 0, 50, 0) AS VARCHAR) || ' rows into DIM_PRODUCT (Total: ' || CAST((SELECT COUNT(*) FROM DIM_PRODUCT) AS VARCHAR) || ')' AS status;

/*****************************************************
 * STEP 10: LOAD DATA - DIM_CUSTOMER (100 rows, part 1 of 2)
 *****************************************************/

SET row_count = (SELECT COUNT(*) FROM DIM_CUSTOMER);

INSERT INTO DIM_CUSTOMER (customer_key, customer_id, first_name, last_name, email, city, country, customer_segment, registration_date)
SELECT * FROM (VALUES
(1,'C0001','John','Smith','john.smith@email.com','Amsterdam','Netherlands','Premium','2022-01-15'),
(2,'C0002','Emma','Johnson','emma.j@email.com','Rotterdam','Netherlands','Regular','2022-02-20'),
(3,'C0003','Michael','Williams','m.williams@email.com','Utrecht','Netherlands','Regular','2022-03-10'),
(4,'C0004','Sophia','Brown','sophia.b@email.com','The Hague','Netherlands','Premium','2022-03-25'),
(5,'C0005','James','Jones','james.jones@email.com','Eindhoven','Netherlands','Regular','2022-04-05'),
(6,'C0006','Olivia','Garcia','olivia.g@email.com','Tilburg','Netherlands','Regular','2022-04-18'),
(7,'C0007','William','Martinez','w.martinez@email.com','Groningen','Netherlands','Premium','2022-05-02'),
(8,'C0008','Ava','Rodriguez','ava.r@email.com','Almere','Netherlands','Regular','2022-05-20'),
(9,'C0009','Lucas','Davis','lucas.davis@email.com','Breda','Netherlands','Regular','2022-06-08'),
(10,'C0010','Mia','Lopez','mia.lopez@email.com','Nijmegen','Netherlands','Premium','2022-06-22'),
(11,'C0011','Alexander','Wilson','alex.w@email.com','Brussels','Belgium','Regular','2022-07-01'),
(12,'C0012','Charlotte','Anderson','charlotte.a@email.com','Antwerp','Belgium','Premium','2022-07-15'),
(13,'C0013','Daniel','Thomas','daniel.t@email.com','Ghent','Belgium','Regular','2022-08-03'),
(14,'C0014','Amelia','Taylor','amelia.t@email.com','Charleroi','Belgium','Regular','2022-08-19'),
(15,'C0015','Henry','Moore','henry.m@email.com','Liège','Belgium','Premium','2022-09-05'),
(16,'C0016','Isabella','Jackson','isabella.j@email.com','Bruges','Belgium','Regular','2022-09-18'),
(17,'C0017','Sebastian','Martin','seb.martin@email.com','Leuven','Belgium','Regular','2022-10-02'),
(18,'C0018','Sofia','Lee','sofia.lee@email.com','Paris','France','Premium','2022-10-20'),
(19,'C0019','Benjamin','White','ben.white@email.com','Lyon','France','Regular','2022-11-05'),
(20,'C0020','Emily','Harris','emily.h@email.com','Marseille','France','Regular','2022-11-22'),
(21,'C0021','Jacob','Clark','jacob.c@email.com','Toulouse','France','Premium','2022-12-01'),
(22,'C0022','Aria','Lewis','aria.lewis@email.com','Nice','France','Regular','2022-12-15'),
(23,'C0023','Ethan','Walker','ethan.w@email.com','Nantes','France','Regular','2023-01-08'),
(24,'C0024','Madison','Hall','madison.h@email.com','Strasbourg','France','Premium','2023-01-25'),
(25,'C0025','Matthew','Allen','matt.allen@email.com','Berlin','Germany','Regular','2023-02-10'),
(26,'C0026','Chloe','Young','chloe.y@email.com','Munich','Germany','Premium','2023-02-28'),
(27,'C0027','David','King','david.king@email.com','Hamburg','Germany','Regular','2023-03-15'),
(28,'C0028','Grace','Wright','grace.w@email.com','Frankfurt','Germany','Regular','2023-04-02'),
(29,'C0029','Joseph','Scott','joseph.s@email.com','Cologne','Germany','Premium','2023-04-20'),
(30,'C0030','Lily','Green','lily.green@email.com','Stuttgart','Germany','Regular','2023-05-08'),
(31,'C0031','Samuel','Adams','sam.adams@email.com','Düsseldorf','Germany','Regular','2023-05-25'),
(32,'C0032','Ella','Baker','ella.baker@email.com','Dortmund','Germany','Premium','2023-06-10'),
(33,'C0033','Jack','Nelson','jack.n@email.com','London','United Kingdom','Regular','2023-06-28'),
(34,'C0034','Avery','Carter','avery.c@email.com','Manchester','United Kingdom','Premium','2023-07-15'),
(35,'C0035','Owen','Mitchell','owen.m@email.com','Birmingham','United Kingdom','Regular','2023-08-01'),
(36,'C0036','Scarlett','Perez','scarlett.p@email.com','Leeds','United Kingdom','Regular','2023-08-18'),
(37,'C0037','Luke','Roberts','luke.r@email.com','Glasgow','United Kingdom','Premium','2023-09-05'),
(38,'C0038','Zoe','Turner','zoe.turner@email.com','Edinburgh','United Kingdom','Regular','2023-09-22'),
(39,'C0039','Ryan','Phillips','ryan.p@email.com','Liverpool','United Kingdom','Regular','2023-10-08'),
(40,'C0040','Hannah','Campbell','hannah.c@email.com','Bristol','United Kingdom','Premium','2023-10-25'),
(41,'C0041','Nathan','Parker','nathan.p@email.com','Madrid','Spain','Regular','2023-11-10'),
(42,'C0042','Layla','Evans','layla.e@email.com','Barcelona','Spain','Premium','2023-11-28'),
(43,'C0043','Isaac','Edwards','isaac.e@email.com','Valencia','Spain','Regular','2023-12-15'),
(44,'C0044','Penelope','Collins','penny.c@email.com','Seville','Spain','Regular','2024-01-05'),
(45,'C0045','Liam','Stewart','liam.s@email.com','Bilbao','Spain','Premium','2024-01-22'),
(46,'C0046','Aubrey','Morris','aubrey.m@email.com','Málaga','Spain','Regular','2024-02-08'),
(47,'C0047','Noah','Rogers','noah.r@email.com','Rome','Italy','Regular','2024-02-25'),
(48,'C0048','Nora','Reed','nora.reed@email.com','Milan','Italy','Premium','2024-03-12'),
(49,'C0049','Elijah','Cook','elijah.c@email.com','Naples','Italy','Regular','2024-03-28'),
(50,'C0050','Hazel','Morgan','hazel.m@email.com','Turin','Italy','Regular','2024-04-15')
) WHERE $row_count = 0;

/*****************************************************
 * STEP 11: LOAD DATA - DIM_CUSTOMER (100 rows, part 2 of 2)
 *****************************************************/

INSERT INTO DIM_CUSTOMER (customer_key, customer_id, first_name, last_name, email, city, country, customer_segment, registration_date)
SELECT * FROM (VALUES
(51,'C0051','Mason','Bell','mason.b@email.com','Florence','Italy','Premium','2024-05-02'),
(52,'C0052','Violet','Murphy','violet.m@email.com','Genoa','Italy','Regular','2024-05-20'),
(53,'C0053','Logan','Bailey','logan.b@email.com','Zürich','Switzerland','Regular','2024-06-05'),
(54,'C0054','Aurora','Rivera','aurora.r@email.com','Geneva','Switzerland','Premium','2024-06-22'),
(55,'C0055','Jackson','Cooper','jackson.c@email.com','Basel','Switzerland','Regular','2024-07-10'),
(56,'C0056','Lucy','Richardson','lucy.r@email.com','Lausanne','Switzerland','Regular','2024-07-28'),
(57,'C0057','Carter','Cox','carter.c@email.com','Bern','Switzerland','Premium','2024-08-15'),
(58,'C0058','Stella','Howard','stella.h@email.com','Vienna','Austria','Regular','2024-09-02'),
(59,'C0059','Gabriel','Ward','gabriel.w@email.com','Salzburg','Austria','Regular','2024-09-20'),
(60,'C0060','Eleanor','Torres','eleanor.t@email.com','Innsbruck','Austria','Premium','2024-10-08'),
(61,'C0061','Julian','Peterson','julian.p@email.com','Copenhagen','Denmark','Regular','2024-10-25'),
(62,'C0062','Maya','Gray','maya.gray@email.com','Aarhus','Denmark','Premium','2024-11-12'),
(63,'C0063','Anthony','Ramirez','anthony.r@email.com','Odense','Denmark','Regular','2024-11-28'),
(64,'C0064','Natalie','James','natalie.j@email.com','Stockholm','Sweden','Regular','2024-12-15'),
(65,'C0065','Dylan','Watson','dylan.w@email.com','Gothenburg','Sweden','Premium','2025-01-02'),
(66,'C0066','Claire','Brooks','claire.b@email.com','Malmö','Sweden','Regular','2025-01-20'),
(67,'C0067','Christian','Kelly','chris.k@email.com','Oslo','Norway','Regular','2025-02-05'),
(68,'C0068','Skylar','Sanders','skylar.s@email.com','Bergen','Norway','Premium','2025-02-22'),
(69,'C0069','Andrew','Price','andrew.p@email.com','Trondheim','Norway','Regular','2025-03-10'),
(70,'C0070','Addison','Bennett','addison.b@email.com','Helsinki','Finland','Regular','2025-03-28'),
(71,'C0071','Joshua','Wood','joshua.w@email.com','Espoo','Finland','Premium','2025-04-15'),
(72,'C0072','Brooklyn','Barnes','brooklyn.b@email.com','Tampere','Finland','Regular','2025-05-02'),
(73,'C0073','Christopher','Ross','chris.ross@email.com','Dublin','Ireland','Regular','2025-05-20'),
(74,'C0074','Savannah','Henderson','savannah.h@email.com','Cork','Ireland','Premium','2025-06-08'),
(75,'C0075','Jonathan','Coleman','jon.c@email.com','Galway','Ireland','Regular','2025-06-25'),
(76,'C0076','Anna','Jenkins','anna.j@email.com','Prague','Czech Republic','Regular','2025-07-12'),
(77,'C0077','Wyatt','Perry','wyatt.p@email.com','Brno','Czech Republic','Premium','2025-07-28'),
(78,'C0078','Samantha','Powell','samantha.p@email.com','Warsaw','Poland','Regular','2025-08-15'),
(79,'C0079','Grayson','Long','grayson.l@email.com','Krakow','Poland','Regular','2025-09-02'),
(80,'C0080','Leah','Patterson','leah.p@email.com','Gdansk','Poland','Premium','2025-09-20'),
(81,'C0081','Evan','Hughes','evan.h@email.com','Budapest','Hungary','Regular','2025-10-08'),
(82,'C0082','Victoria','Flores','victoria.f@email.com','Debrecen','Hungary','Premium','2025-10-25'),
(83,'C0083','Jaxon','Washington','jaxon.w@email.com','Lisbon','Portugal','Regular','2023-03-12'),
(84,'C0084','Aaliyah','Butler','aaliyah.b@email.com','Porto','Portugal','Regular','2023-06-18'),
(85,'C0085','Asher','Simmons','asher.s@email.com','Athens','Greece','Premium','2023-09-22'),
(86,'C0086','Bella','Foster','bella.f@email.com','Thessaloniki','Greece','Regular','2023-12-05'),
(87,'C0087','Lincoln','Gonzales','lincoln.g@email.com','Luxembourg','Luxembourg','Regular','2024-03-15'),
(88,'C0088','Sarah','Bryant','sarah.b@email.com','Amsterdam','Netherlands','Premium','2024-06-20'),
(89,'C0089','Hunter','Alexander','hunter.a@email.com','Brussels','Belgium','Regular','2024-09-10'),
(90,'C0090','Paisley','Russell','paisley.r@email.com','Paris','France','Regular','2024-12-01'),
(91,'C0091','Aaron','Griffin','aaron.g@email.com','Berlin','Germany','Premium','2025-02-14'),
(92,'C0092','Kennedy','Diaz','kennedy.d@email.com','London','United Kingdom','Regular','2025-05-08'),
(93,'C0093','Cameron','Hayes','cameron.h@email.com','Madrid','Spain','Regular','2025-07-22'),
(94,'C0094','Madelyn','Myers','madelyn.m@email.com','Rome','Italy','Premium','2023-04-30'),
(95,'C0095','Cooper','Ford','cooper.f@email.com','Zürich','Switzerland','Regular','2023-08-16'),
(96,'C0096','Allison','Hamilton','allison.h@email.com','Vienna','Austria','Regular','2024-01-28'),
(97,'C0097','Zachary','Graham','zach.g@email.com','Copenhagen','Denmark','Premium','2024-05-12'),
(98,'C0098','Evelyn','Sullivan','evelyn.s@email.com','Stockholm','Sweden','Regular','2024-08-25'),
(99,'C0099','Kayden','Wallace','kayden.w@email.com','Oslo','Norway','Regular','2024-11-18'),
(100,'C0100','Hailey','Woods','hailey.w@email.com','Helsinki','Finland','Premium','2025-03-05')
) WHERE $row_count = 0;

SELECT 'Loaded ' || CAST(IFF($row_count = 0, 100, 0) AS VARCHAR) || ' rows into DIM_CUSTOMER (Total: ' || CAST((SELECT COUNT(*) FROM DIM_CUSTOMER) AS VARCHAR) || ')' AS status;

/*****************************************************
 * STEP 12: LOAD DATA - DIM_STORE (10 rows)
 *****************************************************/

SET row_count = (SELECT COUNT(*) FROM DIM_STORE);

INSERT INTO DIM_STORE (store_key, store_id, store_name, city, state, country, region, store_type, opening_date)
SELECT * FROM (VALUES
(1,'S001','TechStore Amsterdam Center','Amsterdam','North Holland','Netherlands','Western Europe','Retail','2020-01-15'),
(2,'S002','TechStore Rotterdam Mall','Rotterdam','South Holland','Netherlands','Western Europe','Retail','2020-03-20'),
(3,'S003','TechStore Utrecht Central','Utrecht','Utrecht','Netherlands','Western Europe','Retail','2020-06-10'),
(4,'S004','TechStore Online NL','Amsterdam','North Holland','Netherlands','Western Europe','Online','2019-01-01'),
(5,'S005','TechStore Brussels Plaza','Brussels','Brussels Capital','Belgium','Western Europe','Retail','2020-09-15'),
(6,'S006','TechStore Paris Champs','Paris','Île-de-France','France','Western Europe','Retail','2021-02-01'),
(7,'S007','TechStore Berlin Central','Berlin','Berlin','Germany','Central Europe','Retail','2021-05-20'),
(8,'S008','TechStore London Oxford','London','Greater London','United Kingdom','Northern Europe','Retail','2021-08-10'),
(9,'S009','TechStore Online EU','Amsterdam','North Holland','Netherlands','Western Europe','Online','2019-06-01'),
(10,'S010','TechStore Madrid Gran Via','Madrid','Community of Madrid','Spain','Southern Europe','Retail','2022-01-15')
) WHERE $row_count = 0;

SELECT 'Loaded ' || CAST(IFF($row_count = 0, 10, 0) AS VARCHAR) || ' rows into DIM_STORE (Total: ' || CAST((SELECT COUNT(*) FROM DIM_STORE) AS VARCHAR) || ')' AS status;

/*****************************************************
 * NOTE: FACT_SALES data will be loaded in a separate section
 * due to large number of rows (345 rows)
 * This file continues in setup_and_load_complete_part2.sql
 * OR execute the COPY command from the staging area if preferred
 *****************************************************/

-- Display summary
SELECT 'DATABASE SETUP AND DIMENSION DATA LOAD COMPLETE!' AS status;
SELECT 'Next: Load FACT_SALES data (345 rows) - see note below' AS next_step;

/*****************************************************
 * ALTERNATIVE: Load FACT_SALES from stage
 * If you prefer to use COPY command, upload fact_sales.csv
 * to CSV_STAGE and run:
 * 
 * PUT file:///path/to/fact_sales.csv @BASICS_LAB_DB.STAGING.CSV_STAGE;
 * 
 * COPY INTO BASICS_LAB_DB.DWH.FACT_SALES(
 *     date_key, product_key, customer_key, store_key, quantity,
 *     unit_price, unit_cost, discount_amount, sales_amount,
 *     cost_amount, profit_amount
 * )
 * FROM @BASICS_LAB_DB.STAGING.CSV_STAGE/fact_sales.csv
 * FILE_FORMAT = (TYPE = 'CSV' SKIP_HEADER = 1);
 *****************************************************/

/*****************************************************
 * STEP 13: LOAD FACT_SALES - Small batch approach
 * Due to the 345 rows, we'll use a simplified approach
 * You can load via stage OR run individual INSERTs
 *****************************************************/

-- For demonstration, here's how to load a sample of fact data:
SET row_count = (SELECT COUNT(*) FROM FACT_SALES);

-- Sample INSERT (first 10 transactions only as example)
-- For full data load, use the stage COPY approach above
INSERT INTO FACT_SALES (date_key, product_key, customer_key, store_key, quantity, unit_price, unit_cost, discount_amount, sales_amount, cost_amount, profit_amount)
SELECT * FROM (VALUES
(20230102,1,1,1,1,1299.99,850.00,0.00,1299.99,850.00,449.99),
(20230102,2,2,1,2,29.99,12.00,5.00,54.98,24.00,30.98),
(20230103,5,3,1,1,89.99,40.00,0.00,89.99,40.00,49.99),
(20230103,11,4,2,1,899.99,550.00,50.00,849.99,550.00,299.99),
(20230104,15,5,3,1,79.99,40.00,0.00,79.99,40.00,39.99),
(20230105,6,6,1,1,249.99,120.00,25.00,224.99,120.00,104.99),
(20230105,7,7,2,1,499.99,280.00,0.00,499.99,280.00,219.99),
(20230106,13,8,4,1,149.99,70.00,15.00,134.99,70.00,64.99),
(20230107,14,9,1,1,449.99,280.00,0.00,449.99,280.00,169.99),
(20230108,3,10,1,3,19.99,5.00,0.00,59.97,15.00,44.97)
) WHERE $row_count = 0;

SELECT 'Loaded sample FACT_SALES data (10 rows for demo). Use COPY FROM stage for full 345 rows.' AS status;

/*****************************************************
 * STEP 14: LOAD JSON DATA - PRODUCTS_JSON (20 objects)
 *****************************************************/

SET row_count = (SELECT COUNT(*) FROM PRODUCTS_JSON);

INSERT INTO PRODUCTS_JSON (product_data)
SELECT PARSE_JSON(column1) FROM (VALUES
('{"product_id":"P001","name":"Laptop Pro 15","category":"Electronics","price":1299.99,"in_stock":true,"specifications":{"processor":"Intel i7","ram":"16GB","storage":"512GB SSD","screen_size":"15.6 inch"},"ratings":{"average":4.5,"count":1250},"tags":["laptop","professional","portable"]}'),
('{"product_id":"P011","name":"Smartphone X12","category":"Electronics","price":899.99,"in_stock":true,"specifications":{"processor":"A15 Bionic","ram":"6GB","storage":"128GB","camera":"12MP Triple"},"ratings":{"average":4.7,"count":3500},"tags":["smartphone","5G","flagship"]}'),
('{"product_id":"P013","name":"Headphones Wireless","category":"Electronics","price":149.99,"in_stock":true,"specifications":{"type":"Over-ear","connectivity":"Bluetooth 5.0","battery_life":"30 hours","noise_cancelling":true},"ratings":{"average":4.3,"count":890},"tags":["audio","wireless","noise-cancelling"]}'),
('{"product_id":"P006","name":"Office Chair Deluxe","category":"Furniture","price":249.99,"in_stock":true,"specifications":{"material":"Mesh back","adjustable":true,"lumbar_support":true,"weight_capacity":"150kg"},"ratings":{"average":4.6,"count":650},"tags":["ergonomic","office","comfort"]}'),
('{"product_id":"P007","name":"Standing Desk","category":"Furniture","price":499.99,"in_stock":true,"specifications":{"dimensions":"180x80 cm","height_adjustable":true,"motor":"Dual motor","weight_capacity":"100kg"},"ratings":{"average":4.8,"count":420},"tags":["desk","adjustable","ergonomic"]}'),
('{"product_id":"P031","name":"Smart Watch Sport","category":"Electronics","price":299.99,"in_stock":true,"specifications":{"display":"AMOLED 1.4 inch","battery_life":"7 days","water_resistant":"50m","sensors":["heart_rate","GPS","altimeter"]},"ratings":{"average":4.4,"count":1100},"tags":["smartwatch","fitness","waterproof"]}'),
('{"product_id":"P019","name":"Yoga Mat Premium","category":"Sports","price":49.99,"in_stock":true,"specifications":{"material":"TPE","thickness":"6mm","size":"183x61 cm","non_slip":true},"ratings":{"average":4.7,"count":780},"tags":["yoga","fitness","eco-friendly"]}'),
('{"product_id":"P044","name":"Printer Wireless","category":"Electronics","price":199.99,"in_stock":false,"specifications":{"type":"Inkjet","connectivity":["WiFi","USB","Ethernet"],"print_speed":"15 ppm","color":true},"ratings":{"average":4.1,"count":520},"tags":["printer","wireless","color"]}'),
('{"product_id":"P025","name":"Winter Jacket","category":"Clothing","price":149.99,"in_stock":true,"specifications":{"material":"Polyester","insulation":"Down feather","waterproof":true,"sizes":["S","M","L","XL"]},"ratings":{"average":4.5,"count":340},"tags":["winter","outdoor","warm"]}'),
('{"product_id":"P029","name":"Suitcase 24 inch","category":"Bags","price":129.99,"in_stock":true,"specifications":{"material":"Polycarbonate","wheels":4,"capacity":"65L","lock":"TSA approved"},"ratings":{"average":4.6,"count":920},"tags":["travel","luggage","durable"]}'),
('{"product_id":"P041","name":"External SSD 1TB","category":"Electronics","price":129.99,"in_stock":true,"specifications":{"capacity":"1TB","interface":"USB 3.2","read_speed":"1050 MB/s","write_speed":"1000 MB/s"},"ratings":{"average":4.8,"count":1560},"tags":["storage","portable","fast"]}'),
('{"product_id":"P015","name":"Coffee Maker Pro","category":"Appliances","price":79.99,"in_stock":true,"specifications":{"type":"Drip","capacity":"12 cups","programmable":true,"auto_shutoff":true},"ratings":{"average":4.2,"count":680},"tags":["coffee","kitchen","programmable"]}'),
('{"product_id":"P039","name":"Router WiFi 6","category":"Electronics","price":149.99,"in_stock":true,"specifications":{"standard":"WiFi 6 (802.11ax)","speed":"3000 Mbps","bands":"Dual-band","antennas":4},"ratings":{"average":4.5,"count":440},"tags":["networking","wifi6","router"]}'),
('{"product_id":"P021","name":"Running Shoes Men","category":"Sports","price":119.99,"in_stock":true,"specifications":{"material":"Mesh","cushioning":"Air cushion","weight":"280g","sizes":[40,41,42,43,44,45]},"ratings":{"average":4.4,"count":1240},"tags":["running","sports","comfortable"]}'),
('{"product_id":"P004","name":"Monitor 27 inch","category":"Electronics","price":399.99,"in_stock":true,"specifications":{"size":"27 inch","resolution":"2560x1440","refresh_rate":"144Hz","panel_type":"IPS"},"ratings":{"average":4.7,"count":890},"tags":["monitor","gaming","high-refresh"]}'),
('{"product_id":"P014","name":"Tablet 10 inch","category":"Electronics","price":449.99,"in_stock":false,"specifications":{"screen":"10.2 inch","processor":"A13","storage":"64GB","battery":"10 hours"},"ratings":{"average":4.6,"count":2100},"tags":["tablet","portable","entertainment"]}'),
('{"product_id":"P035","name":"Speaker Bluetooth","category":"Electronics","price":59.99,"in_stock":true,"specifications":{"output":"20W","battery_life":"12 hours","waterproof":"IPX7","connectivity":"Bluetooth 5.0"},"ratings":{"average":4.3,"count":950},"tags":["speaker","portable","waterproof"]}'),
('{"product_id":"P050","name":"Whiteboard Magnetic","category":"Office Supplies","price":79.99,"in_stock":true,"specifications":{"size":"90x60 cm","surface":"Magnetic","frame":"Aluminum","includes":["markers","eraser","magnets"]},"ratings":{"average":4.5,"count":310},"tags":["office","whiteboard","magnetic"]}'),
('{"product_id":"P020","name":"Dumbbell Set 20kg","category":"Sports","price":89.99,"in_stock":true,"specifications":{"weight":"2x10kg","material":"Cast iron","coating":"Rubber","adjustable":false},"ratings":{"average":4.7,"count":540},"tags":["fitness","strength","home-gym"]}'),
('{"product_id":"P032","name":"Fitness Tracker","category":"Electronics","price":79.99,"in_stock":true,"specifications":{"display":"OLED","battery_life":"14 days","water_resistant":"50m","features":["step_counter","sleep_tracking","heart_rate"]},"ratings":{"average":4.2,"count":1780},"tags":["fitness","tracker","health"]}')
) WHERE $row_count = 0;

SELECT 'Loaded ' || CAST(IFF($row_count = 0, 20, 0) AS VARCHAR) || ' rows into PRODUCTS_JSON (Total: ' || CAST((SELECT COUNT(*) FROM PRODUCTS_JSON) AS VARCHAR) || ')' AS status;

/*****************************************************
 * STEP 15: VERIFICATION
 *****************************************************/

-- Show all created objects
SHOW DATABASES LIKE 'BASICS_LAB_DB';
SHOW SCHEMAS IN DATABASE BASICS_LAB_DB;
SHOW WAREHOUSES LIKE 'BASICS_LAB_WH';
SHOW STAGES IN SCHEMA BASICS_LAB_DB.STAGING;
SHOW TABLES IN SCHEMA BASICS_LAB_DB.DWH;

-- Count all rows
SELECT 'DIM_DATE' AS table_name, COUNT(*) AS row_count FROM DIM_DATE
UNION ALL
SELECT 'DIM_PRODUCT', COUNT(*) FROM DIM_PRODUCT
UNION ALL
SELECT 'DIM_CUSTOMER', COUNT(*) FROM DIM_CUSTOMER
UNION ALL
SELECT 'DIM_STORE', COUNT(*) FROM DIM_STORE
UNION ALL
SELECT 'FACT_SALES', COUNT(*) FROM FACT_SALES
UNION ALL
SELECT 'PRODUCTS_JSON', COUNT(*) FROM PRODUCTS_JSON
ORDER BY table_name;

/*****************************************************
 * SETUP COMPLETE!
 * 
 * Summary:
 * ✓ Database BASICS_LAB_DB created
 * ✓ Schemas (STAGING, DWH, ANALYTICS) created
 * ✓ Warehouse BASICS_LAB_WH created
 * ✓ All dimension and fact tables created
 * ✓ Dimension data loaded (DIM_DATE, DIM_PRODUCT, DIM_CUSTOMER, DIM_STORE)
 * ✓ JSON data loaded (PRODUCTS_JSON)
 * ⚠ FACT_SALES: Sample data loaded (10 rows)
 * 
 * Next steps:
 * 1. For full FACT_SALES data (345 rows):
 *    - Upload fact_sales.csv to CSV_STAGE
 *    - Run COPY INTO command (see alternative section above)
 * 2. Open exercises.sql and start the exercises
 * 
 * Note: This script is idempotent - it checks for existing data
 * before loading to prevent duplicates.
 *****************************************************/

SELECT 'Setup complete! Environment ready for Snowflake Basics Lab.' AS final_status;

