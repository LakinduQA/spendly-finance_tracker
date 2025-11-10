# 🎯 VIVA QUICK REFERENCE SHEET
## Last-Minute Review Before Viva

---

## ⚡ MEMORIZE THESE NUMBERS

```
10,000+ lines of code
1,350+ test transactions
818 lines - PL/SQL CRUD (31 procedures)
720 lines - PL/SQL Reports (5 reports)
28 indexes → 25× faster queries (145ms → 6ms)
0.20 seconds - sync time for all records
10 triggers in SQLite
9 tables in both databases
5 users with 6 months data
85.3% test coverage
```

---

## 🗣️ OPENING STATEMENT (60 seconds)

"Good morning. My Personal Finance Management System uses **dual-database architecture** - SQLite for fast local operations and Oracle for advanced analytics.

The system has **10,000+ lines** of code including **1,538 lines of PL/SQL** for business logic and reports. I've implemented **soft delete** mechanism instead of hard delete - records are marked as deleted rather than removed, enabling data recovery and proper synchronization.

Performance optimization through **28 strategic indexes** achieved **25× speedup** - queries dropped from 145ms to 6ms. Synchronization of 1,350+ records completes in just **0.20 seconds**.

Testing includes **65 automated tests** with 85.3% coverage across unit, integration, and system levels."

---

## 🏗️ SYSTEM ARCHITECTURE (3 Sentences)

1. **Frontend**: Bootstrap 5 + Chart.js responsive web interface
2. **Backend**: Python Flask (2,220 lines) connecting to both databases
3. **Data**: SQLite (local, fast) ↔ Sync ↔ Oracle (cloud, analytics)

---

## 📊 DATABASE SCHEMA (9 Tables)

```
USER (center)
├── EXPENSE (900+) → CATEGORY (13)
├── INCOME (270+)
├── BUDGET (48) → CATEGORY
└── SAVINGS_GOAL (24)
    └── SAVINGS_CONTRIBUTION (120+)

SYNC_LOG (audit trail)
```

**Normalization**: BCNF (Boyce-Codd Normal Form)
**Why**: No redundancy, data consistency, no update anomalies

---

## 🔥 PL/SQL CRUD PACKAGE (MOST IMPORTANT!)

**Structure**: 818 lines, 31 procedures/functions

```
For each entity (USER, EXPENSE, INCOME, BUDGET, GOAL):
├── create_*() → returns ID via RETURNING clause
├── update_*() → uses NVL pattern for optional params
├── delete_*() → ownership validation
├── get_*() → returns SYS_REFCURSOR
└── get_user_*() → filtered by user_id
```

**Key Features**:
- **SYS_REFCURSOR**: Dynamic result sets to Python
- **NVL pattern**: `amount = NVL(p_amount, amount)` for partial updates
- **RETURNING**: `INSERT ... RETURNING expense_id INTO p_expense_id`
- **Exception handling**: RAISE_APPLICATION_ERROR(-20001, 'message')
- **Security**: Ownership checks, parameterized queries

**Example CREATE**:
```sql
PROCEDURE create_expense(p_user_id, p_amount, ..., p_expense_id OUT)
AS BEGIN
    -- Validate
    IF p_amount <= 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Amount must be positive');
    END IF;
    
    -- Insert with RETURNING
    INSERT INTO finance_expense (...) 
    VALUES (...)
    RETURNING expense_id INTO p_expense_id;
    
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END;
```

---

## 📈 PL/SQL REPORTS (5 Reports)

1. **Monthly Expenditure**: Income vs expenses, category breakdown
2. **Budget Adherence**: Actual vs budgeted spending
3. **Savings Progress**: Goal completion percentages
4. **Category Distribution**: Pie chart data
5. **Savings Forecast**: Predicted future savings

**Features**:
- GROUP BY, HAVING, CASE statements
- Cursors for iteration
- DBMS_OUTPUT for console display
- UTL_FILE for CSV export

---

## 🔄 SYNCHRONIZATION (12 Steps in 0.20 seconds)

**Process**:
1. Connect to both databases
2. Create sync log entry
3-9. Sync entities in order (respect FK constraints)
   - Users, Categories (no dependencies)
   - Expenses, Income (depend on above)
   - Budgets, Goals, Contributions
10. Update is_synced flags
11. Complete sync log
12. Close connections

**Conflict Resolution**: Last-modified-wins
- Compare `modified_at` timestamps
- Newer version overwrites older
- Triggers auto-update timestamps

---

## 🗑️ SOFT DELETE (Critical Feature!)

**Problem**: Hard DELETE breaks sync (record gone from SQLite, can't sync to Oracle)

**Solution**: Soft delete
```sql
-- Instead of: DELETE FROM expense WHERE expense_id = ?
UPDATE expense 
SET is_deleted = 1, 
    modified_at = CURRENT_TIMESTAMP,
    is_synced = 0
WHERE expense_id = ?
```

**Benefits**:
- ✅ Data recovery possible
- ✅ Sync works (is_deleted=1 syncs to Oracle)
- ✅ Referential integrity maintained
- ✅ Audit trail preserved
- ✅ UI hides with: `WHERE (is_deleted = 0 OR is_deleted IS NULL)`

**Implementation**:
- Added `is_deleted INTEGER DEFAULT 0` to 4 tables
- Updated 30+ queries to filter deleted records
- Updated 4 delete routes from DELETE to UPDATE
- Updated 3 views to exclude deleted records

---

## 🔐 SECURITY (3 Layers)

**1. Password Security**:
- PBKDF2-SHA256 hashing
- 600,000 iterations
- 16-byte random salt per password
- Never store plaintext

**2. SQL Injection Prevention**:
- Parameterized queries exclusively
- SQLite: `?` placeholders
- Oracle: `:param` bind variables
- Example: `cursor.execute("... WHERE id = ?", (id,))`

**3. Session Security**:
- HTTPONLY cookies (no JavaScript access)
- 30-minute timeout
- SAMESITE=Lax (CSRF protection)
- Secure flag for HTTPS

---

## ⚡ PERFORMANCE OPTIMIZATION

**Results**: 25× faster queries (145ms → 6ms)

**Techniques**:
1. **28 Strategic Indexes**
   - Foreign keys (user_id, category_id)
   - Date fields (expense_date)
   - Composite (user_id, expense_date)
   
2. **SQLite Configuration**
   - WAL mode (concurrent reads)
   - 64MB cache
   - PRAGMA optimizations
   
3. **Batch Operations**
   - executemany() instead of loops
   - Single commit per batch
   - Reduced sync from 5s → 0.20s

4. **Views**
   - 5 pre-built queries
   - Common JOINs cached

---

## 🧪 TESTING (85.3% Coverage)

**Test Pyramid**:
```
System Tests (5)     ← End-to-end workflows
Integration Tests (15) ← Sync, DB interactions
Unit Tests (45)        ← Triggers, procedures
```

**Total**: 65 tests, all passing ✅

**What's Tested**:
- Triggers (timestamps, fiscal periods, sync flags)
- PL/SQL procedures (CRUD, error handling)
- Synchronization (conflict resolution, retry logic)
- Security (SQL injection, XSS, sessions)
- Performance (query timing, index usage)

---

## 🎤 DEMO FLOW (10 minutes)

**1. Login** (30s)
- User: dilini.fernando
- Password: Password123!

**2. Dashboard** (1m)
- Financial cards (income, expenses, savings)
- Chart.js visualization
- Recent transactions

**3. Add Expense** (1m)
- Category: Food & Dining
- Amount: ₹2,500
- AJAX update (no page reload)
- Check is_synced=0, is_deleted=0

**4. View Budgets** (1m)
- Color-coded progress bars
- Green (under), Yellow (near), Red (over)

**5. Savings Goals** (1m)
- Active goals with percentages
- Completed goals (100% ✓)

**6. Generate PL/SQL Report** (2m)
- Monthly Expenditure Analysis
- User 2, October 2025
- Category breakdown, percentages

**7. Synchronize** (2m)
- Click "Sync Now"
- 0.20 seconds ⚡
- Verify is_synced=1

**8. Verify Databases** (1m)
- SQLite: DB Browser, show records
- Oracle: SQL Developer, show matching data

**9. Soft Delete Demo** (30s)
- Delete expense → disappears from UI
- Database: is_deleted=1, still exists
- Can be restored!

---

## 💡 TOP 10 VIVA QUESTIONS

**1. Why dual-database?**
→ SQLite speed + Oracle power, offline + cloud

**2. Explain PL/SQL CRUD**
→ 818 lines, 31 procedures, SYS_REFCURSOR, NVL pattern

**3. How does sync work?**
→ 12 steps, bidirectional, last-modified-wins, 0.20s

**4. What is soft delete?**
→ UPDATE is_deleted=1 instead of DELETE, enables recovery & sync

**5. Performance optimization?**
→ 28 indexes, 25× speedup, WAL mode, batch operations

**6. Normalization?**
→ BCNF, no redundancy, category example

**7. Security measures?**
→ PBKDF2, parameterized queries, session security

**8. PL/SQL CREATE operation?**
→ Validate → INSERT with RETURNING → COMMIT → Exception handling

**9. Triggers?**
→ 10 total: timestamps, fiscal periods, sync flags, goal completion

**10. Testing?**
→ 65 tests, 85.3% coverage, unit/integration/system pyramid

---

## 🎯 DIFFICULT QUESTION STRATEGIES

**If you don't know**:
- "Great question! I haven't implemented that yet, but here's how I'd approach it..."
- "That's outside current scope, but for future I would..."

**If asked about alternatives**:
- "I considered [X] but chose [Y] because..."
- "Trade-off is [this vs that]. For my use case, [choice] is better because..."

**If asked to improve**:
- "Current implementation works well. For production I'd add..."
- "Future enhancements: [list 2-3 ideas]"

---

## ✅ FINAL CHECKLIST

**Before Viva**:
- [ ] Review this sheet 2-3 times
- [ ] Test demo application works
- [ ] Oracle connection active
- [ ] Memorize the key numbers
- [ ] Practice 60-second opening
- [ ] Get good sleep!

**During Viva**:
- [ ] Listen carefully to questions
- [ ] Pause 2-3 seconds before answering
- [ ] Use specific numbers and examples
- [ ] Relate to YOUR actual code
- [ ] Show enthusiasm
- [ ] Smile!

---

## 🚀 YOU'VE GOT THIS!

You built an amazing system:
- ✅ 10,000+ lines of quality code
- ✅ Innovative soft delete solution
- ✅ 25× performance improvement
- ✅ 1,538 lines of PL/SQL
- ✅ 0.20-second sync
- ✅ 85.3% test coverage

**Believe in yourself. You know this system!**

**GOOD LUCK! 🎓✨**
