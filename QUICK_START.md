# Quick Start Guide - Snowflake Basics Lab

## 🚀 5-Minute Start

### 1. Setup (2 minutes)
```sql
-- Open sql/setup_basics_lab.sql
-- Execute ALL queries
-- Result: Database, Schemas, Warehouse, and Stages are created
```

### 2. Data Upload (2 minutes)
1. Go to: **Data** → **Databases** → **BASICS_LAB_DB** → **STAGING** → **Stages**
2. Click on `CSV_STAGE` → **+ Files** → Upload all 5 CSV files
3. Click on `JSON_STAGE` → **+ Files** → Upload products.json

### 3. Start Exercises (1 minute)
```sql
-- Open sql/exercises.sql
-- Start with Part A
-- Complete exercises in order
```

## 📋 Exercises Overview

| Part | Topic | Exercises | Difficulty |
|------|-------|-----------|------------|
| A | Setup Verification | 2 | ⭐ Easy |
| B | Data Loading | 6 | ⭐ Easy |
| C | Basic SQL | 8 | ⭐⭐ Medium |
| D | Star Schema | 6 | ⭐⭐ Medium |
| E | Transformations | 6 | ⭐⭐ Medium |
| F | JSON Queries | 6 | ⭐⭐⭐ Challenging |
| G | Analytical Questions | 8 | ⭐⭐⭐ Challenging |

**Total:** 42 exercises

## 🎯 Key Commands

### Set Context
```sql
USE ROLE SYSADMIN;
USE DATABASE BASICS_LAB_DB;
USE SCHEMA DWH;
USE WAREHOUSE BASICS_LAB_WH;
```

### Load Data from Stage
```sql
COPY INTO table_name
FROM @stage_name/file.csv
FILE_FORMAT = (TYPE = CSV, SKIP_HEADER = 1);
```

### Basic Query Structure
```sql
SELECT 
    column1,
    COUNT(*) as count,
    SUM(column2) as total
FROM table
WHERE condition
GROUP BY column1
HAVING COUNT(*) > 10
ORDER BY total DESC;
```

### JSON Querying
```sql
SELECT 
    data:field::string as field_value
FROM json_table;
```

## 🔍 Troubleshooting

| Problem | Solution |
|---------|----------|
| "Object does not exist" | Use `USE DATABASE/SCHEMA` commands |
| "Stage not found" | Check if data is uploaded to correct stage |
| "No active warehouse" | Execute `USE WAREHOUSE BASICS_LAB_WH;` |
| JSON field returns null | Check JSON path syntax (use `::string`) |

## 📊 Expected Output

### After Setup:
- ✅ 1 Database (BASICS_LAB_DB)
- ✅ 3 Schemas (STAGING, DWH, ANALYTICS)
- ✅ 1 Warehouse (BASICS_LAB_WH)
- ✅ 2 Stages (CSV_STAGE, JSON_STAGE)

### After Data Loading:
- ✅ 5 CSV files in CSV_STAGE
- ✅ 1 JSON file in JSON_STAGE
- ✅ 5 tables with data in DWH schema

### Data Volumes:
- DIM_DATE: 106 rows (3 years)
- DIM_PRODUCT: 50 rows
- DIM_CUSTOMER: 100 rows
- DIM_STORE: 10 rows
- FACT_SALES: 300+ rows
- Products JSON: 20 records

## ⏱️ Time Estimate

- **Setup + Upload:** 10 minutes
- **Part A-B (Basics):** 20 minutes
- **Part C (SQL):** 30 minutes
- **Part D (Star Schema):** 30 minutes
- **Part E (Transformations):** 30 minutes
- **Part F (JSON):** 30 minutes
- **Part G (Analytical):** 40 minutes

**Total:** ~3 hours

## 💡 Pro Tips

1. **Avoid copy-paste:** Type queries yourself to build muscle memory
2. **Experiment:** Try variations of the queries
3. **Use EXPLAIN:** To see query execution plans
4. **Check row counts:** Use `COUNT(*)` to verify results
5. **Save your work:** Keep your queries in a local file

## 🎓 After Completion

You will have learned:
- ✅ Creating and managing Snowflake objects
- ✅ Loading data via stages
- ✅ Writing SQL queries (SELECT, GROUP BY, HAVING)
- ✅ Working with dimensional models
- ✅ Transforming data
- ✅ Querying semi-structured data (JSON)
- ✅ Writing business intelligence queries

**Ready for the next modules!** 🚀
