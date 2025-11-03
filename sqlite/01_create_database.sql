-- ========================================
-- SQLite Database Creation Script
-- Personal Finance Management System
-- Local Database Implementation
-- ========================================

-- Enable foreign key constraints
PRAGMA foreign_keys = ON;

-- Set journal mode for better concurrency
PRAGMA journal_mode = WAL;

-- Optimize for space
PRAGMA auto_vacuum = INCREMENTAL;

-- Cache size (in pages, 1 page = 4KB typically)
PRAGMA cache_size = 10000;  -- 40MB cache

-- Synchronous mode for balance between safety and speed
PRAGMA synchronous = NORMAL;

-- Temp store in memory for faster operations
PRAGMA temp_store = MEMORY;

-- ========================================
-- DROP EXISTING OBJECTS (for clean reinstall)
-- ========================================

DROP TRIGGER IF EXISTS trg_expense_modified_at;
DROP TRIGGER IF EXISTS trg_income_modified_at;
DROP TRIGGER IF EXISTS trg_budget_modified_at;
DROP TRIGGER IF EXISTS trg_goal_modified_at;
DROP TRIGGER IF EXISTS trg_update_goal_amount;
DROP TRIGGER IF EXISTS trg_expense_reset_sync;
DROP TRIGGER IF EXISTS trg_income_reset_sync;
DROP TRIGGER IF EXISTS trg_budget_reset_sync;
DROP TRIGGER IF EXISTS trg_goal_reset_sync;

DROP VIEW IF EXISTS v_expense_summary;
DROP VIEW IF EXISTS v_budget_performance;
DROP VIEW IF EXISTS v_savings_progress;
DROP VIEW IF EXISTS v_monthly_summary;
DROP VIEW IF EXISTS v_category_spending;

DROP TABLE IF EXISTS sync_log;
DROP TABLE IF EXISTS savings_contribution;
DROP TABLE IF EXISTS savings_goal;
DROP TABLE IF EXISTS budget;
DROP TABLE IF EXISTS income;
DROP TABLE IF EXISTS expense;
DROP TABLE IF EXISTS category;
DROP TABLE IF EXISTS user;

-- ========================================
-- CREATE TABLES
-- ========================================

-- USER Table
CREATE TABLE user (
    user_id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    full_name TEXT NOT NULL,
    created_at TEXT NOT NULL DEFAULT (datetime('now', 'localtime')),
    last_sync TEXT,
    CONSTRAINT chk_email CHECK (email LIKE '%@%')
);

-- CATEGORY Table
CREATE TABLE category (
    category_id INTEGER PRIMARY KEY AUTOINCREMENT,
    category_name TEXT NOT NULL UNIQUE,
    category_type TEXT NOT NULL CHECK (category_type IN ('EXPENSE', 'INCOME')),
    description TEXT,
    is_active INTEGER NOT NULL DEFAULT 1 CHECK (is_active IN (0, 1))
);

-- EXPENSE Table
CREATE TABLE expense (
    expense_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    category_id INTEGER NOT NULL,
    amount REAL NOT NULL CHECK (amount > 0),
    expense_date TEXT NOT NULL,
    description TEXT,
    payment_method TEXT NOT NULL CHECK (payment_method IN ('Cash', 'Credit Card', 'Debit Card', 'Online', 'Bank Transfer')),
    created_at TEXT NOT NULL DEFAULT (datetime('now', 'localtime')),
    modified_at TEXT NOT NULL DEFAULT (datetime('now', 'localtime')),
    is_synced INTEGER NOT NULL DEFAULT 0 CHECK (is_synced IN (0, 1)),
    sync_timestamp TEXT,
    FOREIGN KEY (user_id) REFERENCES user(user_id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES category(category_id) ON DELETE RESTRICT
);

-- INCOME Table
CREATE TABLE income (
    income_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    income_source TEXT NOT NULL CHECK (income_source IN ('Salary', 'Freelance', 'Investment', 'Gift', 'Business', 'Other')),
    amount REAL NOT NULL CHECK (amount > 0),
    income_date TEXT NOT NULL,
    description TEXT,
    created_at TEXT NOT NULL DEFAULT (datetime('now', 'localtime')),
    modified_at TEXT NOT NULL DEFAULT (datetime('now', 'localtime')),
    is_synced INTEGER NOT NULL DEFAULT 0 CHECK (is_synced IN (0, 1)),
    sync_timestamp TEXT,
    FOREIGN KEY (user_id) REFERENCES user(user_id) ON DELETE CASCADE
);

-- BUDGET Table
CREATE TABLE budget (
    budget_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    category_id INTEGER NOT NULL,
    budget_amount REAL NOT NULL CHECK (budget_amount > 0),
    start_date TEXT NOT NULL,
    end_date TEXT NOT NULL,
    created_at TEXT NOT NULL DEFAULT (datetime('now', 'localtime')),
    modified_at TEXT NOT NULL DEFAULT (datetime('now', 'localtime')),
    is_active INTEGER NOT NULL DEFAULT 1 CHECK (is_active IN (0, 1)),
    is_synced INTEGER NOT NULL DEFAULT 0 CHECK (is_synced IN (0, 1)),
    FOREIGN KEY (user_id) REFERENCES user(user_id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES category(category_id) ON DELETE RESTRICT,
    CONSTRAINT chk_date_range CHECK (end_date > start_date)
);

-- SAVINGS_GOAL Table
CREATE TABLE savings_goal (
    goal_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    goal_name TEXT NOT NULL,
    target_amount REAL NOT NULL CHECK (target_amount > 0),
    current_amount REAL NOT NULL DEFAULT 0 CHECK (current_amount >= 0),
    start_date TEXT NOT NULL,
    deadline TEXT NOT NULL,
    priority TEXT NOT NULL CHECK (priority IN ('High', 'Medium', 'Low')),
    status TEXT NOT NULL DEFAULT 'Active' CHECK (status IN ('Active', 'Completed', 'Cancelled')),
    created_at TEXT NOT NULL DEFAULT (datetime('now', 'localtime')),
    modified_at TEXT NOT NULL DEFAULT (datetime('now', 'localtime')),
    is_synced INTEGER NOT NULL DEFAULT 0 CHECK (is_synced IN (0, 1)),
    FOREIGN KEY (user_id) REFERENCES user(user_id) ON DELETE CASCADE,
    CONSTRAINT chk_goal_amount CHECK (current_amount <= target_amount)
);

-- SAVINGS_CONTRIBUTION Table
CREATE TABLE savings_contribution (
    contribution_id INTEGER PRIMARY KEY AUTOINCREMENT,
    goal_id INTEGER NOT NULL,
    contribution_amount REAL NOT NULL CHECK (contribution_amount > 0),
    contribution_date TEXT NOT NULL,
    description TEXT,
    created_at TEXT NOT NULL DEFAULT (datetime('now', 'localtime')),
    FOREIGN KEY (goal_id) REFERENCES savings_goal(goal_id) ON DELETE CASCADE
);

-- SYNC_LOG Table
CREATE TABLE sync_log (
    sync_log_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    sync_start_time TEXT NOT NULL,
    sync_end_time TEXT,
    records_synced INTEGER NOT NULL DEFAULT 0,
    sync_status TEXT NOT NULL CHECK (sync_status IN ('Success', 'Failed', 'Partial')),
    error_message TEXT,
    sync_type TEXT NOT NULL CHECK (sync_type IN ('Manual', 'Automatic')),
    FOREIGN KEY (user_id) REFERENCES user(user_id) ON DELETE CASCADE
);

-- ========================================
-- CREATE INDEXES
-- ========================================

-- USER Indexes
CREATE INDEX idx_user_username ON user(username);
CREATE INDEX idx_user_email ON user(email);

-- CATEGORY Indexes
CREATE INDEX idx_category_name ON category(category_name);
CREATE INDEX idx_category_type ON category(category_type);

-- EXPENSE Indexes
CREATE INDEX idx_expense_user ON expense(user_id);
CREATE INDEX idx_expense_category ON expense(category_id);
CREATE INDEX idx_expense_date ON expense(expense_date);
CREATE INDEX idx_expense_synced ON expense(is_synced);
CREATE INDEX idx_expense_user_date ON expense(user_id, expense_date);

-- INCOME Indexes
CREATE INDEX idx_income_user ON income(user_id);
CREATE INDEX idx_income_date ON income(income_date);
CREATE INDEX idx_income_synced ON income(is_synced);
CREATE INDEX idx_income_user_date ON income(user_id, income_date);

-- BUDGET Indexes
CREATE INDEX idx_budget_user ON budget(user_id);
CREATE INDEX idx_budget_category ON budget(category_id);
CREATE INDEX idx_budget_dates ON budget(start_date, end_date);
CREATE INDEX idx_budget_active ON budget(is_active);

-- SAVINGS_GOAL Indexes
CREATE INDEX idx_goal_user ON savings_goal(user_id);
CREATE INDEX idx_goal_status ON savings_goal(status);
CREATE INDEX idx_goal_deadline ON savings_goal(deadline);

-- SAVINGS_CONTRIBUTION Indexes
CREATE INDEX idx_contribution_goal ON savings_contribution(goal_id);
CREATE INDEX idx_contribution_date ON savings_contribution(contribution_date);

-- SYNC_LOG Indexes
CREATE INDEX idx_sync_user ON sync_log(user_id);
CREATE INDEX idx_sync_status ON sync_log(sync_status);
CREATE INDEX idx_sync_time ON sync_log(sync_start_time);

-- ========================================
-- CREATE TRIGGERS
-- ========================================

-- Trigger: Auto-update modified_at for EXPENSE
CREATE TRIGGER trg_expense_modified_at
AFTER UPDATE ON expense
FOR EACH ROW
WHEN NEW.modified_at = OLD.modified_at
BEGIN
    UPDATE expense SET modified_at = datetime('now', 'localtime')
    WHERE expense_id = NEW.expense_id;
END;

-- Trigger: Auto-update modified_at for INCOME
CREATE TRIGGER trg_income_modified_at
AFTER UPDATE ON income
FOR EACH ROW
WHEN NEW.modified_at = OLD.modified_at
BEGIN
    UPDATE income SET modified_at = datetime('now', 'localtime')
    WHERE income_id = NEW.income_id;
END;

-- Trigger: Auto-update modified_at for BUDGET
CREATE TRIGGER trg_budget_modified_at
AFTER UPDATE ON budget
FOR EACH ROW
WHEN NEW.modified_at = OLD.modified_at
BEGIN
    UPDATE budget SET modified_at = datetime('now', 'localtime')
    WHERE budget_id = NEW.budget_id;
END;

-- Trigger: Auto-update modified_at for SAVINGS_GOAL
CREATE TRIGGER trg_goal_modified_at
AFTER UPDATE ON savings_goal
FOR EACH ROW
WHEN NEW.modified_at = OLD.modified_at
BEGIN
    UPDATE savings_goal SET modified_at = datetime('now', 'localtime')
    WHERE goal_id = NEW.goal_id;
END;

-- Trigger: Auto-update savings goal amount and status
CREATE TRIGGER trg_update_goal_amount
AFTER INSERT ON savings_contribution
FOR EACH ROW
BEGIN
    -- Update current amount
    UPDATE savings_goal 
    SET current_amount = current_amount + NEW.contribution_amount,
        modified_at = datetime('now', 'localtime')
    WHERE goal_id = NEW.goal_id;
    
    -- Auto-complete goal if target reached
    UPDATE savings_goal
    SET status = 'Completed'
    WHERE goal_id = NEW.goal_id 
    AND current_amount >= target_amount
    AND status = 'Active';
END;

-- Trigger: Reset sync status on EXPENSE modification
CREATE TRIGGER trg_expense_reset_sync
AFTER UPDATE ON expense
FOR EACH ROW
WHEN (OLD.amount != NEW.amount 
   OR OLD.category_id != NEW.category_id 
   OR OLD.expense_date != NEW.expense_date
   OR OLD.description != NEW.description)
BEGIN
    UPDATE expense SET is_synced = 0
    WHERE expense_id = NEW.expense_id;
END;

-- Trigger: Reset sync status on INCOME modification
CREATE TRIGGER trg_income_reset_sync
AFTER UPDATE ON income
FOR EACH ROW
WHEN (OLD.amount != NEW.amount 
   OR OLD.income_source != NEW.income_source 
   OR OLD.income_date != NEW.income_date)
BEGIN
    UPDATE income SET is_synced = 0
    WHERE income_id = NEW.income_id;
END;

-- Trigger: Reset sync status on BUDGET modification
CREATE TRIGGER trg_budget_reset_sync
AFTER UPDATE ON budget
FOR EACH ROW
WHEN (OLD.budget_amount != NEW.budget_amount 
   OR OLD.start_date != NEW.start_date 
   OR OLD.end_date != NEW.end_date)
BEGIN
    UPDATE budget SET is_synced = 0
    WHERE budget_id = NEW.budget_id;
END;

-- Trigger: Reset sync status on SAVINGS_GOAL modification
CREATE TRIGGER trg_goal_reset_sync
AFTER UPDATE ON savings_goal
FOR EACH ROW
WHEN (OLD.target_amount != NEW.target_amount 
   OR OLD.current_amount != NEW.current_amount 
   OR OLD.deadline != NEW.deadline)
BEGIN
    UPDATE savings_goal SET is_synced = 0
    WHERE goal_id = NEW.goal_id;
END;

-- ========================================
-- CREATE VIEWS
-- ========================================

-- View: Expense Summary with User and Category Details
CREATE VIEW v_expense_summary AS
SELECT 
    e.expense_id,
    e.user_id,
    u.username,
    u.full_name,
    c.category_name,
    c.category_type,
    e.amount,
    e.expense_date,
    e.description,
    e.payment_method,
    e.created_at,
    e.is_synced,
    CASE 
        WHEN e.is_synced = 1 THEN 'Synced'
        ELSE 'Pending'
    END AS sync_status
FROM expense e
JOIN user u ON e.user_id = u.user_id
JOIN category c ON e.category_id = c.category_id;

-- View: Budget Performance Analysis
CREATE VIEW v_budget_performance AS
SELECT 
    b.budget_id,
    b.user_id,
    u.username,
    c.category_name,
    b.budget_amount,
    b.start_date,
    b.end_date,
    COALESCE(SUM(e.amount), 0) AS actual_spent,
    b.budget_amount - COALESCE(SUM(e.amount), 0) AS remaining,
    ROUND((COALESCE(SUM(e.amount), 0) / b.budget_amount) * 100, 2) AS utilization_percent,
    CASE 
        WHEN COALESCE(SUM(e.amount), 0) > b.budget_amount THEN 'Over Budget'
        WHEN (COALESCE(SUM(e.amount), 0) / b.budget_amount) * 100 >= 80 THEN 'Near Limit'
        ELSE 'Within Budget'
    END AS budget_status,
    COUNT(e.expense_id) AS transaction_count
FROM budget b
JOIN user u ON b.user_id = u.user_id
JOIN category c ON b.category_id = c.category_id
LEFT JOIN expense e ON e.user_id = b.user_id 
    AND e.category_id = b.category_id
    AND e.expense_date BETWEEN b.start_date AND b.end_date
WHERE b.is_active = 1
GROUP BY b.budget_id, b.user_id, u.username, c.category_name, 
         b.budget_amount, b.start_date, b.end_date;

-- View: Savings Goal Progress
CREATE VIEW v_savings_progress AS
SELECT 
    sg.goal_id,
    sg.user_id,
    u.username,
    sg.goal_name,
    sg.target_amount,
    sg.current_amount,
    sg.target_amount - sg.current_amount AS remaining_amount,
    ROUND((sg.current_amount / sg.target_amount) * 100, 2) AS progress_percent,
    sg.start_date,
    sg.deadline,
    sg.priority,
    sg.status,
    CASE 
        WHEN sg.deadline < date('now') AND sg.status = 'Active' THEN 'Overdue'
        WHEN sg.current_amount >= sg.target_amount THEN 'Achieved'
        WHEN sg.status = 'Cancelled' THEN 'Cancelled'
        ELSE 'In Progress'
    END AS achievement_status,
    (SELECT COUNT(*) FROM savings_contribution sc WHERE sc.goal_id = sg.goal_id) AS contribution_count
FROM savings_goal sg
JOIN user u ON sg.user_id = u.user_id;

-- View: Monthly Summary
CREATE VIEW v_monthly_summary AS
SELECT 
    u.user_id,
    u.username,
    strftime('%Y-%m', e.expense_date) AS month,
    strftime('%Y', e.expense_date) AS year,
    strftime('%m', e.expense_date) AS month_num,
    SUM(e.amount) AS total_expenses,
    COUNT(e.expense_id) AS expense_count,
    AVG(e.amount) AS avg_expense,
    MIN(e.amount) AS min_expense,
    MAX(e.amount) AS max_expense
FROM user u
LEFT JOIN expense e ON u.user_id = e.user_id
WHERE e.expense_date IS NOT NULL
GROUP BY u.user_id, u.username, strftime('%Y-%m', e.expense_date)
ORDER BY month DESC;

-- View: Category-wise Spending
CREATE VIEW v_category_spending AS
SELECT 
    u.user_id,
    u.username,
    c.category_name,
    COUNT(e.expense_id) AS transaction_count,
    SUM(e.amount) AS total_spent,
    AVG(e.amount) AS avg_transaction,
    MIN(e.amount) AS min_transaction,
    MAX(e.amount) AS max_transaction,
    strftime('%Y-%m', MAX(e.expense_date)) AS last_expense_month
FROM user u
CROSS JOIN category c
LEFT JOIN expense e ON u.user_id = e.user_id AND c.category_id = e.category_id
WHERE c.category_type = 'EXPENSE'
GROUP BY u.user_id, u.username, c.category_name
HAVING COUNT(e.expense_id) > 0
ORDER BY total_spent DESC;

-- ========================================
-- INSERT DEFAULT CATEGORIES
-- ========================================

-- Expense Categories
INSERT INTO category (category_name, category_type, description, is_active) VALUES
('Food & Dining', 'EXPENSE', 'Groceries, restaurants, food delivery', 1),
('Transportation', 'EXPENSE', 'Fuel, public transport, vehicle maintenance', 1),
('Entertainment', 'EXPENSE', 'Movies, games, hobbies, subscriptions', 1),
('Bills & Utilities', 'EXPENSE', 'Electricity, water, internet, phone bills', 1),
('Healthcare', 'EXPENSE', 'Medical expenses, insurance, pharmacy', 1),
('Shopping', 'EXPENSE', 'Clothing, electronics, household items', 1),
('Education', 'EXPENSE', 'Books, courses, tuition fees', 1),
('Housing', 'EXPENSE', 'Rent, mortgage, home maintenance', 1),
('Personal Care', 'EXPENSE', 'Salon, gym, wellness', 1),
('Others', 'EXPENSE', 'Miscellaneous expenses', 1);

-- Income Categories
INSERT INTO category (category_name, category_type, description, is_active) VALUES
('Salary', 'INCOME', 'Monthly salary income', 1),
('Freelance', 'INCOME', 'Freelance project income', 1),
('Investment', 'INCOME', 'Returns from investments', 1),
('Gift', 'INCOME', 'Money received as gifts', 1),
('Business', 'INCOME', 'Business revenue', 1);

-- ========================================
-- DATABASE READY
-- ========================================

-- Display database info
SELECT 'SQLite Database Created Successfully!' AS Status;
SELECT sqlite_version() AS SQLite_Version;

-- Display tables
SELECT name, type FROM sqlite_master WHERE type IN ('table', 'view', 'trigger', 'index') ORDER BY type, name;

-- Analyze database for query optimization
ANALYZE;
