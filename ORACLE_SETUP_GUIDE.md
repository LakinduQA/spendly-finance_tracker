# Oracle Database Setup Guide
**Personal Finance Management System**

## 📋 Quick Answer to Your Questions

### Q1: What queries should I run to create the tables?
**Answer**: Run the complete script: `d:\DM2_CW\oracle\01_create_database.sql`

### Q2: Should Oracle tables be the same as SQLite tables?
**Answer**: YES! They MUST match for synchronization to work. The script already ensures this.

---

## 🚀 Step-by-Step Oracle Setup

### Step 1: Connect to Oracle Database

```sql
-- Using SQL*Plus
sqlplus sys as sysdba
-- Or use your admin credentials
```

### Step 2: Run the Complete Creation Script

```sql
-- This creates EVERYTHING:
@d:\DM2_CW\oracle\01_create_database.sql
```

### Step 3: Verify the Setup

```sql
-- Connect as the application user
CONN finance_admin/FinanceSecure2025

-- Check tables created
SELECT table_name FROM user_tables ORDER BY table_name;

-- Check sequences created
SELECT sequence_name FROM user_sequences ORDER BY sequence_name;

-- Check triggers created
SELECT trigger_name FROM user_triggers ORDER BY trigger_name;

-- Check views created
SELECT view_name FROM user_views ORDER BY view_name;

-- Check default categories
SELECT category_id, category_name, category_type FROM finance_category;
```

---

## 📊 What the Script Creates

### **9 Sequences** (for auto-increment IDs):
```sql
seq_user_id
seq_category_id
seq_expense_id
seq_income_id
seq_budget_id
seq_goal_id
seq_contribution_id
seq_sync_log_id
seq_audit_id
```

### **9 Tables** (matching SQLite exactly):
```sql
finance_user              -- User accounts
finance_category          -- Income/Expense categories
finance_expense           -- Expense transactions
finance_income            -- Income transactions
finance_budget            -- Budget allocations
finance_savings_goal      -- Savings goals
finance_savings_contribution -- Goal contributions
finance_sync_log          -- Synchronization tracking
finance_audit_log         -- Audit trail
```

### **20+ Triggers** (for automation):
- Auto-increment ID triggers (using sequences)
- Timestamp update triggers
- Fiscal year/month calculation triggers
- Constraint validation triggers

### **30+ Indexes** (for performance):
- Primary key indexes
- Foreign key indexes
- Date range indexes
- User-specific indexes
- Category indexes

### **5 Views** (for reporting):
```sql
vw_monthly_expenses       -- Monthly expense summary
vw_budget_utilization     -- Budget vs actual spending
vw_category_totals        -- Category-wise totals
vw_goal_progress          -- Savings goal progress
vw_user_summary           -- User financial summary
```

---

## 🔄 SQLite vs Oracle: Mapping

### Table Names
| SQLite | Oracle | Notes |
|--------|--------|-------|
| `user` | `finance_user` | Oracle prefix for clarity |
| `category` | `finance_category` | Same structure |
| `expense` | `finance_expense` | Same columns |
| `income` | `finance_income` | Same columns |
| `budget` | `finance_budget` | Same columns |
| `savings_goal` | `finance_savings_goal` | Same columns |
| `savings_contribution` | `finance_savings_contribution` | Same columns |
| `sync_log` | `finance_sync_log` | Same columns |

### Column Types
| SQLite | Oracle | Example |
|--------|--------|---------|
| `INTEGER PRIMARY KEY AUTOINCREMENT` | `NUMBER(10) + Sequence + Trigger` | user_id |
| `DATETIME DEFAULT CURRENT_TIMESTAMP` | `TIMESTAMP DEFAULT SYSTIMESTAMP` | created_at |
| `REAL` | `NUMBER(10,2)` | amount |
| `VARCHAR(50)` | `VARCHAR2(50)` | username |
| `INTEGER` (boolean) | `NUMBER(1) CHECK (0,1)` | is_active |

---

## 📝 Default Data Included

The script automatically populates **13 default categories**:

### Expense Categories:
1. Groceries
2. Rent
3. Utilities
4. Transportation
5. Entertainment
6. Healthcare
7. Education
8. Shopping
9. Dining Out
10. Other Expenses

### Income Categories:
1. Salary
2. Freelance
3. Other Income

---

## ✅ Verification Queries

### After running the script, verify everything:

```sql
-- 1. Check table count (should be 9)
SELECT COUNT(*) as table_count FROM user_tables;

-- 2. Check sequence count (should be 9)
SELECT COUNT(*) as sequence_count FROM user_sequences;

-- 3. Check trigger count (should be 20+)
SELECT COUNT(*) as trigger_count FROM user_triggers;

-- 4. Check index count (should be 30+)
SELECT COUNT(*) as index_count FROM user_indexes;

-- 5. Check view count (should be 5)
SELECT COUNT(*) as view_count FROM user_views;

-- 6. Check categories (should be 13)
SELECT COUNT(*) as category_count FROM finance_category;

-- 7. Test a sequence
SELECT seq_user_id.NEXTVAL FROM dual;

-- 8. Test a view
SELECT * FROM vw_user_summary;
```

---

## 🔧 Troubleshooting

### If you get "insufficient privileges":
```sql
-- Grant additional permissions
GRANT CREATE TABLE TO finance_admin;
GRANT CREATE TRIGGER TO finance_admin;
GRANT CREATE SEQUENCE TO finance_admin;
GRANT CREATE VIEW TO finance_admin;
```

### If tablespace doesn't exist:
```sql
-- Run as SYS/SYSTEM
CREATE TABLESPACE finance_data
DATAFILE 'finance_data01.dbf' SIZE 100M
AUTOEXTEND ON NEXT 10M MAXSIZE 500M;
```

### If user doesn't exist:
```sql
-- The script creates the user automatically
-- Username: finance_admin
-- Password: FinanceSecure2025
```

---

## 🎯 Next Steps After Oracle Setup

### 1. Install cx_Oracle Python Package
```bash
pip install cx_Oracle
```

### 2. Update Configuration File
Edit `d:\DM2_CW\synchronization\config.ini`:

```ini
[oracle]
username = finance_admin
password = FinanceSecure2025
dsn = localhost:1521/XEPDB1
```

### 3. Test Oracle Connection
```bash
cd d:\DM2_CW\synchronization
python -c "import cx_Oracle; conn = cx_Oracle.connect('finance_admin', 'FinanceSecure2025', 'localhost:1521/XEPDB1'); print('Connected!'); conn.close()"
```

### 4. Test Synchronization
```bash
cd d:\DM2_CW\synchronization
python sync_manager.py
```

---

## 📚 Additional Scripts Ready to Run

After the database is created, you can install:

### 1. PL/SQL CRUD Package
```sql
@d:\DM2_CW\oracle\02_plsql_crud_package.sql
```
This provides procedures/functions for all CRUD operations.

### 2. Reports Package
```sql
@d:\DM2_CW\oracle\03_reports_package.sql
```
This provides 5 financial reports with CSV export.

---

## ✅ Success Criteria

Your Oracle database is ready when:
- ✅ All 9 tables exist
- ✅ All 9 sequences exist
- ✅ All triggers are enabled
- ✅ All indexes are valid
- ✅ All 5 views are accessible
- ✅ 13 categories are populated
- ✅ You can insert test data
- ✅ Python can connect using cx_Oracle

---

## 🎉 Summary

**YES - Oracle tables MUST match SQLite tables!**

The script `01_create_database.sql` already ensures this by:
1. Using the same table structure
2. Using the same column names
3. Using the same data types (converted to Oracle syntax)
4. Using the same constraints
5. Using the same default values

**Just run the one script and everything will be set up correctly for synchronization!**

---
*Created: November 1, 2025*
