# Logical Database Design - Personal Finance Management System

## 1. Entity-Relationship Model

### 1.1 Entities and Attributes

#### Entity: USER
- **user_id** (PK): Unique identifier for the user
- username: User's login name
- email: User's email address
- full_name: User's full name
- created_at: Account creation timestamp
- last_sync: Last synchronization timestamp

#### Entity: CATEGORY
- **category_id** (PK): Unique identifier for the category
- category_name: Name of the category (Food, Transport, etc.)
- category_type: Type (EXPENSE or INCOME)
- description: Description of the category
- is_active: Whether the category is currently active

#### Entity: EXPENSE
- **expense_id** (PK): Unique identifier for the expense
- user_id (FK): Reference to USER
- category_id (FK): Reference to CATEGORY
- amount: Expense amount
- expense_date: Date of the expense
- description: Details about the expense
- payment_method: How payment was made (Cash, Card, Online, etc.)
- created_at: Record creation timestamp
- modified_at: Last modification timestamp
- is_synced: Synchronization status flag
- sync_timestamp: Last sync time

#### Entity: INCOME
- **income_id** (PK): Unique identifier for the income
- user_id (FK): Reference to USER
- income_source: Source of income (Salary, Freelance, etc.)
- amount: Income amount
- income_date: Date of the income
- description: Details about the income
- created_at: Record creation timestamp
- modified_at: Last modification timestamp
- is_synced: Synchronization status flag
- sync_timestamp: Last sync time

#### Entity: BUDGET
- **budget_id** (PK): Unique identifier for the budget
- user_id (FK): Reference to USER
- category_id (FK): Reference to CATEGORY
- budget_amount: Budgeted amount
- start_date: Budget period start date
- end_date: Budget period end date
- created_at: Record creation timestamp
- modified_at: Last modification timestamp
- is_active: Whether the budget is currently active
- is_synced: Synchronization status flag

#### Entity: SAVINGS_GOAL
- **goal_id** (PK): Unique identifier for the savings goal
- user_id (FK): Reference to USER
- goal_name: Name of the savings goal
- target_amount: Target amount to save
- current_amount: Current saved amount
- start_date: When the goal was created
- deadline: Target completion date
- priority: Priority level (High, Medium, Low)
- status: Goal status (Active, Completed, Cancelled)
- created_at: Record creation timestamp
- modified_at: Last modification timestamp
- is_synced: Synchronization status flag

#### Entity: SAVINGS_CONTRIBUTION
- **contribution_id** (PK): Unique identifier for the contribution
- goal_id (FK): Reference to SAVINGS_GOAL
- contribution_amount: Amount contributed
- contribution_date: Date of contribution
- description: Notes about the contribution
- created_at: Record creation timestamp

#### Entity: SYNC_LOG
- **sync_log_id** (PK): Unique identifier for the sync log
- user_id (FK): Reference to USER
- sync_start_time: When sync started
- sync_end_time: When sync completed
- records_synced: Number of records synchronized
- sync_status: Status (Success, Failed, Partial)
- error_message: Error details if sync failed
- sync_type: Type of sync (Manual, Automatic)

## 2. Entity Relationships

### 2.1 Relationship Diagram (Text Format)

```
┌─────────────┐
│    USER     │
└──────┬──────┘
       │
       │ 1
       │
       ├──────────────────┬──────────────────┬──────────────────┬──────────────────┐
       │                  │                  │                  │                  │
       │ *                │ *                │ *                │ *                │ *
       │                  │                  │                  │                  │
┌──────▼──────┐    ┌──────▼──────┐    ┌──────▼──────┐    ┌──────▼──────┐    ┌──────▼──────┐
│   EXPENSE   │    │   INCOME    │    │   BUDGET    │    │SAVINGS_GOAL │    │  SYNC_LOG   │
└──────┬──────┘    └─────────────┘    └──────┬──────┘    └──────┬──────┘    └─────────────┘
       │                                      │                  │
       │ *                                    │ *                │ 1
       │                                      │                  │
       │                                      │                  │ *
       │                                      │                  │
       │           ┌──────────────────────────┴──────────────────┤
       │           │                                             │
       │ 1         │ 1                                           │
       │           │                                             │
┌──────▼───────────▼──┐                                 ┌────────▼────────────┐
│     CATEGORY        │                                 │SAVINGS_CONTRIBUTION │
└─────────────────────┘                                 └─────────────────────┘
```

### 2.2 Relationship Descriptions

**USER to EXPENSE (1:N)**
- One user can have many expenses
- Each expense belongs to one user
- Relationship: "incurs"

**USER to INCOME (1:N)**
- One user can have many income records
- Each income record belongs to one user
- Relationship: "receives"

**USER to BUDGET (1:N)**
- One user can create many budgets
- Each budget belongs to one user
- Relationship: "creates"

**USER to SAVINGS_GOAL (1:N)**
- One user can have many savings goals
- Each savings goal belongs to one user
- Relationship: "sets"

**USER to SYNC_LOG (1:N)**
- One user can have many sync logs
- Each sync log belongs to one user
- Relationship: "performs"

**CATEGORY to EXPENSE (1:N)**
- One category can have many expenses
- Each expense belongs to one category
- Relationship: "categorizes"

**CATEGORY to BUDGET (1:N)**
- One category can have many budgets
- Each budget is for one category
- Relationship: "applies_to"

**SAVINGS_GOAL to SAVINGS_CONTRIBUTION (1:N)**
- One savings goal can have many contributions
- Each contribution belongs to one savings goal
- Relationship: "receives"

## 3. Cardinality and Participation

| Relationship | Entity 1 | Cardinality | Participation | Entity 2 | Cardinality | Participation |
|--------------|----------|-------------|---------------|----------|-------------|---------------|
| incurs | USER | 1 | Total | EXPENSE | N | Partial |
| receives | USER | 1 | Total | INCOME | N | Partial |
| creates | USER | 1 | Total | BUDGET | N | Partial |
| sets | USER | 1 | Total | SAVINGS_GOAL | N | Partial |
| performs | USER | 1 | Total | SYNC_LOG | N | Partial |
| categorizes | CATEGORY | 1 | Total | EXPENSE | N | Partial |
| applies_to | CATEGORY | 1 | Total | BUDGET | N | Partial |
| receives | SAVINGS_GOAL | 1 | Total | SAVINGS_CONTRIBUTION | N | Partial |

## 4. Business Rules

### 4.1 Data Integrity Rules
1. Every expense must belong to a valid user
2. Every expense must have a valid category
3. Expense amounts must be positive (> 0)
4. Income amounts must be positive (> 0)
5. Budget amounts must be positive (> 0)
6. Budget end_date must be after start_date
7. Savings goal target_amount must be greater than 0
8. Savings goal current_amount cannot exceed target_amount
9. Contribution amounts must be positive
10. Category names must be unique within their type (EXPENSE/INCOME)

### 4.2 Synchronization Rules
1. Records are synced only when is_synced = FALSE
2. Last modified timestamp determines conflict resolution
3. Sync logs must be created for every synchronization attempt
4. Failed syncs must not mark records as synced
5. Partial syncs are allowed but must be logged

### 4.3 Budget Rules
1. Only one active budget per category per user at a time
2. Budget periods cannot overlap for the same category
3. Budget adherence is calculated as: (actual_spent / budget_amount) * 100

### 4.4 Savings Goal Rules
1. Goal status changes to "Completed" when current_amount >= target_amount
2. Multiple goals can be active simultaneously
3. Contributions are tracked separately but update goal current_amount
4. Goals cannot be deleted if they have contributions (must be cancelled)

## 5. Normalization Analysis

### 5.1 Normal Forms Assessment

**First Normal Form (1NF):** ✓
- All tables have atomic values
- Each column contains values of a single type
- Each column has a unique name
- No repeating groups

**Second Normal Form (2NF):** ✓
- All tables are in 1NF
- All non-key attributes are fully dependent on the primary key
- No partial dependencies exist

**Third Normal Form (3NF):** ✓
- All tables are in 2NF
- No transitive dependencies exist
- All non-key attributes are directly dependent on the primary key only

**Boyce-Codd Normal Form (BCNF):** ✓
- All tables are in 3NF
- Every determinant is a candidate key
- No anomalies identified

### 5.2 Denormalization Considerations

For Oracle Database (Analytics), we may create denormalized views:
- **EXPENSE_SUMMARY_VIEW**: Pre-joined expense data with category and user info
- **BUDGET_PERFORMANCE_VIEW**: Budget vs actual spending comparison
- **SAVINGS_PROGRESS_VIEW**: Savings goals with contribution totals

## 6. Data Dictionary

### 6.1 Data Types and Constraints

| Entity | Attribute | Data Type | Size | Constraints |
|--------|-----------|-----------|------|-------------|
| USER | user_id | INTEGER | - | PK, AUTO_INCREMENT |
| USER | username | VARCHAR | 50 | NOT NULL, UNIQUE |
| USER | email | VARCHAR | 100 | NOT NULL, UNIQUE |
| USER | full_name | VARCHAR | 100 | NOT NULL |
| USER | created_at | TIMESTAMP | - | NOT NULL, DEFAULT CURRENT_TIMESTAMP |
| USER | last_sync | TIMESTAMP | - | NULL |
| CATEGORY | category_id | INTEGER | - | PK, AUTO_INCREMENT |
| CATEGORY | category_name | VARCHAR | 50 | NOT NULL, UNIQUE |
| CATEGORY | category_type | VARCHAR | 10 | NOT NULL, CHECK (IN 'EXPENSE','INCOME') |
| CATEGORY | description | TEXT | - | NULL |
| CATEGORY | is_active | BOOLEAN | - | NOT NULL, DEFAULT TRUE |
| EXPENSE | expense_id | INTEGER | - | PK, AUTO_INCREMENT |
| EXPENSE | user_id | INTEGER | - | FK, NOT NULL |
| EXPENSE | category_id | INTEGER | - | FK, NOT NULL |
| EXPENSE | amount | DECIMAL | 10,2 | NOT NULL, CHECK (> 0) |
| EXPENSE | expense_date | DATE | - | NOT NULL |
| EXPENSE | description | TEXT | - | NULL |
| EXPENSE | payment_method | VARCHAR | 20 | NOT NULL |
| EXPENSE | created_at | TIMESTAMP | - | NOT NULL, DEFAULT CURRENT_TIMESTAMP |
| EXPENSE | modified_at | TIMESTAMP | - | NOT NULL, DEFAULT CURRENT_TIMESTAMP |
| EXPENSE | is_synced | BOOLEAN | - | NOT NULL, DEFAULT FALSE |
| EXPENSE | sync_timestamp | TIMESTAMP | - | NULL |
| INCOME | income_id | INTEGER | - | PK, AUTO_INCREMENT |
| INCOME | user_id | INTEGER | - | FK, NOT NULL |
| INCOME | income_source | VARCHAR | 50 | NOT NULL |
| INCOME | amount | DECIMAL | 10,2 | NOT NULL, CHECK (> 0) |
| INCOME | income_date | DATE | - | NOT NULL |
| INCOME | description | TEXT | - | NULL |
| INCOME | created_at | TIMESTAMP | - | NOT NULL, DEFAULT CURRENT_TIMESTAMP |
| INCOME | modified_at | TIMESTAMP | - | NOT NULL, DEFAULT CURRENT_TIMESTAMP |
| INCOME | is_synced | BOOLEAN | - | NOT NULL, DEFAULT FALSE |
| INCOME | sync_timestamp | TIMESTAMP | - | NULL |
| BUDGET | budget_id | INTEGER | - | PK, AUTO_INCREMENT |
| BUDGET | user_id | INTEGER | - | FK, NOT NULL |
| BUDGET | category_id | INTEGER | - | FK, NOT NULL |
| BUDGET | budget_amount | DECIMAL | 10,2 | NOT NULL, CHECK (> 0) |
| BUDGET | start_date | DATE | - | NOT NULL |
| BUDGET | end_date | DATE | - | NOT NULL, CHECK (> start_date) |
| BUDGET | created_at | TIMESTAMP | - | NOT NULL, DEFAULT CURRENT_TIMESTAMP |
| BUDGET | modified_at | TIMESTAMP | - | NOT NULL, DEFAULT CURRENT_TIMESTAMP |
| BUDGET | is_active | BOOLEAN | - | NOT NULL, DEFAULT TRUE |
| BUDGET | is_synced | BOOLEAN | - | NOT NULL, DEFAULT FALSE |
| SAVINGS_GOAL | goal_id | INTEGER | - | PK, AUTO_INCREMENT |
| SAVINGS_GOAL | user_id | INTEGER | - | FK, NOT NULL |
| SAVINGS_GOAL | goal_name | VARCHAR | 100 | NOT NULL |
| SAVINGS_GOAL | target_amount | DECIMAL | 10,2 | NOT NULL, CHECK (> 0) |
| SAVINGS_GOAL | current_amount | DECIMAL | 10,2 | NOT NULL, DEFAULT 0, CHECK (>= 0) |
| SAVINGS_GOAL | start_date | DATE | - | NOT NULL |
| SAVINGS_GOAL | deadline | DATE | - | NOT NULL |
| SAVINGS_GOAL | priority | VARCHAR | 10 | NOT NULL, CHECK (IN 'High','Medium','Low') |
| SAVINGS_GOAL | status | VARCHAR | 20 | NOT NULL, DEFAULT 'Active' |
| SAVINGS_GOAL | created_at | TIMESTAMP | - | NOT NULL, DEFAULT CURRENT_TIMESTAMP |
| SAVINGS_GOAL | modified_at | TIMESTAMP | - | NOT NULL, DEFAULT CURRENT_TIMESTAMP |
| SAVINGS_GOAL | is_synced | BOOLEAN | - | NOT NULL, DEFAULT FALSE |
| SAVINGS_CONTRIBUTION | contribution_id | INTEGER | - | PK, AUTO_INCREMENT |
| SAVINGS_CONTRIBUTION | goal_id | INTEGER | - | FK, NOT NULL |
| SAVINGS_CONTRIBUTION | contribution_amount | DECIMAL | 10,2 | NOT NULL, CHECK (> 0) |
| SAVINGS_CONTRIBUTION | contribution_date | DATE | - | NOT NULL |
| SAVINGS_CONTRIBUTION | description | TEXT | - | NULL |
| SAVINGS_CONTRIBUTION | created_at | TIMESTAMP | - | NOT NULL, DEFAULT CURRENT_TIMESTAMP |
| SYNC_LOG | sync_log_id | INTEGER | - | PK, AUTO_INCREMENT |
| SYNC_LOG | user_id | INTEGER | - | FK, NOT NULL |
| SYNC_LOG | sync_start_time | TIMESTAMP | - | NOT NULL |
| SYNC_LOG | sync_end_time | TIMESTAMP | - | NULL |
| SYNC_LOG | records_synced | INTEGER | - | NOT NULL, DEFAULT 0 |
| SYNC_LOG | sync_status | VARCHAR | 20 | NOT NULL |
| SYNC_LOG | error_message | TEXT | - | NULL |
| SYNC_LOG | sync_type | VARCHAR | 20 | NOT NULL |

## 7. Logical Design Summary

This logical design provides:
1. **Clear entity definitions** with all necessary attributes
2. **Proper relationships** between entities with correct cardinality
3. **Comprehensive constraints** ensuring data integrity
4. **Normalization to 3NF/BCNF** eliminating data anomalies
5. **Support for all functional requirements** identified in requirements analysis
6. **Flexibility for synchronization** between SQLite and Oracle
7. **Audit trail capabilities** through timestamps and sync logs
8. **Scalability** for future enhancements

This design will be implemented in both SQLite and Oracle databases with appropriate adaptations for each platform's capabilities.
