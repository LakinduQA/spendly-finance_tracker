# Viva Questions and Answers

**Personal Finance Management System**  
**Data Management 2 Coursework**

---

## Table of Contents

- [Database Design & Architecture](#database-design--architecture)
- [Synchronization & Conflict Resolution](#synchronization--conflict-resolution)
- [Security & Authentication](#security--authentication)
- [PL/SQL & Oracle Implementation](#plsql--oracle-implementation)
- [Performance & Optimization](#performance--optimization)
- [Testing & Quality Assurance](#testing--quality-assurance)
- [Backup & Recovery](#backup--recovery)
- [Technical Challenges](#technical-challenges)
- [Web Application & UI](#web-application--ui)
- [Future Enhancements](#future-enhancements)

---

## Database Design & Architecture

### Q1: Why did you choose dual-database architecture?

**📌 Point-wise Answer:**
- SQLite advantages: Fast local operations, offline capability, zero configuration, lightweight
- Oracle advantages: Advanced PL/SQL, complex reporting, enterprise features, scalability
- Combined benefits: Local performance + cloud analytics
- Use case: Desktop/mobile offline work, server-side advanced reporting

**🗣️ Script Answer:**

"I chose a dual-database architecture to leverage the strengths of both systems. SQLite provides fast local operations, offline capability, and zero configuration - perfect for a desktop/mobile app. Oracle provides advanced PL/SQL capabilities, complex reporting, and enterprise-grade features. By using both, users get the best of both worlds - local performance and cloud analytics. Users can work offline with SQLite and sync to Oracle when they have internet connectivity for advanced reports and backup."

---

### Q2: What normalization form did you use and why?

**📌 Point-wise Answer:**
- Normalized to BCNF (Boyce-Codd Normal Form)
- Eliminates all redundancy
- Every determinant is a candidate key
- Example: Categories separated into own table
- Benefits: Data consistency, prevents anomalies
- Update/Insert/Delete anomalies eliminated

**🗣️ Script Answer:**

"I normalized the database to BCNF - Boyce-Codd Normal Form. This eliminates all redundancy and ensures that every determinant is a candidate key. For example, I separated categories into their own table rather than storing category names redundantly in expense records. This ensures data consistency - if I change a category name, it updates everywhere automatically. BCNF also prevents update, insertion, and deletion anomalies. I can insert a new category without any expense records, update category information once, and delete categories cleanly."

---

### Q3: Explain your database schema and entity relationships.

**📌 Point-wise Answer:**
- 9 core tables: USER, CATEGORY, EXPENSE, INCOME, BUDGET, SAVINGS_GOAL, SAVINGS_CONTRIBUTION, SYNC_LOG
- 8 foreign key relationships
- USER is central entity (1:N with expenses, income, budgets, goals)
- CATEGORY links to expenses, income, budgets (1:N)
- SAVINGS_GOAL links to SAVINGS_CONTRIBUTION (1:N)
- All relationships maintain referential integrity with CASCADE deletes
- Same structure in both SQLite and Oracle (with finance_ prefix)

**🗣️ Script Answer:**

"The database has 9 core tables organized around the USER entity. Each user can have multiple expenses, income records, budgets, and savings goals - all connected through foreign keys. The CATEGORY table provides a centralized list of expense and income categories, which I've prepopulated with 13 common categories. SAVINGS_GOAL has a one-to-many relationship with SAVINGS_CONTRIBUTION for tracking progress. The SYNC_LOG table tracks all synchronization operations for audit purposes. All relationships use CASCADE delete to maintain referential integrity - when a user is deleted, all their related data is automatically removed. This same schema exists identically in both SQLite and Oracle, with Oracle using the 'finance_' prefix for table names."

---

### Q4: Why did you separate SQLite and Oracle schemas?

**📌 Point-wise Answer:**
- Different use cases: Local operations vs cloud analytics
- Different performance characteristics
- SQLite: Embedded, no server, single file
- Oracle: Client-server, multi-user, advanced features
- Schema mapping handles differences in data types
- Synchronization bridges the gap

**🗣️ Script Answer:**

"I kept the schemas logically identical but physically separate because they serve different purposes. SQLite is embedded directly in the application - no server needed, just a single file. This makes it perfect for local, offline operations where speed is critical. Oracle, being a client-server system, is better suited for multi-user scenarios and advanced analytics. The schemas are conceptually the same, but I had to handle differences like SQLite's INTEGER vs Oracle's NUMBER, and SQLite's TEXT dates vs Oracle's DATE type. The synchronization module bridges these differences by converting data types appropriately during sync operations."

---

### Q5: How do you handle foreign key constraints during synchronization?

**📌 Point-wise Answer:**
- Sync entities in dependency order
- First: USER and CATEGORY (no dependencies)
- Second: EXPENSE, INCOME, BUDGET (depend on USER, CATEGORY)
- Third: SAVINGS_GOAL (depends on USER)
- Fourth: SAVINGS_CONTRIBUTION (depends on SAVINGS_GOAL)
- Ensures parent records exist before children
- Transaction management: ROLLBACK on any failure

**🗣️ Script Answer:**

"Foreign key constraints require careful ordering during synchronization. I sync entities in dependency order - first USER and CATEGORY tables since they have no dependencies, then EXPENSE, INCOME, and BUDGET which depend on both USER and CATEGORY, then SAVINGS_GOAL which depends on USER, and finally SAVINGS_CONTRIBUTION which depends on SAVINGS_GOAL. This ensures parent records always exist before child records are inserted. The entire sync operation runs in a transaction, so if anything fails, I rollback everything to maintain consistency. SQLite and Oracle both enforce foreign key constraints, so this ordering is critical."

---

## Synchronization & Conflict Resolution

### Q6: How does your synchronization handle conflicts?

**📌 Point-wise Answer:**
- Strategy: Last-modified-wins
- Each record has `modified_at` timestamp
- Triggers automatically update timestamp on changes
- Compare timestamps during sync
- Most recent modification wins
- `is_synced` flag tracks sync status (0=needs sync, 1=synced)
- All operations logged in sync_log table

**🗣️ Script Answer:**

"I use a last-modified-wins strategy. Each record has a `modified_at` timestamp that's automatically updated by triggers whenever the record changes. During sync, if the same record exists in both databases, I compare timestamps - the most recent modification wins. I also maintain an `is_synced` flag to track which records need syncing. When a record is created or modified, this flag is set to 0. After successful sync, it's set to 1. All sync operations are logged in the sync_log table with timestamps, record counts, and status for complete audit trails."

---

### Q7: What happens if synchronization fails midway?

**📌 Point-wise Answer:**
- Transaction management with ROLLBACK
- Each entity type synced in separate transaction
- Partial success is acceptable (some entities synced)
- Sync log records partial completion
- `is_synced` flag remains 0 for failed records
- Retry logic with exponential backoff
- Next sync attempt processes remaining records
- Error messages logged for debugging

**🗣️ Script Answer:**

"If synchronization fails midway, I use transaction management to maintain consistency. Each entity type is synced in its own transaction, so if expenses sync successfully but income fails, the expenses remain synced. The sync_log table records the partial completion with error messages. Records that didn't sync keep their `is_synced` flag at 0, so the next sync attempt will pick them up. I've also implemented retry logic with exponential backoff - if a sync fails due to network issues, it will automatically retry up to 3 times with increasing wait times (1s, 2s, 4s). All errors are comprehensively logged so I can debug what went wrong."

---

### Q8: How do you prevent duplicate records during sync?

**📌 Point-wise Answer:**
- Primary key checking before insert
- SELECT query to check existence
- If exists: UPDATE (conflict resolution)
- If not exists: INSERT
- SQLite: `SELECT expense_id FROM expense WHERE expense_id = ?`
- Oracle: `SELECT expense_id FROM finance_expense WHERE expense_id = :1`
- Auto-increment IDs prevent duplicates
- Unique constraints on username, email

**🗣️ Script Answer:**

"Before inserting any record during sync, I first check if it already exists by querying for its primary key. If the record exists, I perform an UPDATE (applying conflict resolution if needed). If it doesn't exist, I perform an INSERT. This prevents duplicate records. Since primary keys are auto-generated (SQLite AUTOINCREMENT and Oracle SEQUENCE), they're naturally unique. I also have UNIQUE constraints on sensitive fields like username and email. The sync logic explicitly handles the DUP_VAL_ON_INDEX exception in Oracle and UNIQUE constraint violations in SQLite, treating them as expected scenarios rather than errors."

---

### Q9: Explain your bidirectional synchronization process step-by-step.

**📌 Point-wise Answer:**
- **Step 1**: Connect to both SQLite and Oracle databases
- **Step 2**: Create sync_log entry with start timestamp
- **Step 3**: Sync USER table (both directions)
- **Step 4**: Sync CATEGORY table (both directions)
- **Step 5**: Sync EXPENSE table (check is_synced flag, resolve conflicts)
- **Step 6**: Sync INCOME table (same process)
- **Step 7**: Sync BUDGET table
- **Step 8**: Sync SAVINGS_GOAL table
- **Step 9**: Sync SAVINGS_CONTRIBUTION table
- **Step 10**: Update is_synced flags
- **Step 11**: Complete sync_log entry with end timestamp, count, status
- **Step 12**: Close connections

**🗣️ Script Answer:**

"The bidirectional sync process has 12 steps. First, I establish connections to both databases using Python's sqlite3 and cx_Oracle libraries. Second, I create a sync_log entry with the start timestamp and user ID. Then I sync each entity type in order: users, categories, expenses, income, budgets, goals, and contributions. For each entity, I check the is_synced flag - only unsynced records (is_synced=0) are processed. I handle conflicts using the last-modified-wins strategy. After syncing a record, I update its is_synced flag to 1. Finally, I complete the sync_log entry with the end timestamp, total records synced, and success/failure status. The entire process typically takes 0.20 seconds for 1,350+ records."

---

### Q10: What conflict resolution strategies did you consider and why did you choose last-modified-wins?

**📌 Point-wise Answer:**
- **Considered strategies**:
  - Last-modified-wins (chosen)
  - First-write-wins
  - Manual resolution
  - Version vectors
  - CRDTs (Conflict-free Replicated Data Types)
- **Reason for choice**:
  - Simple to implement
  - Appropriate for single-user scenario
  - Timestamp-based, no complex logic
  - Acceptable data loss risk (rare concurrent edits)
  - Good performance
- **Alternatives for multi-user**: Vector clocks, operational transforms

**🗣️ Script Answer:**

"I considered several conflict resolution strategies. Last-modified-wins is the simplest - just compare timestamps and keep the newest version. First-write-wins would keep the oldest version. Manual resolution would prompt users to choose, but that's poor UX. Version vectors or CRDTs would handle concurrent modifications better but add significant complexity. I chose last-modified-wins because it's appropriate for a personal finance app where typically one user manages their own data. Concurrent modifications on the same record are rare. The implementation is simple, performs well, and the risk of data loss is acceptable for this use case. For a multi-user scenario, I'd implement vector clocks or operational transforms instead."

---

### Q11: How do you handle network failures during synchronization?

**📌 Point-wise Answer:**
- Try-except blocks around database operations
- Catch connection errors (cx_Oracle.DatabaseError)
- Retry logic: 3 attempts with exponential backoff (1s, 2s, 4s)
- Graceful degradation: Continue with SQLite only
- User notification of sync failure
- Sync log records error message
- Queued changes persist until next successful sync
- Manual sync button allows user retry

**🗣️ Script Answer:**

"Network failures are handled through comprehensive exception handling. All database operations are wrapped in try-except blocks that catch connection errors. If a sync fails, I implement retry logic with exponential backoff - it will attempt 3 times with wait times of 1, 2, and 4 seconds. If all retries fail, the system gracefully degrades to SQLite-only mode. Users receive a notification about the sync failure. All changes remain queued (is_synced=0) until the next successful sync. The error details are logged in the sync_log table for debugging. Users can manually trigger a sync retry using the 'Sync Now' button in the web interface whenever they want."

---

## Security & Authentication

### Q12: How do you prevent SQL injection attacks?

**📌 Point-wise Answer:**
- Parameterized queries exclusively throughout codebase
- SQLite: Question mark placeholders `?`
- Oracle: Bind variables with colon notation `:1` or `:param`
- User input treated as data, never executable SQL
- Example: `cursor.execute("SELECT * FROM user WHERE username = ?", (username,))`
- Input validation at multiple layers
- Type checking, range checking, format validation
- No string concatenation in SQL queries

**🗣️ Script Answer:**

"I use parameterized queries exclusively throughout the codebase. In SQLite, I use question mark placeholders, and in Oracle, I use bind variables with colon notation. This ensures user input is always treated as data, never as executable SQL code. For example, instead of string concatenation like `query = f'SELECT * FROM user WHERE username = {username}'`, I write `cursor.execute('SELECT * FROM user WHERE username = ?', (username,))`. This makes SQL injection impossible. I also validate all inputs for type, range, and format before using them in queries. The database driver handles proper escaping automatically with parameterized queries."

---

### Q13: Why PBKDF2 for password hashing?

**📌 Point-wise Answer:**
- NIST-recommended key derivation function
- Specifically designed for password hashing
- Configuration: SHA-256 hash function, 600,000 iterations
- 16-byte random salt per password
- Computationally expensive (prevents brute-force)
- Salt prevents rainbow table attacks
- Werkzeug library implementation
- Format: `pbkdf2:sha256:600000$salt$hash`
- Never store plain text passwords

**🗣️ Script Answer:**

"PBKDF2 is a NIST-recommended key derivation function that's specifically designed for password hashing. I configured it with SHA-256 hash function and 600,000 iterations, which makes brute-force attacks computationally expensive. Each password gets a unique 16-byte random salt, preventing rainbow table attacks. The Werkzeug library I used implements PBKDF2 securely and handles salt generation automatically. The stored format is 'pbkdf2:sha256:600000$salt$hash', containing the algorithm, iterations, salt, and hash. Importantly, the actual password is never stored - only the hash. During login, I hash the input password and compare hashes."

---

### Q14: Explain your session management implementation.

**📌 Point-wise Answer:**
- Flask-Session library
- Configuration:
  - SECRET_KEY for encryption
  - SESSION_TYPE = 'filesystem'
  - SESSION_PERMANENT = False
  - SESSION_COOKIE_HTTPONLY = True (prevents JavaScript access)
  - SESSION_COOKIE_SECURE = True (HTTPS only in production)
  - SESSION_COOKIE_SAMESITE = 'Lax' (CSRF protection)
- 30-minute timeout after inactivity
- Session stores: user_id, username, last_activity
- @login_required decorator for protected routes
- session.clear() on logout

**🗣️ Script Answer:**

"I use Flask-Session for secure session management. Sessions are configured with multiple security layers. The SECRET_KEY encrypts session data. I set HTTPONLY flag so cookies cannot be accessed by JavaScript, preventing XSS attacks. The SECURE flag ensures cookies are only sent over HTTPS in production. SAMESITE=Lax prevents CSRF attacks. Sessions expire after 30 minutes of inactivity, which I track using a last_activity timestamp. The session stores user_id, username, and last_activity. I created a @login_required decorator that checks if user_id exists in the session before allowing access to protected routes. On logout, I call session.clear() to remove all session data."

---

### Q15: How do you protect against XSS (Cross-Site Scripting) attacks?

**📌 Point-wise Answer:**
- Jinja2 template auto-escaping (Flask default)
- User input sanitized before display
- HTML special characters escaped: `<`, `>`, `&`, `"`, `'`
- No eval() or direct HTML insertion
- Content-Security-Policy headers (production)
- HTTPONLY cookies prevent JavaScript access to session
- Input validation removes dangerous characters
- Flask's escape() function for manual escaping

**🗣️ Script Answer:**

"Flask's Jinja2 templating engine automatically escapes all user input by default, which prevents XSS attacks. When displaying user-generated content like expense descriptions, HTML special characters like '<', '>', '&', quotes are automatically converted to safe entities. I never use eval() or directly insert HTML. HTTPONLY cookies prevent JavaScript from accessing session data even if an XSS vulnerability existed. In production, I'd add Content-Security-Policy headers to further restrict what scripts can execute. For any manual HTML generation, I use Flask's escape() function. Input validation also removes potentially dangerous characters before they ever reach the database."

---

### Q16: What authorization checks do you implement?

**📌 Point-wise Answer:**
- User-based data filtering: All queries include user_id from session
- Example: `SELECT * FROM expense WHERE user_id = ?`
- Ownership verification before UPDATE/DELETE operations
- HTTP 403 Forbidden if user tries to access another user's data
- @login_required decorator for authentication
- Role-based access control (future enhancement)
- No direct database ID exposure in URLs
- Session validation on every request

**🗣️ Script Answer:**

"Every database query includes the user_id from the session, ensuring users can only see their own data. For example, when fetching expenses, I query 'SELECT * FROM expense WHERE user_id = ?' with the session user_id. Before UPDATE or DELETE operations, I verify ownership - I first fetch the record and check if its user_id matches the session user_id. If not, I return HTTP 403 Forbidden. The @login_required decorator ensures users are authenticated before accessing any protected route. I don't expose database IDs in URLs where possible. Session validation happens on every request through Flask's before_request hook. Future enhancements would include role-based access control for admin features."

---

## PL/SQL & Oracle Implementation

### Q17: How do your PL/SQL reports work?

**📌 Point-wise Answer:**
- Reports package: pkg_finance_reports (720 lines)
- 5 reports, each with 2 procedures:
  - generate_* : CSV export using UTL_FILE
  - display_* : Console output using DBMS_OUTPUT
- SQL features used:
  - Cursors for iteration
  - GROUP BY for aggregations
  - CASE statements for conditional logic
  - HAVING for filtered aggregates
  - Subqueries for complex calculations
- Parameter validation
- Exception handling (NO_DATA_FOUND, OTHERS)
- CSV files saved to DATA_PUMP_DIR

**🗣️ Script Answer:**

"I created a reports package with 5 procedures, each generating a different financial report. They use cursors to iterate through data, GROUP BY for aggregations, CASE statements for conditional logic, and DBMS_OUTPUT for formatted display. I also implemented CSV export using UTL_FILE. Each report validates parameters, handles exceptions properly, and returns meaningful error messages if something goes wrong. For example, the Monthly Expenditure report uses a cursor to loop through categories, calculates totals with SUM, and formats output with proper alignment. The generate_ versions write CSV files to Oracle's DATA_PUMP_DIR, while display_ versions output formatted text to the console."

---

### Q18: Explain the structure of your CRUD package.

**📌 Point-wise Answer:**
- Package: pkg_finance_crud (818 lines)
- 31 procedures/functions organized by entity:
  - USER: create, update, delete, get, get_all (5 ops)
  - EXPENSE: create, update, delete, get, get_user_expenses (5 ops)
  - INCOME: 5 operations
  - BUDGET: 5 operations
  - SAVINGS_GOAL: 5 operations
  - SAVINGS_CONTRIBUTION: 2 operations
  - SYNC_LOG: 2 operations
  - Utilities: 2 functions (monthly_summary, category_summary)
- Features:
  - SYS_REFCURSOR for dynamic result sets
  - RETURNING clause for generated IDs
  - NVL for optional parameters
  - RAISE_APPLICATION_ERROR for custom errors
  - Transaction management (COMMIT/ROLLBACK)

**🗣️ Script Answer:**

"The CRUD package contains 31 stored procedures and functions organized by entity type. Each entity has five core operations: create, read, update, delete, and list. For example, create_expense inserts a new expense and returns the generated expense_id using the RETURNING clause. Update_expense uses NVL to handle optional parameters - if a parameter is NULL, it keeps the existing value. Get_expense returns a SYS_REFCURSOR for flexible result handling. All procedures include proper error handling with RAISE_APPLICATION_ERROR for custom error messages and automatic ROLLBACK on exceptions. The package also includes utility functions like get_monthly_summary and get_category_summary for common calculations."

---

### Q19: Why did you use SYS_REFCURSOR instead of explicit cursors?

**📌 Point-wise Answer:**
- SYS_REFCURSOR = dynamic cursor variable
- Can be returned from functions to calling application
- Flexible: Result set determined at runtime
- Python can fetch rows from returned cursor
- Example: `cursor_var = function_call(); rows = cursor_var.fetchall()`
- More versatile than explicit cursors
- Client controls when to fetch data
- Memory efficient: Doesn't load all rows at once

**🗣️ Script Answer:**

"SYS_REFCURSOR is a dynamic cursor variable that can be returned from PL/SQL functions to the calling application. This is much more flexible than explicit cursors. The Python application can call a PL/SQL function, get back a SYS_REFCURSOR, and then fetch rows as needed using fetchone() or fetchall(). The result set is determined at runtime, so the same function can return different data based on parameters. It's also memory efficient because the client controls when to fetch data, avoiding loading all rows into memory at once. Explicit cursors are harder to pass between PL/SQL and external applications, making SYS_REFCURSOR the better choice for my architecture."

---

### Q20: How do you handle errors in PL/SQL procedures?

**📌 Point-wise Answer:**
- Exception handling in every procedure
- Specific exceptions:
  - DUP_VAL_ON_INDEX (duplicate primary/unique keys)
  - NO_DATA_FOUND (SELECT returned no rows)
  - TOO_MANY_ROWS (SELECT returned multiple rows)
- RAISE_APPLICATION_ERROR for custom errors
  - Error codes: -20001 to -20099
  - Meaningful error messages
- OTHERS exception for unexpected errors
- ROLLBACK on any exception
- SQLERRM for error message text
- Example: `RAISE_APPLICATION_ERROR(-20001, 'Username already exists')`

**🗣️ Script Answer:**

"Every PL/SQL procedure has comprehensive exception handling. I catch specific exceptions like DUP_VAL_ON_INDEX for duplicate keys, NO_DATA_FOUND when a record doesn't exist, and TOO_MANY_ROWS for unexpected multiple results. For business logic errors, I use RAISE_APPLICATION_ERROR with custom error codes (-20001 to -20099) and meaningful messages. The OTHERS exception catches any unexpected errors. On any exception, I execute ROLLBACK to undo changes and maintain data integrity. I use SQLERRM to capture the error message text for logging. For example, when creating a user with a duplicate username, I raise error -20001 with message 'Username already exists' instead of showing the cryptic Oracle error to users."

---

### Q21: Compare CRUD operations in SQLite vs PL/SQL. How do they differ?

**📌 Point-wise Answer:**
- **SQLite CRUD (Python direct SQL)**:
  - Direct SQL execution via cursor.execute()
  - Parameterized queries with ? placeholders
  - Example: `cursor.execute("INSERT INTO expense (...) VALUES (?,?,?)", (...))`
  - Returns lastrowid for auto-generated IDs
  - Simple, no stored procedures
  - Business logic in Python application layer
  
- **Oracle CRUD (PL/SQL procedures)**:
  - Encapsulated in pkg_finance_crud package
  - Stored procedures on database server
  - Example: `pkg_finance_crud.create_expense(:p_user_id, :p_amount, ...)`
  - Returns IDs via RETURNING clause with OUT parameters
  - Complex business logic in database layer
  - Reusable across applications
  
- **Key Differences**:
  - SQLite: Application-centric, procedural code
  - Oracle: Database-centric, declarative procedures
  - SQLite: Simpler, less network overhead
  - Oracle: More secure, centralized validation

**🗣️ Script Answer:**

"CRUD operations differ significantly between SQLite and Oracle in my implementation. For SQLite, I use direct SQL execution from Python with parameterized queries using question mark placeholders. For example, inserting an expense is a simple cursor.execute() call with tuple parameters. The lastrowid property gives me the auto-generated ID. Business logic stays in the Python application layer.

For Oracle, I encapsulated all CRUD operations in the pkg_finance_crud package - 31 stored procedures covering all entities. Instead of executing raw SQL, Python calls these procedures like functions. For example, pkg_finance_crud.create_expense() takes parameters and returns the generated ID through an OUT parameter using the RETURNING clause. Business logic validation happens in the database layer.

The key difference is architecture - SQLite is application-centric with simple procedural code, while Oracle is database-centric with declarative stored procedures. SQLite is simpler with less network overhead. Oracle provides better security, centralized validation, and reusability across multiple applications."

---

### Q22: Walk me through a complete CREATE operation in both databases.

**📌 Point-wise Answer:**
- **SQLite CREATE Expense**:
  1. Python receives form data
  2. Validate input (amount > 0, date format, etc.)
  3. Execute INSERT: `cursor.execute("INSERT INTO expense (user_id, ...) VALUES (?, ...)", (user_id, ...))`
  4. Triggers automatically fire:
     - trigger_expense_timestamps (sets created_at, modified_at)
     - trigger_expense_fiscal_period (calculates fiscal_year, fiscal_month)
     - trigger_expense_sync_flag (sets is_synced=0)
  5. Get ID: `expense_id = cursor.lastrowid`
  6. Commit: `conn.commit()`
  7. Return expense_id to application
  
- **Oracle CREATE Expense**:
  1. Python receives form data
  2. Prepare procedure call with bind variables
  3. Execute: `cursor.callproc('pkg_finance_crud.create_expense', [user_id, ..., expense_id_out])`
  4. Inside procedure:
     - Validate parameters (NVL for optional fields)
     - INSERT with RETURNING clause: `RETURNING expense_id INTO p_expense_id`
     - Exception handling (DUP_VAL_ON_INDEX, OTHERS)
     - Triggers fire automatically (timestamps, fiscal period)
     - COMMIT
  5. Fetch OUT parameter: `expense_id = expense_id_out.getvalue()`
  6. Return expense_id to application

**🗣️ Script Answer:**

"Let me walk through creating an expense in both databases. In SQLite, Python receives form data and validates it first - checking amount is positive, date is valid format, etc. Then I execute a parameterized INSERT statement with question mark placeholders. When the INSERT happens, three triggers fire automatically: trigger_expense_timestamps sets created_at and modified_at, trigger_expense_fiscal_period calculates the fiscal year and month from the date, and trigger_expense_sync_flag sets is_synced to 0. I get the generated ID using cursor.lastrowid, commit the transaction, and return the expense_id.

In Oracle, the process is different. Python prepares a procedure call with bind variables and executes pkg_finance_crud.create_expense. Inside the procedure, parameters are validated using NVL for optional fields. The INSERT uses a RETURNING clause to capture the generated expense_id into an OUT parameter. The procedure has comprehensive exception handling for duplicate values and other errors. Triggers fire automatically here too for timestamps and fiscal period calculation. The procedure commits internally. Python fetches the OUT parameter value and returns the expense_id. Oracle's approach is more robust with centralized validation and error handling."

---

### Q23: How do UPDATE operations differ between SQLite and Oracle?

**📌 Point-wise Answer:**
- **SQLite UPDATE**:
  - Direct SQL with SET clause
  - Example: `UPDATE expense SET amount = ?, description = ? WHERE expense_id = ? AND user_id = ?`
  - Always include user_id for security (ownership check)
  - Trigger updates modified_at automatically
  - Trigger sets is_synced=0 for sync tracking
  - Python checks cursor.rowcount to verify update succeeded
  - Explicit COMMIT needed
  
- **Oracle UPDATE (PL/SQL)**:
  - Procedure: `pkg_finance_crud.update_expense(p_expense_id, p_amount, ...)`
  - NVL handles optional parameters: `amount = NVL(p_amount, amount)`
  - Only provided fields are updated (keeps existing for NULL params)
  - Ownership validation inside procedure
  - RAISE_APPLICATION_ERROR if record not found or not owned
  - Returns affected row count via OUT parameter
  - Automatic COMMIT inside procedure
  
- **Key Advantage of PL/SQL**:
  - Partial updates easy (NVL pattern)
  - Consistent validation logic
  - Better error messages

**🗣️ Script Answer:**

"UPDATE operations show the power of PL/SQL procedures. In SQLite, I execute direct SQL UPDATE statements with SET clauses for each field. Critically, I always include user_id in the WHERE clause for security - this ensures users can only update their own records. Triggers automatically update the modified_at timestamp and set is_synced to 0 for sync tracking. I check cursor.rowcount to verify the update succeeded - if it's 0, the record doesn't exist or doesn't belong to the user.

In Oracle, I call pkg_finance_crud.update_expense with all parameters. The clever part is using NVL to handle optional parameters - if a parameter is NULL, it keeps the existing value. This allows partial updates easily. For example, NVL(p_amount, amount) means 'use the new amount if provided, otherwise keep the current amount'. Ownership validation happens inside the procedure - it checks the user_id matches. If not, it raises a custom error. The procedure returns the affected row count and commits automatically.

The PL/SQL approach is superior for partial updates and provides consistent validation logic across all applications using the database. The NVL pattern is particularly elegant for optional fields."

---

### Q24: Explain DELETE operations and cascading in both systems.

**📌 Point-wise Answer:**
- **SQLite DELETE**:
  - Direct SQL: `DELETE FROM expense WHERE expense_id = ? AND user_id = ?`
  - Foreign key constraints with CASCADE:
    - Deleting user cascades to all expenses, income, budgets, goals
    - Deleting goal cascades to all contributions
  - PRAGMA foreign_keys=ON required for cascade
  - Soft delete option: UPDATE is_deleted=1 (not implemented but possible)
  - Check cursor.rowcount to verify deletion
  
- **Oracle DELETE (PL/SQL)**:
  - Procedure: `pkg_finance_crud.delete_expense(p_expense_id, p_user_id)`
  - Ownership check: `SELECT COUNT(*) ... WHERE user_id = p_user_id`
  - RAISE_APPLICATION_ERROR if not owned
  - Foreign key constraints with ON DELETE CASCADE
  - Explicit DELETE: `DELETE FROM finance_expense WHERE expense_id = p_expense_id`
  - Returns success/failure via EXCEPTION block
  
- **Cascade Example**:
  - Delete user → all expenses deleted → sync_log updated
  - Delete savings_goal → all contributions deleted
  - Prevents orphaned records

**🗣️ Script Answer:**

"DELETE operations demonstrate foreign key cascading. In SQLite, I use direct DELETE statements always including user_id for ownership verification. The critical part is foreign key constraints with CASCADE delete - when a user is deleted, all their expenses, income, budgets, and savings goals are automatically deleted too. When a savings goal is deleted, all its contributions cascade delete. This requires PRAGMA foreign_keys=ON to be set. I check cursor.rowcount to verify the deletion actually happened.

In Oracle, pkg_finance_crud.delete_expense first checks ownership by querying if the expense belongs to the user. If not, it raises a custom application error. Then it executes the DELETE statement. Oracle also has ON DELETE CASCADE constraints that work identically - deleting a user cascades to all related records.

A practical example: When user dilini.fernando is deleted, the cascade automatically removes her 180 expenses, 54 income records, 8 budgets, 5 savings goals, and 25 contributions - all in one transaction maintaining referential integrity. This prevents orphaned records that would break the database structure. Both systems handle this gracefully, but PL/SQL provides better error messages when cascade constraints are violated."

---

### Q25: How do READ operations work with complex queries?

**📌 Point-wise Answer:**
- **SQLite Complex READ**:
  - JOINs for related data:
    ```sql
    SELECT e.*, c.category_name, u.username
    FROM expense e
    JOIN category c ON e.category_id = c.category_id
    JOIN user u ON e.user_id = u.user_id
    WHERE e.user_id = ?
    ```
  - Views for common queries: vw_expense_details, vw_budget_utilization
  - Aggregations: SUM, AVG, GROUP BY
  - Date filtering: `WHERE expense_date >= ? AND expense_date <= ?`
  - Indexes speed up JOINs (25× faster)
  
- **Oracle Complex READ (PL/SQL)**:
  - SYS_REFCURSOR procedures return result sets:
    ```sql
    PROCEDURE get_user_expenses(p_user_id NUMBER, p_cursor OUT SYS_REFCURSOR)
    ```
  - Complex joins in procedure body
  - Python fetches: `cursor_var.fetchall()`
  - Utility functions: get_monthly_summary, get_category_summary
  - Report procedures with GROUP BY, HAVING, aggregations
  
- **Advantage**:
  - SQLite: Direct queries, simpler debugging
  - Oracle: Encapsulated logic, reusable queries

**🗣️ Script Answer:**

"Complex READ operations showcase both approaches. In SQLite, I write multi-table JOINs directly in Python. For example, fetching expenses with category names and usernames requires joining three tables - expense, category, and user. I always filter by user_id for security. For common complex queries, I created 5 views like vw_expense_details that pre-join tables. This avoids repeating complex JOINs and improves performance through indexed views. Aggregations use GROUP BY for monthly summaries - SUM for totals, AVG for averages.

In Oracle, complex reads are encapsulated in procedures that return SYS_REFCURSOR. For example, get_user_expenses opens a cursor with a complex join query and returns it to Python. Python then fetches rows using fetchall(). I also created utility functions like get_monthly_summary that calculate totals across categories for a specific month. Report procedures use GROUP BY, HAVING clauses, and complex aggregations.

The advantage: SQLite's direct queries are simpler to debug - I can see exactly what SQL is executed. Oracle's approach encapsulates complex logic in the database layer making it reusable across different applications. For example, a mobile app and web app could both call the same get_user_expenses procedure. Both approaches work well, but for different use cases."

---

### Q26: How do you handle transactions in CRUD operations?

**📌 Point-wise Answer:**
- **SQLite Transactions**:
  - Explicit control: `conn.commit()` or `conn.rollback()`
  - Context manager for auto-rollback:
    ```python
    with conn:
        cursor.execute(...)  # auto-commits
    ```
  - Multi-statement transactions:
    ```python
    cursor.execute("INSERT INTO expense ...")
    cursor.execute("UPDATE budget ...")
    conn.commit()  # commit both or rollback both
    ```
  - Exception handling triggers rollback
  - PRAGMA synchronous=NORMAL for performance
  
- **Oracle Transactions (PL/SQL)**:
  - Automatic in procedures: COMMIT or ROLLBACK
  - Exception block forces ROLLBACK:
    ```sql
    EXCEPTION
      WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
    ```
  - Multi-procedure transactions from Python:
    ```python
    conn.begin()
    cursor.callproc('pkg_finance_crud.create_expense', ...)
    cursor.callproc('pkg_finance_crud.update_budget', ...)
    conn.commit()
    ```
  - Savepoints for partial rollback (advanced)
  
- **Importance**: Maintains ACID properties

**🗣️ Script Answer:**

"Transaction management is critical for data integrity. In SQLite, I have explicit control over transactions with commit() and rollback(). I often use Python's context manager which automatically commits on success or rolls back on exception. For multi-statement transactions, like creating an expense and updating a budget, I execute both statements then commit once - if either fails, both rollback maintaining consistency.

In Oracle, PL/SQL procedures handle transactions internally. Each procedure has an EXCEPTION block that executes ROLLBACK if any error occurs, then re-raises the exception. This ensures partial changes never persist. For multi-procedure transactions, I control it from Python - I start a transaction, call multiple procedures, then commit or rollback based on overall success.

The importance is maintaining ACID properties - Atomicity ensures all-or-nothing execution, Consistency maintains database constraints, Isolation prevents interference between concurrent transactions, and Durability ensures committed data persists. For example, when adding an expense, if the budget update fails, the entire transaction rolls back - you never get an expense without the corresponding budget adjustment. Both systems handle this well, but PL/SQL's built-in exception handling makes it more robust for complex multi-step operations."

---

### Q27: What are the performance differences between SQLite and Oracle CRUD operations?

**📌 Point-wise Answer:**
- **SQLite Performance**:
  - CREATE: ~2-3ms per insert (with indexes)
  - READ: 6ms with joins (after indexing)
  - UPDATE: ~4-5ms (triggers + index updates)
  - DELETE: ~3-4ms (cascade deletes + index updates)
  - Bulk operations: 500 inserts in ~1 second
  - WAL mode enables concurrent reads during writes
  - 28 indexes provide 25× speedup
  
- **Oracle Performance**:
  - CREATE: ~5-8ms (includes network latency + procedure overhead)
  - READ: 10-15ms (network + cursor fetching)
  - UPDATE: ~7-10ms (procedure execution + validation)
  - DELETE: ~6-9ms (ownership check + delete)
  - Bulk operations: PL/SQL FORALL faster than individual calls
  - Connection pooling reduces overhead
  
- **Why Different**:
  - SQLite: Local, embedded, no network
  - Oracle: Network latency, client-server architecture
  - Oracle: More validation, security checks
  - Trade-off: SQLite faster, Oracle more robust

**🗣️ Script Answer:**

"Performance differs significantly due to architecture. SQLite CRUD operations are faster because it's embedded locally - no network latency. CREATE takes 2-3ms per insert including trigger execution and index updates. READ operations take 6ms even with complex joins thanks to 28 strategic indexes - that's a 25× speedup from the original 145ms. UPDATE takes 4-5ms including timestamp triggers and sync flag updates. DELETE is 3-4ms including cascade deletes.

Oracle operations take longer due to network latency and client-server architecture. CREATE takes 5-8ms including the round-trip to the database server and procedure overhead. READ is 10-15ms including cursor fetching. UPDATE is 7-10ms because the procedure does ownership validation and business logic. DELETE is 6-9ms with ownership checks.

However, for bulk operations, Oracle's PL/SQL FORALL statement processes arrays of data much faster than individual calls. I use connection pooling to reduce the overhead of establishing connections.

The trade-off is clear: SQLite is faster for individual operations due to being local and lightweight. Oracle is slower but provides more robust validation, centralized business logic, and better security. For synchronization, I sync 1,350+ records in just 0.20 seconds by batching operations efficiently. In production, the extra milliseconds in Oracle are worth it for the enterprise features."

---

### Q28: How do you handle bulk operations efficiently in both databases?

**📌 Point-wise Answer:**
- **SQLite Bulk Operations**:
  - executemany() for batch inserts:
    ```python
    cursor.executemany("INSERT INTO expense (...) VALUES (?,?,?)", data_list)
    ```
  - Single commit for all inserts (much faster)
  - Disable triggers temporarily for massive imports (optional)
  - Begin immediate transaction for exclusive write lock
  - Typical: 500 inserts in ~1 second
  
- **Oracle Bulk Operations**:
  - FORALL statement in PL/SQL:
    ```sql
    FORALL i IN data_array.FIRST..data_array.LAST
      INSERT INTO finance_expense VALUES data_array(i);
    ```
  - Bulk collect for reads: `BULK COLLECT INTO array_var`
  - Array binding from Python: `cursor.executemany()`
  - Batch size optimization: 100-1000 records per batch
  - Reduces network round-trips significantly
  
- **Synchronization Example**:
  - Sync 1,350 records in 0.20 seconds
  - Batch by entity type (all expenses, then all income)
  - Use executemany() instead of individual inserts
  - Single transaction per entity type

**🗣️ Script Answer:**

"Bulk operations require special techniques for efficiency. In SQLite, I use executemany() which batches multiple inserts into a single database call. Instead of executing 500 individual INSERT statements with 500 commits, I execute them all at once and commit once - this is dramatically faster, completing 500 inserts in about 1 second. For massive data imports, I can temporarily disable triggers to speed things up further, though I don't do this for normal operations. I use BEGIN IMMEDIATE to get an exclusive write lock for the entire batch.

In Oracle, PL/SQL's FORALL statement is the key. Instead of executing INSERT 500 times in a loop, FORALL processes an array of data in one operation. I also use BULK COLLECT for reads to fetch multiple rows into an array at once. From Python, I use cursor.executemany() with array binding which sends all parameters in one network call. The trick is finding the optimal batch size - I use 100-1000 records per batch depending on the operation.

This is critical for synchronization. When syncing 1,350+ records, I batch by entity type. First, I collect all unsynced expenses and use executemany() to insert them all in Oracle. Then all income records, then budgets, etc. Each entity type is one transaction. This achieves the 0.20 second sync time - without batching, it would take 10+ seconds. The key lesson: minimize database round-trips and commits. Batch similar operations together and commit once per batch."

---

### Q29: Explain the role of triggers in your CRUD implementation.

**📌 Point-wise Answer:**
- **SQLite Triggers (10 total)**:
  1. **trigger_user_timestamps**: Sets created_at, modified_at on INSERT/UPDATE
  2. **trigger_expense_timestamps**: Auto-updates timestamps
  3. **trigger_expense_fiscal_period**: Calculates fiscal_year, fiscal_month from date
  4. **trigger_expense_sync_flag**: Sets is_synced=0 on INSERT/UPDATE
  5. **trigger_income_timestamps**: Similar to expense
  6. **trigger_income_fiscal_period**: Fiscal period calculation
  7. **trigger_income_sync_flag**: Sync flag management
  8. **trigger_budget_timestamps**: Auto-timestamps
  9. **trigger_goal_timestamps**: Auto-timestamps
  10. **trigger_goal_status_update**: Auto-completes goal when target reached
  
- **Oracle Triggers**:
  - Auto-increment via sequences (BEFORE INSERT triggers)
  - Same timestamp and fiscal period logic
  - Sync flag management mirrors SQLite
  
- **Benefits**:
  - Automatic, consistent behavior
  - DRY principle (Don't Repeat Yourself)
  - Application doesn't need to remember
  - Can't be bypassed (database-level enforcement)

**🗣️ Script Answer:**

"Triggers are crucial for automatic, consistent behavior across CRUD operations. I created 10 triggers in SQLite handling three main responsibilities. First, timestamp triggers automatically set created_at when records are inserted and update modified_at whenever records change. This is critical - the application never has to remember to set these fields, they're always correct.

Second, fiscal period triggers calculate fiscal_year and fiscal_month from the expense or income date. My fiscal year starts in April, so an expense on May 15, 2025 is fiscal year 2025-2026, fiscal month 2. The trigger handles this complex calculation automatically using date math.

Third, sync flag triggers set is_synced to 0 whenever records are created or modified. This marks them for synchronization. Without triggers, I'd have to remember to set this flag in every INSERT and UPDATE statement - error-prone and violating DRY principle.

I also have a special trigger for savings goals - trigger_goal_status_update checks if the current amount has reached the target amount and automatically changes status from 'Active' to 'Completed'. Users see their goals complete automatically without manual intervention.

Oracle has similar triggers with the same logic. The benefit is consistency - whether I insert from Python, from SQL*Plus, or from any other application, the triggers fire. It's database-level enforcement that can't be bypassed. This is defensive programming at its best - the database protects its own integrity."

---

### Q30: How would you implement a new CRUD entity in both databases?

**📌 Point-wise Answer:**
- **Step-by-Step Process**:
  
  **1. SQLite Implementation**:
  - Create table with proper constraints:
    ```sql
    CREATE TABLE new_entity (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER NOT NULL,
      created_at TEXT DEFAULT (datetime('now', 'localtime')),
      modified_at TEXT DEFAULT (datetime('now', 'localtime')),
      is_synced INTEGER DEFAULT 0,
      FOREIGN KEY (user_id) REFERENCES user(user_id) ON DELETE CASCADE
    );
    ```
  - Create indexes for performance
  - Create triggers (timestamps, sync flag)
  - Create view if needed for common joins
  
  **2. Oracle Implementation**:
  - Create table with finance_ prefix
  - Create sequence for auto-increment
  - Create BEFORE INSERT trigger for sequence
  - Add CRUD procedures to pkg_finance_crud:
    - create_entity (5 parameters + OUT)
    - update_entity (with NVL pattern)
    - delete_entity (with ownership check)
    - get_entity (return SYS_REFCURSOR)
    - get_user_entities (filtered by user)
  
  **3. Python Application Layer**:
  - Create model class
  - Implement CRUD functions for SQLite (direct SQL)
  - Implement CRUD functions for Oracle (procedure calls)
  - Add to synchronization module
  - Create Flask routes (add, edit, delete, list)
  - Create HTML templates (forms, lists)
  
  **4. Testing**:
  - Unit tests for triggers
  - Integration tests for procedures
  - System tests for full workflow

**🗣️ Script Answer:**

"Adding a new CRUD entity requires systematic implementation across both databases. Let me walk through the complete process.

First, in SQLite, I create the table with all standard fields - primary key with AUTOINCREMENT, user_id foreign key with CASCADE delete, created_at and modified_at timestamps with default values, and is_synced flag defaulting to 0. I add proper indexes on user_id and any date fields for performance. Then I create three triggers: one for timestamps on INSERT/UPDATE, one for the sync flag, and any entity-specific triggers like fiscal period calculation.

Second, in Oracle, I create the equivalent table with the finance_ prefix. I create a sequence for auto-incrementing IDs and a BEFORE INSERT trigger to populate the ID from the sequence. Then I add five procedures to pkg_finance_crud package: create_entity that uses RETURNING clause for the ID, update_entity using the NVL pattern for optional parameters, delete_entity with ownership verification, get_entity returning a SYS_REFCURSOR for a single record, and get_user_entities for filtered lists. Each procedure has full exception handling with RAISE_APPLICATION_ERROR.

Third, in the Python application layer, I create a model class or at minimum CRUD functions. For SQLite, these execute direct parameterized SQL. For Oracle, these call the stored procedures with bind variables. I add the entity to the synchronization module in the correct dependency order - if it references other entities, those must sync first. I create Flask routes for all CRUD operations and HTML templates with forms.

Finally, comprehensive testing: unit tests verify triggers fire correctly, integration tests validate procedures handle edge cases, and system tests walk through complete workflows. This systematic approach ensures consistency, security, and maintainability. It took me about 2 hours per entity to implement everything properly."

---

## Performance & Optimization

### Q21: How did you optimize query performance?

**📌 Point-wise Answer:**
- **Strategic Indexing**: 28 indexes created
  - Primary key indexes (automatic)
  - Foreign key indexes (for JOINs)
  - Date-based indexes (for time-range queries)
  - Composite indexes (user_id, expense_date)
  - Covering indexes (include SELECT columns)
- **Results**: 25× speedup (145ms → 6ms)
- **Views**: Pre-built queries for common reports
- **Query optimization**:
  - Avoid SELECT * (specify columns)
  - Use WHERE clauses to filter early
  - Proper JOIN order
- **SQLite optimizations**:
  - WAL mode (concurrent reads/writes)
  - PRAGMA synchronous=NORMAL
  - ANALYZE command for statistics

**🗣️ Script Answer:**

"Query performance optimization was critical. I created 28 strategic indexes including primary key indexes, foreign key indexes for joins, date-based indexes for time-range queries, and composite indexes combining frequently queried columns like user_id and expense_date. This indexing strategy improved query performance by 25 times - queries that took 145 milliseconds now take just 6 milliseconds. I also created 5 views for common reporting queries to avoid repeatedly writing complex JOINs. For SQLite, I enabled WAL mode for concurrent access and set PRAGMA synchronous=NORMAL for better write performance. I ran ANALYZE to update query optimizer statistics. In queries, I avoid SELECT * and explicitly name needed columns, use WHERE clauses to filter early, and order JOINs appropriately."

---

### Q22: Explain your indexing strategy in detail.

**📌 Point-wise Answer:**
- **Types of indexes created**:
  1. Primary Key: All 9 tables (automatic)
  2. Foreign Key: 8 indexes (user_id, category_id, goal_id)
  3. Date indexes: expense_date, income_date (for date range queries)
  4. Composite: (user_id, expense_date) for user's monthly expenses
  5. Fiscal period: (fiscal_year, fiscal_month) for reports
  6. Covering: Include payment_method, description for common SELECTs
- **Benefits**:
  - Fast WHERE clause filtering
  - Efficient JOINs
  - Quick ORDER BY sorting
  - Index-only scans (covering indexes)
- **Trade-offs**:
  - Increased INSERT/UPDATE time (minimal)
  - Storage overhead (15:1 ratio, acceptable)
  - Maintenance overhead (automatic)

**🗣️ Script Answer:**

"My indexing strategy has multiple layers. First, primary key indexes on all 9 tables for unique record identification. Second, foreign key indexes on columns like user_id and category_id to speed up JOINs - these are critical since every query joins to the user or category table. Third, date-based indexes on expense_date and income_date for time-range queries like 'show me last month's expenses'. Fourth, composite indexes combining user_id with dates for common patterns like 'user X's expenses in date range Y'. Fifth, covering indexes that include frequently selected columns to enable index-only scans without touching the table. The trade-off is slower INSERTs and UPDATE, but testing showed this is minimal - less than 1ms overhead. Storage overhead is about 15:1 index-to-data ratio, which is acceptable. The 25× query speedup far outweighs these costs."

---

### Q23: How do you monitor and measure performance?

**📌 Point-wise Answer:**
- **SQLite timing**: `.timer on` command
- **Oracle timing**: `SET TIMING ON` command
- **Python timing**: time.time() before/after queries
- **Execution plans**:
  - SQLite: EXPLAIN QUERY PLAN
  - Oracle: EXPLAIN PLAN + DBMS_XPLAN.DISPLAY
- **Benchmarking**:
  - Before optimization: 145ms per query
  - After optimization: 6ms per query
  - Sync duration: 0.20 seconds for 1,350+ records
- **Monitoring**:
  - Query logs with timestamps
  - Slow query identification (>100ms)
  - Index usage statistics
  - Cache hit rates

**🗣️ Script Answer:**

"I measure performance at multiple levels. In SQLite, I use the `.timer on` command to see query execution time. In Oracle, `SET TIMING ON` shows timing for each statement. In Python, I wrap database calls with time.time() to measure duration. For deeper analysis, I use EXPLAIN QUERY PLAN in SQLite and EXPLAIN PLAN with DBMS_XPLAN in Oracle to see execution plans and verify indexes are being used. My benchmarking showed dramatic improvements - queries went from 145ms to 6ms, a 25× speedup. Synchronization of 1,350+ records takes only 0.20 seconds. I log all queries with timestamps and flag slow queries over 100ms for investigation. In production, I'd use tools like Prometheus for continuous monitoring and Grafana for visualization."

---

## Testing & Quality Assurance

### Q24: How did you test the system?

**📌 Point-wise Answer:**
- **Three testing levels**:
  1. Unit tests (45 tests): Individual functions, triggers, procedures
  2. Integration tests (15 tests): Synchronization, database interactions
  3. System tests (5 tests): End-to-end user workflows
- **Total**: 65 tests, 85.3% code coverage
- **Test data**: 1,350+ transactions across 5 Sri Lankan users
- **Testing framework**: Python unittest
- **Test categories**:
  - SQLite triggers (timestamp updates, fiscal periods, goal completion)
  - PL/SQL procedures (CRUD operations, error handling)
  - Synchronization (conflict resolution, retry logic)
  - Web application (authentication, authorization, forms)
  - Security (SQL injection, XSS, session management)
  - Performance (query timing, index usage)

**🗣️ Script Answer:**

"I implemented three levels of testing: Unit tests for individual functions and triggers (45 tests), integration tests for synchronization and database interactions (15 tests), and system tests for end-to-end workflows (5 tests). Total 65 tests with 85.3% code coverage. I also generated comprehensive test data - 1,350+ transactions across 5 users - to test with realistic scenarios. The unit tests verify triggers update timestamps correctly, fiscal periods calculate properly, and goals auto-complete when targets are reached. Integration tests validate synchronization handles conflicts correctly and retries on failures. System tests walk through complete user journeys from login to adding expenses to viewing reports. All security measures are tested including SQL injection attempts and XSS prevention. All 65 tests pass successfully."

---

### Q25: Explain your test data generation strategy.

**📌 Point-wise Answer:**
- **5 Sri Lankan users** with realistic names:
  - dilini.fernando, kasun.silva, thilini.perera, nuwan.rajapaksa, sachini.wijesinghe
- **6 months of data** per user (May-October 2025)
- **Transaction distribution**:
  - 180 expenses per user (30 per month, 5 per category)
  - 54 income records per user (9 per month, various sources)
  - 8 budgets per user (monthly and quarterly)
  - 4-5 savings goals per user
  - 20-25 contributions per user
- **Realistic amounts**: ₹3,000-15,000 for expenses, ₹50,000-100,000 for income
- **Variety**: Different categories, payment methods, descriptions
- **Edge cases**: Over-budget scenarios, completed goals, failed syncs

**🗣️ Script Answer:**

"I created comprehensive test data with 5 users having realistic Sri Lankan names. Each user has 6 months of financial history from May to October 2025. Per user, I generated 180 expenses distributed across 6 categories, 54 income records from various sources, 8 budgets both monthly and quarterly, 4-5 savings goals with different targets, and 20-25 contributions. Amounts are realistic - expenses range from ₹3,000 to ₹15,000, income from ₹50,000 to ₹100,000. I included variety in payment methods, descriptions, and categories. Importantly, I included edge cases like over-budget scenarios, completed savings goals, and some failed sync records to test error handling. This totals over 1,350 transactions providing rich data for testing all features."

---

### Q26: What bugs did you find during testing and how did you fix them?

**📌 Point-wise Answer:**
- **Bug 1**: Fiscal period not calculated for income
  - Fix: Added trigger_income_fiscal_period trigger
- **Bug 2**: Sync log timestamp in wrong timezone
  - Fix: Changed to datetime('now', 'localtime')
- **Bug 3**: Goal status not auto-completing
  - Fix: Added trigger_goal_status_update trigger
- **Bug 4**: SQL injection vulnerability in search
  - Fix: Changed to parameterized query
- **Bug 5**: Session not expiring after inactivity
  - Fix: Added last_activity timestamp checking
- **Bug 6**: Sync retry logic not working
  - Fix: Fixed exception handling in retry loop

**🗣️ Script Answer:**

"Testing revealed several bugs that I fixed. Bug 1: Fiscal year and month weren't being calculated for income records - I added a trigger similar to the expense one. Bug 2: Sync log timestamps were in UTC instead of local time - changed to use 'localtime' parameter. Bug 3: Savings goal status wasn't automatically changing to 'Completed' when target was reached - added a trigger to check and update status. Bug 4: The search functionality was vulnerable to SQL injection - I converted it to use parameterized queries. Bug 5: Sessions weren't timing out after 30 minutes of inactivity - added last_activity timestamp checking in the before_request hook. Bug 6: Retry logic wasn't catching the right exceptions - fixed the exception handling. All bugs are now resolved and regression tests added to prevent recurrence."

---

## Backup & Recovery

### Q27: Explain your backup strategy.

**📌 Point-wise Answer:**
- **Backup schedule**:
  - Hourly: Incremental backups (last 24 hours)
  - Daily: Full backups (last 7 days)
  - Weekly: Full backups (last 4 weeks)
  - Monthly: Full backups (12 months archive)
- **3-2-1 Rule**:
  - 3 copies of data (original + 2 backups)
  - 2 different media (local disk + cloud)
  - 1 off-site backup (cloud storage)
- **SQLite backup**: Using .backup command and Python shutil
- **Oracle backup**: Data Pump (expdp/impdp) and RMAN
- **Backup verification**: Integrity checks after each backup
- **RTO**: < 4 hours (Recovery Time Objective)
- **RPO**: < 24 hours (Recovery Point Objective)

**🗣️ Script Answer:**

"My backup strategy follows the 3-2-1 rule: 3 copies of data, 2 different media types, and 1 off-site backup. I maintain hourly incremental backups for the last 24 hours, daily full backups for 7 days, weekly full backups for 4 weeks, and monthly archives for 12 months. For SQLite, I use the .backup command and Python's shutil.copy2 for online backups without locking the database. For Oracle, I use Data Pump for logical backups and RMAN for physical backups. Each backup is verified for integrity using PRAGMA integrity_check in SQLite and RESTORE VALIDATE in Oracle. My RTO is under 4 hours and RPO under 24 hours, meaning I can recover within 4 hours with at most 24 hours of data loss."

---

### Q28: How would you recover from database corruption?

**📌 Point-wise Answer:**
- **Detection**:
  - PRAGMA integrity_check for SQLite
  - RMAN VALIDATE for Oracle
  - Application errors/crashes
- **Recovery steps**:
  1. Stop application immediately
  2. Backup current (corrupt) database for forensics
  3. Identify last known good backup
  4. Restore from backup
  5. Verify restored database integrity
  6. Apply transaction logs if available
  7. Test with sample queries
  8. Restart application
  9. Monitor for issues
- **Data loss**: Maximum 24 hours (RPO)
- **Prevention**: Regular integrity checks, RAID storage, UPS

**🗣️ Script Answer:**

"If database corruption is detected through integrity checks or application errors, I would immediately stop the application to prevent further damage. First, I'd backup the corrupt database for forensic analysis. Then I'd identify the last known good backup - checking backup logs and running integrity checks on backup files. I'd restore from that backup using SQLite's .restore command or Oracle's impdp/RMAN RESTORE. After restoration, I'd verify integrity using PRAGMA integrity_check or DBMS_REPAIR. If available, I'd apply transaction logs to minimize data loss. I'd test with sample queries to ensure everything works. Finally, restart the application and monitor closely. Maximum data loss would be 24 hours based on my RPO. Prevention measures include regular integrity checks, RAID storage, and UPS for power failure protection."

---

### Q29: What disaster recovery procedures do you have?

**📌 Point-wise Answer:**
- **Disaster scenarios**:
  1. Hardware failure (1-2 hours recovery)
  2. Data corruption (30-60 minutes recovery)
  3. Accidental deletion (15-30 minutes recovery)
  4. Ransomware (2-4 hours recovery from off-site backup)
  5. Site disaster (4-8 hours failover to cloud)
- **Communication plan**:
  - Notify stakeholders immediately
  - Status updates every 30 minutes
  - Post-mortem after resolution
- **Runbooks**: Documented step-by-step procedures
- **Testing**: Monthly disaster recovery drills
- **Automated failover**: To cloud backup (future)

**🗣️ Script Answer:**

"I've documented disaster recovery procedures for five scenarios. For hardware failure, I can restore to new hardware in 1-2 hours from daily backups. Data corruption recovery takes 30-60 minutes using last verified backup. Accidental deletion can be recovered in 15-30 minutes from hourly incrementals. Ransomware requires off-site backup restoration taking 2-4 hours. Complete site disaster involves failover to cloud in 4-8 hours. Each scenario has a documented runbook with step-by-step procedures. Communication plan includes immediate stakeholder notification and status updates every 30 minutes. After recovery, we conduct post-mortems to improve processes. I'd test these procedures monthly through disaster recovery drills. Future enhancements would include automated failover to cloud infrastructure for even faster recovery."

---

## Technical Challenges

### Q31: What were your biggest technical challenges?

**📌 Point-wise Answer:**
- **Challenge 1**: Bidirectional sync with conflict resolution
  - Solution: Last-modified-wins, transaction management, retry logic
- **Challenge 2**: Schema differences between SQLite and Oracle
  - Solution: Detailed mapping, data type conversion functions
- **Challenge 3**: Performance optimization
  - Solution: Strategic indexing (28 indexes), views, WAL mode
- **Challenge 4**: PL/SQL cursor management
  - Solution: SYS_REFCURSOR for dynamic results
- **Challenge 5**: Security implementation
  - Solution: PBKDF2 hashing, parameterized queries, session security
- **Challenge 6**: Test data generation
  - Solution: Automated scripts with realistic patterns

**🗣️ Script Answer:**

"The biggest challenge was implementing bidirectional synchronization with conflict resolution. I had to ensure data consistency while handling edge cases like concurrent modifications, network failures, and partial syncs. I solved this with proper transaction management, retry logic with exponential backoff, and comprehensive logging. Another challenge was performance optimization - strategic indexing improved query speed by 25 times. Schema differences between SQLite and Oracle required detailed mapping and conversion functions. PL/SQL cursor management was solved using SYS_REFCURSOR for dynamic result sets. Security implementation required PBKDF2 password hashing, parameterized queries throughout, and secure session management. These challenges made the project more interesting and taught me valuable lessons about distributed systems and database optimization."

---

**Total Questions: 41**  
**Coverage**:
- Database Design & Architecture: 5 questions
- Synchronization & Conflict Resolution: 6 questions  
- Security & Authentication: 5 questions
- **PL/SQL & Oracle Implementation: 15 questions** ⭐ **(COMPREHENSIVE CRUD coverage)**
- Performance & Optimization: 3 questions
- Testing & Quality Assurance: 3 questions
- Backup & Recovery: 3 questions
- Technical Challenges: 1 question

**🔥 NEW Deep-Dive CRUD Questions Added:**
- **Q21**: Compare CRUD operations in SQLite vs PL/SQL ✨
- **Q22**: Walk through CREATE operations in both databases 🔨
- **Q23**: UPDATE operations - differences and NVL pattern 📝
- **Q24**: DELETE operations and cascading behavior 🗑️
- **Q25**: Complex READ operations with JOINs and aggregations 📊
- **Q26**: Transaction management in CRUD operations 💾
- **Q27**: Performance differences between SQLite and Oracle CRUD ⚡
- **Q28**: Bulk operations and optimization strategies 📦
- **Q29**: Role of triggers in CRUD implementation 🎯
- **Q30**: How to implement a new CRUD entity (complete guide) 🛠️

---

**Preparation Tips:**
1. ✅ Practice answering out loud
2. ✅ Understand the concepts, don't memorize
3. ✅ Be ready to show code examples
4. ✅ Have your database open during viva
5. ✅ Be honest if you don't know something
6. ✅ Relate answers to your actual implementation
7. ✅ Use specific numbers (e.g., "28 indexes", "0.20 seconds")
8. ✅ Show enthusiasm for your work

**Good luck with your viva! 🎓**
