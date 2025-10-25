# Physical Database Design - SQLite (Local Database)

## 1. SQLite-Specific Considerations

### 1.1 SQLite Characteristics
- **Storage**: Single file database (finance_local.db)
- **Data Types**: Uses type affinity (INTEGER, REAL, TEXT, BLOB)
- **Constraints**: Supports PK, FK, NOT NULL, UNIQUE, CHECK, DEFAULT
- **Auto-increment**: Uses AUTOINCREMENT keyword or INTEGER PRIMARY KEY
- **Transactions**: ACID compliant
- **Size**: Optimized for < 100MB typical usage
- **Concurrency**: Single writer, multiple readers

### 1.2 Design Adaptations for SQLite
- Use INTEGER PRIMARY KEY for auto-increment (more efficient than AUTOINCREMENT)
- Foreign keys must be explicitly enabled: `PRAGMA foreign_keys = ON;`
- No BOOLEAN type - use INTEGER (0 = FALSE, 1 = TRUE)
- No native TIMESTAMP - use TEXT with ISO8601 format or INTEGER (Unix timestamp)
- DECIMAL stored as REAL with precision handled at application level

## 2. Physical Table Structures

### 2.1 USER Table
```sql
CREATE TABLE IF NOT EXISTS user (
    user_id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT NOT NULL UNIQUE,
    email TEXT NOT NULL UNIQUE,
    full_name TEXT NOT NULL,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    last_sync TEXT,
    CONSTRAINT chk_email CHECK (email LIKE '%@%')
);
```

**Indexes:**
```sql
CREATE INDEX idx_user_username ON user(username);
CREATE INDEX idx_user_email ON user(email);
```

### 2.2 CATEGORY Table
```sql
CREATE TABLE IF NOT EXISTS category (
    category_id INTEGER PRIMARY KEY AUTOINCREMENT,
    category_name TEXT NOT NULL UNIQUE,
    category_type TEXT NOT NULL CHECK (category_type IN ('EXPENSE', 'INCOME')),
    description TEXT,
    is_active INTEGER NOT NULL DEFAULT 1 CHECK (is_active IN (0, 1))
);
```

**Indexes:**
```sql
CREATE INDEX idx_category_name ON category(category_name);
CREATE INDEX idx_category_type ON category(category_type);
```

### 2.3 EXPENSE Table
```sql
CREATE TABLE IF NOT EXISTS expense (
    expense_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    category_id INTEGER NOT NULL,
    amount REAL NOT NULL CHECK (amount > 0),
    expense_date TEXT NOT NULL,
    description TEXT,
    payment_method TEXT NOT NULL CHECK (payment_method IN ('Cash', 'Credit Card', 'Debit Card', 'Online', 'Bank Transfer')),
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    modified_at TEXT NOT NULL DEFAULT (datetime('now')),
    is_synced INTEGER NOT NULL DEFAULT 0 CHECK (is_synced IN (0, 1)),
    sync_timestamp TEXT,
    FOREIGN KEY (user_id) REFERENCES user(user_id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES category(category_id) ON DELETE RESTRICT
);
```

**Indexes:**
```sql
CREATE INDEX idx_expense_user ON expense(user_id);
CREATE INDEX idx_expense_category ON expense(category_id);
CREATE INDEX idx_expense_date ON expense(expense_date);
CREATE INDEX idx_expense_synced ON expense(is_synced);
CREATE INDEX idx_expense_user_date ON expense(user_id, expense_date);
```

### 2.4 INCOME Table
```sql
CREATE TABLE IF NOT EXISTS income (
    income_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    income_source TEXT NOT NULL CHECK (income_source IN ('Salary', 'Freelance', 'Investment', 'Gift', 'Business', 'Other')),
    amount REAL NOT NULL CHECK (amount > 0),
    income_date TEXT NOT NULL,
    description TEXT,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    modified_at TEXT NOT NULL DEFAULT (datetime('now')),
    is_synced INTEGER NOT NULL DEFAULT 0 CHECK (is_synced IN (0, 1)),
    sync_timestamp TEXT,
    FOREIGN KEY (user_id) REFERENCES user(user_id) ON DELETE CASCADE
);
```

**Indexes:**
```sql
CREATE INDEX idx_income_user ON income(user_id);
CREATE INDEX idx_income_date ON income(income_date);
CREATE INDEX idx_income_synced ON income(is_synced);
CREATE INDEX idx_income_user_date ON income(user_id, income_date);
```

### 2.5 BUDGET Table
```sql
CREATE TABLE IF NOT EXISTS budget (
    budget_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    category_id INTEGER NOT NULL,
    budget_amount REAL NOT NULL CHECK (budget_amount > 0),
    start_date TEXT NOT NULL,
    end_date TEXT NOT NULL,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    modified_at TEXT NOT NULL DEFAULT (datetime('now')),
    is_active INTEGER NOT NULL DEFAULT 1 CHECK (is_active IN (0, 1)),
    is_synced INTEGER NOT NULL DEFAULT 0 CHECK (is_synced IN (0, 1)),
    FOREIGN KEY (user_id) REFERENCES user(user_id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES category(category_id) ON DELETE RESTRICT,
    CONSTRAINT chk_date_range CHECK (end_date > start_date)
);
```

**Indexes:**
```sql
CREATE INDEX idx_budget_user ON budget(user_id);
CREATE INDEX idx_budget_category ON budget(category_id);
CREATE INDEX idx_budget_dates ON budget(start_date, end_date);
CREATE INDEX idx_budget_active ON budget(is_active);
```

### 2.6 SAVINGS_GOAL Table
```sql
CREATE TABLE IF NOT EXISTS savings_goal (
    goal_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    goal_name TEXT NOT NULL,
    target_amount REAL NOT NULL CHECK (target_amount > 0),
    current_amount REAL NOT NULL DEFAULT 0 CHECK (current_amount >= 0),
    start_date TEXT NOT NULL,
    deadline TEXT NOT NULL,
    priority TEXT NOT NULL CHECK (priority IN ('High', 'Medium', 'Low')),
    status TEXT NOT NULL DEFAULT 'Active' CHECK (status IN ('Active', 'Completed', 'Cancelled')),
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    modified_at TEXT NOT NULL DEFAULT (datetime('now')),
    is_synced INTEGER NOT NULL DEFAULT 0 CHECK (is_synced IN (0, 1)),
    FOREIGN KEY (user_id) REFERENCES user(user_id) ON DELETE CASCADE,
    CONSTRAINT chk_goal_amount CHECK (current_amount <= target_amount)
);
```

**Indexes:**
```sql
CREATE INDEX idx_goal_user ON savings_goal(user_id);
CREATE INDEX idx_goal_status ON savings_goal(status);
CREATE INDEX idx_goal_deadline ON savings_goal(deadline);
```

### 2.7 SAVINGS_CONTRIBUTION Table
```sql
CREATE TABLE IF NOT EXISTS savings_contribution (
    contribution_id INTEGER PRIMARY KEY AUTOINCREMENT,
    goal_id INTEGER NOT NULL,
    contribution_amount REAL NOT NULL CHECK (contribution_amount > 0),
    contribution_date TEXT NOT NULL,
    description TEXT,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    FOREIGN KEY (goal_id) REFERENCES savings_goal(goal_id) ON DELETE CASCADE
);
```

**Indexes:**
```sql
CREATE INDEX idx_contribution_goal ON savings_contribution(goal_id);
CREATE INDEX idx_contribution_date ON savings_contribution(contribution_date);
```

### 2.8 SYNC_LOG Table
```sql
CREATE TABLE IF NOT EXISTS sync_log (
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
```

**Indexes:**
```sql
CREATE INDEX idx_sync_user ON sync_log(user_id);
CREATE INDEX idx_sync_status ON sync_log(sync_status);
CREATE INDEX idx_sync_time ON sync_log(sync_start_time);
```

## 3. Triggers for Data Integrity

### 3.1 Auto-update modified_at Timestamp
```sql
-- Trigger for EXPENSE table
CREATE TRIGGER trg_expense_modified_at
AFTER UPDATE ON expense
FOR EACH ROW
BEGIN
    UPDATE expense SET modified_at = datetime('now')
    WHERE expense_id = NEW.expense_id;
END;

-- Trigger for INCOME table
CREATE TRIGGER trg_income_modified_at
AFTER UPDATE ON income
FOR EACH ROW
BEGIN
    UPDATE income SET modified_at = datetime('now')
    WHERE income_id = NEW.income_id;
END;

-- Trigger for BUDGET table
CREATE TRIGGER trg_budget_modified_at
AFTER UPDATE ON budget
FOR EACH ROW
BEGIN
    UPDATE budget SET modified_at = datetime('now')
    WHERE budget_id = NEW.budget_id;
END;

-- Trigger for SAVINGS_GOAL table
CREATE TRIGGER trg_goal_modified_at
AFTER UPDATE ON savings_goal
FOR EACH ROW
BEGIN
    UPDATE savings_goal SET modified_at = datetime('now')
    WHERE goal_id = NEW.goal_id;
END;
```

### 3.2 Auto-update Savings Goal Current Amount
```sql
CREATE TRIGGER trg_update_goal_amount
AFTER INSERT ON savings_contribution
FOR EACH ROW
BEGIN
    UPDATE savings_goal 
    SET current_amount = current_amount + NEW.contribution_amount,
        modified_at = datetime('now')
    WHERE goal_id = NEW.goal_id;
    
    -- Auto-complete goal if target reached
    UPDATE savings_goal
    SET status = 'Completed'
    WHERE goal_id = NEW.goal_id 
    AND current_amount >= target_amount
    AND status = 'Active';
END;
```

### 3.3 Reset Sync Status on Modification
```sql
-- Trigger for EXPENSE
CREATE TRIGGER trg_expense_reset_sync
AFTER UPDATE ON expense
FOR EACH ROW
WHEN OLD.amount != NEW.amount 
   OR OLD.category_id != NEW.category_id 
   OR OLD.expense_date != NEW.expense_date
BEGIN
    UPDATE expense SET is_synced = 0
    WHERE expense_id = NEW.expense_id;
END;

-- Similar triggers for other tables...
```

## 4. Views for Common Queries

### 4.1 Expense Summary View
```sql
CREATE VIEW IF NOT EXISTS v_expense_summary AS
SELECT 
    e.expense_id,
    e.user_id,
    u.username,
    c.category_name,
    e.amount,
    e.expense_date,
    e.description,
    e.payment_method,
    e.is_synced
FROM expense e
JOIN user u ON e.user_id = u.user_id
JOIN category c ON e.category_id = c.category_id;
```

### 4.2 Budget Performance View
```sql
CREATE VIEW IF NOT EXISTS v_budget_performance AS
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
    ROUND((COALESCE(SUM(e.amount), 0) / b.budget_amount) * 100, 2) AS utilization_percent
FROM budget b
JOIN user u ON b.user_id = u.user_id
JOIN category c ON b.category_id = c.category_id
LEFT JOIN expense e ON e.user_id = b.user_id 
    AND e.category_id = b.category_id
    AND e.expense_date BETWEEN b.start_date AND b.end_date
WHERE b.is_active = 1
GROUP BY b.budget_id, b.user_id, u.username, c.category_name, 
         b.budget_amount, b.start_date, b.end_date;
```

### 4.3 Savings Progress View
```sql
CREATE VIEW IF NOT EXISTS v_savings_progress AS
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
        ELSE 'In Progress'
    END AS achievement_status
FROM savings_goal sg
JOIN user u ON sg.user_id = u.user_id;
```

### 4.4 Monthly Summary View
```sql
CREATE VIEW IF NOT EXISTS v_monthly_summary AS
SELECT 
    u.user_id,
    u.username,
    strftime('%Y-%m', e.expense_date) AS month,
    SUM(e.amount) AS total_expenses,
    COUNT(e.expense_id) AS expense_count
FROM user u
LEFT JOIN expense e ON u.user_id = e.user_id
GROUP BY u.user_id, u.username, strftime('%Y-%m', e.expense_date);
```

## 5. Storage and Performance Optimization

### 5.1 Pragmas for Performance
```sql
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
```

### 5.2 Index Strategy
- **Primary indexes**: On all primary keys (automatic)
- **Foreign key indexes**: On all foreign key columns for faster joins
- **Date indexes**: For time-based queries
- **Composite indexes**: For frequently joined columns (user_id + date)
- **Sync indexes**: For efficient synchronization queries

### 5.3 Maintenance Operations
```sql
-- Periodic database optimization
VACUUM;

-- Analyze query patterns for optimizer
ANALYZE;

-- Rebuild indexes if needed
REINDEX;
```

## 6. Data File Structure

### 6.1 Database File
- **Filename**: `finance_local.db`
- **Location**: Application data directory
- **Expected Size**: 10-50 MB (typical usage)
- **Maximum Size**: Unlimited (practical limit ~281 TB)

### 6.2 Supporting Files
- `finance_local.db-wal`: Write-Ahead Log file (WAL mode)
- `finance_local.db-shm`: Shared memory file (WAL mode)

## 7. Security Considerations

### 7.1 Encryption at Rest
```sql
-- SQLite Encryption Extension (SEE) or SQLCipher
-- Example using SQLCipher:
PRAGMA key = 'your-encryption-key';
PRAGMA cipher_page_size = 4096;
PRAGMA kdf_iter = 64000;
```

### 7.2 Access Control
- File-level permissions (OS level)
- Application-level authentication
- No direct database access from external applications

## 8. Backup Strategy

### 8.1 Backup Methods
```sql
-- Using SQLite backup API
-- Command line backup:
.backup finance_local_backup.db

-- Or copy file when database is not in use
```

### 8.2 Backup Schedule
- **Automatic**: Daily backup before sync
- **Manual**: User-triggered backup option
- **Location**: User's Documents/Backups folder
- **Retention**: Keep last 7 daily backups

## 9. Physical Design Summary

**File Location**: `d:\DM2_CW\sqlite\finance_local.db`

**Characteristics**:
- 8 tables with proper relationships
- 15+ indexes for performance
- 10+ triggers for data integrity
- 4 views for common queries
- Foreign key constraints enabled
- WAL mode for concurrency
- Optimized for offline, single-user access

**Estimated Size**:
- Empty database: ~100 KB
- With 1000 transactions: ~5 MB
- With 10,000 transactions: ~30 MB

This physical design provides a robust, efficient, and secure local database implementation for the personal finance management system.
