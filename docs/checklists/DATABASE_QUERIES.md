# Database Query Reference

**Personal Finance Management System**  
**Quick Reference for Checking Table Data**

---

## SQLite Queries

### Connect to SQLite Database

```bash
# Windows
cd D:\DM2_CW\sqlite
sqlite3 finance_local.db

# Linux/Mac
cd /path/to/DM2_CW/sqlite
sqlite3 finance_local.db
```

---

### 1. USER Table

```sql
-- View all users
SELECT * FROM user;

-- Count users
SELECT COUNT(*) AS total_users FROM user;

-- View specific user
SELECT * FROM user WHERE user_id = 2;

-- View users with details
SELECT user_id, username, email, full_name, created_at 
FROM user 
ORDER BY created_at DESC;
```

---

### 2. CATEGORY Table

```sql
-- View all categories
SELECT * FROM category;

-- Count categories
SELECT COUNT(*) AS total_categories FROM category;

-- View by category type
SELECT * FROM category WHERE category_type = 'EXPENSE';
SELECT * FROM category WHERE category_type = 'INCOME';

-- View active categories
SELECT category_id, category_name, category_type, icon, color
FROM category 
WHERE is_active = 1
ORDER BY category_name;
```

---

### 3. EXPENSE Table

```sql
-- View all expenses
SELECT * FROM expense;

-- Count expenses
SELECT COUNT(*) AS total_expenses FROM expense;

-- View expenses for specific user
SELECT * FROM expense WHERE user_id = 2;

-- View recent expenses (last 10)
SELECT e.expense_id, u.username, c.category_name, e.amount, 
       e.expense_date, e.description, e.payment_method
FROM expense e
JOIN user u ON e.user_id = u.user_id
JOIN category c ON e.category_id = c.category_id
ORDER BY e.expense_date DESC
LIMIT 10;

-- View expenses for current month
SELECT * FROM expense 
WHERE strftime('%Y-%m', expense_date) = strftime('%Y-%m', 'now');

-- Total expenses by user
SELECT u.username, COUNT(*) AS expense_count, SUM(e.amount) AS total_amount
FROM expense e
JOIN user u ON e.user_id = u.user_id
GROUP BY u.username
ORDER BY total_amount DESC;
```

---

### 4. INCOME Table

```sql
-- View all income
SELECT * FROM income;

-- Count income records
SELECT COUNT(*) AS total_income FROM income;

-- View income for specific user
SELECT * FROM income WHERE user_id = 2;

-- View recent income (last 10)
SELECT i.income_id, u.username, c.category_name, i.amount, 
       i.income_date, i.description, i.income_source
FROM income i
JOIN user u ON i.user_id = u.user_id
JOIN category c ON i.category_id = c.category_id
ORDER BY i.income_date DESC
LIMIT 10;

-- Total income by user
SELECT u.username, COUNT(*) AS income_count, SUM(i.amount) AS total_amount
FROM income i
JOIN user u ON i.user_id = u.user_id
GROUP BY u.username
ORDER BY total_amount DESC;
```

---

### 5. BUDGET Table

```sql
-- View all budgets
SELECT * FROM budget;

-- Count budgets
SELECT COUNT(*) AS total_budgets FROM budget;

-- View budgets for specific user
SELECT * FROM budget WHERE user_id = 2;

-- View active budgets
SELECT b.budget_id, u.username, c.category_name, b.budget_amount,
       b.start_date, b.end_date, b.budget_status
FROM budget b
JOIN user u ON b.user_id = u.user_id
JOIN category c ON b.category_id = c.category_id
WHERE b.budget_status = 'Active'
ORDER BY b.start_date DESC;

-- Budget utilization
SELECT u.username, c.category_name, b.budget_amount,
       COALESCE(SUM(e.amount), 0) AS spent,
       (b.budget_amount - COALESCE(SUM(e.amount), 0)) AS remaining,
       ROUND((COALESCE(SUM(e.amount), 0) * 100.0 / b.budget_amount), 2) AS utilization_percent
FROM budget b
JOIN user u ON b.user_id = u.user_id
JOIN category c ON b.category_id = c.category_id
LEFT JOIN expense e ON e.user_id = b.user_id 
    AND e.category_id = b.category_id
    AND e.expense_date BETWEEN b.start_date AND b.end_date
WHERE b.budget_status = 'Active'
GROUP BY b.budget_id, u.username, c.category_name, b.budget_amount
ORDER BY utilization_percent DESC;
```

---

### 6. SAVINGS_GOAL Table

```sql
-- View all savings goals
SELECT * FROM savings_goal;

-- Count savings goals
SELECT COUNT(*) AS total_goals FROM savings_goal;

-- View goals for specific user
SELECT * FROM savings_goal WHERE user_id = 2;

-- View active goals
SELECT goal_id, goal_name, target_amount, current_amount, target_date, goal_status
FROM savings_goal
WHERE goal_status = 'Active'
ORDER BY target_date;

-- Goals with progress percentage
SELECT u.username, g.goal_name, g.target_amount, g.current_amount,
       ROUND((g.current_amount * 100.0 / g.target_amount), 2) AS progress_percent,
       g.target_date, g.goal_status
FROM savings_goal g
JOIN user u ON g.user_id = u.user_id
ORDER BY progress_percent DESC;
```

---

### 7. SAVINGS_CONTRIBUTION Table

```sql
-- View all contributions
SELECT * FROM savings_contribution;

-- Count contributions
SELECT COUNT(*) AS total_contributions FROM savings_contribution;

-- View contributions for specific goal
SELECT * FROM savings_contribution WHERE goal_id = 1;

-- View recent contributions
SELECT sc.contribution_id, u.username, g.goal_name, 
       sc.contribution_amount, sc.contribution_date, sc.contribution_notes
FROM savings_contribution sc
JOIN savings_goal g ON sc.goal_id = g.goal_id
JOIN user u ON g.user_id = u.user_id
ORDER BY sc.contribution_date DESC
LIMIT 10;

-- Total contributions by goal
SELECT g.goal_name, COUNT(*) AS contribution_count, 
       SUM(sc.contribution_amount) AS total_contributed
FROM savings_contribution sc
JOIN savings_goal g ON sc.goal_id = g.goal_id
GROUP BY g.goal_name
ORDER BY total_contributed DESC;
```

---

### 8. SYNC_LOG Table

```sql
-- View all sync logs
SELECT * FROM sync_log;

-- Count sync logs
SELECT COUNT(*) AS total_syncs FROM sync_log;

-- View recent syncs
SELECT sync_log_id, user_id, sync_start_time, sync_end_time, 
       records_synced, sync_status, sync_type
FROM sync_log
ORDER BY sync_start_time DESC
LIMIT 10;

-- Sync statistics by user
SELECT u.username, 
       COUNT(*) AS total_syncs,
       SUM(sl.records_synced) AS total_records_synced,
       SUM(CASE WHEN sl.sync_status = 'Success' THEN 1 ELSE 0 END) AS successful_syncs,
       SUM(CASE WHEN sl.sync_status = 'Failed' THEN 1 ELSE 0 END) AS failed_syncs
FROM sync_log sl
JOIN user u ON sl.user_id = u.user_id
GROUP BY u.username
ORDER BY total_syncs DESC;

-- Average sync duration
SELECT AVG(
    (julianday(sync_end_time) - julianday(sync_start_time)) * 86400
) AS avg_sync_seconds
FROM sync_log
WHERE sync_status = 'Success';
```

---

## Oracle Queries

### Connect to Oracle Database

```bash
sqlplus finance_user/password@172.20.10.4:1521/xe
```

---

### 1. FINANCE_USER Table

```sql
-- View all users
SELECT * FROM finance_user;

-- Count users
SELECT COUNT(*) AS total_users FROM finance_user;

-- View specific user
SELECT * FROM finance_user WHERE user_id = 2;

-- View users with details
SELECT user_id, username, email, full_name, 
       TO_CHAR(created_at, 'YYYY-MM-DD HH24:MI:SS') AS created_at
FROM finance_user
ORDER BY created_at DESC;
```

---

### 2. FINANCE_CATEGORY Table

```sql
-- View all categories
SELECT * FROM finance_category;

-- Count categories
SELECT COUNT(*) AS total_categories FROM finance_category;

-- View by category type
SELECT * FROM finance_category WHERE category_type = 'EXPENSE';
SELECT * FROM finance_category WHERE category_type = 'INCOME';

-- View active categories
SELECT category_id, category_name, category_type, icon, color
FROM finance_category
WHERE is_active = 1
ORDER BY category_name;
```

---

### 3. FINANCE_EXPENSE Table

```sql
-- View all expenses
SELECT * FROM finance_expense;

-- Count expenses
SELECT COUNT(*) AS total_expenses FROM finance_expense;

-- View expenses for specific user
SELECT * FROM finance_expense WHERE user_id = 2;

-- View recent expenses (last 10)
SELECT e.expense_id, u.username, c.category_name, e.amount,
       TO_CHAR(e.expense_date, 'YYYY-MM-DD') AS expense_date,
       e.description, e.payment_method
FROM finance_expense e
JOIN finance_user u ON e.user_id = u.user_id
JOIN finance_category c ON e.category_id = c.category_id
ORDER BY e.expense_date DESC
FETCH FIRST 10 ROWS ONLY;

-- View expenses for current month
SELECT * FROM finance_expense
WHERE TO_CHAR(expense_date, 'YYYY-MM') = TO_CHAR(SYSDATE, 'YYYY-MM');

-- Total expenses by user
SELECT u.username, COUNT(*) AS expense_count, SUM(e.amount) AS total_amount
FROM finance_expense e
JOIN finance_user u ON e.user_id = u.user_id
GROUP BY u.username
ORDER BY total_amount DESC;
```

---

### 4. FINANCE_INCOME Table

```sql
-- View all income
SELECT * FROM finance_income;

-- Count income records
SELECT COUNT(*) AS total_income FROM finance_income;

-- View income for specific user
SELECT * FROM finance_income WHERE user_id = 2;

-- View recent income (last 10)
SELECT i.income_id, u.username, c.category_name, i.amount,
       TO_CHAR(i.income_date, 'YYYY-MM-DD') AS income_date,
       i.description, i.income_source
FROM finance_income i
JOIN finance_user u ON i.user_id = u.user_id
JOIN finance_category c ON i.category_id = c.category_id
ORDER BY i.income_date DESC
FETCH FIRST 10 ROWS ONLY;

-- Total income by user
SELECT u.username, COUNT(*) AS income_count, SUM(i.amount) AS total_amount
FROM finance_income i
JOIN finance_user u ON i.user_id = u.user_id
GROUP BY u.username
ORDER BY total_amount DESC;
```

---

### 5. FINANCE_BUDGET Table

```sql
-- View all budgets
SELECT * FROM finance_budget;

-- Count budgets
SELECT COUNT(*) AS total_budgets FROM finance_budget;

-- View budgets for specific user
SELECT * FROM finance_budget WHERE user_id = 2;

-- View active budgets
SELECT b.budget_id, u.username, c.category_name, b.budget_amount,
       TO_CHAR(b.start_date, 'YYYY-MM-DD') AS start_date,
       TO_CHAR(b.end_date, 'YYYY-MM-DD') AS end_date,
       b.budget_status
FROM finance_budget b
JOIN finance_user u ON b.user_id = u.user_id
JOIN finance_category c ON b.category_id = c.category_id
WHERE b.budget_status = 'Active'
ORDER BY b.start_date DESC;

-- Budget utilization
SELECT u.username, c.category_name, b.budget_amount,
       NVL(SUM(e.amount), 0) AS spent,
       (b.budget_amount - NVL(SUM(e.amount), 0)) AS remaining,
       ROUND((NVL(SUM(e.amount), 0) * 100.0 / b.budget_amount), 2) AS utilization_percent
FROM finance_budget b
JOIN finance_user u ON b.user_id = u.user_id
JOIN finance_category c ON b.category_id = c.category_id
LEFT JOIN finance_expense e ON e.user_id = b.user_id
    AND e.category_id = b.category_id
    AND e.expense_date BETWEEN b.start_date AND b.end_date
WHERE b.budget_status = 'Active'
GROUP BY b.budget_id, u.username, c.category_name, b.budget_amount
ORDER BY utilization_percent DESC;
```

---

### 6. FINANCE_SAVINGS_GOAL Table

```sql
-- View all savings goals
SELECT * FROM finance_savings_goal;

-- Count savings goals
SELECT COUNT(*) AS total_goals FROM finance_savings_goal;

-- View goals for specific user
SELECT * FROM finance_savings_goal WHERE user_id = 2;

-- View active goals
SELECT goal_id, goal_name, target_amount, current_amount,
       TO_CHAR(target_date, 'YYYY-MM-DD') AS target_date, goal_status
FROM finance_savings_goal
WHERE goal_status = 'Active'
ORDER BY target_date;

-- Goals with progress percentage
SELECT u.username, g.goal_name, g.target_amount, g.current_amount,
       ROUND((g.current_amount * 100.0 / g.target_amount), 2) AS progress_percent,
       TO_CHAR(g.target_date, 'YYYY-MM-DD') AS target_date, g.goal_status
FROM finance_savings_goal g
JOIN finance_user u ON g.user_id = u.user_id
ORDER BY progress_percent DESC;
```

---

### 7. FINANCE_SAVINGS_CONTRIBUTION Table

```sql
-- View all contributions
SELECT * FROM finance_savings_contribution;

-- Count contributions
SELECT COUNT(*) AS total_contributions FROM finance_savings_contribution;

-- View contributions for specific goal
SELECT * FROM finance_savings_contribution WHERE goal_id = 1;

-- View recent contributions
SELECT sc.contribution_id, u.username, g.goal_name,
       sc.contribution_amount,
       TO_CHAR(sc.contribution_date, 'YYYY-MM-DD') AS contribution_date,
       sc.contribution_notes
FROM finance_savings_contribution sc
JOIN finance_savings_goal g ON sc.goal_id = g.goal_id
JOIN finance_user u ON g.user_id = u.user_id
ORDER BY sc.contribution_date DESC
FETCH FIRST 10 ROWS ONLY;

-- Total contributions by goal
SELECT g.goal_name, COUNT(*) AS contribution_count,
       SUM(sc.contribution_amount) AS total_contributed
FROM finance_savings_contribution sc
JOIN finance_savings_goal g ON sc.goal_id = g.goal_id
GROUP BY g.goal_name
ORDER BY total_contributed DESC;
```

---

### 8. FINANCE_SYNC_LOG Table

```sql
-- View all sync logs
SELECT * FROM finance_sync_log;

-- Count sync logs
SELECT COUNT(*) AS total_syncs FROM finance_sync_log;

-- View recent syncs
SELECT sync_log_id, user_id,
       TO_CHAR(sync_start_time, 'YYYY-MM-DD HH24:MI:SS') AS sync_start,
       TO_CHAR(sync_end_time, 'YYYY-MM-DD HH24:MI:SS') AS sync_end,
       records_synced, sync_status, sync_type
FROM finance_sync_log
ORDER BY sync_start_time DESC
FETCH FIRST 10 ROWS ONLY;

-- Sync statistics by user
SELECT u.username,
       COUNT(*) AS total_syncs,
       SUM(sl.records_synced) AS total_records_synced,
       SUM(CASE WHEN sl.sync_status = 'Success' THEN 1 ELSE 0 END) AS successful_syncs,
       SUM(CASE WHEN sl.sync_status = 'Failed' THEN 1 ELSE 0 END) AS failed_syncs
FROM finance_sync_log sl
JOIN finance_user u ON sl.user_id = u.user_id
GROUP BY u.username
ORDER BY total_syncs DESC;

-- Average sync duration
SELECT AVG(
    (CAST(sync_end_time AS DATE) - CAST(sync_start_time AS DATE)) * 86400
) AS avg_sync_seconds
FROM finance_sync_log
WHERE sync_status = 'Success';
```

---

## Useful Administrative Queries

### SQLite

```sql
-- List all tables
SELECT name FROM sqlite_master WHERE type='table';

-- Table schema
PRAGMA table_info(expense);

-- List all indexes
SELECT name, tbl_name FROM sqlite_master WHERE type='index';

-- List all triggers
SELECT name, tbl_name FROM sqlite_master WHERE type='trigger';

-- List all views
SELECT name, sql FROM sqlite_master WHERE type='view';

-- Database size
SELECT page_count * page_size AS size_bytes 
FROM pragma_page_count(), pragma_page_size();

-- Vacuum database (optimize)
VACUUM;

-- Analyze database (update statistics)
ANALYZE;
```

---

### Oracle

```sql
-- List all tables
SELECT table_name FROM user_tables ORDER BY table_name;

-- Table schema
DESC finance_expense;

-- List all indexes
SELECT index_name, table_name, uniqueness 
FROM user_indexes 
ORDER BY table_name;

-- List all triggers
SELECT trigger_name, table_name, triggering_event 
FROM user_triggers 
ORDER BY table_name;

-- List all sequences
SELECT sequence_name, last_number 
FROM user_sequences 
ORDER BY sequence_name;

-- List all packages
SELECT object_name, object_type, status 
FROM user_objects 
WHERE object_type IN ('PACKAGE', 'PACKAGE BODY')
ORDER BY object_name;

-- Check PL/SQL package status
SELECT object_name, object_type, status, last_ddl_time
FROM user_objects
WHERE object_name LIKE 'PKG_FINANCE%'
ORDER BY object_name;

-- Table sizes
SELECT segment_name, bytes/1024/1024 AS size_mb
FROM user_segments
WHERE segment_type = 'TABLE'
ORDER BY bytes DESC;

-- Index sizes
SELECT segment_name, bytes/1024/1024 AS size_mb
FROM user_segments
WHERE segment_type = 'INDEX'
ORDER BY bytes DESC;
```

---

## Quick Data Verification

### Check Data Consistency (SQLite vs Oracle)

```sql
-- SQLite: Record counts
SELECT 'users' AS table_name, COUNT(*) AS count FROM user
UNION ALL
SELECT 'categories', COUNT(*) FROM category
UNION ALL
SELECT 'expenses', COUNT(*) FROM expense
UNION ALL
SELECT 'income', COUNT(*) FROM income
UNION ALL
SELECT 'budgets', COUNT(*) FROM budget
UNION ALL
SELECT 'savings_goals', COUNT(*) FROM savings_goal
UNION ALL
SELECT 'contributions', COUNT(*) FROM savings_contribution
UNION ALL
SELECT 'sync_logs', COUNT(*) FROM sync_log;

-- Oracle: Record counts
SELECT 'users' AS table_name, COUNT(*) AS count FROM finance_user
UNION ALL
SELECT 'categories', COUNT(*) FROM finance_category
UNION ALL
SELECT 'expenses', COUNT(*) FROM finance_expense
UNION ALL
SELECT 'income', COUNT(*) FROM finance_income
UNION ALL
SELECT 'budgets', COUNT(*) FROM finance_budget
UNION ALL
SELECT 'savings_goals', COUNT(*) FROM finance_savings_goal
UNION ALL
SELECT 'contributions', COUNT(*) FROM finance_savings_contribution
UNION ALL
SELECT 'sync_logs', COUNT(*) FROM finance_sync_log;
```

---

## Export Data to CSV

### SQLite

```sql
-- Enable headers and CSV mode
.headers on
.mode csv
.output expenses.csv
SELECT * FROM expense;
.output stdout
```

### Oracle

```sql
-- Using SQL*Plus
SET COLSEP ','
SET PAGESIZE 0
SET TRIMSPOOL ON
SET HEADSEP OFF
SET LINESIZE 1000
SPOOL expenses.csv
SELECT * FROM finance_expense;
SPOOL OFF
```

---

## Performance Testing Queries

### SQLite

```sql
-- Query execution time
.timer on

-- Test query performance
SELECT COUNT(*) FROM expense WHERE user_id = 2;

-- Check query plan
EXPLAIN QUERY PLAN 
SELECT * FROM expense WHERE user_id = 2 AND expense_date >= '2025-10-01';
```

### Oracle

```sql
-- Enable timing
SET TIMING ON

-- Test query performance
SELECT COUNT(*) FROM finance_expense WHERE user_id = 2;

-- Check execution plan
EXPLAIN PLAN FOR
SELECT * FROM finance_expense WHERE user_id = 2 AND expense_date >= TO_DATE('2025-10-01', 'YYYY-MM-DD');

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);
```

---

**Quick Reference Guide**  
**Last Updated**: November 4, 2025  
**Database Version**: SQLite 3.35+ | Oracle 21c XE
