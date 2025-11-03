# Section 5: Oracle PL/SQL Implementation

**Personal Finance Management System**  
**Oracle Database with Advanced PL/SQL**

---

## 4.1 PL/SQL CRUD Package

### 4.1.1 Package Specification

**File**: `oracle/02_plsql_crud_package.sql` (818 lines)

```sql
CREATE OR REPLACE PACKAGE pkg_finance_crud AS
    
    -- USER CRUD Operations
    PROCEDURE create_user(p_username IN VARCHAR2, p_email IN VARCHAR2, 
                         p_full_name IN VARCHAR2, p_user_id OUT NUMBER);
    PROCEDURE update_user(p_user_id IN NUMBER, p_username IN VARCHAR2 DEFAULT NULL, 
                         p_email IN VARCHAR2 DEFAULT NULL, p_full_name IN VARCHAR2 DEFAULT NULL);
    PROCEDURE delete_user(p_user_id IN NUMBER);
    FUNCTION get_user(p_user_id IN NUMBER) RETURN SYS_REFCURSOR;
    FUNCTION get_all_users RETURN SYS_REFCURSOR;
    
    -- EXPENSE CRUD Operations (5 procedures)
    PROCEDURE create_expense(...);
    PROCEDURE update_expense(...);
    PROCEDURE delete_expense(p_expense_id IN NUMBER);
    FUNCTION get_expense(p_expense_id IN NUMBER) RETURN SYS_REFCURSOR;
    FUNCTION get_user_expenses(p_user_id IN NUMBER, p_start_date IN DATE DEFAULT NULL, 
                              p_end_date IN DATE DEFAULT NULL) RETURN SYS_REFCURSOR;
    
    -- INCOME CRUD Operations (5 procedures)
    -- BUDGET CRUD Operations (5 procedures)
    -- SAVINGS GOAL CRUD Operations (5 procedures)
    -- SAVINGS CONTRIBUTION Operations
    -- SYNC LOG Operations
    -- Utility Functions
    
END pkg_finance_crud;
/
```

### 4.1.2 User CRUD Implementation

```sql
PROCEDURE create_user(
    p_username IN VARCHAR2,
    p_email IN VARCHAR2,
    p_full_name IN VARCHAR2,
    p_user_id OUT NUMBER
) AS
BEGIN
    INSERT INTO finance_user (username, email, full_name)
    VALUES (p_username, p_email, p_full_name)
    RETURNING user_id INTO p_user_id;
    
    COMMIT;
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        RAISE_APPLICATION_ERROR(-20001, 'Username or email already exists');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END create_user;

PROCEDURE update_user(
    p_user_id IN NUMBER,
    p_username IN VARCHAR2 DEFAULT NULL,
    p_email IN VARCHAR2 DEFAULT NULL,
    p_full_name IN VARCHAR2 DEFAULT NULL
) AS
BEGIN
    UPDATE finance_user
    SET username = NVL(p_username, username),
        email = NVL(p_email, email),
        full_name = NVL(p_full_name, full_name)
    WHERE user_id = p_user_id;
    
    IF SQL%ROWCOUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'User not found');
    END IF;
    
    COMMIT;
END update_user;
```

**Total CRUD Package**: 25+ procedures/functions, 818 lines

---

## 4.2 PL/SQL Reports Package

**File**: `oracle/03_reports_package.sql` (720 lines)

### 5 Comprehensive Reports

1. **Monthly Expenditure Analysis**
2. **Budget Adherence Tracking**
3. **Savings Goal Progress**
4. **Category Distribution**
5. **Savings Forecast**

### Report 1: Monthly Expenditure

```sql
PROCEDURE display_monthly_expenditure(
    p_user_id IN NUMBER,
    p_year IN NUMBER,
    p_month IN NUMBER
) AS
    v_total_income NUMBER := 0;
    v_total_expenses NUMBER := 0;
    v_net_savings NUMBER := 0;
    
    CURSOR c_categories IS
        SELECT c.category_name, COUNT(e.expense_id) AS transaction_count,
               SUM(e.amount) AS total_amount, AVG(e.amount) AS avg_amount
        FROM finance_category c
        LEFT JOIN finance_expense e ON c.category_id = e.category_id
            AND e.user_id = p_user_id AND e.fiscal_year = p_year 
            AND e.fiscal_month = p_month
        WHERE c.category_type = 'EXPENSE'
        GROUP BY c.category_name
        HAVING COUNT(e.expense_id) > 0
        ORDER BY total_amount DESC;
BEGIN
    -- Calculate totals
    SELECT NVL(SUM(amount), 0) INTO v_total_expenses
    FROM finance_expense
    WHERE user_id = p_user_id AND fiscal_year = p_year AND fiscal_month = p_month;
    
    -- Display formatted report
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('MONTHLY EXPENDITURE ANALYSIS');
    -- ... detailed output
END display_monthly_expenditure;
```

---

## 4.3 Stored Procedures Summary

| Category | Procedures | Lines | Purpose |
|----------|-----------|-------|---------|
| User Management | 5 | 120 | CREATE, READ, UPDATE, DELETE, LIST |
| Expense Management | 5 | 150 | Full CRUD + date range queries |
| Income Management | 5 | 130 | Full CRUD + filtering |
| Budget Management | 5 | 140 | Full CRUD + utilization tracking |
| Savings Goals | 5 | 160 | Full CRUD + progress tracking |
| Contributions | 2 | 60 | Add contribution, get list |
| Sync Operations | 2 | 80 | Create log, complete log |
| Utilities | 2 | 58 | Monthly summary, category summary |
| **Total** | **31** | **818** | **Complete data layer** |

---

## 4.4 Functions and Cursors

### SYS_REFCURSOR Usage

```sql
FUNCTION get_user_expenses(
    p_user_id IN NUMBER,
    p_start_date IN DATE DEFAULT NULL,
    p_end_date IN DATE DEFAULT NULL
) RETURN SYS_REFCURSOR AS
    l_cursor SYS_REFCURSOR;
BEGIN
    OPEN l_cursor FOR
        SELECT e.expense_id, e.amount, e.expense_date, e.description,
               c.category_name, e.payment_method
        FROM finance_expense e
        INNER JOIN finance_category c ON e.category_id = c.category_id
        WHERE e.user_id = p_user_id
          AND (p_start_date IS NULL OR e.expense_date >= p_start_date)
          AND (p_end_date IS NULL OR e.expense_date <= p_end_date)
        ORDER BY e.expense_date DESC;
    
    RETURN l_cursor;
END get_user_expenses;
```

### Error Handling Pattern

```sql
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        RAISE_APPLICATION_ERROR(-20001, 'Duplicate value');
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20002, 'Record not found');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20099, 'Error: ' || SQLERRM);
END;
```

**Summary**: Complete PL/SQL implementation with 31 procedures, 818 lines of CRUD code, 720 lines of reporting code, comprehensive error handling.
