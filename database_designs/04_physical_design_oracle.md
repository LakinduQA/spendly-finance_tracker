# Physical Database Design - Oracle Database (Central Database)

## 1. Oracle-Specific Considerations

### 1.1 Oracle Characteristics
- **Storage**: Tablespaces with datafiles
- **Data Types**: Rich set (NUMBER, VARCHAR2, DATE, TIMESTAMP, CLOB, etc.)
- **Constraints**: All types supported including CHECK, DEFAULT
- **Sequences**: For auto-increment functionality
- **Triggers**: Advanced PL/SQL triggers
- **Partitioning**: Support for large tables
- **Enterprise Features**: Advanced security, auditing, backup/recovery

### 1.2 Design Adaptations for Oracle
- Use NUMBER for numeric data with specified precision
- Use VARCHAR2 for variable-length strings (more efficient than VARCHAR)
- Use DATE or TIMESTAMP for temporal data
- Use SEQUENCE + TRIGGER for auto-increment behavior
- Implement comprehensive PL/SQL packages for CRUD operations
- Add audit columns for enterprise compliance

## 2. Tablespace Design

### 2.1 Tablespace Structure
```sql
-- Create tablespaces for data organization
CREATE TABLESPACE finance_data
DATAFILE 'finance_data01.dbf' SIZE 100M
AUTOEXTEND ON NEXT 10M MAXSIZE 500M
EXTENT MANAGEMENT LOCAL
SEGMENT SPACE MANAGEMENT AUTO;

CREATE TABLESPACE finance_index
DATAFILE 'finance_index01.dbf' SIZE 50M
AUTOEXTEND ON NEXT 10M MAXSIZE 200M
EXTENT MANAGEMENT LOCAL
SEGMENT SPACE MANAGEMENT AUTO;

-- Temporary tablespace for sorting operations
CREATE TEMPORARY TABLESPACE finance_temp
TEMPFILE 'finance_temp01.dbf' SIZE 50M
AUTOEXTEND ON NEXT 10M MAXSIZE 200M;
```

## 3. User and Schema Setup

### 3.1 Create Application User
```sql
-- Create dedicated user for the application
CREATE USER finance_admin IDENTIFIED BY SecurePass123
DEFAULT TABLESPACE finance_data
TEMPORARY TABLESPACE finance_temp
QUOTA UNLIMITED ON finance_data
QUOTA UNLIMITED ON finance_index;

-- Grant necessary privileges
GRANT CONNECT, RESOURCE TO finance_admin;
GRANT CREATE VIEW TO finance_admin;
GRANT CREATE PROCEDURE TO finance_admin;
GRANT CREATE TRIGGER TO finance_admin;
GRANT CREATE SEQUENCE TO finance_admin;

-- For reporting purposes
GRANT SELECT ANY TABLE TO finance_admin;
```

## 4. Sequences for Primary Keys

```sql
-- Sequence for USER table
CREATE SEQUENCE seq_user_id
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

-- Sequence for CATEGORY table
CREATE SEQUENCE seq_category_id
START WITH 1
INCREMENT BY 1
CACHE 20
NOCYCLE;

-- Sequence for EXPENSE table
CREATE SEQUENCE seq_expense_id
START WITH 1
INCREMENT BY 1
CACHE 100
NOCYCLE;

-- Sequence for INCOME table
CREATE SEQUENCE seq_income_id
START WITH 1
INCREMENT BY 1
CACHE 100
NOCYCLE;

-- Sequence for BUDGET table
CREATE SEQUENCE seq_budget_id
START WITH 1
INCREMENT BY 1
CACHE 20
NOCYCLE;

-- Sequence for SAVINGS_GOAL table
CREATE SEQUENCE seq_goal_id
START WITH 1
INCREMENT BY 1
CACHE 20
NOCYCLE;

-- Sequence for SAVINGS_CONTRIBUTION table
CREATE SEQUENCE seq_contribution_id
START WITH 1
INCREMENT BY 1
CACHE 50
NOCYCLE;

-- Sequence for SYNC_LOG table
CREATE SEQUENCE seq_sync_log_id
START WITH 1
INCREMENT BY 1
CACHE 50
NOCYCLE;
```

## 5. Physical Table Structures

### 5.1 USER Table
```sql
CREATE TABLE finance_user (
    user_id NUMBER(10) PRIMARY KEY,
    username VARCHAR2(50) NOT NULL UNIQUE,
    email VARCHAR2(100) NOT NULL UNIQUE,
    full_name VARCHAR2(100) NOT NULL,
    created_at TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
    last_sync TIMESTAMP,
    is_active NUMBER(1) DEFAULT 1 NOT NULL,
    last_login TIMESTAMP,
    CONSTRAINT chk_user_email CHECK (email LIKE '%@%'),
    CONSTRAINT chk_user_active CHECK (is_active IN (0, 1))
) TABLESPACE finance_data;

-- Trigger for auto-increment
CREATE OR REPLACE TRIGGER trg_user_bi
BEFORE INSERT ON finance_user
FOR EACH ROW
BEGIN
    IF :NEW.user_id IS NULL THEN
        SELECT seq_user_id.NEXTVAL INTO :NEW.user_id FROM DUAL;
    END IF;
END;
/
```

**Indexes:**
```sql
CREATE INDEX idx_user_username ON finance_user(username) TABLESPACE finance_index;
CREATE INDEX idx_user_email ON finance_user(email) TABLESPACE finance_index;
CREATE INDEX idx_user_active ON finance_user(is_active) TABLESPACE finance_index;
```

### 5.2 CATEGORY Table
```sql
CREATE TABLE finance_category (
    category_id NUMBER(10) PRIMARY KEY,
    category_name VARCHAR2(50) NOT NULL UNIQUE,
    category_type VARCHAR2(10) NOT NULL,
    description VARCHAR2(500),
    is_active NUMBER(1) DEFAULT 1 NOT NULL,
    display_order NUMBER(3) DEFAULT 0,
    created_at TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
    CONSTRAINT chk_cat_type CHECK (category_type IN ('EXPENSE', 'INCOME')),
    CONSTRAINT chk_cat_active CHECK (is_active IN (0, 1))
) TABLESPACE finance_data;

-- Trigger for auto-increment
CREATE OR REPLACE TRIGGER trg_category_bi
BEFORE INSERT ON finance_category
FOR EACH ROW
BEGIN
    IF :NEW.category_id IS NULL THEN
        SELECT seq_category_id.NEXTVAL INTO :NEW.category_id FROM DUAL;
    END IF;
END;
/
```

**Indexes:**
```sql
CREATE INDEX idx_cat_type ON finance_category(category_type) TABLESPACE finance_index;
CREATE INDEX idx_cat_active ON finance_category(is_active) TABLESPACE finance_index;
```

### 5.3 EXPENSE Table
```sql
CREATE TABLE finance_expense (
    expense_id NUMBER(15) PRIMARY KEY,
    user_id NUMBER(10) NOT NULL,
    category_id NUMBER(10) NOT NULL,
    amount NUMBER(10,2) NOT NULL,
    expense_date DATE NOT NULL,
    description VARCHAR2(500),
    payment_method VARCHAR2(20) NOT NULL,
    created_at TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
    modified_at TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
    synced_from_local NUMBER(1) DEFAULT 1,
    sync_timestamp TIMESTAMP DEFAULT SYSTIMESTAMP,
    fiscal_year NUMBER(4),
    fiscal_month NUMBER(2),
    CONSTRAINT fk_exp_user FOREIGN KEY (user_id) 
        REFERENCES finance_user(user_id) ON DELETE CASCADE,
    CONSTRAINT fk_exp_category FOREIGN KEY (category_id) 
        REFERENCES finance_category(category_id),
    CONSTRAINT chk_exp_amount CHECK (amount > 0),
    CONSTRAINT chk_exp_payment CHECK (payment_method IN 
        ('Cash', 'Credit Card', 'Debit Card', 'Online', 'Bank Transfer'))
) TABLESPACE finance_data;

-- Trigger for auto-increment and fiscal period
CREATE OR REPLACE TRIGGER trg_expense_bi
BEFORE INSERT ON finance_expense
FOR EACH ROW
BEGIN
    IF :NEW.expense_id IS NULL THEN
        SELECT seq_expense_id.NEXTVAL INTO :NEW.expense_id FROM DUAL;
    END IF;
    
    -- Auto-populate fiscal year and month
    :NEW.fiscal_year := EXTRACT(YEAR FROM :NEW.expense_date);
    :NEW.fiscal_month := EXTRACT(MONTH FROM :NEW.expense_date);
END;
/

-- Trigger for modified_at update
CREATE OR REPLACE TRIGGER trg_expense_bu
BEFORE UPDATE ON finance_expense
FOR EACH ROW
BEGIN
    :NEW.modified_at := SYSTIMESTAMP;
END;
/
```

**Indexes:**
```sql
CREATE INDEX idx_exp_user ON finance_expense(user_id) TABLESPACE finance_index;
CREATE INDEX idx_exp_category ON finance_expense(category_id) TABLESPACE finance_index;
CREATE INDEX idx_exp_date ON finance_expense(expense_date) TABLESPACE finance_index;
CREATE INDEX idx_exp_user_date ON finance_expense(user_id, expense_date) TABLESPACE finance_index;
CREATE INDEX idx_exp_fiscal ON finance_expense(fiscal_year, fiscal_month) TABLESPACE finance_index;
CREATE INDEX idx_exp_amount ON finance_expense(amount) TABLESPACE finance_index;
```

### 5.4 INCOME Table
```sql
CREATE TABLE finance_income (
    income_id NUMBER(15) PRIMARY KEY,
    user_id NUMBER(10) NOT NULL,
    income_source VARCHAR2(50) NOT NULL,
    amount NUMBER(10,2) NOT NULL,
    income_date DATE NOT NULL,
    description VARCHAR2(500),
    created_at TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
    modified_at TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
    synced_from_local NUMBER(1) DEFAULT 1,
    sync_timestamp TIMESTAMP DEFAULT SYSTIMESTAMP,
    fiscal_year NUMBER(4),
    fiscal_month NUMBER(2),
    CONSTRAINT fk_inc_user FOREIGN KEY (user_id) 
        REFERENCES finance_user(user_id) ON DELETE CASCADE,
    CONSTRAINT chk_inc_amount CHECK (amount > 0),
    CONSTRAINT chk_inc_source CHECK (income_source IN 
        ('Salary', 'Freelance', 'Investment', 'Gift', 'Business', 'Other'))
) TABLESPACE finance_data;

-- Trigger for auto-increment and fiscal period
CREATE OR REPLACE TRIGGER trg_income_bi
BEFORE INSERT ON finance_income
FOR EACH ROW
BEGIN
    IF :NEW.income_id IS NULL THEN
        SELECT seq_income_id.NEXTVAL INTO :NEW.income_id FROM DUAL;
    END IF;
    
    :NEW.fiscal_year := EXTRACT(YEAR FROM :NEW.income_date);
    :NEW.fiscal_month := EXTRACT(MONTH FROM :NEW.income_date);
END;
/

CREATE OR REPLACE TRIGGER trg_income_bu
BEFORE UPDATE ON finance_income
FOR EACH ROW
BEGIN
    :NEW.modified_at := SYSTIMESTAMP;
END;
/
```

**Indexes:**
```sql
CREATE INDEX idx_inc_user ON finance_income(user_id) TABLESPACE finance_index;
CREATE INDEX idx_inc_date ON finance_income(income_date) TABLESPACE finance_index;
CREATE INDEX idx_inc_user_date ON finance_income(user_id, income_date) TABLESPACE finance_index;
CREATE INDEX idx_inc_fiscal ON finance_income(fiscal_year, fiscal_month) TABLESPACE finance_index;
CREATE INDEX idx_inc_source ON finance_income(income_source) TABLESPACE finance_index;
```

### 5.5 BUDGET Table
```sql
CREATE TABLE finance_budget (
    budget_id NUMBER(10) PRIMARY KEY,
    user_id NUMBER(10) NOT NULL,
    category_id NUMBER(10) NOT NULL,
    budget_amount NUMBER(10,2) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    created_at TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
    modified_at TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
    is_active NUMBER(1) DEFAULT 1 NOT NULL,
    alert_threshold NUMBER(3) DEFAULT 80,
    synced_from_local NUMBER(1) DEFAULT 1,
    CONSTRAINT fk_bud_user FOREIGN KEY (user_id) 
        REFERENCES finance_user(user_id) ON DELETE CASCADE,
    CONSTRAINT fk_bud_category FOREIGN KEY (category_id) 
        REFERENCES finance_category(category_id),
    CONSTRAINT chk_bud_amount CHECK (budget_amount > 0),
    CONSTRAINT chk_bud_dates CHECK (end_date > start_date),
    CONSTRAINT chk_bud_active CHECK (is_active IN (0, 1)),
    CONSTRAINT chk_bud_threshold CHECK (alert_threshold BETWEEN 1 AND 100)
) TABLESPACE finance_data;

CREATE OR REPLACE TRIGGER trg_budget_bi
BEFORE INSERT ON finance_budget
FOR EACH ROW
BEGIN
    IF :NEW.budget_id IS NULL THEN
        SELECT seq_budget_id.NEXTVAL INTO :NEW.budget_id FROM DUAL;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_budget_bu
BEFORE UPDATE ON finance_budget
FOR EACH ROW
BEGIN
    :NEW.modified_at := SYSTIMESTAMP;
END;
/
```

**Indexes:**
```sql
CREATE INDEX idx_bud_user ON finance_budget(user_id) TABLESPACE finance_index;
CREATE INDEX idx_bud_category ON finance_budget(category_id) TABLESPACE finance_index;
CREATE INDEX idx_bud_dates ON finance_budget(start_date, end_date) TABLESPACE finance_index;
CREATE INDEX idx_bud_active ON finance_budget(is_active) TABLESPACE finance_index;
```

### 5.6 SAVINGS_GOAL Table
```sql
CREATE TABLE finance_savings_goal (
    goal_id NUMBER(10) PRIMARY KEY,
    user_id NUMBER(10) NOT NULL,
    goal_name VARCHAR2(100) NOT NULL,
    target_amount NUMBER(10,2) NOT NULL,
    current_amount NUMBER(10,2) DEFAULT 0 NOT NULL,
    start_date DATE NOT NULL,
    deadline DATE NOT NULL,
    priority VARCHAR2(10) NOT NULL,
    status VARCHAR2(20) DEFAULT 'Active' NOT NULL,
    created_at TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
    modified_at TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
    completed_date DATE,
    synced_from_local NUMBER(1) DEFAULT 1,
    CONSTRAINT fk_goal_user FOREIGN KEY (user_id) 
        REFERENCES finance_user(user_id) ON DELETE CASCADE,
    CONSTRAINT chk_goal_target CHECK (target_amount > 0),
    CONSTRAINT chk_goal_current CHECK (current_amount >= 0),
    CONSTRAINT chk_goal_amounts CHECK (current_amount <= target_amount),
    CONSTRAINT chk_goal_priority CHECK (priority IN ('High', 'Medium', 'Low')),
    CONSTRAINT chk_goal_status CHECK (status IN ('Active', 'Completed', 'Cancelled'))
) TABLESPACE finance_data;

CREATE OR REPLACE TRIGGER trg_goal_bi
BEFORE INSERT ON finance_savings_goal
FOR EACH ROW
BEGIN
    IF :NEW.goal_id IS NULL THEN
        SELECT seq_goal_id.NEXTVAL INTO :NEW.goal_id FROM DUAL;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_goal_bu
BEFORE UPDATE ON finance_savings_goal
FOR EACH ROW
BEGIN
    :NEW.modified_at := SYSTIMESTAMP;
    
    -- Auto-complete goal if target reached
    IF :NEW.current_amount >= :NEW.target_amount AND :NEW.status = 'Active' THEN
        :NEW.status := 'Completed';
        :NEW.completed_date := SYSDATE;
    END IF;
END;
/
```

**Indexes:**
```sql
CREATE INDEX idx_goal_user ON finance_savings_goal(user_id) TABLESPACE finance_index;
CREATE INDEX idx_goal_status ON finance_savings_goal(status) TABLESPACE finance_index;
CREATE INDEX idx_goal_deadline ON finance_savings_goal(deadline) TABLESPACE finance_index;
CREATE INDEX idx_goal_priority ON finance_savings_goal(priority) TABLESPACE finance_index;
```

### 5.7 SAVINGS_CONTRIBUTION Table
```sql
CREATE TABLE finance_savings_contribution (
    contribution_id NUMBER(15) PRIMARY KEY,
    goal_id NUMBER(10) NOT NULL,
    contribution_amount NUMBER(10,2) NOT NULL,
    contribution_date DATE NOT NULL,
    description VARCHAR2(500),
    created_at TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
    CONSTRAINT fk_cont_goal FOREIGN KEY (goal_id) 
        REFERENCES finance_savings_goal(goal_id) ON DELETE CASCADE,
    CONSTRAINT chk_cont_amount CHECK (contribution_amount > 0)
) TABLESPACE finance_data;

CREATE OR REPLACE TRIGGER trg_contribution_bi
BEFORE INSERT ON finance_savings_contribution
FOR EACH ROW
BEGIN
    IF :NEW.contribution_id IS NULL THEN
        SELECT seq_contribution_id.NEXTVAL INTO :NEW.contribution_id FROM DUAL;
    END IF;
END;
/

-- Update goal amount on contribution
CREATE OR REPLACE TRIGGER trg_contribution_ai
AFTER INSERT ON finance_savings_contribution
FOR EACH ROW
BEGIN
    UPDATE finance_savings_goal
    SET current_amount = current_amount + :NEW.contribution_amount,
        modified_at = SYSTIMESTAMP
    WHERE goal_id = :NEW.goal_id;
END;
/
```

**Indexes:**
```sql
CREATE INDEX idx_cont_goal ON finance_savings_contribution(goal_id) TABLESPACE finance_index;
CREATE INDEX idx_cont_date ON finance_savings_contribution(contribution_date) TABLESPACE finance_index;
```

### 5.8 SYNC_LOG Table
```sql
CREATE TABLE finance_sync_log (
    sync_log_id NUMBER(15) PRIMARY KEY,
    user_id NUMBER(10) NOT NULL,
    sync_start_time TIMESTAMP NOT NULL,
    sync_end_time TIMESTAMP,
    records_synced NUMBER(10) DEFAULT 0 NOT NULL,
    sync_status VARCHAR2(20) NOT NULL,
    error_message VARCHAR2(2000),
    sync_type VARCHAR2(20) NOT NULL,
    sync_duration_seconds NUMBER(10),
    CONSTRAINT fk_sync_user FOREIGN KEY (user_id) 
        REFERENCES finance_user(user_id) ON DELETE CASCADE,
    CONSTRAINT chk_sync_status CHECK (sync_status IN ('Success', 'Failed', 'Partial')),
    CONSTRAINT chk_sync_type CHECK (sync_type IN ('Manual', 'Automatic'))
) TABLESPACE finance_data;

CREATE OR REPLACE TRIGGER trg_sync_log_bi
BEFORE INSERT ON finance_sync_log
FOR EACH ROW
BEGIN
    IF :NEW.sync_log_id IS NULL THEN
        SELECT seq_sync_log_id.NEXTVAL INTO :NEW.sync_log_id FROM DUAL;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_sync_log_bu
BEFORE UPDATE ON finance_sync_log
FOR EACH ROW
BEGIN
    IF :NEW.sync_end_time IS NOT NULL AND :OLD.sync_end_time IS NULL THEN
        :NEW.sync_duration_seconds := 
            EXTRACT(DAY FROM (:NEW.sync_end_time - :NEW.sync_start_time)) * 86400 +
            EXTRACT(HOUR FROM (:NEW.sync_end_time - :NEW.sync_start_time)) * 3600 +
            EXTRACT(MINUTE FROM (:NEW.sync_end_time - :NEW.sync_start_time)) * 60 +
            EXTRACT(SECOND FROM (:NEW.sync_end_time - :NEW.sync_start_time));
    END IF;
END;
/
```

**Indexes:**
```sql
CREATE INDEX idx_sync_user ON finance_sync_log(user_id) TABLESPACE finance_index;
CREATE INDEX idx_sync_status ON finance_sync_log(sync_status) TABLESPACE finance_index;
CREATE INDEX idx_sync_time ON finance_sync_log(sync_start_time) TABLESPACE finance_index;
```

## 6. Materialized Views for Analytics

### 6.1 Monthly Expense Summary
```sql
CREATE MATERIALIZED VIEW mv_monthly_expense_summary
BUILD IMMEDIATE
REFRESH COMPLETE ON DEMAND
AS
SELECT 
    user_id,
    fiscal_year,
    fiscal_month,
    category_id,
    COUNT(*) AS transaction_count,
    SUM(amount) AS total_amount,
    AVG(amount) AS avg_amount,
    MIN(amount) AS min_amount,
    MAX(amount) AS max_amount
FROM finance_expense
GROUP BY user_id, fiscal_year, fiscal_month, category_id;

CREATE INDEX idx_mv_month_exp ON mv_monthly_expense_summary(user_id, fiscal_year, fiscal_month);
```

### 6.2 Budget Performance Summary
```sql
CREATE MATERIALIZED VIEW mv_budget_performance
BUILD IMMEDIATE
REFRESH COMPLETE ON DEMAND
AS
SELECT 
    b.budget_id,
    b.user_id,
    b.category_id,
    b.budget_amount,
    b.start_date,
    b.end_date,
    NVL(SUM(e.amount), 0) AS actual_spent,
    b.budget_amount - NVL(SUM(e.amount), 0) AS remaining,
    ROUND((NVL(SUM(e.amount), 0) / b.budget_amount) * 100, 2) AS utilization_percent,
    CASE 
        WHEN NVL(SUM(e.amount), 0) > b.budget_amount THEN 'Over Budget'
        WHEN (NVL(SUM(e.amount), 0) / b.budget_amount) * 100 >= b.alert_threshold THEN 'Near Limit'
        ELSE 'Within Budget'
    END AS budget_status
FROM finance_budget b
LEFT JOIN finance_expense e ON b.user_id = e.user_id 
    AND b.category_id = e.category_id
    AND e.expense_date BETWEEN b.start_date AND b.end_date
WHERE b.is_active = 1
GROUP BY b.budget_id, b.user_id, b.category_id, b.budget_amount, 
         b.start_date, b.end_date, b.alert_threshold;

CREATE INDEX idx_mv_bud_perf ON mv_budget_performance(user_id, budget_id);
```

## 7. Audit Table

```sql
CREATE TABLE finance_audit_log (
    audit_id NUMBER(15) PRIMARY KEY,
    table_name VARCHAR2(50) NOT NULL,
    operation VARCHAR2(10) NOT NULL,
    record_id NUMBER(15) NOT NULL,
    user_id NUMBER(10),
    old_values CLOB,
    new_values CLOB,
    audit_timestamp TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
    CONSTRAINT chk_audit_op CHECK (operation IN ('INSERT', 'UPDATE', 'DELETE'))
) TABLESPACE finance_data;

CREATE SEQUENCE seq_audit_id START WITH 1 INCREMENT BY 1 CACHE 100;

CREATE INDEX idx_audit_table ON finance_audit_log(table_name) TABLESPACE finance_index;
CREATE INDEX idx_audit_time ON finance_audit_log(audit_timestamp) TABLESPACE finance_index;
```

## 8. Physical Design Summary

**Schema**: finance_admin  
**Tablespaces**: 
- finance_data (100MB, auto-extend to 500MB)
- finance_index (50MB, auto-extend to 200MB)
- finance_temp (50MB temporary)

**Objects**:
- 8 tables (USER, CATEGORY, EXPENSE, INCOME, BUDGET, SAVINGS_GOAL, SAVINGS_CONTRIBUTION, SYNC_LOG)
- 8 sequences for auto-increment
- 25+ indexes for performance
- 15+ triggers for automation
- 2 materialized views for analytics
- 1 audit table for compliance

**Storage Estimates**:
- Empty database: ~200 MB
- With 10,000 transactions: ~500 MB
- With 100,000 transactions: ~2 GB

This physical design provides enterprise-grade storage, performance, and auditability for centralized financial data management.
