# Snowflake Basics Lab - Hands-on Exercises

## 📋 Lab Overview

Welcome to the Snowflake Basics Lab! In this hands-on exercise, you'll learn the fundamental aspects of Snowflake:
- Database, schema, and warehouse setup
- Basic SQL queries (SELECT, FROM, GROUP BY, HAVING)
- Working with a star schema
- Data transformations
- JSON data queries
- Solving analytical problems

**Estimated time:** 2-3 hours

## 🎯 Learning Objectives

After completing this lab, you will be able to:
1. Set up a complete Snowflake environment (database, schemas, warehouses)
2. Load data via Snowflake stages
3. Write and execute basic SQL queries
4. Work with a star schema for analytical queries
5. Perform data transformations
6. Query semi-structured data (JSON)
7. Answer business questions using SQL queries

## 📁 Lab Structure

```
Snowflake-Basics-Lab/
├── README_snowflake_basics_lab.md     # This file (instructions)
├── QUICK_START.md                     # Quick start guide
├── sql/
│   ├── setup_basics_lab.sql          # Step 1: Environment setup
│   ├── exercises.sql                  # Step 2: All exercises
│   ├── answers.sql                    # Answers to all exercises
│   └── cleanup_basics_lab.sql        # Cleanup after lab
└── data/
    ├── dim_date.csv                   # Date dimension
    ├── dim_product.csv                # Product dimension
    ├── dim_customer.csv               # Customer dimension
    ├── dim_store.csv                  # Store dimension
    ├── fact_sales.csv                 # Sales fact table
    └── products.json                  # JSON sample data
```

## 🚀 Step-by-Step Instructions

### **Step 1: Preparation**

1. Log in to your Snowflake account
2. Download all files from the `data/` folder to your local computer
3. Open the Snowflake Web Interface (Snowsight)

### **Step 2: Environment Setup**

1. Open the file `sql/setup_basics_lab.sql` in Snowsight
2. Execute all queries (you can run them one by one or all at once)
3. This creates:
   - Database: `BASICS_LAB_DB`
   - Schemas: `STAGING`, `DWH`, `ANALYTICS`
   - Warehouse: `BASICS_LAB_WH`
   - Stages: `CSV_STAGE` and `JSON_STAGE`

### **Step 3: Upload Data**

**Via Snowflake Web Interface:**

1. Go to **Data** → **Databases** → **BASICS_LAB_DB** → **STAGING**
2. Click on **Stages** in the left menu
3. Click on the stage `CSV_STAGE`
4. Click the **+ Files** button (top right)
5. Upload all CSV files:
   - `dim_date.csv`
   - `dim_product.csv`
   - `dim_customer.csv`
   - `dim_store.csv`
   - `fact_sales.csv`
6. Go back to Stages and click on `JSON_STAGE`
7. Upload the JSON file:
   - `products.json`

### **Step 4: Complete Exercises**

1. Open the file `sql/exercises.sql`
2. This file contains all exercises divided into sections:
   - **Part A:** Database and Warehouse Setup (verification)
   - **Part B:** Loading Data from Stages
   - **Part C:** Basic SQL Queries (SELECT, FROM, GROUP BY, HAVING)
   - **Part D:** Star Schema Queries
   - **Part E:** Data Transformations
   - **Part F:** JSON Data Queries
   - **Part G:** Analytical Questions

3. Complete the exercises in order
4. Write your solutions in the indicated sections
5. Test your queries and check the results

### **Step 5: Check Answers**

If you get stuck or want to check your answers:
- Open the file `sql/answers.sql`
- This contains all worked-out solutions with explanations

⚠️ **Note:** Try to complete the exercises yourself first before looking at the answers!

### **Step 6: Cleanup (Optional)**

When you're done and want to clean up the environment:
1. Open the file `sql/cleanup_basics_lab.sql`
2. Execute the queries to remove all objects

## 📚 Important Concepts

### **Star Schema**

A star schema is a data warehouse model with:
- **Fact Table:** Contains measurable events (e.g., sales transactions)
- **Dimension Tables:** Contains context information (who, what, where, when)

In this lab:
```
          DIM_DATE
              |
DIM_CUSTOMER--FACT_SALES--DIM_PRODUCT
              |
          DIM_STORE
```

### **Snowflake Stages**

Stages are locations where data files are stored before being loaded into tables:
- **Internal Stage:** Within Snowflake (what we use in this lab)
- **External Stage:** External cloud storage (S3, Azure Blob, GCS)

### **Data Transformations**

Typical transformations in this lab:
- Data type conversions
- String manipulations
- Date calculations
- Aggregations
- Filtering and conditional logic

## 💡 Tips for Success

1. **Read questions carefully:** Each exercise has specific requirements
2. **Test your queries:** Execute queries and check results
3. **Use LIMIT:** During development, use `LIMIT 10` to test faster
4. **Document your code:** Add comments to complex queries
5. **Work incrementally:** Start simple and build the query step by step
6. **Use Snowflake documentation:** https://docs.snowflake.com

## 🔍 Common Errors

1. **Wrong context:** Make sure you're in the correct database and schema
   ```sql
   USE DATABASE BASICS_LAB_DB;
   USE SCHEMA DWH;
   ```

2. **Stage not found:** Check if data was uploaded correctly to the stage

3. **Data type mismatches:** Pay attention to date formats and numeric conversions

4. **JSON path syntax:** Use correct notation for JSON fields (e.g., `data:field::string`)

## 📞 Need Help?

- Check the `QUICK_START.md` for quick reference
- Consult the `answers.sql` if you get stuck
- Use the Snowflake documentation: https://docs.snowflake.com
- Ask your instructor for help

## ✅ Checklist

- [ ] Setup script executed
- [ ] All CSV files uploaded to CSV_STAGE
- [ ] JSON file uploaded to JSON_STAGE
- [ ] Data loaded into staging tables
- [ ] Basic SQL queries working
- [ ] Star schema queries executed
- [ ] Transformations applied
- [ ] JSON queries working
- [ ] All analytical questions answered

## 🎓 Next Steps

After this lab, you can continue with:
- **Module 1:** BigData 5Vs Lab
- **Module 2:** BigData Architectures & Platforms Lab
- **Module 3:** RBAC & Governance Lab

Good luck with the exercises! 🚀
