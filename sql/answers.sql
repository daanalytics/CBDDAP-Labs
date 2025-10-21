/*****************************************************
 * SNOWFLAKE BASICS LAB - ANSWERS
 * 
 * This file contains all worked-out solutions
 * for the exercises in exercises.sql
 * 
 * IMPORTANT:
 * - Try to complete the exercises yourself first!
 * - Only use this file to check your answers
 * - Read the explanation for each answer for better understanding
 *****************************************************/

-- Set the correct context
USE ROLE SYSADMIN;
USE DATABASE BASICS_LAB_DB;
USE WAREHOUSE BASICS_LAB_WH;


/*****************************************************
 * PART A: DATABASE AND WAREHOUSE SETUP (VERIFICATION)
 *****************************************************/

-- ============================================
-- Exercise A1: Show all schemas in the database
-- ============================================

SHOW SCHEMAS IN DATABASE BASICS_LAB_DB;

-- Alternative with query:
SELECT SCHEMA_NAME 
FROM INFORMATION_SCHEMA.SCHEMATA 
WHERE CATALOG_NAME = 'BASICS_LAB_DB';


-- ============================================
-- Exercise A2: Show all tables in the DWH schema
-- ============================================

SHOW TABLES IN SCHEMA BASICS_LAB_DB.DWH;

-- Alternative with query:
SELECT TABLE_NAME 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_SCHEMA = 'DWH' 
  AND TABLE_CATALOG = 'BASICS_LAB_DB';


/*****************************************************
 * PART B: LOADING DATA FROM STAGES
 *****************************************************/

USE SCHEMA DWH;

-- ============================================
-- Exercise B1: View which files are in the CSV_STAGE
-- ============================================

LIST @BASICS_LAB_DB.STAGING.CSV_STAGE;


-- ============================================
-- Exercise B2: Load data into the DIM_DATE table
-- ============================================

COPY INTO DIM_DATE
FROM @BASICS_LAB_DB.STAGING.CSV_STAGE/dim_date.csv
FILE_FORMAT = (TYPE = CSV, SKIP_HEADER = 1)
ON_ERROR = 'CONTINUE';

-- Verify:
SELECT COUNT(*) as row_count FROM DIM_DATE;


-- ============================================
-- Exercise B3: Load data into the DIM_PRODUCT table
-- ============================================

COPY INTO DIM_PRODUCT
FROM @BASICS_LAB_DB.STAGING.CSV_STAGE/dim_product.csv
FILE_FORMAT = (TYPE = CSV, SKIP_HEADER = 1)
ON_ERROR = 'CONTINUE';

-- Verify:
SELECT COUNT(*) as row_count FROM DIM_PRODUCT;


-- ============================================
-- Exercise B4: Load data into the DIM_CUSTOMER table
-- ============================================

COPY INTO DIM_CUSTOMER
FROM @BASICS_LAB_DB.STAGING.CSV_STAGE/dim_customer.csv
FILE_FORMAT = (TYPE = CSV, SKIP_HEADER = 1)
ON_ERROR = 'CONTINUE';

-- Verify:
SELECT COUNT(*) as row_count FROM DIM_CUSTOMER;


-- ============================================
-- Exercise B5: Load data into the DIM_STORE table
-- ============================================

COPY INTO DIM_STORE
FROM @BASICS_LAB_DB.STAGING.CSV_STAGE/dim_store.csv
FILE_FORMAT = (TYPE = CSV, SKIP_HEADER = 1)
ON_ERROR = 'CONTINUE';

-- Verify:
SELECT COUNT(*) as row_count FROM DIM_STORE;


-- ============================================
-- Exercise B6: Load data into the FACT_SALES table
-- ============================================

COPY INTO FACT_SALES (
    date_key, product_key, customer_key, store_key,
    quantity, unit_price, unit_cost, discount_amount,
    sales_amount, cost_amount, profit_amount
)
FROM @BASICS_LAB_DB.STAGING.CSV_STAGE/fact_sales.csv
FILE_FORMAT = (TYPE = CSV, SKIP_HEADER = 1)
ON_ERROR = 'CONTINUE';

-- Verify:
SELECT COUNT(*) as row_count FROM FACT_SALES;


-- ============================================
-- Exercise B7: Load JSON data into the PRODUCTS_JSON table
-- ============================================

COPY INTO PRODUCTS_JSON (product_data)
FROM @BASICS_LAB_DB.STAGING.JSON_STAGE/products.json
FILE_FORMAT = (TYPE = JSON, STRIP_OUTER_ARRAY = TRUE)
ON_ERROR = 'CONTINUE';

-- Verify:
SELECT COUNT(*) as row_count FROM PRODUCTS_JSON;


-- ============================================
-- Exercise B8: Verify that all data is loaded
-- ============================================

SELECT 'DIM_DATE' as table_name, COUNT(*) as row_count FROM DIM_DATE
UNION ALL
SELECT 'DIM_PRODUCT', COUNT(*) FROM DIM_PRODUCT
UNION ALL
SELECT 'DIM_CUSTOMER', COUNT(*) FROM DIM_CUSTOMER
UNION ALL
SELECT 'DIM_STORE', COUNT(*) FROM DIM_STORE
UNION ALL
SELECT 'FACT_SALES', COUNT(*) FROM FACT_SALES
UNION ALL
SELECT 'PRODUCTS_JSON', COUNT(*) FROM PRODUCTS_JSON;


/*****************************************************
 * PART C: BASIC SQL QUERIES
 *****************************************************/

-- ============================================
-- Exercise C1: Select all products
-- ============================================

SELECT * 
FROM DIM_PRODUCT;


-- ============================================
-- Exercise C2: Select specific columns
-- ============================================

SELECT 
    product_name,
    category,
    unit_price
FROM DIM_PRODUCT;


-- ============================================
-- Exercise C3: Filter on category
-- ============================================

SELECT * 
FROM DIM_PRODUCT
WHERE category = 'Electronics';


-- ============================================
-- Exercise C4: Sort products by price
-- ============================================

SELECT 
    product_name,
    unit_price
FROM DIM_PRODUCT
ORDER BY unit_price DESC;


-- ============================================
-- Exercise C5: Count products per category
-- ============================================

SELECT 
    category,
    COUNT(*) as number_of_products
FROM DIM_PRODUCT
GROUP BY category;


-- ============================================
-- Exercise C6: Calculate average price per category
-- ============================================

SELECT 
    category,
    ROUND(AVG(unit_price), 2) as average_price
FROM DIM_PRODUCT
GROUP BY category;


-- ============================================
-- Exercise C7: Filter on aggregated values with HAVING
-- ============================================

SELECT 
    category,
    COUNT(*) as number_of_products
FROM DIM_PRODUCT
GROUP BY category
HAVING COUNT(*) > 10;

-- Explanation: HAVING is used to filter AFTER aggregation
-- WHERE filters BEFORE aggregation


-- ============================================
-- Exercise C8: Complex query with GROUP BY and HAVING
-- ============================================

SELECT 
    category,
    ROUND(AVG(unit_price), 2) as average_price,
    COUNT(*) as number_of_products
FROM DIM_PRODUCT
GROUP BY category
HAVING AVG(unit_price) > 100
ORDER BY average_price DESC;


/*****************************************************
 * PART D: STAR SCHEMA QUERIES
 *****************************************************/

-- ============================================
-- Exercise D1: Simple JOIN with one dimension
-- ============================================

SELECT 
    f.sales_key,
    p.product_name,
    f.quantity,
    f.sales_amount
FROM FACT_SALES f
JOIN DIM_PRODUCT p ON f.product_key = p.product_key;


-- ============================================
-- Exercise D2: JOIN with multiple dimensions
-- ============================================

SELECT 
    p.product_name,
    c.first_name as customer_first_name,
    c.last_name as customer_last_name,
    s.store_name,
    f.sales_amount
FROM FACT_SALES f
JOIN DIM_PRODUCT p ON f.product_key = p.product_key
JOIN DIM_CUSTOMER c ON f.customer_key = c.customer_key
JOIN DIM_STORE s ON f.store_key = s.store_key;


-- ============================================
-- Exercise D3: JOIN with date dimension
-- ============================================

SELECT 
    d.full_date,
    d.year,
    d.month_name,
    p.product_name,
    f.sales_amount
FROM FACT_SALES f
JOIN DIM_DATE d ON f.date_key = d.date_key
JOIN DIM_PRODUCT p ON f.product_key = p.product_key;


-- ============================================
-- Exercise D4: Aggregation per time period
-- ============================================

SELECT 
    d.year,
    d.month,
    d.month_name,
    SUM(f.sales_amount) as total_sales
FROM FACT_SALES f
JOIN DIM_DATE d ON f.date_key = d.date_key
GROUP BY d.year, d.month, d.month_name
ORDER BY d.year, d.month;


-- ============================================
-- Exercise D5: Top 5 best-selling products
-- ============================================

SELECT 
    p.product_name,
    SUM(f.quantity) as total_quantity_sold,
    SUM(f.sales_amount) as total_revenue
FROM FACT_SALES f
JOIN DIM_PRODUCT p ON f.product_key = p.product_key
GROUP BY p.product_name
ORDER BY total_revenue DESC
LIMIT 5;


-- ============================================
-- Exercise D6: Sales analysis per country
-- ============================================

SELECT 
    c.country,
    COUNT(*) as number_of_transactions,
    SUM(f.sales_amount) as total_revenue
FROM FACT_SALES f
JOIN DIM_CUSTOMER c ON f.customer_key = c.customer_key
GROUP BY c.country
ORDER BY total_revenue DESC;


/*****************************************************
 * PART E: DATA TRANSFORMATIONS
 *****************************************************/

-- ============================================
-- Exercise E1: String concatenation
-- ============================================

SELECT 
    customer_id,
    CONCAT(first_name, ' ', last_name) as full_name,
    -- Or use ||:
    -- first_name || ' ' || last_name as full_name,
    email
FROM DIM_CUSTOMER;


-- ============================================
-- Exercise E2: String functions
-- ============================================

SELECT 
    customer_id,
    email,
    UPPER(email) as email_uppercase,
    SPLIT_PART(email, '@', 2) as email_domain
FROM DIM_CUSTOMER;


-- ============================================
-- Exercise E3: Calculate profit margin percentage
-- ============================================

SELECT 
    product_name,
    unit_price,
    unit_cost,
    ROUND(((unit_price - unit_cost) / unit_price * 100), 2) as profit_margin_percentage
FROM DIM_PRODUCT
ORDER BY profit_margin_percentage DESC;


-- ============================================
-- Exercise E4: CASE statement - Price categorization
-- ============================================

SELECT 
    product_name,
    unit_price,
    CASE 
        WHEN unit_price < 50 THEN 'Budget'
        WHEN unit_price BETWEEN 50 AND 200 THEN 'Mid-range'
        WHEN unit_price > 200 THEN 'Premium'
    END as price_category
FROM DIM_PRODUCT;


-- ============================================
-- Exercise E5: Date calculations
-- ============================================

SELECT 
    customer_id,
    CONCAT(first_name, ' ', last_name) as full_name,
    registration_date,
    DATEDIFF(day, registration_date, CURRENT_DATE()) as days_since_registration
FROM DIM_CUSTOMER;


-- ============================================
-- Exercise E6: Aggregation with CASE
-- ============================================

SELECT 
    c.customer_segment,
    COUNT(*) as number_of_sales,
    SUM(f.sales_amount) as total_revenue,
    ROUND(AVG(f.sales_amount), 2) as average_order_value
FROM FACT_SALES f
JOIN DIM_CUSTOMER c ON f.customer_key = c.customer_key
GROUP BY c.customer_segment
ORDER BY total_revenue DESC;


/*****************************************************
 * PART F: JSON DATA QUERIES
 *****************************************************/

-- ============================================
-- Exercise F1: Basic JSON extraction
-- ============================================

SELECT 
    product_data:product_id::string as product_id,
    product_data:name::string as name,
    product_data:price::number as price
FROM PRODUCTS_JSON;


-- ============================================
-- Exercise F2: Nested JSON fields
-- ============================================

SELECT 
    product_data:product_id::string as product_id,
    product_data:name::string as name,
    product_data:specifications.processor::string as processor
FROM PRODUCTS_JSON
WHERE product_data:specifications.processor IS NOT NULL;

-- Explanation: Use dot notation (.) for nested fields


-- ============================================
-- Exercise F3: Boolean fields and filtering
-- ============================================

SELECT 
    product_data:product_id::string as product_id,
    product_data:name::string as name,
    product_data:price::number as price,
    product_data:in_stock::boolean as in_stock
FROM PRODUCTS_JSON
WHERE product_data:in_stock::boolean = TRUE;


-- ============================================
-- Exercise F4: JSON ratings and sorting
-- ============================================

SELECT 
    product_data:product_id::string as product_id,
    product_data:name::string as name,
    product_data:price::number as price,
    product_data:ratings.average::number as average_rating,
    product_data:ratings.count::number as rating_count
FROM PRODUCTS_JSON
ORDER BY average_rating DESC;


-- ============================================
-- Exercise F5: JSON array field
-- ============================================

SELECT 
    product_data:product_id::string as product_id,
    product_data:name::string as name,
    product_data:tags::string as tags
FROM PRODUCTS_JSON;

-- For flattening arrays, you can use FLATTEN() (advanced)


-- ============================================
-- Exercise F6: Complex JSON query with calculations
-- ============================================

SELECT 
    product_data:product_id::string as product_id,
    product_data:name::string as name,
    product_data:ratings.average::number as average_rating,
    product_data:ratings.count::number as rating_count,
    product_data:ratings.average::number * product_data:ratings.count::number as total_score
FROM PRODUCTS_JSON
WHERE product_data:ratings.average::number >= 4.5
ORDER BY total_score DESC;


/*****************************************************
 * PART G: ANALYTICAL QUESTIONS
 *****************************************************/

-- ============================================
-- Question G1: What is the total revenue per quarter in 2024?
-- ============================================

SELECT 
    d.year,
    d.quarter,
    SUM(f.sales_amount) as total_revenue
FROM FACT_SALES f
JOIN DIM_DATE d ON f.date_key = d.date_key
WHERE d.year = 2024
GROUP BY d.year, d.quarter
ORDER BY d.quarter;


-- ============================================
-- Question G2: Which products have the highest profit margin?
-- ============================================

SELECT 
    p.product_name,
    COUNT(*) as quantity_sold,
    ROUND(AVG((f.sales_amount - f.cost_amount) / f.sales_amount * 100), 2) as avg_profit_margin_percentage
FROM FACT_SALES f
JOIN DIM_PRODUCT p ON f.product_key = p.product_key
GROUP BY p.product_name
ORDER BY avg_profit_margin_percentage DESC
LIMIT 10;


-- ============================================
-- Question G3: Which customers have spent the most?
-- ============================================

SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) as full_name,
    c.country,
    SUM(f.sales_amount) as total_spent,
    COUNT(*) as number_of_orders
FROM FACT_SALES f
JOIN DIM_CUSTOMER c ON f.customer_key = c.customer_key
GROUP BY c.customer_id, c.first_name, c.last_name, c.country
ORDER BY total_spent DESC
LIMIT 10;


-- ============================================
-- Question G4: What is the sales trend per month for Electronics?
-- ============================================

SELECT 
    d.year,
    d.month,
    d.month_name,
    SUM(f.quantity) as quantity_sold,
    SUM(f.sales_amount) as total_revenue
FROM FACT_SALES f
JOIN DIM_DATE d ON f.date_key = d.date_key
JOIN DIM_PRODUCT p ON f.product_key = p.product_key
WHERE p.category = 'Electronics'
GROUP BY d.year, d.month, d.month_name
ORDER BY d.year, d.month;


-- ============================================
-- Question G5: Which store has the best performance?
-- ============================================

SELECT 
    s.store_name,
    s.city,
    s.country,
    SUM(f.sales_amount) as total_revenue,
    SUM(f.profit_amount) as total_profit,
    COUNT(*) as number_of_transactions
FROM FACT_SALES f
JOIN DIM_STORE s ON f.store_key = s.store_key
GROUP BY s.store_name, s.city, s.country
ORDER BY total_profit DESC;


-- ============================================
-- Question G6: Weekend vs Weekday sales
-- ============================================

SELECT 
    CASE 
        WHEN d.is_weekend = TRUE THEN 'Weekend'
        ELSE 'Weekday'
    END as day_type,
    COUNT(*) as number_of_transactions,
    SUM(f.sales_amount) as total_revenue,
    ROUND(AVG(f.sales_amount), 2) as avg_order_value
FROM FACT_SALES f
JOIN DIM_DATE d ON f.date_key = d.date_key
GROUP BY day_type;


-- ============================================
-- Question G7: Product cross-selling analysis
-- ============================================

SELECT 
    p.category,
    COUNT(DISTINCT f.customer_key) as number_of_unique_customers,
    COUNT(*) as number_of_transactions,
    SUM(f.sales_amount) as total_revenue
FROM FACT_SALES f
JOIN DIM_PRODUCT p ON f.product_key = p.product_key
GROUP BY p.category
ORDER BY number_of_unique_customers DESC;


-- ============================================
-- Question G8: Seasonal performance analysis
-- ============================================

SELECT 
    CASE d.quarter
        WHEN 1 THEN 'Winter'
        WHEN 2 THEN 'Spring'
        WHEN 3 THEN 'Summer'
        WHEN 4 THEN 'Fall'
    END as season,
    COUNT(*) as number_of_transactions,
    SUM(f.sales_amount) as total_revenue,
    ROUND(AVG(f.sales_amount), 2) as average_order_value
FROM FACT_SALES f
JOIN DIM_DATE d ON f.date_key = d.date_key
GROUP BY season
ORDER BY total_revenue DESC;


/*****************************************************
 * BONUS EXERCISES
 *****************************************************/

-- ============================================
-- Bonus 1: Cohort analysis - Customers per registration month
-- ============================================

SELECT 
    YEAR(c.registration_date) as registration_year,
    MONTH(c.registration_date) as registration_month,
    COUNT(DISTINCT c.customer_key) as number_of_customers,
    SUM(f.sales_amount) as total_revenue,
    ROUND(SUM(f.sales_amount) / COUNT(DISTINCT c.customer_key), 2) as avg_spending_per_customer
FROM DIM_CUSTOMER c
LEFT JOIN FACT_SALES f ON c.customer_key = f.customer_key
GROUP BY registration_year, registration_month
ORDER BY registration_year, registration_month;


-- ============================================
-- Bonus 2: Running total per month
-- ============================================

WITH monthly_sales AS (
    SELECT 
        d.year,
        d.month,
        SUM(f.sales_amount) as monthly_revenue
    FROM FACT_SALES f
    JOIN DIM_DATE d ON f.date_key = d.date_key
    WHERE d.year = 2024
    GROUP BY d.year, d.month
)
SELECT 
    year,
    month,
    monthly_revenue,
    SUM(monthly_revenue) OVER (ORDER BY year, month) as cumulative_revenue
FROM monthly_sales
ORDER BY year, month;

-- Explanation: Window functions use OVER() clause for cumulative calculations


-- ============================================
-- Bonus 3: Customer Lifetime Value (CLV)
-- ============================================

SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) as full_name,
    COUNT(*) as number_of_orders,
    SUM(f.sales_amount) as total_spent,
    ROUND(AVG(f.sales_amount), 2) as average_order_value,
    MIN(d.full_date) as first_purchase,
    MAX(d.full_date) as last_purchase,
    DATEDIFF(day, MIN(d.full_date), MAX(d.full_date)) as days_between_first_and_last
FROM FACT_SALES f
JOIN DIM_CUSTOMER c ON f.customer_key = c.customer_key
JOIN DIM_DATE d ON f.date_key = d.date_key
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING COUNT(*) > 1
ORDER BY total_spent DESC;


/*****************************************************
 * EXTRA: USEFUL QUERIES FOR VERIFICATION
 *****************************************************/

-- Check if all foreign keys are valid
SELECT 'Invalid product_key' as issue, COUNT(*) as count
FROM FACT_SALES f
LEFT JOIN DIM_PRODUCT p ON f.product_key = p.product_key
WHERE p.product_key IS NULL
UNION ALL
SELECT 'Invalid customer_key', COUNT(*)
FROM FACT_SALES f
LEFT JOIN DIM_CUSTOMER c ON f.customer_key = c.customer_key
WHERE c.customer_key IS NULL
UNION ALL
SELECT 'Invalid date_key', COUNT(*)
FROM FACT_SALES f
LEFT JOIN DIM_DATE d ON f.date_key = d.date_key
WHERE d.date_key IS NULL;


-- Data quality check: find negative values
SELECT 
    'Negative quantity' as issue,
    COUNT(*) as count
FROM FACT_SALES
WHERE quantity < 0
UNION ALL
SELECT 'Negative sales_amount', COUNT(*)
FROM FACT_SALES
WHERE sales_amount < 0;


-- Overview of data distribution
SELECT 
    'Total number of products' as metric,
    COUNT(*) as value
FROM DIM_PRODUCT
UNION ALL
SELECT 'Total number of customers', COUNT(*)
FROM DIM_CUSTOMER
UNION ALL
SELECT 'Total number of transactions', COUNT(*)
FROM FACT_SALES
UNION ALL
SELECT 'Total revenue', ROUND(SUM(sales_amount), 2)
FROM FACT_SALES
UNION ALL
SELECT 'Total profit', ROUND(SUM(profit_amount), 2)
FROM FACT_SALES;


/*****************************************************
 * END OF ANSWERS
 * 
 * We hope these worked-out solutions have helped you
 * better understand Snowflake SQL!
 * 
 * Key lessons:
 * 1. SELECT, FROM, WHERE, GROUP BY, HAVING, ORDER BY
 * 2. JOINs for combining tables
 * 3. Aggregation functions (COUNT, SUM, AVG, MIN, MAX)
 * 4. String functions (CONCAT, UPPER, SPLIT_PART)
 * 5. Date functions (DATEDIFF, YEAR, MONTH)
 * 6. CASE statements for conditional logic
 * 7. JSON path notation for semi-structured data
 * 8. Window functions (bonus) for advanced analytics
 *****************************************************/

SELECT 'You have reviewed all answers! Good luck with your Snowflake journey! 🎓' AS message;
