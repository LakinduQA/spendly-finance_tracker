-- ========================================
-- Oracle Database Creation Script
-- Personal Finance Management System
-- Central Database Implementation
-- ========================================

-- ========================================
-- SECTION 1: TABLESPACE CREATION
-- ========================================

-- Create tablespace for data storage
CREATE TABLESPACE finance_data
DATAFILE 'finance_data01.dbf' SIZE 100M
AUTOEXTEND ON NEXT 10M MAXSIZE 500M
EXTENT MANAGEMENT LOCAL
SEGMENT SPACE MANAGEMENT AUTO;

-- Create tablespace for indexes
CREATE TABLESPACE finance_index
DATAFILE 'finance_index01.dbf' SIZE 50M
AUTOEXTEND ON NEXT 10M MAXSIZE 200M
EXTENT MANAGEMENT LOCAL
SEGMENT SPACE MANAGEMENT AUTO;

-- Create temporary tablespace
CREATE TEMPORARY TABLESPACE finance_temp
TEMPFILE 'finance_temp01.dbf' SIZE 50M
AUTOEXTEND ON NEXT 10M MAXSIZE 200M;

-- ========================================
-- SECTION 2: USER AND SCHEMA SETUP
-- ========================================

-- Create application user
CREATE USER finance_admin IDENTIFIED BY FinanceSecure2025
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
GRANT CREATE MATERIALIZED VIEW TO finance_admin;

-- Connect as finance_admin for remaining operations
-- CONN finance_admin/FinanceSecure2025

-- ========================================
-- SECTION 3: DROP EXISTING OBJECTS (for clean reinstall)
-- ========================================

BEGIN
    -- Drop tables
    FOR t IN (SELECT table_name FROM user_tables WHERE table_name LIKE 'FINANCE_%') LOOP
        EXECUTE IMMEDIATE 'DROP TABLE ' || t.table_name || ' CASCADE CONSTRAINTS';
    END LOOP;
    
    -- Drop sequences
    FOR s IN (SELECT sequence_name FROM user_sequences WHERE sequence_name LIKE 'SEQ_%') LOOP
        EXECUTE IMMEDIATE 'DROP SEQUENCE ' || s.sequence_name;
    END LOOP;
    
    -- Drop materialized views
    FOR mv IN (SELECT mview_name FROM user_mviews WHERE mview_name LIKE 'MV_%') LOOP
        EXECUTE IMMEDIATE 'DROP MATERIALIZED VIEW ' || mv.mview_name;
    END LOOP;
END;
/

-- ========================================
-- SECTION 4: CREATE SEQUENCES
-- ========================================

CREATE SEQUENCE seq_user_id
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

CREATE SEQUENCE seq_category_id
START WITH 1
INCREMENT BY 1
CACHE 20
NOCYCLE;

CREATE SEQUENCE seq_expense_id
START WITH 1
INCREMENT BY 1
CACHE 100
NOCYCLE;

CREATE SEQUENCE seq_income_id
START WITH 1
INCREMENT BY 1
CACHE 100
NOCYCLE;

CREATE SEQUENCE seq_budget_id
START WITH 1
INCREMENT BY 1
CACHE 20
NOCYCLE;

CREATE SEQUENCE seq_goal_id
START WITH 1
INCREMENT BY 1
CACHE 20
NOCYCLE;

CREATE SEQUENCE seq_contribution_id
START WITH 1
INCREMENT BY 1
CACHE 50
NOCYCLE;

CREATE SEQUENCE seq_sync_log_id
START WITH 1
INCREMENT BY 1
CACHE 50
NOCYCLE;

CREATE SEQUENCE seq_audit_id
START WITH 1
INCREMENT BY 1
CACHE 100
NOCYCLE;

-- ========================================
-- SECTION 5: CREATE TABLES
-- ========================================

-- USER Table
CREATE TABLE finance_user (
    user_id NUMBER(10) PRIMARY KEY,
    username VARCHAR2(50) NOT NULL UNIQUE,
    password_hash VARCHAR2(255) NOT NULL,
    email VARCHAR2(100) NOT NULL UNIQUE,
    full_name VARCHAR2(100) NOT NULL,
    created_at TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
    last_sync TIMESTAMP,
    is_active NUMBER(1) DEFAULT 1 NOT NULL,
    last_login TIMESTAMP,
    CONSTRAINT chk_user_email CHECK (email LIKE '%@%'),
    CONSTRAINT chk_user_active CHECK (is_active IN (0, 1))
) TABLESPACE finance_data;

-- CATEGORY Table
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

-- EXPENSE Table
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

-- INCOME Table
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

-- BUDGET Table
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

-- SAVINGS_GOAL Table
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

-- SAVINGS_CONTRIBUTION Table
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

-- SYNC_LOG Table
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

-- AUDIT_LOG Table
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

-- ========================================
-- SECTION 6: CREATE INDEXES
-- ========================================

-- USER Indexes
CREATE INDEX idx_user_username ON finance_user(username) TABLESPACE finance_index;
CREATE INDEX idx_user_email ON finance_user(email) TABLESPACE finance_index;
CREATE INDEX idx_user_active ON finance_user(is_active) TABLESPACE finance_index;

-- CATEGORY Indexes
CREATE INDEX idx_cat_type ON finance_category(category_type) TABLESPACE finance_index;
CREATE INDEX idx_cat_active ON finance_category(is_active) TABLESPACE finance_index;

-- EXPENSE Indexes
CREATE INDEX idx_exp_user ON finance_expense(user_id) TABLESPACE finance_index;
CREATE INDEX idx_exp_category ON finance_expense(category_id) TABLESPACE finance_index;
CREATE INDEX idx_exp_date ON finance_expense(expense_date) TABLESPACE finance_index;
CREATE INDEX idx_exp_user_date ON finance_expense(user_id, expense_date) TABLESPACE finance_index;
CREATE INDEX idx_exp_fiscal ON finance_expense(fiscal_year, fiscal_month) TABLESPACE finance_index;
CREATE INDEX idx_exp_amount ON finance_expense(amount) TABLESPACE finance_index;

-- INCOME Indexes
CREATE INDEX idx_inc_user ON finance_income(user_id) TABLESPACE finance_index;
CREATE INDEX idx_inc_date ON finance_income(income_date) TABLESPACE finance_index;
CREATE INDEX idx_inc_user_date ON finance_income(user_id, income_date) TABLESPACE finance_index;
CREATE INDEX idx_inc_fiscal ON finance_income(fiscal_year, fiscal_month) TABLESPACE finance_index;
CREATE INDEX idx_inc_source ON finance_income(income_source) TABLESPACE finance_index;

-- BUDGET Indexes
CREATE INDEX idx_bud_user ON finance_budget(user_id) TABLESPACE finance_index;
CREATE INDEX idx_bud_category ON finance_budget(category_id) TABLESPACE finance_index;
CREATE INDEX idx_bud_dates ON finance_budget(start_date, end_date) TABLESPACE finance_index;
CREATE INDEX idx_bud_active ON finance_budget(is_active) TABLESPACE finance_index;

-- SAVINGS_GOAL Indexes
CREATE INDEX idx_goal_user ON finance_savings_goal(user_id) TABLESPACE finance_index;
CREATE INDEX idx_goal_status ON finance_savings_goal(status) TABLESPACE finance_index;
CREATE INDEX idx_goal_deadline ON finance_savings_goal(deadline) TABLESPACE finance_index;
CREATE INDEX idx_goal_priority ON finance_savings_goal(priority) TABLESPACE finance_index;

-- SAVINGS_CONTRIBUTION Indexes
CREATE INDEX idx_cont_goal ON finance_savings_contribution(goal_id) TABLESPACE finance_index;
CREATE INDEX idx_cont_date ON finance_savings_contribution(contribution_date) TABLESPACE finance_index;

-- SYNC_LOG Indexes
CREATE INDEX idx_sync_user ON finance_sync_log(user_id) TABLESPACE finance_index;
CREATE INDEX idx_sync_status ON finance_sync_log(sync_status) TABLESPACE finance_index;
CREATE INDEX idx_sync_time ON finance_sync_log(sync_start_time) TABLESPACE finance_index;

-- AUDIT_LOG Indexes
CREATE INDEX idx_audit_table ON finance_audit_log(table_name) TABLESPACE finance_index;
CREATE INDEX idx_audit_time ON finance_audit_log(audit_timestamp) TABLESPACE finance_index;

-- ========================================
-- SECTION 7: CREATE TRIGGERS
-- ========================================

-- USER auto-increment trigger
CREATE OR REPLACE TRIGGER trg_user_bi
BEFORE INSERT ON finance_user
FOR EACH ROW
BEGIN
    IF :NEW.user_id IS NULL THEN
        SELECT seq_user_id.NEXTVAL INTO :NEW.user_id FROM DUAL;
    END IF;
END;
/

-- CATEGORY auto-increment trigger
CREATE OR REPLACE TRIGGER trg_category_bi
BEFORE INSERT ON finance_category
FOR EACH ROW
BEGIN
    IF :NEW.category_id IS NULL THEN
        SELECT seq_category_id.NEXTVAL INTO :NEW.category_id FROM DUAL;
    END IF;
END;
/

-- EXPENSE auto-increment and fiscal period trigger
CREATE OR REPLACE TRIGGER trg_expense_bi
BEFORE INSERT ON finance_expense
FOR EACH ROW
BEGIN
    IF :NEW.expense_id IS NULL THEN
        SELECT seq_expense_id.NEXTVAL INTO :NEW.expense_id FROM DUAL;
    END IF;
    
    :NEW.fiscal_year := EXTRACT(YEAR FROM :NEW.expense_date);
    :NEW.fiscal_month := EXTRACT(MONTH FROM :NEW.expense_date);
END;
/

-- EXPENSE modified_at trigger
CREATE OR REPLACE TRIGGER trg_expense_bu
BEFORE UPDATE ON finance_expense
FOR EACH ROW
BEGIN
    :NEW.modified_at := SYSTIMESTAMP;
END;
/

-- INCOME auto-increment and fiscal period trigger
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

-- INCOME modified_at trigger
CREATE OR REPLACE TRIGGER trg_income_bu
BEFORE UPDATE ON finance_income
FOR EACH ROW
BEGIN
    :NEW.modified_at := SYSTIMESTAMP;
END;
/

-- BUDGET auto-increment trigger
CREATE OR REPLACE TRIGGER trg_budget_bi
BEFORE INSERT ON finance_budget
FOR EACH ROW
BEGIN
    IF :NEW.budget_id IS NULL THEN
        SELECT seq_budget_id.NEXTVAL INTO :NEW.budget_id FROM DUAL;
    END IF;
END;
/

-- BUDGET modified_at trigger
CREATE OR REPLACE TRIGGER trg_budget_bu
BEFORE UPDATE ON finance_budget
FOR EACH ROW
BEGIN
    :NEW.modified_at := SYSTIMESTAMP;
END;
/

-- SAVINGS_GOAL auto-increment trigger
CREATE OR REPLACE TRIGGER trg_goal_bi
BEFORE INSERT ON finance_savings_goal
FOR EACH ROW
BEGIN
    IF :NEW.goal_id IS NULL THEN
        SELECT seq_goal_id.NEXTVAL INTO :NEW.goal_id FROM DUAL;
    END IF;
END;
/

-- SAVINGS_GOAL modified_at and auto-complete trigger
CREATE OR REPLACE TRIGGER trg_goal_bu
BEFORE UPDATE ON finance_savings_goal
FOR EACH ROW
BEGIN
    :NEW.modified_at := SYSTIMESTAMP;
    
    IF :NEW.current_amount >= :NEW.target_amount AND :NEW.status = 'Active' THEN
        :NEW.status := 'Completed';
        :NEW.completed_date := SYSDATE;
    END IF;
END;
/

-- SAVINGS_CONTRIBUTION auto-increment trigger
CREATE OR REPLACE TRIGGER trg_contribution_bi
BEFORE INSERT ON finance_savings_contribution
FOR EACH ROW
BEGIN
    IF :NEW.contribution_id IS NULL THEN
        SELECT seq_contribution_id.NEXTVAL INTO :NEW.contribution_id FROM DUAL;
    END IF;
END;
/

-- SAVINGS_CONTRIBUTION update goal amount trigger
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

-- SYNC_LOG auto-increment trigger
CREATE OR REPLACE TRIGGER trg_sync_log_bi
BEFORE INSERT ON finance_sync_log
FOR EACH ROW
BEGIN
    IF :NEW.sync_log_id IS NULL THEN
        SELECT seq_sync_log_id.NEXTVAL INTO :NEW.sync_log_id FROM DUAL;
    END IF;
END;
/

-- SYNC_LOG duration calculator trigger
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

-- AUDIT_LOG auto-increment trigger
CREATE OR REPLACE TRIGGER trg_audit_bi
BEFORE INSERT ON finance_audit_log
FOR EACH ROW
BEGIN
    IF :NEW.audit_id IS NULL THEN
        SELECT seq_audit_id.NEXTVAL INTO :NEW.audit_id FROM DUAL;
    END IF;
END;
/

-- ========================================
-- SECTION 8: INSERT DEFAULT CATEGORIES
-- ========================================

-- Expense Categories
INSERT INTO finance_category (category_name, category_type, description, is_active, display_order) VALUES
('Food & Dining', 'EXPENSE', 'Groceries, restaurants, food delivery', 1, 1);

INSERT INTO finance_category (category_name, category_type, description, is_active, display_order) VALUES
('Transportation', 'EXPENSE', 'Fuel, public transport, vehicle maintenance', 1, 2);

INSERT INTO finance_category (category_name, category_type, description, is_active, display_order) VALUES
('Entertainment', 'EXPENSE', 'Movies, games, hobbies, subscriptions', 1, 3);

INSERT INTO finance_category (category_name, category_type, description, is_active, display_order) VALUES
('Bills & Utilities', 'EXPENSE', 'Electricity, water, internet, phone bills', 1, 4);

INSERT INTO finance_category (category_name, category_type, description, is_active, display_order) VALUES
('Healthcare', 'EXPENSE', 'Medical expenses, insurance, pharmacy', 1, 5);

INSERT INTO finance_category (category_name, category_type, description, is_active, display_order) VALUES
('Shopping', 'EXPENSE', 'Clothing, electronics, household items', 1, 6);

INSERT INTO finance_category (category_name, category_type, description, is_active, display_order) VALUES
('Education', 'EXPENSE', 'Books, courses, tuition fees', 1, 7);

INSERT INTO finance_category (category_name, category_type, description, is_active, display_order) VALUES
('Housing', 'EXPENSE', 'Rent, mortgage, home maintenance', 1, 8);

INSERT INTO finance_category (category_name, category_type, description, is_active, display_order) VALUES
('Personal Care', 'EXPENSE', 'Salon, gym, wellness', 1, 9);

INSERT INTO finance_category (category_name, category_type, description, is_active, display_order) VALUES
('Others', 'EXPENSE', 'Miscellaneous expenses', 1, 10);

-- Income Categories
INSERT INTO finance_category (category_name, category_type, description, is_active, display_order) VALUES
('Salary', 'INCOME', 'Monthly salary income', 1, 1);

INSERT INTO finance_category (category_name, category_type, description, is_active, display_order) VALUES
('Freelance', 'INCOME', 'Freelance project income', 1, 2);

INSERT INTO finance_category (category_name, category_type, description, is_active, display_order) VALUES
('Investment', 'INCOME', 'Returns from investments', 1, 3);

INSERT INTO finance_category (category_name, category_type, description, is_active, display_order) VALUES
('Gift', 'INCOME', 'Money received as gifts', 1, 4);

INSERT INTO finance_category (category_name, category_type, description, is_active, display_order) VALUES
('Business', 'INCOME', 'Business revenue', 1, 5);

COMMIT;

-- ========================================
-- DATABASE CREATED SUCCESSFULLY
-- ========================================

-- Display creation summary
SELECT 'Oracle Database Created Successfully!' AS status FROM DUAL;

SELECT table_name FROM user_tables WHERE table_name LIKE 'FINANCE_%' ORDER BY table_name;

SELECT sequence_name FROM user_sequences WHERE sequence_name LIKE 'SEQ_%' ORDER BY sequence_name;

-- Gather statistics for optimizer
BEGIN
    DBMS_STATS.GATHER_SCHEMA_STATS('FINANCE_ADMIN');
END;
/


