# Section 3: Database Design

**Personal Finance Management System**  
**Logical and Physical Database Design**

---

## 2.1 Logical Design

### 2.1.1 Entity-Relationship Diagram

```
                    ┌──────────────────────┐
                    │       USER           │
                    │──────────────────────│
                    │ PK: user_id          │
                    │ username (UNIQUE)    │
                    │ password_hash        │
                    │ email (UNIQUE)       │
                    │ full_name            │
                    │ created_at           │
                    │ last_sync            │
                    └──────────┬───────────┘
                               │
                               │ 1
                               │
                 ┌─────────────┼─────────────┬─────────────┬─────────────┐
                 │             │             │             │             │
                 │M            │M            │M            │M            │
    ┌────────────▼──────────┐ │ ┌──────────▼──────────┐ │ ┌──────────▼──────────┐
    │      EXPENSE          │ │ │       INCOME        │ │ │       BUDGET        │
    │───────────────────────│ │ │─────────────────────│ │ │─────────────────────│
    │ PK: expense_id        │ │ │ PK: income_id       │ │ │ PK: budget_id       │
    │ FK: user_id           │ │ │ FK: user_id         │ │ │ FK: user_id         │
    │ FK: category_id       │ │ │ income_source       │ │ │ FK: category_id     │
    │ amount                │ │ │ amount              │ │ │ budget_amount       │
    │ expense_date          │ │ │ income_date         │ │ │ start_date          │
    │ description           │ │ │ description         │ │ │ end_date            │
    │ payment_method        │ │ │ created_at          │ │ │ is_active           │
    │ fiscal_year           │ │ │ modified_at         │ │ │ created_at          │
    │ fiscal_month          │ │ │ is_synced           │ │ │ modified_at         │
    │ created_at            │ │ │ sync_timestamp      │ │ │ is_synced           │
    │ modified_at           │ │ └─────────────────────┘ │ └─────────────────────┘
    │ is_synced             │ │                         │
    │ sync_timestamp        │ │                         │ ┌──────────▼──────────┐
    └───────────┬───────────┘ │                         │ │   SAVINGS_GOAL      │
                │M             │                         │ │─────────────────────│
                │              │                         │ │ PK: goal_id         │
                │              │                         │ │ FK: user_id         │
    ┌───────────▼──────────┐  │                         │ │ goal_name           │
    │      CATEGORY        │  │                         │ │ target_amount       │
    │──────────────────────│  │                         │ │ current_amount      │
    │ PK: category_id      │  │                         │ │ start_date          │
    │ category_name (UNIQUE)│ │                         │ │ deadline            │
    │ category_type        │  │                         │ │ priority            │
    │ description          │  │                         │ │ status              │
    │ is_active            │  │                         │ │ created_at          │
    └──────────────────────┘  │                         │ │ modified_at         │
                               │                         │ │ is_synced           │
                               │                         │ └──────────┬──────────┘
                               │                         │            │
                               │                         │            │ 1
                               │                         │            │
                               │                         │            │M
                               │                         │ ┌──────────▼──────────┐
                               │                         │ │ SAVINGS_CONTRIBUTION│
                               │                         │ │─────────────────────│
                               │                         │ │ PK: contribution_id │
                               │                         │ │ FK: goal_id         │
                               │                         │ │ contribution_amount │
                               │                         │ │ contribution_date   │
                               │                         │ │ description         │
                               │                         │ │ created_at          │
                               │                         │ └─────────────────────┘
                               │M
                               │
                    ┌──────────▼──────────┐
                    │      SYNC_LOG       │
                    │─────────────────────│
                    │ PK: sync_log_id     │
                    │ FK: user_id         │
                    │ sync_start_time     │
                    │ sync_end_time       │
                    │ records_synced      │
                    │ sync_status         │
                    │ error_message       │
                    │ sync_type           │
                    └─────────────────────┘
```

### 2.1.2 Entity Descriptions

#### Entity 1: USER
**Purpose**: Stores user account information and authentication credentials

| Attribute | Type | Constraints | Description |
|-----------|------|-------------|-------------|
| user_id | INTEGER | PK, AUTO_INCREMENT | Unique identifier for each user |
| username | VARCHAR(50) | UNIQUE, NOT NULL | Login username |
| password_hash | VARCHAR(255) | NOT NULL | PBKDF2-SHA256 hashed password |
| email | VARCHAR(100) | UNIQUE, NOT NULL | User's email address |
| full_name | VARCHAR(100) | NOT NULL | User's full name |
| created_at | TIMESTAMP | NOT NULL, DEFAULT NOW() | Account creation timestamp |
| last_sync | TIMESTAMP | NULL | Last successful synchronization |

**Business Rules**:
- Username must be unique across all users
- Password must be hashed using PBKDF2-SHA256
- Email must contain '@' symbol
- Minimum password length: 8 characters

#### Entity 2: CATEGORY
**Purpose**: Defines expense and income categories for transaction classification

| Attribute | Type | Constraints | Description |
|-----------|------|-------------|-------------|
| category_id | INTEGER | PK, AUTO_INCREMENT | Unique category identifier |
| category_name | VARCHAR(50) | UNIQUE, NOT NULL | Category display name |
| category_type | ENUM | 'EXPENSE' or 'INCOME' | Transaction type classification |
| description | TEXT | NULL | Category description |
| is_active | BOOLEAN | DEFAULT TRUE | Active/inactive status |

**Predefined Categories** (13 total):
- **Expense**: Food & Dining, Transportation, Healthcare, Entertainment, Shopping, Utilities, Education, Housing, Personal Care, Savings, Other
- **Income**: Income (general), Other Income

#### Entity 3: EXPENSE
**Purpose**: Records all user expenses with detailed transaction information

| Attribute | Type | Constraints | Description |
|-----------|------|-------------|-------------|
| expense_id | INTEGER | PK, AUTO_INCREMENT | Unique expense identifier |
| user_id | INTEGER | FK → USER, NOT NULL | Owner of the expense |
| category_id | INTEGER | FK → CATEGORY, NOT NULL | Expense category |
| amount | DECIMAL(10,2) | NOT NULL, CHECK > 0 | Transaction amount |
| expense_date | DATE | NOT NULL | Date of expense |
| description | TEXT | NULL | Optional transaction description |
| payment_method | ENUM | NOT NULL | Cash, Credit Card, Debit Card, Online, Bank Transfer |
| fiscal_year | INTEGER | CALCULATED | Year extracted from expense_date |
| fiscal_month | INTEGER | CALCULATED | Month extracted from expense_date |
| created_at | TIMESTAMP | NOT NULL, DEFAULT NOW() | Record creation time |
| modified_at | TIMESTAMP | NOT NULL, DEFAULT NOW() | Last modification time |
| is_synced | BOOLEAN | DEFAULT FALSE | Synchronization status |
| sync_timestamp | TIMESTAMP | NULL | Last sync time |

**Business Rules**:
- Amount must be positive (> 0)
- Fiscal year/month automatically calculated via triggers
- Sync status updated by synchronization module

#### Entity 4: INCOME
**Purpose**: Tracks all user income from various sources

| Attribute | Type | Constraints | Description |
|-----------|------|-------------|-------------|
| income_id | INTEGER | PK, AUTO_INCREMENT | Unique income identifier |
| user_id | INTEGER | FK → USER, NOT NULL | Owner of the income |
| income_source | ENUM | NOT NULL | Salary, Freelance, Investment, Gift, Business, Other |
| amount | DECIMAL(10,2) | NOT NULL, CHECK > 0 | Income amount |
| income_date | DATE | NOT NULL | Date of income received |
| description | TEXT | NULL | Optional description |
| fiscal_year | INTEGER | CALCULATED | Year from income_date |
| fiscal_month | INTEGER | CALCULATED | Month from income_date |
| created_at | TIMESTAMP | NOT NULL, DEFAULT NOW() | Record creation time |
| modified_at | TIMESTAMP | NOT NULL, DEFAULT NOW() | Last modification time |
| is_synced | BOOLEAN | DEFAULT FALSE | Synchronization status |
| sync_timestamp | TIMESTAMP | NULL | Last sync time |

#### Entity 5: BUDGET
**Purpose**: Defines spending limits for categories over specific periods

| Attribute | Type | Constraints | Description |
|-----------|------|-------------|-------------|
| budget_id | INTEGER | PK, AUTO_INCREMENT | Unique budget identifier |
| user_id | INTEGER | FK → USER, NOT NULL | Budget owner |
| category_id | INTEGER | FK → CATEGORY, NOT NULL | Category for budget |
| budget_amount | DECIMAL(10,2) | NOT NULL, CHECK > 0 | Budget limit |
| start_date | DATE | NOT NULL | Budget period start |
| end_date | DATE | NOT NULL, CHECK > start_date | Budget period end |
| created_at | TIMESTAMP | NOT NULL, DEFAULT NOW() | Record creation time |
| modified_at | TIMESTAMP | NOT NULL, DEFAULT NOW() | Last modification time |
| is_active | BOOLEAN | DEFAULT TRUE | Active/inactive status |
| is_synced | BOOLEAN | DEFAULT FALSE | Synchronization status |

**Business Rules**:
- End date must be after start date
- One active budget per category per overlapping period
- Budget amount must be positive

#### Entity 6: SAVINGS_GOAL
**Purpose**: Manages user savings goals with target amounts and deadlines

| Attribute | Type | Constraints | Description |
|-----------|------|-------------|-------------|
| goal_id | INTEGER | PK, AUTO_INCREMENT | Unique goal identifier |
| user_id | INTEGER | FK → USER, NOT NULL | Goal owner |
| goal_name | VARCHAR(100) | NOT NULL | Goal description |
| target_amount | DECIMAL(10,2) | NOT NULL, CHECK > 0 | Target savings amount |
| current_amount | DECIMAL(10,2) | DEFAULT 0, CHECK >= 0 | Current progress |
| start_date | DATE | NOT NULL | Goal start date |
| deadline | DATE | NOT NULL, CHECK > start_date | Goal deadline |
| priority | ENUM | NOT NULL | High, Medium, Low |
| status | ENUM | DEFAULT 'Active' | Active, Completed, Cancelled |
| created_at | TIMESTAMP | NOT NULL, DEFAULT NOW() | Record creation time |
| modified_at | TIMESTAMP | NOT NULL, DEFAULT NOW() | Last modification time |
| is_synced | BOOLEAN | DEFAULT FALSE | Synchronization status |

**Business Rules**:
- Current amount ≤ target amount
- Deadline must be after start date
- Status automatically updated to "Completed" when current ≥ target

#### Entity 7: SAVINGS_CONTRIBUTION
**Purpose**: Records individual contributions towards savings goals

| Attribute | Type | Constraints | Description |
|-----------|------|-------------|-------------|
| contribution_id | INTEGER | PK, AUTO_INCREMENT | Unique contribution ID |
| goal_id | INTEGER | FK → SAVINGS_GOAL, NOT NULL | Associated goal |
| contribution_amount | DECIMAL(10,2) | NOT NULL, CHECK > 0 | Contribution amount |
| contribution_date | DATE | NOT NULL | Date of contribution |
| description | TEXT | NULL | Optional notes |
| created_at | TIMESTAMP | NOT NULL, DEFAULT NOW() | Record creation time |

**Business Rules**:
- Contribution amount must be positive
- Trigger automatically updates goal's current_amount
- Deleting contribution reduces goal's current_amount

#### Entity 8: SYNC_LOG
**Purpose**: Tracks synchronization operations between SQLite and Oracle

| Attribute | Type | Constraints | Description |
|-----------|------|-------------|-------------|
| sync_log_id | INTEGER | PK, AUTO_INCREMENT | Unique sync log ID |
| user_id | INTEGER | FK → USER, NOT NULL | User being synced |
| sync_start_time | TIMESTAMP | NOT NULL | Sync operation start |
| sync_end_time | TIMESTAMP | NULL | Sync operation end |
| records_synced | INTEGER | DEFAULT 0 | Total records synchronized |
| sync_status | ENUM | NOT NULL | Success, Failed, Partial |
| error_message | TEXT | NULL | Error details if failed |
| sync_type | ENUM | NOT NULL | Manual, Automatic |

### 2.1.3 Relationship Mappings

| Relationship | From Entity | To Entity | Cardinality | Type | Description |
|--------------|-------------|-----------|-------------|------|-------------|
| R1 | USER | EXPENSE | 1:M | Identifying | One user can have many expenses |
| R2 | USER | INCOME | 1:M | Identifying | One user can have many income records |
| R3 | USER | BUDGET | 1:M | Identifying | One user can have many budgets |
| R4 | USER | SAVINGS_GOAL | 1:M | Identifying | One user can have many savings goals |
| R5 | USER | SYNC_LOG | 1:M | Identifying | One user can have many sync logs |
| R6 | CATEGORY | EXPENSE | 1:M | Non-identifying | One category can classify many expenses |
| R7 | CATEGORY | BUDGET | 1:M | Non-identifying | One category can have many budgets |
| R8 | SAVINGS_GOAL | SAVINGS_CONTRIBUTION | 1:M | Identifying | One goal can have many contributions |

**Referential Integrity Rules**:
- **CASCADE DELETE**: When a user is deleted, all their expenses, income, budgets, goals, and sync logs are deleted
- **RESTRICT DELETE**: Categories cannot be deleted if they have associated expenses or budgets
- **CASCADE UPDATE**: Primary key updates propagate to foreign keys (not commonly used)

### 2.1.4 Normalization

#### First Normal Form (1NF)
✅ **Achieved**: All attributes contain atomic values
- No repeating groups
- Each cell contains a single value
- Example: payment_method is a single value, not a comma-separated list

#### Second Normal Form (2NF)
✅ **Achieved**: All non-key attributes fully depend on the primary key
- No partial dependencies
- All tables have single-column primary keys (or composite keys where all parts are needed)
- Example: In EXPENSE table, amount depends on expense_id, not on part of it

#### Third Normal Form (3NF)
✅ **Achieved**: No transitive dependencies
- Non-key attributes don't depend on other non-key attributes
- **Example**: Category information separated into CATEGORY table instead of storing category_name in EXPENSE table
- **Benefit**: Category name can be updated once, affecting all expenses automatically

#### Boyce-Codd Normal Form (BCNF)
✅ **Achieved**: Every determinant is a candidate key
- All functional dependencies are on superkeys
- No anomalies from overlapping candidate keys
- **Example**: USER table has username and email as unique keys, both are candidate keys

**Normalization Benefits**:
1. **Data Integrity**: Eliminates update anomalies
2. **Storage Efficiency**: Reduces data redundancy
3. **Maintenance**: Easier to update category names, user info
4. **Consistency**: Single source of truth for shared data

### 2.1.5 Integrity Constraints

#### Domain Constraints
| Constraint | Description | Implementation |
|------------|-------------|----------------|
| Amount > 0 | All monetary amounts must be positive | CHECK (amount > 0) |
| Email format | Email must contain '@' | CHECK (email LIKE '%@%') |
| Date range | End date > Start date | CHECK (end_date > start_date) |
| Boolean values | 0 or 1 only | CHECK (is_active IN (0, 1)) |
| Goal progress | current_amount ≤ target_amount | CHECK (current_amount <= target_amount) |

#### Entity Integrity Constraints
- **Primary Keys**: NOT NULL, UNIQUE on all PK columns
- **Auto-increment**: Automatic ID generation for all entities
- **No nulls in required fields**: username, email, password_hash, amounts, dates

#### Referential Integrity Constraints
```sql
-- User-Expense relationship
FOREIGN KEY (user_id) REFERENCES user(user_id) 
    ON DELETE CASCADE

-- Category-Expense relationship  
FOREIGN KEY (category_id) REFERENCES category(category_id) 
    ON DELETE RESTRICT

-- Goal-Contribution relationship
FOREIGN KEY (goal_id) REFERENCES savings_goal(goal_id) 
    ON DELETE CASCADE
```

#### Business Logic Constraints
1. **Unique Constraints**:
   - USERNAME must be unique across all users
   - EMAIL must be unique across all users
   - CATEGORY_NAME must be unique

2. **Enumeration Constraints**:
   - payment_method ∈ {Cash, Credit Card, Debit Card, Online, Bank Transfer}
   - income_source ∈ {Salary, Freelance, Investment, Gift, Business, Other}
   - priority ∈ {High, Medium, Low}
   - status ∈ {Active, Completed, Cancelled}
   - category_type ∈ {EXPENSE, INCOME}
   - sync_status ∈ {Success, Failed, Partial}

3. **Temporal Constraints**:
   - Budget end_date > start_date
   - Goal deadline > start_date
   - modified_at ≥ created_at

---

## 2.2 Physical Design - SQLite

### 2.2.1 SQLite Configuration

```sql
-- Enable foreign key constraints (not enabled by default in SQLite)
PRAGMA foreign_keys = ON;

-- Set journal mode for better concurrency and crash recovery
PRAGMA journal_mode = WAL;  -- Write-Ahead Logging

-- Optimize for space efficiency
PRAGMA auto_vacuum = INCREMENTAL;

-- Cache size (10,000 pages × 4KB = 40MB cache)
PRAGMA cache_size = 10000;

-- Balance between safety and speed
PRAGMA synchronous = NORMAL;

-- Store temporary tables in memory for faster operations
PRAGMA temp_store = MEMORY;
```

**Configuration Benefits**:
- **WAL Mode**: 30% faster writes, readers don't block writers
- **Large Cache**: Reduces disk I/O by keeping hot data in memory
- **NORMAL Sync**: Good balance (vs FULL which is slower, vs OFF which risks corruption)
- **Memory Temp**: Temporary operations don't hit disk

### 2.2.2 Table Schemas

#### USER Table (SQLite)
```sql
CREATE TABLE user (
    user_id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    full_name TEXT NOT NULL,
    created_at TEXT NOT NULL DEFAULT (datetime('now', 'localtime')),
    last_sync TEXT,
    is_active INTEGER NOT NULL DEFAULT 1 CHECK (is_active IN (0, 1)),
    CONSTRAINT chk_email CHECK (email LIKE '%@%'),
    CONSTRAINT chk_username_length CHECK (length(username) >= 3)
);
```

**SQLite-Specific Features**:
- TEXT type for timestamps (ISO 8601 format: 'YYYY-MM-DD HH:MM:SS')
- INTEGER for booleans (0 = false, 1 = true)
- AUTOINCREMENT prevents ID reuse even after deletion

#### CATEGORY Table (SQLite)
```sql
CREATE TABLE category (
    category_id INTEGER PRIMARY KEY AUTOINCREMENT,
    category_name TEXT NOT NULL UNIQUE,
    category_type TEXT NOT NULL CHECK (category_type IN ('EXPENSE', 'INCOME')),
    description TEXT,
    is_active INTEGER NOT NULL DEFAULT 1 CHECK (is_active IN (0, 1))
);

-- Prepopulate categories
INSERT INTO category (category_name, category_type, description) VALUES
('Food & Dining', 'EXPENSE', 'Meals, groceries, restaurants'),
('Transportation', 'EXPENSE', 'Fuel, public transport, vehicle maintenance'),
('Healthcare', 'EXPENSE', 'Medical bills, medicines, insurance'),
('Entertainment', 'EXPENSE', 'Movies, games, subscriptions'),
('Shopping', 'EXPENSE', 'Clothing, electronics, general purchases'),
('Utilities', 'EXPENSE', 'Electricity, water, internet, phone'),
('Education', 'EXPENSE', 'Tuition, books, courses'),
('Housing', 'EXPENSE', 'Rent, mortgage, property taxes'),
('Personal Care', 'EXPENSE', 'Grooming, fitness, wellness'),
('Savings', 'EXPENSE', 'Transfers to savings accounts'),
('Other', 'EXPENSE', 'Miscellaneous expenses'),
('Income', 'INCOME', 'General income'),
('Other Income', 'INCOME', 'Miscellaneous income');
```

#### EXPENSE Table (SQLite)
```sql
CREATE TABLE expense (
    expense_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    category_id INTEGER NOT NULL,
    amount REAL NOT NULL CHECK (amount > 0),
    expense_date TEXT NOT NULL,
    description TEXT,
    payment_method TEXT NOT NULL CHECK (payment_method IN 
        ('Cash', 'Credit Card', 'Debit Card', 'Online', 'Bank Transfer')),
    fiscal_year INTEGER,
    fiscal_month INTEGER,
    created_at TEXT NOT NULL DEFAULT (datetime('now', 'localtime')),
    modified_at TEXT NOT NULL DEFAULT (datetime('now', 'localtime')),
    is_synced INTEGER NOT NULL DEFAULT 0 CHECK (is_synced IN (0, 1)),
    sync_timestamp TEXT,
    FOREIGN KEY (user_id) REFERENCES user(user_id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES category(category_id) ON DELETE RESTRICT,
    CONSTRAINT chk_fiscal_year CHECK (fiscal_year >= 2000 AND fiscal_year <= 2100),
    CONSTRAINT chk_fiscal_month CHECK (fiscal_month >= 1 AND fiscal_month <= 12)
);
```

**Key Design Decisions**:
- **REAL for amounts**: Handles decimal currency values
- **TEXT for dates**: SQLite stores dates as strings, uses date functions for manipulation
- **fiscal_year/month**: Enables fast queries without date parsing
- **is_synced flag**: Tracks which records need synchronization

#### INCOME Table (SQLite)
```sql
CREATE TABLE income (
    income_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    income_source TEXT NOT NULL CHECK (income_source IN 
        ('Salary', 'Freelance', 'Investment', 'Gift', 'Business', 'Other')),
    amount REAL NOT NULL CHECK (amount > 0),
    income_date TEXT NOT NULL,
    description TEXT,
    fiscal_year INTEGER,
    fiscal_month INTEGER,
    created_at TEXT NOT NULL DEFAULT (datetime('now', 'localtime')),
    modified_at TEXT NOT NULL DEFAULT (datetime('now', 'localtime')),
    is_synced INTEGER NOT NULL DEFAULT 0 CHECK (is_synced IN (0, 1)),
    sync_timestamp TEXT,
    FOREIGN KEY (user_id) REFERENCES user(user_id) ON DELETE CASCADE
);
```

#### BUDGET Table (SQLite)
```sql
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
    CONSTRAINT chk_date_range CHECK (date(end_date) > date(start_date))
);
```

#### SAVINGS_GOAL Table (SQLite)
```sql
CREATE TABLE savings_goal (
    goal_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    goal_name TEXT NOT NULL,
    target_amount REAL NOT NULL CHECK (target_amount > 0),
    current_amount REAL NOT NULL DEFAULT 0 CHECK (current_amount >= 0),
    start_date TEXT NOT NULL,
    deadline TEXT NOT NULL,
    priority TEXT NOT NULL CHECK (priority IN ('High', 'Medium', 'Low')),
    status TEXT NOT NULL DEFAULT 'Active' CHECK (status IN 
        ('Active', 'Completed', 'Cancelled')),
    created_at TEXT NOT NULL DEFAULT (datetime('now', 'localtime')),
    modified_at TEXT NOT NULL DEFAULT (datetime('now', 'localtime')),
    is_synced INTEGER NOT NULL DEFAULT 0 CHECK (is_synced IN (0, 1)),
    FOREIGN KEY (user_id) REFERENCES user(user_id) ON DELETE CASCADE,
    CONSTRAINT chk_goal_amount CHECK (current_amount <= target_amount),
    CONSTRAINT chk_goal_deadline CHECK (date(deadline) > date(start_date))
);
```

#### SAVINGS_CONTRIBUTION Table (SQLite)
```sql
CREATE TABLE savings_contribution (
    contribution_id INTEGER PRIMARY KEY AUTOINCREMENT,
    goal_id INTEGER NOT NULL,
    contribution_amount REAL NOT NULL CHECK (contribution_amount > 0),
    contribution_date TEXT NOT NULL,
    description TEXT,
    created_at TEXT NOT NULL DEFAULT (datetime('now', 'localtime')),
    FOREIGN KEY (goal_id) REFERENCES savings_goal(goal_id) ON DELETE CASCADE
);
```

#### SYNC_LOG Table (SQLite)
```sql
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
```

### 2.2.3 Storage Characteristics

| Table | Avg Row Size | Rows (Test Data) | Storage | Growth Rate |
|-------|--------------|------------------|---------|-------------|
| user | 150 bytes | 5 | 750 bytes | Low (fixed users) |
| category | 80 bytes | 13 | 1 KB | None (predefined) |
| expense | 200 bytes | 1,350 | 270 KB | High (daily growth) |
| income | 180 bytes | 90 | 16 KB | Medium (monthly) |
| budget | 150 bytes | 25 | 3.75 KB | Low (periodic) |
| savings_goal | 180 bytes | 15 | 2.7 KB | Low |
| savings_contribution | 120 bytes | 45 | 5.4 KB | Medium |
| sync_log | 160 bytes | 50 | 8 KB | Medium (per sync) |
| **Total** | - | **1,593** | **~308 KB** | - |

**With Indexes**: ~5 MB total (indexes are ~15× data size for this workload)

---

## 2.3 Physical Design - Oracle

### 2.3.1 Oracle-Specific Features

#### Sequences (Auto-increment replacement)
```sql
-- Oracle uses sequences instead of AUTOINCREMENT
CREATE SEQUENCE seq_user_id START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_category_id START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_expense_id START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_income_id START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_budget_id START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_goal_id START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_contribution_id START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_sync_log_id START WITH 1 INCREMENT BY 1 NOCACHE;
```

#### Tablespace Organization
```sql
-- Separate tablespaces for data and indexes (performance optimization)
CREATE TABLESPACE finance_data
    DATAFILE 'finance_data01.dbf' SIZE 100M
    AUTOEXTEND ON NEXT 10M MAXSIZE 500M
    EXTENT MANAGEMENT LOCAL AUTOALLOCATE
    SEGMENT SPACE MANAGEMENT AUTO;

CREATE TABLESPACE finance_indexes
    DATAFILE 'finance_indexes01.dbf' SIZE 50M
    AUTOEXTEND ON NEXT 5M MAXSIZE 200M
    EXTENT MANAGEMENT LOCAL AUTOALLOCATE;
```

### 2.3.2 Schema Differences from SQLite

| Feature | SQLite | Oracle | Notes |
|---------|--------|--------|-------|
| **Auto-increment** | AUTOINCREMENT | SEQUENCE + TRIGGER | Oracle requires separate objects |
| **Boolean** | INTEGER (0/1) | NUMBER(1) or CHAR(1) | Oracle has no native BOOLEAN type |
| **Date/Time** | TEXT | DATE or TIMESTAMP | Oracle has native date types |
| **String** | TEXT | VARCHAR2 | Oracle uses VARCHAR2 (variable length) |
| **Decimal** | REAL | NUMBER(10,2) | Oracle NUMBER is more precise |
| **Default NOW()** | datetime('now') | SYSDATE or SYSTIMESTAMP | Different function names |
| **Check Constraints** | Supported | Supported | Same functionality |

### 2.3.3 Oracle Table Definitions

#### USER Table (Oracle)
```sql
CREATE TABLE finance_user (
    user_id NUMBER(10) PRIMARY KEY,
    username VARCHAR2(50) NOT NULL UNIQUE,
    password_hash VARCHAR2(255) NOT NULL,
    email VARCHAR2(100) NOT NULL UNIQUE,
    full_name VARCHAR2(100) NOT NULL,
    created_at TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
    last_sync TIMESTAMP,
    is_active NUMBER(1) DEFAULT 1 NOT NULL CHECK (is_active IN (0, 1)),
    CONSTRAINT chk_user_email CHECK (INSTR(email, '@') > 0),
    CONSTRAINT chk_user_username_length CHECK (LENGTH(username) >= 3)
) TABLESPACE finance_data;

-- Trigger for auto-increment
CREATE OR REPLACE TRIGGER trg_user_id
BEFORE INSERT ON finance_user
FOR EACH ROW
BEGIN
    IF :NEW.user_id IS NULL THEN
        SELECT seq_user_id.NEXTVAL INTO :NEW.user_id FROM DUAL;
    END IF;
END;
/
```

#### EXPENSE Table (Oracle)
```sql
CREATE TABLE finance_expense (
    expense_id NUMBER(10) PRIMARY KEY,
    user_id NUMBER(10) NOT NULL,
    category_id NUMBER(10) NOT NULL,
    amount NUMBER(10,2) NOT NULL CHECK (amount > 0),
    expense_date DATE NOT NULL,
    description VARCHAR2(500),
    payment_method VARCHAR2(20) NOT NULL CHECK (payment_method IN 
        ('Cash', 'Credit Card', 'Debit Card', 'Online', 'Bank Transfer')),
    fiscal_year NUMBER(4),
    fiscal_month NUMBER(2),
    created_at TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
    modified_at TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
    is_synced NUMBER(1) DEFAULT 0 NOT NULL CHECK (is_synced IN (0, 1)),
    sync_timestamp TIMESTAMP,
    CONSTRAINT fk_expense_user FOREIGN KEY (user_id) 
        REFERENCES finance_user(user_id) ON DELETE CASCADE,
    CONSTRAINT fk_expense_category FOREIGN KEY (category_id) 
        REFERENCES finance_category(category_id),
    CONSTRAINT chk_expense_fiscal_year CHECK (fiscal_year BETWEEN 2000 AND 2100),
    CONSTRAINT chk_expense_fiscal_month CHECK (fiscal_month BETWEEN 1 AND 12)
) TABLESPACE finance_data;

-- Auto-increment trigger
CREATE OR REPLACE TRIGGER trg_expense_id
BEFORE INSERT ON finance_expense
FOR EACH ROW
BEGIN
    IF :NEW.expense_id IS NULL THEN
        SELECT seq_expense_id.NEXTVAL INTO :NEW.expense_id FROM DUAL;
    END IF;
    -- Auto-calculate fiscal period
    :NEW.fiscal_year := EXTRACT(YEAR FROM :NEW.expense_date);
    :NEW.fiscal_month := EXTRACT(MONTH FROM :NEW.expense_date);
END;
/
```

#### Complete Oracle Schema Size
```sql
-- Query to check actual sizes in Oracle
SELECT 
    segment_name,
    segment_type,
    tablespace_name,
    ROUND(bytes/1024/1024, 2) AS size_mb
FROM user_segments
WHERE segment_name LIKE 'FINANCE%'
ORDER BY bytes DESC;
```

**Expected Oracle Storage** (with test data):
- Tables (data): ~2 MB
- Indexes: ~3 MB  
- PL/SQL Code: ~500 KB
- **Total**: ~5.5 MB

### 2.3.4 Oracle Indexes

```sql
-- Primary key indexes (automatically created)
-- Explicit indexes for foreign keys and queries
CREATE INDEX idx_expense_user ON finance_expense(user_id) 
    TABLESPACE finance_indexes;
CREATE INDEX idx_expense_category ON finance_expense(category_id) 
    TABLESPACE finance_indexes;
CREATE INDEX idx_expense_date ON finance_expense(expense_date) 
    TABLESPACE finance_indexes;
CREATE INDEX idx_expense_fiscal ON finance_expense(user_id, fiscal_year, fiscal_month) 
    TABLESPACE finance_indexes;

-- Composite index for common queries
CREATE INDEX idx_expense_user_date_category 
    ON finance_expense(user_id, expense_date, category_id)
    TABLESPACE finance_indexes;
```

---

**Summary**: The database design follows industry best practices with proper normalization (3NF/BCNF), comprehensive integrity constraints, and optimized physical implementations for both SQLite and Oracle. The dual-database architecture provides offline capability (SQLite) with enterprise features (Oracle PL/SQL).
