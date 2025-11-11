# 🔧 SYSTEM TECHNICAL QUESTIONS
## Personal Finance Management System - Deep Dive

**Purpose**: Technical explanations for viva demonstration  
**Date**: November 11, 2025

---

## �️ QUICK FILE REFERENCE

**If lecturer asks to show code, open these files:**

| Topic | File Location | Lines | What to Show |
|-------|--------------|-------|--------------|
| **PL/SQL Reports** | `oracle\03_reports_package.sql` | 1-720 | Package with 5 reports |
| **PL/SQL CRUD** | `oracle\02_plsql_crud_package.sql` | 1-818 | 31 procedures for CRUD |
| **Synchronization** | `synchronization\sync_manager.py` | 1-400+ | Sync logic |
| **Flask App** | `webapp\app.py` | 1-2000+ | Web application |
| **SQLite Schema** | `sqlite\01_create_database.sql` | 1-485 | Local database |
| **Oracle Schema** | `oracle\01_create_database.sql` | 1-600+ | Cloud database |
| **Soft Delete** | `sqlite\06_add_soft_delete.sql` | 1-50 | is_deleted column |
| **Soft Delete (Oracle)** | `oracle\07_add_soft_delete.sql` | 1-50 | is_deleted column |

---

## �📋 TABLE OF CONTENTS

1. [Synchronization Process](#1-synchronization-process)
2. [Security Measures](#2-security-measures)
3. [PL/SQL Techniques Used](#3-plsql-techniques-used)
4. [PL/SQL Report Generation](#4-plsql-report-generation)
5. [Database Backup Strategy](#5-database-backup-strategy)

---

## 1. SYNCHRONIZATION PROCESS

### **How Synchronization Works**

#### **📌 Key Points:**
- Uses `sync_manager.py` as the synchronization engine
- Bidirectional sync between SQLite (local) and Oracle (cloud)
- Tracks sync status with `is_synced` flag
- Handles conflicts using last-modified-wins strategy
- Batch operations for performance (~0.20 seconds for 1,350 records)

#### **🔗 Database Connections:**

**SQLite Connection:**
```python
# Local database connection
conn = sqlite3.connect('sqlite/finance_local.db')
conn.row_factory = sqlite3.Row  # Access columns by name
cursor = conn.cursor()
```

**Oracle Connection:**
```python
# Cloud database connection
import cx_Oracle

oracle_conn = cx_Oracle.connect(
    user='your_username',
    password='your_password',
    dsn='172.20.10.4:1521/xe',  # Host:Port/ServiceName
    encoding='UTF-8'
)
oracle_cursor = oracle_conn.cursor()
```

#### **🔄 Sync Process (12 Steps):**

1. **Connect to both databases**
   - Establish SQLite connection
   - Establish Oracle connection

2. **Start sync log**
   - Record sync start time
   - Set sync type (Manual/Automatic)

3. **Fetch pending records from SQLite**
   ```python
   # Get records where is_synced = 0
   cursor.execute("SELECT * FROM income WHERE is_synced = 0")
   pending_income = cursor.fetchall()
   ```

4. **Check if record exists in Oracle**
   ```python
   oracle_cursor.execute(
       "SELECT income_id FROM finance_income WHERE income_id = :id",
       {'id': record['income_id']}
   )
   exists = oracle_cursor.fetchone()
   ```

5. **INSERT or UPDATE in Oracle**
   ```python
   if not exists:
       # INSERT new record
       oracle_cursor.execute(
           "INSERT INTO finance_income VALUES (:1, :2, :3, ...)",
           (record['income_id'], record['user_id'], ...)
       )
   else:
       # UPDATE existing record
       oracle_cursor.execute(
           "UPDATE finance_income SET amount = :amt WHERE income_id = :id",
           {'amt': record['amount'], 'id': record['income_id']}
       )
   ```

6. **Mark as synced in SQLite**
   ```python
   cursor.execute(
       "UPDATE income SET is_synced = 1 WHERE income_id = ?",
       (record['income_id'],)
   )
   ```

7. **Fetch new records from Oracle**
   ```python
   # Get Oracle records not in SQLite
   oracle_cursor.execute(
       "SELECT * FROM finance_income WHERE synced_from_local = 0"
   )
   ```

8. **Sync Oracle → SQLite**
   - Same INSERT/UPDATE logic in reverse

9. **Handle soft deletes**
   ```python
   # Sync is_deleted flag both ways
   cursor.execute("UPDATE expense SET is_deleted = 1 WHERE expense_id = ?")
   ```

10. **Commit transactions**
    ```python
    conn.commit()
    oracle_conn.commit()
    ```

11. **Update sync log**
    ```python
    cursor.execute(
        "UPDATE sync_log SET sync_end_time = ?, records_synced = ?, sync_status = 'Success'",
        (datetime.now(), total_records)
    )
    ```

12. **Close connections**
    ```python
    cursor.close()
    conn.close()
    oracle_cursor.close()
    oracle_conn.close()
    ```

#### **⚡ Performance Optimization:**
- **Batch operations**: Process multiple records in single transaction
- **Connection pooling**: Reuse database connections
- **Indexed columns**: Fast lookups on `user_id`, `is_synced`
- **Prepared statements**: Faster execution, prevents SQL injection

---

## 2. SECURITY MEASURES

### **Database Security**

#### **📌 Key Points:**
- Password hashing with PBKDF2-SHA256
- Parameterized queries prevent SQL injection
- Foreign key constraints maintain data integrity
- CHECK constraints validate data
- User privileges and roles (Oracle)

#### **🔐 Security Implementation:**

**1. Password Security:**
```python
from werkzeug.security import generate_password_hash, check_password_hash

# Registration - Hash password
password_hash = generate_password_hash(
    password, 
    method='pbkdf2:sha256', 
    salt_length=16
)

# Login - Verify password
if check_password_hash(stored_hash, entered_password):
    # Login successful
```

**2. SQL Injection Prevention:**
```python
# ❌ BAD - Vulnerable to SQL injection
query = f"SELECT * FROM user WHERE username = '{username}'"

# ✅ GOOD - Parameterized query
query = "SELECT * FROM user WHERE username = ?"
cursor.execute(query, (username,))
```

**3. Database Constraints:**
```sql
-- SQLite constraints
CHECK (amount > 0)
CHECK (email LIKE '%@%')
CHECK (is_deleted IN (0, 1))
FOREIGN KEY (user_id) REFERENCES user(user_id) ON DELETE CASCADE
```

**4. Oracle User Privileges:**
```sql
-- Create limited user
CREATE USER finance_admin IDENTIFIED BY SecurePassword2025;
GRANT CONNECT, RESOURCE TO finance_admin;
-- No DROP, ALTER SYSTEM privileges (limited access)
```

### **System Security**

#### **📌 Key Points:**
- Session management with Flask
- HTTPS for production (encrypted communication)
- Environment variables for sensitive data
- Input validation and sanitization
- CSRF protection

#### **🛡️ Security Implementation:**

**1. Session Management:**
```python
from flask import session

# Login - Create session
session['user_id'] = user_id
session['username'] = username

# Protected routes - Check session
@app.route('/dashboard')
def dashboard():
    if 'user_id' not in session:
        return redirect(url_for('login'))
    # User is authenticated
```

**2. Environment Variables:**
```python
import os
from dotenv import load_dotenv

load_dotenv()

# Don't hardcode credentials
ORACLE_USER = os.getenv('ORACLE_USER')
ORACLE_PASSWORD = os.getenv('ORACLE_PASSWORD')
```

**3. Input Validation:**
```python
# Validate email format
if not re.match(r'^[\w\.-]+@[\w\.-]+\.\w+$', email):
    return "Invalid email format"

# Validate amount is positive
if float(amount) <= 0:
    return "Amount must be positive"
```

**4. Error Handling:**
```python
try:
    cursor.execute(query, params)
except sqlite3.IntegrityError:
    return "Username already exists"
except Exception as e:
    logging.error(f"Database error: {e}")
    return "An error occurred"
```

---

## 3. PL/SQL TECHNIQUES USED

### **📌 Key Techniques:**
1. **Stored Procedures** - Encapsulate business logic
2. **Cursors** - Iterate through result sets
3. **Loops** - FOR, WHILE loops for processing
4. **Exception Handling** - Robust error management
5. **Packages** - Organize related procedures
6. **RETURNING Clause** - Get auto-generated IDs
7. **NVL/COALESCE** - Handle NULL values
8. **Triggers** - Auto-update timestamps

---

### **1. Stored Procedures**

**Purpose**: Encapsulate CRUD operations in reusable procedures

```sql
CREATE OR REPLACE PROCEDURE sp_add_income(
    p_user_id IN NUMBER,
    p_income_source IN VARCHAR2,
    p_amount IN NUMBER,
    p_income_date IN DATE,
    p_description IN VARCHAR2,
    p_income_id OUT NUMBER  -- Return generated ID
)
IS
BEGIN
    INSERT INTO finance_income (
        user_id, income_source, amount, income_date, description
    ) VALUES (
        p_user_id, p_income_source, p_amount, p_income_date, p_description
    ) RETURNING income_id INTO p_income_id;  -- Get auto-generated ID
    
    COMMIT;
    
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20001, 'Error adding income: ' || SQLERRM);
END;
/
```

**Key Points:**
- `IN` parameters = input
- `OUT` parameters = output (return values)
- `RETURNING INTO` = get auto-generated primary key
- `EXCEPTION` block = error handling
- `COMMIT/ROLLBACK` = transaction control

---

### **2. Cursors**

**Purpose**: Fetch and process multiple rows one by one

```sql
CREATE OR REPLACE PROCEDURE sp_get_user_expenses(
    p_user_id IN NUMBER,
    p_expense_cursor OUT SYS_REFCURSOR  -- Return cursor to caller
)
IS
BEGIN
    OPEN p_expense_cursor FOR
        SELECT e.expense_id, c.category_name, e.amount, e.expense_date
        FROM finance_expense e
        JOIN finance_category c ON e.category_id = c.category_id
        WHERE e.user_id = p_user_id
          AND (e.is_deleted = 0 OR e.is_deleted IS NULL)
        ORDER BY e.expense_date DESC;
        
    -- Cursor is returned to caller (Python fetches the rows)
END;
/
```

**Key Points:**
- `SYS_REFCURSOR` = cursor variable (can be returned)
- `OPEN ... FOR` = execute query and populate cursor
- Caller (Python) uses `cursor.fetchall()` to get rows

**Python Usage:**
```python
cursor = oracle_conn.cursor()
result_cursor = cursor.var(cx_Oracle.CURSOR)

cursor.callproc('sp_get_user_expenses', [user_id, result_cursor])

for row in result_cursor.getvalue():
    print(row)
```

---

### **3. Loops**

**Purpose**: Iterate through data for processing

**FOR Loop (with cursor):**
```sql
CREATE OR REPLACE PROCEDURE sp_calculate_total_expenses(
    p_user_id IN NUMBER,
    p_total OUT NUMBER
)
IS
    v_sum NUMBER := 0;
BEGIN
    -- FOR loop automatically declares cursor and iterates
    FOR expense_rec IN (
        SELECT amount 
        FROM finance_expense 
        WHERE user_id = p_user_id
          AND (is_deleted = 0 OR is_deleted IS NULL)
    ) LOOP
        v_sum := v_sum + expense_rec.amount;
    END LOOP;
    
    p_total := v_sum;
END;
/
```

**WHILE Loop:**
```sql
DECLARE
    v_counter NUMBER := 1;
BEGIN
    WHILE v_counter <= 10 LOOP
        DBMS_OUTPUT.PUT_LINE('Count: ' || v_counter);
        v_counter := v_counter + 1;
    END LOOP;
END;
/
```

---

### **4. Exception Handling**

**Purpose**: Catch and handle errors gracefully

```sql
CREATE OR REPLACE PROCEDURE sp_update_budget(
    p_budget_id IN NUMBER,
    p_budget_amount IN NUMBER
)
IS
BEGIN
    UPDATE finance_budget
    SET budget_amount = p_budget_amount
    WHERE budget_id = p_budget_id;
    
    IF SQL%ROWCOUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Budget not found');
    END IF;
    
    COMMIT;
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20003, 'No budget exists with this ID');
    WHEN DUP_VAL_ON_INDEX THEN
        RAISE_APPLICATION_ERROR(-20004, 'Duplicate budget entry');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20099, 'Unexpected error: ' || SQLERRM);
END;
/
```

**Key Points:**
- `SQL%ROWCOUNT` = number of rows affected
- `NO_DATA_FOUND` = SELECT found no rows
- `DUP_VAL_ON_INDEX` = unique constraint violation
- `OTHERS` = catch-all for other errors
- `RAISE_APPLICATION_ERROR(code, message)` = custom error

---

### **5. Packages**

**Purpose**: Group related procedures together

**Package Specification (header):**
```sql
CREATE OR REPLACE PACKAGE pkg_finance_crud IS
    -- Procedure declarations
    PROCEDURE sp_add_income(p_user_id IN NUMBER, ...);
    PROCEDURE sp_add_expense(p_user_id IN NUMBER, ...);
    PROCEDURE sp_get_all_income(p_user_id IN NUMBER, p_cursor OUT SYS_REFCURSOR);
END pkg_finance_crud;
/
```

**Package Body (implementation):**
```sql
CREATE OR REPLACE PACKAGE BODY pkg_finance_crud IS
    -- Procedure implementations
    PROCEDURE sp_add_income(...) IS
    BEGIN
        -- Code here
    END;
    
    PROCEDURE sp_add_expense(...) IS
    BEGIN
        -- Code here
    END;
END pkg_finance_crud;
/
```

**Call package procedure:**
```python
cursor.callproc('pkg_finance_crud.sp_add_income', [user_id, source, amount, ...])
```

---

### **6. NVL/COALESCE (NULL Handling)**

**Purpose**: Provide default values for NULL fields

```sql
CREATE OR REPLACE PROCEDURE sp_update_expense(
    p_expense_id IN NUMBER,
    p_amount IN NUMBER DEFAULT NULL,
    p_description IN VARCHAR2 DEFAULT NULL
)
IS
BEGIN
    UPDATE finance_expense
    SET amount = NVL(p_amount, amount),  -- If p_amount is NULL, keep old value
        description = NVL(p_description, description),
        modified_at = SYSTIMESTAMP
    WHERE expense_id = p_expense_id;
    
    COMMIT;
END;
/
```

**Key Points:**
- `NVL(value, default)` = if value is NULL, use default
- `COALESCE(val1, val2, val3)` = return first non-NULL value
- Useful for partial updates (only update fields that are provided)

---

### **7. Triggers**

**Purpose**: Auto-execute code on INSERT/UPDATE/DELETE

**Auto-update modified_at:**
```sql
CREATE OR REPLACE TRIGGER trg_expense_bu
BEFORE UPDATE ON finance_expense
FOR EACH ROW
BEGIN
    :NEW.modified_at := SYSTIMESTAMP;
END;
/
```

**Auto-calculate fiscal year:**
```sql
CREATE OR REPLACE TRIGGER trg_income_bi
BEFORE INSERT ON finance_income
FOR EACH ROW
BEGIN
    :NEW.fiscal_year := EXTRACT(YEAR FROM :NEW.income_date);
    :NEW.fiscal_month := EXTRACT(MONTH FROM :NEW.income_date);
END;
/
```

**Key Points:**
- `BEFORE/AFTER` = when trigger fires
- `INSERT/UPDATE/DELETE` = triggering event
- `:NEW` = new row values
- `:OLD` = old row values (before update)

---

## 4. PL/SQL REPORT GENERATION

### **� WHERE TO FIND THE CODE:**

**File Location**: `d:\DM2_CW\oracle\03_reports_package.sql` (720 lines)

**Package Structure:**
- **Lines 11-76**: Package Specification (`pkg_finance_reports`)
  - Declares 5 report generation procedures
  - Declares 5 display procedures (console output)
  
- **Lines 83-706**: Package Body (implementation)
  - **Lines 89-205**: `display_monthly_expenditure()` - Monthly analysis
  - **Lines 210-330**: `display_budget_adherence()` - Budget tracking
  - **Lines 335-450**: `display_savings_progress()` - Goal progress
  - **Lines 455-570**: `display_category_distribution()` - Expense breakdown
  - **Lines 575-690**: `display_savings_forecast()` - Future predictions

**Total Reports**: 5 comprehensive reports with CSV export functionality

**Show Lecturer**: Open `oracle\03_reports_package.sql` in editor

---

### **�📌 Strategy:**
1. Use stored procedures to generate formatted reports
2. Calculate aggregates (SUM, AVG, COUNT, MAX, MIN)
3. Use cursors to fetch detailed data
4. Format output with DBMS_OUTPUT
5. Return data via SYS_REFCURSOR to Python

---

### **Report Example: Monthly Expenditure Analysis**

**Location**: `oracle\03_reports_package.sql` (Lines 89-205)

**Report Structure:**
- Financial summary (income, expenses, savings)
- Transaction statistics
- Category-wise breakdown with percentages

**PL/SQL Code (from actual file):**

```sql
CREATE OR REPLACE PROCEDURE display_monthly_expenditure(
    p_user_id IN NUMBER,
    p_year IN NUMBER,
    p_month IN NUMBER
)
IS
    -- Variables for calculations
    v_total_income NUMBER := 0;
    v_total_expense NUMBER := 0;
    v_net_savings NUMBER := 0;
    v_savings_rate NUMBER := 0;
    v_income_count NUMBER := 0;
    v_expense_count NUMBER := 0;
    v_avg_expense NUMBER := 0;
    v_max_expense NUMBER := 0;
    
    -- Cursor for category breakdown
    CURSOR c_category_breakdown IS
        SELECT 
            c.category_name,
            SUM(e.amount) as total,
            ROUND(SUM(e.amount) * 100.0 / 
                  NULLIF(v_total_expense, 0), 2) as percentage
        FROM finance_expense e
        JOIN finance_category c ON e.category_id = c.category_id
        WHERE e.user_id = p_user_id
          AND EXTRACT(YEAR FROM e.expense_date) = p_year
          AND EXTRACT(MONTH FROM e.expense_date) = p_month
          AND (e.is_deleted = 0 OR e.is_deleted IS NULL)
        GROUP BY c.category_name
        ORDER BY total DESC;
        
BEGIN
    -- 1. Calculate total income
    SELECT NVL(SUM(amount), 0), COUNT(*)
    INTO v_total_income, v_income_count
    FROM finance_income
    WHERE user_id = p_user_id
      AND EXTRACT(YEAR FROM income_date) = p_year
      AND EXTRACT(MONTH FROM income_date) = p_month
      AND (is_deleted = 0 OR is_deleted IS NULL);
    
    -- 2. Calculate total expenses
    SELECT NVL(SUM(amount), 0), COUNT(*), 
           NVL(AVG(amount), 0), NVL(MAX(amount), 0)
    INTO v_total_expense, v_expense_count, 
         v_avg_expense, v_max_expense
    FROM finance_expense
    WHERE user_id = p_user_id
      AND EXTRACT(YEAR FROM expense_date) = p_year
      AND EXTRACT(MONTH FROM expense_date) = p_month
      AND (is_deleted = 0 OR is_deleted IS NULL);
    
    -- 3. Calculate net savings and rate
    v_net_savings := v_total_income - v_total_expense;
    
    IF v_total_income > 0 THEN
        v_savings_rate := ROUND((v_net_savings / v_total_income) * 100, 2);
    END IF;
    
    -- 4. Print header
    DBMS_OUTPUT.PUT_LINE('============================================================');
    DBMS_OUTPUT.PUT_LINE('MONTHLY EXPENDITURE ANALYSIS');
    DBMS_OUTPUT.PUT_LINE('============================================================');
    DBMS_OUTPUT.PUT_LINE('Period: ' || TO_CHAR(TO_DATE(p_month, 'MM'), 'Month') || ' ' || p_year);
    DBMS_OUTPUT.PUT_LINE('');
    
    -- 5. Print financial summary
    DBMS_OUTPUT.PUT_LINE('FINANCIAL SUMMARY:');
    DBMS_OUTPUT.PUT_LINE('------------------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Total Income:       Rs. ' || TO_CHAR(v_total_income, '999,999,990.00'));
    DBMS_OUTPUT.PUT_LINE('Total Expenses:     Rs. ' || TO_CHAR(v_total_expense, '999,999,990.00'));
    DBMS_OUTPUT.PUT_LINE('Net Savings:        Rs. ' || TO_CHAR(v_net_savings, '999,999,990.00'));
    DBMS_OUTPUT.PUT_LINE('Savings Rate:       ' || v_savings_rate || '%');
    DBMS_OUTPUT.PUT_LINE('');
    
    -- 6. Print transaction statistics
    DBMS_OUTPUT.PUT_LINE('TRANSACTION STATISTICS:');
    DBMS_OUTPUT.PUT_LINE('------------------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Income Transactions:    ' || v_income_count);
    DBMS_OUTPUT.PUT_LINE('Expense Transactions:   ' || v_expense_count);
    DBMS_OUTPUT.PUT_LINE('Average Expense:        Rs. ' || TO_CHAR(v_avg_expense, '999,999,990.00'));
    DBMS_OUTPUT.PUT_LINE('Maximum Expense:        Rs. ' || TO_CHAR(v_max_expense, '999,999,990.00'));
    DBMS_OUTPUT.PUT_LINE('');
    
    -- 7. Print category breakdown using cursor
    DBMS_OUTPUT.PUT_LINE('CATEGORY-WISE BREAKDOWN:');
    DBMS_OUTPUT.PUT_LINE('------------------------------------------------------------');
    
    FOR category_rec IN c_category_breakdown LOOP
        DBMS_OUTPUT.PUT_LINE(
            RPAD(category_rec.category_name, 25) || 
            'Rs. ' || TO_CHAR(category_rec.total, '999,999,990.00') || 
            '  (' || category_rec.percentage || '%)'
        );
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('------------------------------------------------------------');
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('No transactions found for this period.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error generating report: ' || SQLERRM);
END display_monthly_expenditure;
/
```

---

### **How Report Generation Works:**

**Step 1: Calculate Aggregates**
```sql
SELECT SUM(amount), COUNT(*), AVG(amount), MAX(amount)
INTO v_total, v_count, v_avg, v_max
FROM finance_expense
WHERE conditions...
```

**Step 2: Process Categories with Cursor**
```sql
FOR category_rec IN c_category_breakdown LOOP
    -- Loop automatically fetches each row
    -- Access with: category_rec.category_name, category_rec.total
END LOOP;
```

**Step 3: Format Output**
```sql
DBMS_OUTPUT.PUT_LINE('Text: ' || variable);
TO_CHAR(number, '999,999,990.00')  -- Format with commas
RPAD(text, 25)  -- Right-pad to 25 characters
```

**Step 4: Call from Python**
```python
cursor = oracle_conn.cursor()
cursor.callproc('display_monthly_expenditure', [user_id, 2025, 11])

# If using SYS_REFCURSOR instead of DBMS_OUTPUT:
result_cursor = cursor.var(cx_Oracle.CURSOR)
cursor.callproc('get_monthly_report', [user_id, 2025, 11, result_cursor])

for row in result_cursor.getvalue():
    print(row)
```

---

## 5. DATABASE BACKUP STRATEGY

### **SQLite Backup**

#### **📌 Key Points:**
- File-based backup (copy entire .db file)
- Automated daily backups
- Quick and simple
- Restore by replacing file

#### **🔄 Backup Script:**

```python
import shutil
import os
from datetime import datetime

def backup_sqlite():
    """Backup SQLite database"""
    
    # Source database
    source = 'sqlite/finance_local.db'
    
    # Backup directory
    backup_dir = 'backups/sqlite'
    os.makedirs(backup_dir, exist_ok=True)
    
    # Backup filename with timestamp
    timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
    backup_file = f'{backup_dir}/finance_backup_{timestamp}.db'
    
    # Copy database file
    shutil.copy2(source, backup_file)
    
    print(f"✅ SQLite backup created: {backup_file}")
    
    # Keep only last 7 backups (delete older)
    cleanup_old_backups(backup_dir, keep=7)
    
def cleanup_old_backups(backup_dir, keep=7):
    """Keep only the most recent backups"""
    files = sorted(
        [f for f in os.listdir(backup_dir) if f.endswith('.db')],
        reverse=True
    )
    
    # Delete old backups
    for old_file in files[keep:]:
        os.remove(os.path.join(backup_dir, old_file))
        print(f"🗑️ Deleted old backup: {old_file}")

# Run backup
backup_sqlite()
```

#### **💾 Restore SQLite:**

```bash
# Simply replace the database file
copy backups\sqlite\finance_backup_20251111_120000.db sqlite\finance_local.db
```

---

### **Oracle Backup**

#### **📌 Key Points:**
- Export using Data Pump (expdp)
- Logical backup (exports tables, procedures, triggers)
- Can backup entire schema or specific tables
- Compressed backup files

#### **📤 Export (Backup):**

**Full Schema Export:**
```bash
# Export entire finance_admin schema
expdp finance_admin/password \
    schemas=finance_admin \
    directory=BACKUP_DIR \
    dumpfile=finance_backup_%U.dmp \
    logfile=finance_backup.log \
    compression=ALL

# Windows PowerShell:
expdp finance_admin/password schemas=finance_admin directory=BACKUP_DIR dumpfile=finance_backup.dmp logfile=backup.log
```

**Table-Level Export:**
```bash
# Export specific tables only
expdp finance_admin/password \
    tables=finance_expense,finance_income,finance_budget \
    directory=BACKUP_DIR \
    dumpfile=finance_tables.dmp
```

**Create Directory (first time):**
```sql
-- As DBA user
CREATE DIRECTORY BACKUP_DIR AS 'D:/oracle_backups';
GRANT READ, WRITE ON DIRECTORY BACKUP_DIR TO finance_admin;
```

#### **📥 Import (Restore):**

```bash
# Import from backup file
impdp finance_admin/password \
    schemas=finance_admin \
    directory=BACKUP_DIR \
    dumpfile=finance_backup.dmp \
    logfile=restore.log \
    table_exists_action=REPLACE

# Windows PowerShell:
impdp finance_admin/password schemas=finance_admin directory=BACKUP_DIR dumpfile=finance_backup.dmp table_exists_action=REPLACE
```

#### **🔄 Automated Backup Script:**

**Python Script:**
```python
import subprocess
from datetime import datetime

def backup_oracle():
    """Backup Oracle database using Data Pump"""
    
    timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
    dumpfile = f'finance_backup_{timestamp}.dmp'
    logfile = f'finance_backup_{timestamp}.log'
    
    # Data Pump export command
    cmd = [
        'expdp',
        'finance_admin/password',
        f'schemas=finance_admin',
        f'directory=BACKUP_DIR',
        f'dumpfile={dumpfile}',
        f'logfile={logfile}',
        'compression=ALL'
    ]
    
    # Execute backup
    result = subprocess.run(cmd, capture_output=True, text=True)
    
    if result.returncode == 0:
        print(f"✅ Oracle backup created: {dumpfile}")
    else:
        print(f"❌ Backup failed: {result.stderr}")

# Run backup
backup_oracle()
```

**Scheduled Task (Windows):**
```powershell
# Create scheduled task to run daily at 2 AM
schtasks /create /tn "Oracle Finance Backup" /tr "python D:\DM2_CW\scripts\backup_oracle.py" /sc daily /st 02:00
```

---

### **Backup Comparison**

| Feature | SQLite | Oracle |
|---------|--------|--------|
| **Method** | File copy | Data Pump (expdp) |
| **Speed** | Very fast | Moderate |
| **Size** | Small (~10 MB) | Larger (compressed) |
| **Automation** | Python script | Python + expdp |
| **Restore** | File replace | impdp command |
| **Schedule** | Daily | Daily |
| **Retention** | Keep 7 days | Keep 30 days |

---

## 📊 SUMMARY

### **Synchronization:**
- `sync_manager.py` handles bidirectional sync
- SQLite (sqlite3) + Oracle (cx_Oracle) connections
- 12-step process with conflict resolution
- Batch operations for performance

### **Security:**
- **Database**: Password hashing, parameterized queries, constraints, privileges
- **System**: Session management, input validation, environment variables, error handling

### **PL/SQL Techniques:**
- Stored procedures (31 procedures in CRUD package)
- SYS_REFCURSOR for returning data
- FOR loops with cursors
- Exception handling with RAISE_APPLICATION_ERROR
- Packages to organize code
- NVL for partial updates
- Triggers for auto-timestamps

### **Report Generation:**
- Aggregate functions (SUM, AVG, COUNT, MAX)
- Cursors to iterate categories
- DBMS_OUTPUT for formatted text
- Percentage calculations
- Called from Python with `callproc()`

### **Backups:**
- **SQLite**: File copy, 7-day retention, Python automation
- **Oracle**: Data Pump (expdp/impdp), 30-day retention, scheduled tasks

---

## 🎯 VIVA QUICK ANSWERS

### **"Show me the PL/SQL report code"**
**Answer**: "Yes sir, it's in `oracle\03_reports_package.sql`. Let me open it."
- Open file in VS Code
- Scroll to line 89 (display_monthly_expenditure)
- Explain: "This is one of 5 reports. The package is 720 lines with full implementations."

### **"Where are your CRUD procedures?"**
**Answer**: "They're in `oracle\02_plsql_crud_package.sql`, sir."
- Open file
- Show package specification (line ~10-50)
- Show one procedure implementation (e.g., sp_add_income)
- Explain: "31 procedures total for all CRUD operations."

### **"How does synchronization work?"**
**Answer**: "The sync logic is in `synchronization\sync_manager.py`, sir."
- Open file
- Show sync function
- Explain: "It connects to both databases, checks is_synced flags, and performs bidirectional updates."

### **"Show me your database schema"**
**Answer**: 
- **SQLite**: "Here's the local database in `sqlite\01_create_database.sql`"
- **Oracle**: "And the cloud database in `oracle\01_create_database.sql`"
- Show CREATE TABLE statements
- Explain triggers, indexes, constraints

### **"How do you handle security?"**
**Answer**: "Multiple layers, sir:"
1. Password hashing (show in `webapp\app.py` - generate_password_hash)
2. Parameterized queries (show example in routes)
3. Session management (show @app.route with session checks)
4. Input validation (show validation code)

---

**Good luck with your viva! 🎓✨**

*Created: November 11, 2025*  
*For: Personal Finance Management System Technical Viva*
