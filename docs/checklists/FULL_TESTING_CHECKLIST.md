# 🧪 FULL COVERAGE TESTING CHECKLIST

**Project**: Personal Finance Management System  
**Date**: November 2, 2025  
**Purpose**: Complete functional testing before submission

---

## 📝 HOW TO USE THIS CHECKLIST

1. **Test each item systematically** - Don't skip!
2. **Mark with:** ✅ Pass | ❌ Fail | ⚠️ Has Issues | ⏭️ Skip
3. **Write notes** for every failure or unexpected behavior
4. **Take screenshots** of any errors
5. **Retest** after fixing issues

---

## PART 1: DATABASE TESTING 🗄️

### A. SQLite Database Structure

**Open DB Browser for SQLite → Open `sqlite/finance_local.db`**

#### Table Verification
```
Run: SELECT name FROM sqlite_master WHERE type='table' ORDER BY name;
```
- [ ] Table: user (exists)
- [ ] Table: category (exists)
- [ ] Table: expense (exists)
- [ ] Table: income (exists)
- [ ] Table: budget (exists)
- [ ] Table: savings_goal (exists)
- [ ] Table: goal_contribution (exists)
- [ ] Table: sync_log (exists)
- [ ] Table: audit_log (exists)

**Notes:** _____________________________________________

#### Index Verification
```
Run: SELECT COUNT(*) FROM sqlite_master WHERE type='index';
```
- [ ] Result shows 28 indexes

**Notes:** _____________________________________________

#### Trigger Verification
```
Run: SELECT COUNT(*) FROM sqlite_master WHERE type='trigger';
```
- [ ] Result shows 10 triggers

**Notes:** _____________________________________________

#### View Verification
```
Run: SELECT COUNT(*) FROM sqlite_master WHERE type='view';
```
- [ ] Result shows 5 views

**Notes:** _____________________________________________

#### Data Count Verification
```sql
SELECT 'users' as table_name, COUNT(*) as count FROM user
UNION ALL SELECT 'categories', COUNT(*) FROM category
UNION ALL SELECT 'expenses', COUNT(*) FROM expense
UNION ALL SELECT 'income', COUNT(*) FROM income
UNION ALL SELECT 'budgets', COUNT(*) FROM budget
UNION ALL SELECT 'goals', COUNT(*) FROM savings_goal;
```

Expected Results:
- [ ] users = 2 (john_doe, jane_smith)
- [ ] categories = 15
- [ ] expenses = 367
- [ ] income = 8
- [ ] budgets = 8
- [ ] goals = 5

**Notes:** _____________________________________________

#### Foreign Key Test
```sql
-- Should return 0 (no orphaned records)
SELECT COUNT(*) FROM expense WHERE category_id NOT IN (SELECT category_id FROM category);
SELECT COUNT(*) FROM expense WHERE user_id NOT IN (SELECT user_id FROM user);
```
- [ ] No orphaned expenses (result = 0 for both)

**Notes:** _____________________________________________

#### Trigger Test (updated_at)
```sql
-- Note the current time
SELECT expense_id, updated_at FROM expense WHERE expense_id = 1;

-- Update the record
UPDATE expense SET amount = amount + 0.01 WHERE expense_id = 1;

-- Check if updated_at changed
SELECT expense_id, updated_at FROM expense WHERE expense_id = 1;
```
- [ ] updated_at timestamp changed after UPDATE

**Notes:** _____________________________________________

---

### B. Oracle Database Structure

**Open SQL Developer → Connect: system/oracle123@172.20.10.4:1521/xe**

#### Connection Test
- [ ] Connection successful
- [ ] No errors

**Notes:** _____________________________________________

#### Table Verification
```sql
SELECT table_name FROM user_tables ORDER BY table_name;
```

Expected 9 tables:
- [ ] FINANCE_AUDIT_LOG
- [ ] FINANCE_BUDGET
- [ ] FINANCE_CATEGORY
- [ ] FINANCE_EXPENSE
- [ ] FINANCE_GOAL_CONTRIBUTION
- [ ] FINANCE_INCOME
- [ ] FINANCE_SAVINGS_GOAL
- [ ] FINANCE_SYNC_LOG
- [ ] FINANCE_USER

**Notes:** _____________________________________________

#### Synced Data Verification
```sql
SELECT 
    (SELECT COUNT(*) FROM FINANCE_USER) as users,
    (SELECT COUNT(*) FROM FINANCE_EXPENSE) as expenses,
    (SELECT COUNT(*) FROM FINANCE_INCOME) as income,
    (SELECT COUNT(*) FROM FINANCE_BUDGET) as budgets,
    (SELECT COUNT(*) FROM FINANCE_SAVINGS_GOAL) as goals
FROM dual;
```

Expected after sync:
- [ ] users = 2
- [ ] expenses = 367
- [ ] income = 8
- [ ] budgets = 8
- [ ] goals = 5

**Notes:** _____________________________________________

#### PL/SQL Package Status
```sql
SELECT object_name, object_type, status 
FROM user_objects 
WHERE object_type IN ('PACKAGE', 'PACKAGE BODY')
ORDER BY object_name, object_type;
```

Expected 4 objects (all VALID):
- [ ] PKG_FINANCE_CRUD (PACKAGE) - VALID
- [ ] PKG_FINANCE_CRUD (PACKAGE BODY) - VALID
- [ ] PKG_FINANCE_REPORTS (PACKAGE) - VALID
- [ ] PKG_FINANCE_REPORTS (PACKAGE BODY) - VALID

**Notes:** _____________________________________________

#### Test PL/SQL CRUD - Create User
```sql
SET SERVEROUTPUT ON;
DECLARE
    v_username VARCHAR2(50) := 'test_user_' || TO_CHAR(SYSDATE, 'HHMISS');
BEGIN
    pkg_finance_crud.create_user(
        p_username => v_username,
        p_email => 'test@example.com',
        p_full_name => 'Test User'
    );
    DBMS_OUTPUT.PUT_LINE('Created user: ' || v_username);
    COMMIT;
END;
/
```
- [ ] Executes without errors
- [ ] Shows "Created user: test_user_XXXXXX"

**Notes:** _____________________________________________

#### Test PL/SQL CRUD - Get User
```sql
DECLARE
    v_user pkg_finance_crud.user_record;
BEGIN
    v_user := pkg_finance_crud.get_user(1);
    DBMS_OUTPUT.PUT_LINE('Username: ' || v_user.username);
    DBMS_OUTPUT.PUT_LINE('Email: ' || v_user.email);
END;
/
```
- [ ] Executes without errors
- [ ] Shows user details

**Notes:** _____________________________________________

#### Test PL/SQL CRUD - Create Expense
```sql
BEGIN
    pkg_finance_crud.create_expense(
        p_user_id => 1,
        p_category_id => 1,
        p_amount => 99.99,
        p_expense_date => SYSDATE,
        p_description => 'Test Expense from PL/SQL',
        p_payment_method => 'Cash'
    );
    COMMIT;
END;
/
```
- [ ] Executes without errors
- [ ] Check: `SELECT * FROM FINANCE_EXPENSE WHERE description LIKE '%Test Expense%'`

**Notes:** _____________________________________________

#### Test Report 1: Monthly Expenditure
```sql
SET SERVEROUTPUT ON SIZE UNLIMITED;
BEGIN
    pkg_finance_reports.generate_monthly_expenditure(
        p_user_id => 1,
        p_months => 3
    );
END;
/
```
- [ ] Executes without errors
- [ ] Shows output with monthly totals
- [ ] Data looks reasonable

**Notes:** _____________________________________________

#### Test Report 2: Budget Adherence
```sql
BEGIN
    pkg_finance_reports.generate_budget_adherence(
        p_user_id => 1,
        p_year => 2024,
        p_month => 11
    );
END;
/
```
- [ ] Executes without errors
- [ ] Shows budget vs actual spending
- [ ] Percentages calculated correctly

**Notes:** _____________________________________________

#### Test Report 3: Savings Progress
```sql
BEGIN
    pkg_finance_reports.generate_savings_progress(
        p_user_id => 1
    );
END;
/
```
- [ ] Executes without errors
- [ ] Shows all 5 savings goals
- [ ] Progress percentages shown

**Notes:** _____________________________________________

#### Test Report 4: Category Distribution
```sql
BEGIN
    pkg_finance_reports.generate_category_distribution(
        p_user_id => 1,
        p_start_date => ADD_MONTHS(SYSDATE, -3),
        p_end_date => SYSDATE
    );
END;
/
```
- [ ] Executes without errors
- [ ] Shows expenses grouped by category
- [ ] Percentages add up to ~100%

**Notes:** _____________________________________________

#### Test Report 5: Forecasted Savings
```sql
BEGIN
    pkg_finance_reports.generate_savings_forecast(
        p_user_id => 1,
        p_months_ahead => 6
    );
END;
/
```
- [ ] Executes without errors
- [ ] Shows forecast for next 6 months
- [ ] Calculations look reasonable

**Notes:** _____________________________________________

---

## PART 2: WEB APPLICATION TESTING 🌐

### A. Application Startup

#### Start Flask Server
```powershell
cd d:\DM2_CW\webapp
python app.py
```

Check terminal output:
- [ ] No Python errors
- [ ] Shows "Running on http://127.0.0.1:5000"
- [ ] Shows "Press CTRL+C to quit"
- [ ] SQLite connection successful
- [ ] Oracle connection successful (or warning if disabled)

**Notes:** _____________________________________________

---

### B. Homepage Testing

#### Access Homepage
- [ ] Open browser: http://127.0.0.1:5000
- [ ] Page loads (no 404/500 error)
- [ ] No errors in browser console (F12 → Console)
- [ ] Bootstrap CSS loaded (page looks styled)
- [ ] Icons display correctly

**Visual Check:**
- [ ] Navigation bar displays
- [ ] Logo/title shows
- [ ] "Login" button visible
- [ ] "Register" button visible
- [ ] Footer displays (if any)

**Notes:** _____________________________________________

---

### C. User Registration Testing

#### Test 1: Valid Registration
1. [ ] Navigate to `/register` or click "Register" button
2. [ ] Form displays with 4 fields:
   - Username
   - Email
   - Full Name
3. [ ] Fill in valid data:
   - Username: `tester1`
   - Email: `tester1@test.com`
   - Full Name: `Tester One`
4. [ ] Click "Register" / "Create Account" button
5. [ ] Success message appears (flash message)
6. [ ] Redirected to login page
7. [ ] Verify in database:
   ```sql
   SELECT * FROM user WHERE username = 'tester1';
   ```
   - [ ] User exists in database

**Notes:** _____________________________________________

#### Test 2: Duplicate Username
1. [ ] Go to registration page
2. [ ] Try to register with username: `john_doe` (already exists)
3. [ ] Fill other fields with valid data
4. [ ] Submit form
5. [ ] Error message appears: "Username already exists" or similar
6. [ ] NOT redirected (stays on registration page)
7. [ ] User NOT duplicated in database

**Notes:** _____________________________________________

#### Test 3: Empty Fields
1. [ ] Go to registration page
2. [ ] Leave username empty
3. [ ] Fill other fields
4. [ ] Submit form
5. [ ] Error message appears
6. [ ] Form validation works

**Notes:** _____________________________________________

#### Test 4: Invalid Email
1. [ ] Go to registration page
2. [ ] Enter email: `notvalidemail` (no @ sign)
3. [ ] Fill other fields
4. [ ] Submit form
5. [ ] Check what happens (HTML5 validation or server-side?)

**Notes:** _____________________________________________

---

### D. User Login Testing

#### Test 1: Valid Login
1. [ ] Navigate to `/login` or click "Login" button
2. [ ] Form displays with username field
3. [ ] Enter username: `john_doe`
4. [ ] Click "Login" / "Sign In" button
5. [ ] Success message appears
6. [ ] Redirected to `/dashboard`
7. [ ] Username shows in navigation (Welcome, john_doe)
8. [ ] Session cookie created (F12 → Application → Cookies)

**Notes:** _____________________________________________

#### Test 2: Non-existent User
1. [ ] Go to login page
2. [ ] Enter username: `doesnotexist999`
3. [ ] Submit form
4. [ ] Error message appears: "User not found" or similar
5. [ ] NOT logged in
6. [ ] Stays on login page

**Notes:** _____________________________________________

#### Test 3: Empty Username
1. [ ] Go to login page
2. [ ] Leave username empty
3. [ ] Submit form
4. [ ] Error message or validation appears

**Notes:** _____________________________________________

#### Test 4: SQL Injection Attempt
1. [ ] Go to login page
2. [ ] Enter username: `admin' OR '1'='1`
3. [ ] Submit form
4. [ ] Should NOT log in (parameterized queries prevent injection)
5. [ ] No database errors

**Notes:** _____________________________________________

---

### E. Dashboard Testing

**Prerequisites: Login as `john_doe` first**

#### Page Load
- [ ] Dashboard URL: http://127.0.0.1:5000/dashboard
- [ ] Page loads without errors
- [ ] No JavaScript errors in console
- [ ] No 404 errors for CSS/JS files

**Notes:** _____________________________________________

#### Summary Cards/Stats
Check if these display correctly:
- [ ] Total Expenses (This Month)
- [ ] Total Income (This Month)
- [ ] Budget Utilization (percentage)
- [ ] Savings Progress (total or percentage)
- [ ] Numbers look reasonable (not 0 or NaN)

**Notes:** _____________________________________________

#### Charts
- [ ] Chart 1: Expense Trend Chart (line/bar chart)
  - [ ] Chart renders using Chart.js
  - [ ] Shows last 6-12 months
  - [ ] Data points visible
  - [ ] Labels readable
- [ ] Chart 2: Category Distribution (pie/doughnut chart)
  - [ ] Chart renders
  - [ ] Shows expense categories
  - [ ] Percentages shown
  - [ ] Legend displays

**Notes:** _____________________________________________

#### Recent Transactions
- [ ] Shows list of recent expenses (top 5-10)
- [ ] Each item shows: date, category, amount, description
- [ ] Amounts formatted correctly ($XX.XX)
- [ ] Dates formatted correctly

**Notes:** _____________________________________________

#### Navigation Menu
- [ ] All menu items visible (Dashboard, Expenses, Income, Budgets, Goals, Reports)
- [ ] Current page highlighted (Dashboard is active)
- [ ] Clicking other menu items works

**Notes:** _____________________________________________

---

### F. Expenses Page Testing

**Navigate to: http://127.0.0.1:5000/expenses**

#### View Expenses List
- [ ] Page loads successfully
- [ ] Table/list displays expenses
- [ ] Shows correct columns:
  - [ ] Date
  - [ ] Category
  - [ ] Amount
  - [ ] Description
  - [ ] Payment Method
  - [ ] Actions (Edit/Delete buttons)
- [ ] All 367 expenses load (or pagination works)
- [ ] Data is from logged-in user only (john_doe's expenses)

**Notes:** _____________________________________________

#### Add New Expense
1. [ ] Click "Add Expense" button
2. [ ] Form appears (modal or new page)
3. [ ] Form has fields:
   - [ ] Category dropdown (15 options)
   - [ ] Amount input
   - [ ] Date picker
   - [ ] Description textarea
   - [ ] Payment method dropdown (Cash, Credit Card, Debit Card, Online, Bank Transfer)
4. [ ] Fill in test data:
   - Category: Food & Dining
   - Amount: 45.75
   - Date: Today's date
   - Description: "Lunch at restaurant"
   - Payment: Credit Card
5. [ ] Submit form
6. [ ] Success message appears
7. [ ] New expense appears at top of list
8. [ ] Verify in database:
   ```sql
   SELECT * FROM expense WHERE description = 'Lunch at restaurant';
   ```
   - [ ] Expense saved correctly

**Notes:** _____________________________________________

#### Edit Expense
1. [ ] Click "Edit" button on any expense
2. [ ] Edit form appears
3. [ ] Form pre-filled with existing data
4. [ ] Change amount from X to Y
5. [ ] Change description
6. [ ] Submit form
7. [ ] Success message appears
8. [ ] Expense updated in list
9. [ ] Verify in database - changes saved

**Notes:** _____________________________________________

#### Delete Expense
1. [ ] Click "Delete" button on an expense
2. [ ] Confirmation prompt appears ("Are you sure?")
3. [ ] Click "Confirm" / "Yes"
4. [ ] Success message appears
5. [ ] Expense removed from list
6. [ ] Verify in database - expense deleted or soft-deleted

**Notes:** _____________________________________________

#### Filter/Search (if implemented)
- [ ] Filter by category dropdown
- [ ] Select "Food & Dining"
- [ ] Only food expenses show
- [ ] Clear filter - all expenses show again

**Notes:** _____________________________________________

#### Validation Tests
**Test 1: Negative Amount**
1. [ ] Try adding expense with amount: -50
2. [ ] Should show error or prevent submission

**Test 2: Zero Amount**
1. [ ] Try adding expense with amount: 0
2. [ ] Should show error or prevent submission

**Test 3: Empty Required Fields**
1. [ ] Try submitting form with empty category
2. [ ] Should show validation error

**Test 4: Future Date**
1. [ ] Try adding expense dated 1 year in future
2. [ ] Check if accepted or rejected

**Test 5: XSS Attack**
1. [ ] Try adding expense with description: `<script>alert('XSS')</script>`
2. [ ] Submit form
3. [ ] View expense in list
4. [ ] Script should display as text, NOT execute
5. [ ] Check page source - should be HTML-escaped

**Notes:** _____________________________________________

---

### G. Income Page Testing

**Navigate to: http://127.0.0.1:5000/income**

#### View Income List
- [ ] Page loads successfully
- [ ] Table/list displays income records
- [ ] Shows columns:
  - [ ] Date
  - [ ] Source
  - [ ] Amount
  - [ ] Description
  - [ ] Actions
- [ ] Shows 8 income records for john_doe

**Notes:** _____________________________________________

#### Add New Income
1. [ ] Click "Add Income" button
2. [ ] Form appears with fields:
   - [ ] Source (e.g., Salary, Freelance, Investment)
   - [ ] Amount
   - [ ] Date
   - [ ] Description
3. [ ] Fill in test data:
   - Source: "Freelance Work"
   - Amount: 500.00
   - Date: Today
   - Description: "Website development"
4. [ ] Submit form
5. [ ] Success message appears
6. [ ] New income appears in list
7. [ ] Verify in database

**Notes:** _____________________________________________

#### Edit Income
1. [ ] Click "Edit" on an income record
2. [ ] Modify amount
3. [ ] Submit
4. [ ] Verify update saved

**Notes:** _____________________________________________

#### Delete Income
1. [ ] Click "Delete" on an income record
2. [ ] Confirm deletion
3. [ ] Verify income removed

**Notes:** _____________________________________________

---

### H. Budgets Page Testing

**Navigate to: http://127.0.0.1:5000/budgets**

#### View Budgets
- [ ] Page loads successfully
- [ ] Shows 8 budgets for current month
- [ ] Each budget card/row displays:
  - [ ] Category name
  - [ ] Budget amount (limit)
  - [ ] Spent amount (actual expenses)
  - [ ] Remaining amount
  - [ ] Progress bar (visual indicator)
  - [ ] Percentage used
- [ ] Progress bars display correctly:
  - [ ] Green if under 70%
  - [ ] Yellow if 70-90%
  - [ ] Red if over 90%
- [ ] Over-budget budgets highlighted

**Notes:** _____________________________________________

#### Create New Budget
1. [ ] Click "Create Budget" button
2. [ ] Form appears with fields:
   - [ ] Category dropdown
   - [ ] Amount
   - [ ] Month
   - [ ] Year
3. [ ] Fill in test data:
   - Category: Shopping
   - Amount: 300.00
   - Month: 11 (November)
   - Year: 2024
4. [ ] Submit form
5. [ ] Success message appears
6. [ ] New budget appears in list
7. [ ] Progress bar shows based on existing expenses
8. [ ] Verify in database

**Notes:** _____________________________________________

#### Edit Budget
1. [ ] Click "Edit" on a budget
2. [ ] Change amount from X to Y
3. [ ] Submit
4. [ ] Progress bar recalculates
5. [ ] Verify update saved

**Notes:** _____________________________________________

#### Delete Budget
1. [ ] Click "Delete" on a budget
2. [ ] Confirm deletion
3. [ ] Budget removed from list
4. [ ] Verify in database

**Notes:** _____________________________________________

#### Budget Calculation Test
1. [ ] Note a budget's spent amount (e.g., Food: $450 spent)
2. [ ] Go to Expenses page
3. [ ] Add new expense in that category (e.g., $50 Food expense)
4. [ ] Return to Budgets page
5. [ ] Verify spent amount increased ($450 → $500)
6. [ ] Progress bar updated

**Notes:** _____________________________________________

---

### I. Savings Goals Testing

**Navigate to: http://127.0.0.1:5000/goals**

#### View Goals
- [ ] Page loads successfully
- [ ] Shows 5 savings goals
- [ ] Each goal displays:
  - [ ] Goal name
  - [ ] Target amount
  - [ ] Current amount
  - [ ] Remaining amount
  - [ ] Progress bar
  - [ ] Percentage complete
  - [ ] Target date
  - [ ] Priority (High/Medium/Low)
- [ ] Progress bars accurate

**Notes:** _____________________________________________

#### Create New Goal
1. [ ] Click "Create Goal" button
2. [ ] Form appears with fields:
   - [ ] Goal name
   - [ ] Target amount
   - [ ] Current amount (optional, default 0)
   - [ ] Target date
   - [ ] Priority
3. [ ] Fill in test data:
   - Name: "Gaming Console"
   - Target: 500.00
   - Current: 0.00
   - Date: 3 months from now
   - Priority: Low
4. [ ] Submit form
5. [ ] Success message appears
6. [ ] New goal appears in list
7. [ ] Progress bar shows 0%
8. [ ] Verify in database

**Notes:** _____________________________________________

#### Add Contribution to Goal
1. [ ] Click "Add Contribution" on a goal
2. [ ] Form appears with:
   - [ ] Amount field
   - [ ] Date field
3. [ ] Enter contribution:
   - Amount: 100.00
   - Date: Today
4. [ ] Submit
5. [ ] Success message appears
6. [ ] Goal's current amount increases by 100
7. [ ] Progress bar updates
8. [ ] Percentage recalculates
9. [ ] Verify in database (goal_contribution table)

**Notes:** _____________________________________________

#### Edit Goal
1. [ ] Click "Edit" on a goal
2. [ ] Change target amount
3. [ ] Submit
4. [ ] Progress percentage recalculates
5. [ ] Verify update saved

**Notes:** _____________________________________________

#### Delete Goal
1. [ ] Click "Delete" on a goal
2. [ ] Confirm deletion
3. [ ] Goal removed from list
4. [ ] Verify contributions also deleted (cascade)

**Notes:** _____________________________________________

#### Goal Completion Test
1. [ ] Find a goal close to completion (e.g., 90% complete)
2. [ ] Add contribution to reach 100%
3. [ ] Check if goal marked as "Completed" or changes color
4. [ ] Progress bar shows 100%

**Notes:** _____________________________________________

---

### J. Reports Page Testing

**Navigate to: http://127.0.0.1:5000/reports**

#### Page Load
- [ ] Page loads successfully
- [ ] Report selection dropdown visible
- [ ] Date range pickers visible (if applicable)
- [ ] "Generate Report" button visible

**Notes:** _____________________________________________

#### Report 1: Monthly Expenditure Analysis
1. [ ] Select "Monthly Expenditure" from dropdown
2. [ ] Select last 3 months
3. [ ] Click "Generate Report"
4. [ ] Report displays:
   - [ ] Table with months and totals
   - [ ] Chart showing trend over time
   - [ ] Data matches database
5. [ ] Can export/download (if implemented)

**Notes:** _____________________________________________

#### Report 2: Budget Adherence Tracking
1. [ ] Select "Budget Adherence"
2. [ ] Select current month
3. [ ] Generate report
4. [ ] Report shows:
   - [ ] Each budget vs actual spending
   - [ ] Over/under budget status
   - [ ] Visual indicators (colors)
5. [ ] Data matches budgets page

**Notes:** _____________________________________________

#### Report 3: Savings Goal Progress
1. [ ] Select "Savings Progress"
2. [ ] Generate report
3. [ ] Report shows:
   - [ ] All goals with progress
   - [ ] Completion percentages
   - [ ] Time remaining to target date
   - [ ] Visual progress bars

**Notes:** _____________________________________________

#### Report 4: Category Distribution
1. [ ] Select "Category Distribution"
2. [ ] Select date range (last 3 months)
3. [ ] Generate report
4. [ ] Report shows:
   - [ ] Pie/doughnut chart
   - [ ] Percentages per category
   - [ ] Table with amounts
   - [ ] Percentages add up to 100%

**Notes:** _____________________________________________

#### Report 5: Forecasted Savings
1. [ ] Select "Forecasted Savings"
2. [ ] Select forecast period (6 months)
3. [ ] Generate report
4. [ ] Report shows:
   - [ ] Historical average income/expenses
   - [ ] Projected savings per month
   - [ ] Chart showing forecast
   - [ ] Calculations seem reasonable

**Notes:** _____________________________________________

---

### K. Synchronization Testing

#### Manual Sync (if button exists in UI)
1. [ ] Look for "Sync to Oracle" button (dashboard or settings)
2. [ ] Click sync button
3. [ ] Loading indicator appears
4. [ ] Success message after completion
5. [ ] Check Oracle database - new data synced

**Notes:** _____________________________________________

#### Test Sync Script
```powershell
cd d:\DM2_CW
python test_sync_extended.py
```

Expected output:
- [ ] "Connected to SQLite successfully"
- [ ] "Connected to Oracle successfully"
- [ ] "Step 1: Syncing users..."
- [ ] "Step 2: Syncing expenses..."
- [ ] "Step 3: Syncing income..."
- [ ] "Step 4: Syncing budgets..."
- [ ] "Step 5: Syncing savings goals..."
- [ ] "Synchronization completed successfully"
- [ ] Shows total records synced
- [ ] Shows time taken
- [ ] No errors

Verify in Oracle:
```sql
SELECT COUNT(*) FROM FINANCE_EXPENSE;  -- Should match SQLite count
SELECT MAX(sync_date) FROM FINANCE_SYNC_LOG;  -- Should show recent sync
```
- [ ] Counts match SQLite
- [ ] Sync log updated

**Notes:** _____________________________________________

---

### L. Session & Security Testing

#### Session Management
1. [ ] Login to app
2. [ ] Open browser DevTools (F12)
3. [ ] Go to Application → Cookies
4. [ ] Find session cookie
5. [ ] Note the cookie value
6. [ ] Open new incognito/private window
7. [ ] Try accessing /dashboard directly (without login)
8. [ ] Should redirect to login page

**Notes:** _____________________________________________

#### Logout Functionality
1. [ ] While logged in, click "Logout"
2. [ ] Redirected to login page
3. [ ] Success message: "Logged out successfully"
4. [ ] Session cookie deleted (check DevTools)
5. [ ] Try accessing /dashboard
6. [ ] Should redirect to login (not accessible)
7. [ ] Try browser back button
8. [ ] Should still be logged out

**Notes:** _____________________________________________

#### Unauthorized Access Prevention
Without logging in:
- [ ] Try accessing: http://127.0.0.1:5000/dashboard
  - Should redirect to login
- [ ] Try accessing: http://127.0.0.1:5000/expenses
  - Should redirect to login
- [ ] Try accessing: http://127.0.0.1:5000/income
  - Should redirect to login

**Notes:** _____________________________________________

#### User Data Isolation
1. [ ] Login as john_doe
2. [ ] Note expense count (should be ~367)
3. [ ] Logout
4. [ ] Login as jane_smith
5. [ ] Check expenses
6. [ ] Should show jane_smith's expenses only (different from john_doe)
7. [ ] Users cannot see each other's data

**Notes:** _____________________________________________

---

### M. Error Handling Testing

#### Database Connection Error (SQLite)
1. [ ] Stop Flask app
2. [ ] Rename `finance_local.db` to `finance_local.db.bak`
3. [ ] Start Flask app
4. [ ] Try accessing expenses page
5. [ ] Should show error message (not crash)
6. [ ] Should be user-friendly error
7. [ ] Restore database (rename back)

**Notes:** _____________________________________________

#### 404 Error
- [ ] Try accessing: http://127.0.0.1:5000/nonexistent
- [ ] Should show 404 page (not crash)
- [ ] 404 page should be styled
- [ ] Should have link back to home

**Notes:** _____________________________________________

#### Invalid Form Submission
1. [ ] Go to add expense form
2. [ ] Fill in category but leave amount empty
3. [ ] Submit
4. [ ] Should show validation error
5. [ ] Should NOT crash or show Python error

**Notes:** _____________________________________________

---

## PART 3: UI/UX TESTING 🎨

### A. Responsive Design

#### Desktop (1920×1080)
- [ ] Open app in full screen
- [ ] All pages display correctly
- [ ] No horizontal scrolling
- [ ] Charts fit properly
- [ ] Tables don't overflow
- [ ] Navigation bar looks good

**Notes:** _____________________________________________

#### Laptop (1366×768)
- [ ] Resize browser to 1366×768
- [ ] All elements still visible
- [ ] No overlapping
- [ ] Text readable
- [ ] Forms usable

**Notes:** _____________________________________________

#### Tablet (768×1024) - Simulate with DevTools
1. [ ] Open DevTools (F12)
2. [ ] Click device toggle (Ctrl+Shift+M)
3. [ ] Select "iPad" or set 768×1024
4. [ ] Test all pages:
   - [ ] Navigation adapts (hamburger menu?)
   - [ ] Tables responsive or scrollable
   - [ ] Forms still usable
   - [ ] Charts resize

**Notes:** _____________________________________________

#### Mobile (375×667) - iPhone SE simulation
1. [ ] Set DevTools to 375×667 (iPhone SE)
2. [ ] Test all pages:
   - [ ] Navigation collapses to hamburger menu
   - [ ] Text is readable (not too small)
   - [ ] Buttons are tap-able
   - [ ] Forms work on small screen
   - [ ] Charts responsive
   - [ ] Tables don't break layout

**Notes:** _____________________________________________

---

### B. Browser Compatibility

#### Google Chrome
- [ ] All features work
- [ ] No console errors
- [ ] Charts render correctly
- [ ] Forms submit properly

**Notes:** _____________________________________________

#### Mozilla Firefox
- [ ] All features work
- [ ] No console errors
- [ ] Charts render correctly
- [ ] Forms submit properly

**Notes:** _____________________________________________

#### Microsoft Edge
- [ ] All features work
- [ ] No console errors
- [ ] Charts render correctly
- [ ] Forms submit properly

**Notes:** _____________________________________________

---

### C. Visual & Accessibility

#### Visual Check
- [ ] All fonts load correctly (no fallback fonts)
- [ ] Bootstrap Icons display (not boxes)
- [ ] Colors are consistent across pages
- [ ] Buttons have hover effects
- [ ] Links change color on hover
- [ ] Forms have proper labels
- [ ] Error messages are red/visible
- [ ] Success messages are green/visible
- [ ] No broken images
- [ ] No overlapping text
- [ ] Proper spacing/padding

**Notes:** _____________________________________________

#### Navigation
- [ ] All nav links work
- [ ] Active page highlighted in nav
- [ ] Logo/title is clickable (goes to home/dashboard)
- [ ] Breadcrumbs work (if implemented)
- [ ] Browser back button works correctly
- [ ] Can navigate from any page to any other page

**Notes:** _____________________________________________

---

## PART 4: PERFORMANCE TESTING ⚡

### A. Page Load Times

Use browser DevTools → Network tab

- [ ] Dashboard loads in < 2 seconds
- [ ] Expenses page loads in < 2 seconds
- [ ] Reports generate in < 5 seconds
- [ ] No requests timeout

**Notes:** _____________________________________________

### B. Large Dataset

#### Test with More Data
```powershell
# Run populate script again to add more data
cd d:\DM2_CW\webapp
python populate_sample_data.py
```

After adding more data:
- [ ] Expenses page still loads fast
- [ ] Dashboard charts still render
- [ ] Reports still generate
- [ ] No performance degradation
- [ ] Pagination works (if implemented)

**Notes:** _____________________________________________

---

## PART 5: DATA INTEGRITY TESTING 🔒

### A. Constraint Testing

#### Primary Key
```sql
-- Try inserting duplicate user_id (should fail)
INSERT INTO user (user_id, username, email, full_name) 
VALUES (1, 'duplicate', 'dup@test.com', 'Duplicate User');
```
- [ ] Insert fails with constraint error

**Notes:** _____________________________________________

#### Foreign Key
```sql
-- Try inserting expense with invalid category_id (should fail)
INSERT INTO expense (user_id, category_id, amount, expense_date, description, payment_method)
VALUES (1, 999, 100, date('now'), 'Test', 'Cash');
```
- [ ] Insert fails with foreign key error

**Notes:** _____________________________________________

#### NOT NULL
```sql
-- Try inserting expense with NULL amount (should fail)
INSERT INTO expense (user_id, category_id, amount, expense_date, description, payment_method)
VALUES (1, 1, NULL, date('now'), 'Test', 'Cash');
```
- [ ] Insert fails with NOT NULL error

**Notes:** _____________________________________________

#### CHECK Constraint
```sql
-- Try inserting expense with invalid payment_method (should fail)
INSERT INTO expense (user_id, category_id, amount, expense_date, description, payment_method)
VALUES (1, 1, 100, date('now'), 'Test', 'Bitcoin');
```
- [ ] Insert fails with CHECK constraint error

**Notes:** _____________________________________________

---

### B. Cascade Operations

#### Delete User (if allowed)
1. [ ] Create a test user
2. [ ] Add expenses for that user
3. [ ] Delete the user
4. [ ] Check if user's expenses are:
   - [ ] Deleted (CASCADE DELETE), or
   - [ ] Prevented (RESTRICT), or
   - [ ] Set to NULL (SET NULL)
5. [ ] Behavior matches design

**Notes:** _____________________________________________

---

## PART 6: COMPLETE USER JOURNEYS 🚶

### Journey 1: New User Complete Flow

**Simulate brand new user:**

1. [ ] Open app (logged out)
2. [ ] Click "Register"
3. [ ] Fill registration form
4. [ ] Submit - account created
5. [ ] Redirected to login
6. [ ] Login with new username
7. [ ] See dashboard (empty, no data)
8. [ ] Click "Add Expense"
9. [ ] Add first expense
10. [ ] See expense in list
11. [ ] Click "Budgets"
12. [ ] Create first budget
13. [ ] See budget with 0% used
14. [ ] Click "Goals"
15. [ ] Create first savings goal
16. [ ] Add contribution to goal
17. [ ] See progress increase
18. [ ] Click "Reports"
19. [ ] Generate category distribution report
20. [ ] See report (minimal data)
21. [ ] Click "Logout"
22. [ ] Successfully logged out

**Everything should work smoothly!**

**Notes:** _____________________________________________

---

### Journey 2: Existing User Flow

**Test with john_doe (has 367 expenses):**

1. [ ] Login as john_doe
2. [ ] Dashboard loads with data
   - [ ] Charts show expense trends
   - [ ] Stats show correct numbers
3. [ ] Click "Expenses"
4. [ ] See full list of 367 expenses
5. [ ] Filter by category "Food & Dining"
6. [ ] See only food expenses
7. [ ] Click "Add Expense"
8. [ ] Add new expense
9. [ ] New expense appears at top
10. [ ] Click "Edit" on an expense
11. [ ] Modify amount
12. [ ] Save - expense updated
13. [ ] Click "Budgets"
14. [ ] See 8 budgets with progress bars
15. [ ] Some budgets over 100% (red)
16. [ ] Click "Goals"
17. [ ] See 5 goals at various percentages
18. [ ] Add $50 contribution to "Emergency Fund"
19. [ ] Progress increases
20. [ ] Click "Reports"
21. [ ] Generate "Monthly Expenditure" report
22. [ ] See 3 months of data
23. [ ] Chart displays correctly
24. [ ] Generate "Budget Adherence" report
25. [ ] See over/under budget status
26. [ ] Logout

**Everything works with real data!**

**Notes:** _____________________________________________

---

## 📊 TESTING SUMMARY

### Statistics

**Total Tests Performed:** ______ / ~200  
**Tests Passed:** ______  
**Tests Failed:** ______  
**Tests Skipped:** ______  

---

### Critical Issues Found (MUST FIX)

Priority: 🔴 High

```
1. ___________________________________________________________
   Impact: ___________________________________________________
   Steps to reproduce: _______________________________________
   
2. ___________________________________________________________
   Impact: ___________________________________________________
   Steps to reproduce: _______________________________________
   
3. ___________________________________________________________
   Impact: ___________________________________________________
   Steps to reproduce: _______________________________________
```

---

### Medium Issues Found (SHOULD FIX)

Priority: 🟡 Medium

```
1. ___________________________________________________________
   Impact: ___________________________________________________
   
2. ___________________________________________________________
   Impact: ___________________________________________________
```

---

### Minor Issues / Improvements (NICE TO HAVE)

Priority: 🟢 Low

```
1. ___________________________________________________________
2. ___________________________________________________________
3. ___________________________________________________________
```

---

### Features Working Well ✅

**Highlight what works great:**

```
1. ___________________________________________________________
2. ___________________________________________________________
3. ___________________________________________________________
```

---

## ✅ FINAL SIGN-OFF

**Tested By:** _____________________________  
**Date Completed:** _____________________________  
**Time Spent:** _______ hours  

**Overall Assessment:**
- [ ] ✅ PASS - Ready for submission
- [ ] ⚠️ PASS WITH MINOR ISSUES - Can submit, document known issues
- [ ] ❌ FAIL - Critical bugs found, needs fixes before submission

**Confidence Level:** _____ / 10

**Additional Comments:**
```
________________________________________________________________
________________________________________________________________
________________________________________________________________
```

---

## 📸 SCREENSHOTS TO CAPTURE

After testing, capture these for final report:

- [ ] Login page
- [ ] Registration page
- [ ] Dashboard with charts
- [ ] Expenses page with data
- [ ] Add expense form
- [ ] Income page
- [ ] Budgets page with progress bars
- [ ] Savings goals page
- [ ] Reports page - Monthly expenditure chart
- [ ] Reports page - Category distribution pie chart
- [ ] SQL Developer - Oracle tables with data
- [ ] SQL Developer - PL/SQL package status (VALID)
- [ ] DB Browser - SQLite database structure
- [ ] DB Browser - Sample data in expense table
- [ ] Terminal - Sync script output

---

**🎯 TESTING COMPLETE!**

**Next Steps:**
1. Fix all critical issues
2. Document known minor issues
3. Capture screenshots
4. Update final report
5. Submit! 🚀

---

**Good luck! Test thoroughly! 🧪✨**
