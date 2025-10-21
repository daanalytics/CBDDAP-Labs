/*****************************************************
 * SNOWFLAKE BASICS LAB - EXERCISES
 * 
 * This file contains all hands-on exercises
 * for the Snowflake Basics Lab.
 * 
 * INSTRUCTIONS:
 * 1. Read each exercise carefully
 * 2. Write your SQL query below each task
 * 3. Test your query and check the result
 * 4. Only move to the next exercise when the current one works
 * 
 * TIP: Use /* ... */ for comments with your solutions
 *****************************************************/

-- Set the correct context
USE ROLE SYSADMIN;
USE DATABASE BASICS_LAB_DB;
USE WAREHOUSE BASICS_LAB_WH;


/*****************************************************
 * PART A: DATABASE AND WAREHOUSE SETUP (VERIFICATION)
 * 
 * These exercises help you verify that the setup
 * was executed correctly.
 *****************************************************/

-- ============================================
-- Exercise A1: Show all schemas in the database
-- ============================================
-- Expected: STAGING, DWH, ANALYTICS (and PUBLIC)

-- YOUR SOLUTION HERE:




-- ============================================
-- Exercise A2: Show all tables in the DWH schema
-- ============================================
-- Expected: DIM_DATE, DIM_PRODUCT, DIM_CUSTOMER, DIM_STORE, FACT_SALES, PRODUCTS_JSON

-- YOUR SOLUTION HERE:




/*****************************************************
 * PART B: LOADING DATA FROM STAGES
 * 
 * In this part, you will load data from the internal
 * stages into the tables in the DWH schema.
 * 
 * IMPORTANT: Make sure you have first uploaded all CSV and JSON
 * files to the correct stages!
 *****************************************************/

-- Set the context to the DWH schema
USE SCHEMA DWH;

-- ============================================
-- Exercise B1: View which files are in the CSV_STAGE
-- ============================================
-- TIP: Use LIST @stage_name

-- YOUR SOLUTION HERE:




-- ============================================
-- Exercise B2: Load data into the DIM_DATE table
-- ============================================
-- Load the data from dim_date.csv into the DIM_DATE table
-- TIP: Use COPY INTO with the CSV_STAGE

-- YOUR SOLUTION HERE:




-- ============================================
-- Exercise B3: Load data into the DIM_PRODUCT table
-- ============================================
-- Load the data from dim_product.csv into the DIM_PRODUCT table

-- YOUR SOLUTION HERE:




-- ============================================
-- Exercise B4: Load data into the DIM_CUSTOMER table
-- ============================================
-- Load the data from dim_customer.csv into the DIM_CUSTOMER table

-- YOUR SOLUTION HERE:




-- ============================================
-- Exercise B5: Load data into the DIM_STORE table
-- ============================================
-- Load the data from dim_store.csv into the DIM_STORE table

-- YOUR SOLUTION HERE:




-- ============================================
-- Exercise B6: Load data into the FACT_SALES table
-- ============================================
-- Load the data from fact_sales.csv into the FACT_SALES table

-- YOUR SOLUTION HERE:




-- ============================================
-- Exercise B7: Load JSON data into the PRODUCTS_JSON table
-- ============================================
-- Load the data from products.json into the PRODUCTS_JSON table
-- TIP: Use the JSON_STAGE (note: the format is different than CSV!)

-- YOUR SOLUTION HERE:




-- ============================================
-- Exercise B8: Verify that all data is loaded
-- ============================================
-- Show the number of rows in each table
-- Expected approximately:
-- - DIM_DATE: ~100 rows
-- - DIM_PRODUCT: 50 rows
-- - DIM_CUSTOMER: 100 rows
-- - DIM_STORE: 10 rows
-- - FACT_SALES: ~300 rows
-- - PRODUCTS_JSON: 20 rows

-- YOUR SOLUTION HERE (write 6 SELECT COUNT(*) queries):




/*****************************************************
 * PART C: BASIC SQL QUERIES
 * 
 * Now we'll practice with basic SQL syntax:
 * - SELECT, FROM
 * - WHERE
 * - ORDER BY
 * - GROUP BY
 * - HAVING
 *****************************************************/

-- ============================================
-- Exercise C1: Select all products
-- ============================================
-- Show all columns from the DIM_PRODUCT table

-- YOUR SOLUTION HERE:




-- ============================================
-- Exercise C2: Select specific columns
-- ============================================
-- Show only product_name, category, and unit_price of all products

-- YOUR SOLUTION HERE:




-- ============================================
-- Exercise C3: Filter on category
-- ============================================
-- Show all products in the 'Electronics' category

-- YOUR SOLUTION HERE:




-- ============================================
-- Exercise C4: Sort products by price
-- ============================================
-- Show product_name and unit_price, sorted by price (highest first)

-- YOUR SOLUTION HERE:




-- ============================================
-- Exercise C5: Count products per category
-- ============================================
-- Show the number of products per category
-- Output: category, number_of_products

-- YOUR SOLUTION HERE:




-- ============================================
-- Exercise C6: Calculate average price per category
-- ============================================
-- Show the average unit_price per category
-- Output: category, average_price
-- TIP: Use ROUND() to round the price to 2 decimals

-- YOUR SOLUTION HERE:




-- ============================================
-- Exercise C7: Filter on aggregated values with HAVING
-- ============================================
-- Show categories with more than 10 products
-- Output: category, number_of_products
-- TIP: Use HAVING to filter on the count

-- YOUR SOLUTION HERE:




-- ============================================
-- Exercise C8: Complex query with GROUP BY and HAVING
-- ============================================
-- Show categories where the average price is higher than 100
-- Sort by average price (highest first)
-- Output: category, average_price, number_of_products

-- YOUR SOLUTION HERE:




/*****************************************************
 * PART D: STAR SCHEMA QUERIES
 * 
 * Now we'll work with the star schema:
 * - JOINs between fact and dimension tables
 * - Aggregations across multiple dimensions
 *****************************************************/

-- ============================================
-- Exercise D1: Simple JOIN with one dimension
-- ============================================
-- Show all sales with the product name
-- Output: sales_key, product_name, quantity, sales_amount
-- TIP: JOIN FACT_SALES with DIM_PRODUCT

-- YOUR SOLUTION HERE:




-- ============================================
-- Exercise D2: JOIN with multiple dimensions
-- ============================================
-- Show sales with product name, customer name, and store name
-- Output: product_name, customer_first_name, customer_last_name, 
--         store_name, sales_amount
-- TIP: JOIN with DIM_PRODUCT, DIM_CUSTOMER, and DIM_STORE

-- YOUR SOLUTION HERE:




-- ============================================
-- Exercise D3: JOIN with date dimension
-- ============================================
-- Show sales with full date information
-- Output: full_date, year, month_name, product_name, sales_amount
-- TIP: JOIN with DIM_DATE

-- YOUR SOLUTION HERE:




-- ============================================
-- Exercise D4: Aggregation per time period
-- ============================================
-- Show total sales per year and month
-- Output: year, month, month_name, total_sales
-- Sort by year and month

-- YOUR SOLUTION HERE:




-- ============================================
-- Exercise D5: Top 5 best-selling products
-- ============================================
-- Show the 5 products with the highest total sales
-- Output: product_name, total_quantity_sold, total_revenue
-- TIP: Use SUM() and LIMIT

-- YOUR SOLUTION HERE:




-- ============================================
-- Exercise D6: Sales analysis per country
-- ============================================
-- Show total sales per customer country
-- Output: country, number_of_transactions, total_revenue
-- Sort by total revenue (highest first)

-- YOUR SOLUTION HERE:




/*****************************************************
 * PART E: DATA TRANSFORMATIONS
 * 
 * Exercises with data transformations:
 * - String manipulations
 * - Numeric calculations
 * - Date functions
 * - CASE statements
 *****************************************************/

-- ============================================
-- Exercise E1: String concatenation
-- ============================================
-- Create a full customer name (first name + last name)
-- Output: customer_id, full_name, email
-- TIP: Use CONCAT() or ||

-- YOUR SOLUTION HERE:




-- ============================================
-- Exercise E2: String functions
-- ============================================
-- Show customer email in uppercase and extract the domain
-- Output: customer_id, email, email_uppercase, email_domain
-- TIP: Use UPPER() and SPLIT_PART() or SUBSTRING()

-- YOUR SOLUTION HERE:




-- ============================================
-- Exercise E3: Calculate profit margin percentage
-- ============================================
-- Calculate the profit margin percentage for each product
-- Formula: (unit_price - unit_cost) / unit_price * 100
-- Output: product_name, unit_price, unit_cost, profit_margin_percentage
-- Sort by margin (highest first)

-- YOUR SOLUTION HERE:




-- ============================================
-- Exercise E4: CASE statement - Price categorization
-- ============================================
-- Categorize products based on price:
-- - 'Budget' if unit_price < 50
-- - 'Mid-range' if unit_price between 50 and 200
-- - 'Premium' if unit_price > 200
-- Output: product_name, unit_price, price_category

-- YOUR SOLUTION HERE:




-- ============================================
-- Exercise E5: Date calculations
-- ============================================
-- Calculate the number of days since customer registration
-- Output: customer_id, full_name, registration_date, days_since_registration
-- TIP: Use DATEDIFF() with CURRENT_DATE()

-- YOUR SOLUTION HERE:




-- ============================================
-- Exercise E6: Aggregation with CASE
-- ============================================
-- Count number of sales per customer segment and calculate total revenue per segment
-- Output: customer_segment, number_of_sales, total_revenue, average_order_value
-- TIP: JOIN FACT_SALES with DIM_CUSTOMER

-- YOUR SOLUTION HERE:




/*****************************************************
 * PART F: JSON DATA QUERIES
 * 
 * Exercises with semi-structured data (JSON):
 * - JSON path notation
 * - Extracting nested fields
 * - Filtering on JSON attributes
 *****************************************************/

-- ============================================
-- Exercise F1: Basic JSON extraction
-- ============================================
-- Extract product_id, name, and price from the JSON data
-- Output: product_id, name, price
-- TIP: Use product_data:field_name::TYPE syntax

-- YOUR SOLUTION HERE:




-- ============================================
-- Exercise F2: Nested JSON fields
-- ============================================
-- Extract specifications from the JSON (nested object)
-- Output: product_id, name, processor (from specifications)
-- TIP: Use product_data:specifications.processor::string

-- YOUR SOLUTION HERE:




-- ============================================
-- Exercise F3: Boolean fields and filtering
-- ============================================
-- Show only products that are in stock
-- Output: product_id, name, price, in_stock
-- TIP: Filter on product_data:in_stock::boolean = TRUE

-- YOUR SOLUTION HERE:




-- ============================================
-- Exercise F4: JSON ratings and sorting
-- ============================================
-- Show products with their ratings, sorted by rating
-- Output: product_id, name, price, average_rating, rating_count
-- Sort by average_rating (highest first)

-- YOUR SOLUTION HERE:




-- ============================================
-- Exercise F5: JSON array field
-- ============================================
-- Extract the tags (array) as a string
-- Output: product_id, name, tags
-- TIP: Use product_data:tags::string to show the array as a string

-- YOUR SOLUTION HERE:




-- ============================================
-- Exercise F6: Complex JSON query with calculations
-- ============================================
-- Calculate total review score (average_rating * rating_count) for each product
-- Show only products with an average_rating >= 4.5
-- Output: product_id, name, average_rating, rating_count, total_score
-- Sort by total_score (highest first)

-- YOUR SOLUTION HERE:




/*****************************************************
 * PART G: ANALYTICAL QUESTIONS
 * 
 * Solve these business questions with SQL queries.
 * These exercises combine everything you've learned!
 *****************************************************/

-- ============================================
-- Question G1: What is the total revenue per quarter in 2024?
-- ============================================
-- Output: year, quarter, total_revenue
-- Filter only on 2024 and sort by quarter

-- YOUR SOLUTION HERE:




-- ============================================
-- Question G2: Which products have the highest profit margin?
-- ============================================
-- Calculate the average profit margin per product
-- Formula: (sales_amount - cost_amount) / sales_amount * 100
-- Output: product_name, quantity_sold, avg_profit_margin_percentage
-- Show top 10, sorted by margin

-- YOUR SOLUTION HERE:




-- ============================================
-- Question G3: Which customers have spent the most?
-- ============================================
-- Output: customer_id, full_name, country, total_spent, number_of_orders
-- Show top 10 customers, sorted by total spent

-- YOUR SOLUTION HERE:




-- ============================================
-- Question G4: What is the sales trend per month for Electronics?
-- ============================================
-- Show monthly sales of Electronics products
-- Output: year, month, month_name, quantity_sold, total_revenue
-- Sort by year and month

-- YOUR SOLUTION HERE:




-- ============================================
-- Question G5: Which store has the best performance?
-- ============================================
-- Output: store_name, city, country, total_revenue, total_profit, number_of_transactions
-- Sort by total profit (highest first)

-- YOUR SOLUTION HERE:




-- ============================================
-- Question G6: Weekend vs Weekday sales
-- ============================================
-- Compare sales between weekend and weekdays
-- Output: day_type ('Weekend' or 'Weekday'), number_of_transactions, total_revenue, avg_order_value
-- TIP: Use CASE with is_weekend field from DIM_DATE

-- YOUR SOLUTION HERE:




-- ============================================
-- Question G7: Product cross-selling analysis
-- ============================================
-- Which product categories are often bought together?
-- For each category, show how many unique customers have bought it
-- Output: category, number_of_unique_customers, number_of_transactions, total_revenue
-- Sort by number of unique customers (highest first)

-- YOUR SOLUTION HERE:




-- ============================================
-- Question G8: Seasonal performance analysis
-- ============================================
-- Compare sales per season (use quarters as proxy)
-- Q1: Winter, Q2: Spring, Q3: Summer, Q4: Fall
-- For all years in the data:
-- Output: season, number_of_transactions, total_revenue, average_order_value
-- TIP: Use CASE to map quarter to season

-- YOUR SOLUTION HERE:




/*****************************************************
 * BONUS EXERCISES (OPTIONAL)
 * 
 * Challenging exercises if you want to learn more!
 *****************************************************/

-- ============================================
-- Bonus 1: Cohort analysis - Customers per registration month
-- ============================================
-- Group customers by registration month and count their total spending
-- Output: registration_year, registration_month, number_of_customers, 
--         total_revenue, avg_spending_per_customer

-- YOUR SOLUTION HERE (if you want to try this):




-- ============================================
-- Bonus 2: Running total per month
-- ============================================
-- Show cumulative revenue per month in 2024
-- Output: year, month, monthly_revenue, cumulative_revenue
-- TIP: Use window function SUM() OVER (ORDER BY ...)

-- YOUR SOLUTION HERE (if you want to try this):




-- ============================================
-- Bonus 3: Customer Lifetime Value (CLV)
-- ============================================
-- Calculate for each customer:
-- - Total number of orders
-- - Total amount spent
-- - Average order value
-- - First purchase date
-- - Last purchase date
-- - Days between first and last purchase
-- Only customers with more than 1 order

-- YOUR SOLUTION HERE (if you want to try this):




/*****************************************************
 * END OF EXERCISES
 * 
 * Congratulations! If you've completed all exercises,
 * you now have a solid foundation in Snowflake SQL!
 * 
 * Next steps:
 * - Check your answers with answers.sql
 * - Experiment with your own queries
 * - Continue with the other lab modules
 *****************************************************/

SELECT 'You have completed all exercises! 🎉' AS message;
