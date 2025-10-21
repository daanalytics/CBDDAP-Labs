# Snowflake Basics Lab - Summary

## 📊 Lab Overview

This lab provides a complete hands-on introduction to Snowflake for beginners. Students learn all the essential skills needed to work with Snowflake.

## 🎯 What Will Students Learn?

### 1. **Snowflake Environment Setup**
- Create and configure database
- Organize schemas (STAGING, DWH, ANALYTICS)
- Manage warehouses (sizing, auto-suspend/resume)
- Use internal stages for data upload

### 2. **Data Loading**
- Upload CSV files to internal stages
- Upload JSON files to internal stages
- Use COPY INTO commands
- Configure file formats
- Error handling during data load

### 3. **SQL Fundamentals**
- **SELECT & FROM**: Basic data selection
- **WHERE**: Filtering
- **ORDER BY**: Sorting
- **GROUP BY**: Aggregations
- **HAVING**: Filtering on aggregated data
- **JOINs**: Combining multiple tables

### 4. **Dimensional Modeling (Star Schema)**
- Understand fact tables (FACT_SALES)
- Use dimension tables (DATE, PRODUCT, CUSTOMER, STORE)
- Foreign key relationships
- Write analytical queries across multiple dimensions

### 5. **Data Transformations**
- String functions (CONCAT, UPPER, SPLIT_PART)
- Numeric calculations
- Date functions (DATEDIFF, YEAR, MONTH)
- CASE statements for conditional logic

### 6. **Semi-Structured Data (JSON)**
- Load JSON data in Snowflake
- VARIANT data type
- JSON path notation (data:field::type)
- Extract nested JSON fields
- Arrays in JSON

### 7. **Business Analytics**
- Calculate KPIs (revenue, profit, margin)
- Trend analyses
- Customer segmentation
- Product performance
- Seasonal analyses

## 📁 Files and Structure

```
Module0/Snowflake-Basics-Lab/
├── README_snowflake_basics_lab.md     # Full instructions
├── QUICK_START.md                     # Quick start guide
├── LAB_SUMMARY.md                     # This document
├── sql/
│   ├── setup_basics_lab.sql          # Setup (5 min)
│   ├── exercises.sql                  # 42 exercises (3 hours)
│   ├── answers.sql                    # All answers with explanations
│   └── cleanup_basics_lab.sql        # Cleanup
└── data/
    ├── dim_date.csv                   # 106 dates (2023-2025)
    ├── dim_product.csv                # 50 products
    ├── dim_customer.csv               # 100 customers
    ├── dim_store.csv                  # 10 stores
    ├── fact_sales.csv                 # 300+ transactions
    └── products.json                  # 20 JSON records
```

## 📈 Exercises Breakdown

### Part A: Setup Verification (2 exercises)
✅ Easy - Verify that setup is correct

### Part B: Data Loading (8 exercises)
✅ Easy - Practically learn to work with stages and COPY INTO

### Part C: Basic SQL (8 exercises)
⭐ Medium - SELECT, WHERE, GROUP BY, HAVING, ORDER BY

### Part D: Star Schema (6 exercises)
⭐ Medium - JOINs and dimensional analyses

### Part E: Transformations (6 exercises)
⭐ Medium - String, numeric, date functions and CASE

### Part F: JSON Queries (6 exercises)
⭐⭐ Challenging - Process semi-structured data

### Part G: Analytical Questions (8 exercises)
⭐⭐ Challenging - Real-world business scenarios

### Bonus (3 exercises)
⭐⭐⭐ Advanced - Cohort analysis, window functions, CLV

**Total: 42 regular + 3 bonus = 45 exercises**

## ⏱️ Time Estimate

| Activity | Time |
|----------|------|
| Setup + Data Upload | 10 min |
| Part A-B (Basics) | 20 min |
| Part C (SQL) | 30 min |
| Part D (Star Schema) | 30 min |
| Part E (Transformations) | 30 min |
| Part F (JSON) | 30 min |
| Part G (Analytical) | 40 min |
| Bonus (optional) | 30 min |
| **Total** | **~3 hours** |

## 💾 Data Volumes

| Object | Rows | Columns | Notes |
|--------|------|---------|-------|
| DIM_DATE | 106 | 12 | Important dates in 2023-2025 |
| DIM_PRODUCT | 50 | 8 | Various product categories |
| DIM_CUSTOMER | 100 | 9 | European customers |
| DIM_STORE | 10 | 9 | Retail & Online stores |
| FACT_SALES | 300+ | 11 | Sales transactions |
| PRODUCTS_JSON | 20 | 2 (VARIANT) | Nested JSON structures |

## 🎓 Learning Objectives by Level

### Beginner (after Part A-C)
✅ Can set up Snowflake environment
✅ Load data via stages
✅ Write basic SQL queries
✅ Create simple aggregations

### Intermediate (after Part D-E)
✅ Understand and use star schema
✅ Write complex JOINs
✅ Apply data transformations
✅ Implement business logic with CASE

### Advanced (after Part F-G)
✅ Query semi-structured data
✅ Use JSON path notation
✅ Write complex analytical queries
✅ Solve business problems

### Expert (after Bonus)
✅ Use window functions
✅ Create cohort analyses
✅ Calculate advanced KPIs

## 🔑 Key Concepts

### Snowflake Architecture
- **Database**: Container for schemas
- **Schema**: Container for tables and views
- **Warehouse**: Compute resources (pay per second)
- **Stage**: Location for data files

### Star Schema
```
        DIM_DATE
            |
DIM_CUSTOMER--FACT_SALES--DIM_PRODUCT
            |
        DIM_STORE
```

### VARIANT Data Type
- Can store JSON, Avro, XML, Parquet
- Use path notation: `data:field::type`
- Nested fields: `data:parent.child::type`

### Best Practices
1. **Warehouse management**: Use auto-suspend/resume
2. **Data organization**: Logical schema layout
3. **File formats**: Define reusable file formats
4. **Error handling**: Use ON_ERROR in COPY INTO
5. **Query optimization**: Filter early, aggregate late

## 📝 Practical Tips for Instructors

### Before the Lesson
1. Ensure students have Snowflake access
2. Test all scripts in a clean environment
3. Download all data files and test the upload

### During the Lesson
1. **Start with demo**: First show the complete flow
2. **Hands-on first**: Let students start immediately
3. **Live coding**: Do difficult exercises together
4. **Peer learning**: Let students help each other
5. **Breakpoints**: Questions and discussion after each part

### Frequently Asked Questions
- **Q: "Warehouse is suspended"** → A: Auto-resume works, wait 10 sec
- **Q: "Stage is empty"** → A: Check if files are uploaded
- **Q: "JSON gives null"** → A: Check ::type casting
- **Q: "COPY INTO doesn't work"** → A: Check file format and path

### Troubleshooting
```sql
-- Check warehouse status
SHOW WAREHOUSES;

-- Check stage files
LIST @CSV_STAGE;

-- Check loaded rows
SELECT COUNT(*) FROM table_name;

-- View last errors
SELECT * FROM TABLE(INFORMATION_SCHEMA.COPY_HISTORY(
    TABLE_NAME=>'DIM_PRODUCT', 
    START_TIME=>DATEADD(hours, -1, CURRENT_TIMESTAMP())
));
```

## 🎯 Success Criteria

Students have successfully completed the lab if they can:
- ✅ Independently set up a Snowflake environment
- ✅ Load data via stages
- ✅ Write SQL queries with JOINs and aggregations
- ✅ Understand and query a star schema
- ✅ Process JSON data
- ✅ Translate business questions into SQL

## 🔄 Extension Possibilities

This lab can be extended with:
1. **Time Travel**: Queries on historical data
2. **Zero-Copy Cloning**: Create database clones
3. **Views**: Materialized and regular views
4. **UDFs**: Write custom functions
5. **Tasks & Streams**: Automation and change tracking
6. **Data Sharing**: Secure data sharing between accounts

## 📚 Additional Resources

After this lab, students can continue with:
- Snowflake documentation: https://docs.snowflake.com
- Snowflake University (free training)
- Hands-On Essentials badge programs
- Modules 1-15 of this course

## 🎉 Conclusion

This lab provides a solid foundation for working with Snowflake. Students get hands-on experience with all essential concepts and are ready for the more advanced modules in the course.

**Good luck with teaching!** 🚀
