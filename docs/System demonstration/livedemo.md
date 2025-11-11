# 🎬 LIVE DEMONSTRATION GUIDE
## Personal Finance Management System - Complete Walkthrough

**Purpose**: Step-by-step demonstration with test data and database validation  
**Duration**: 15-20 minutes  
**Date**: November 11, 2025

---

## 📋 TABLE OF CONTENTS

1. [Setup & Preparation](#1-setup--preparation)
2. [User Registration](#2-user-registration)
3. [User Login](#3-user-login)
4. [Add Income](#4-add-income)
5. [Add Expense](#5-add-expense)
6. [Create Budget](#6-create-budget)
7. [Create Savings Goal](#7-create-savings-goal)
8. [Add Goal Contribution](#8-add-goal-contribution)
9. [View Dashboard](#9-view-dashboard)
10. [Synchronization](#10-synchronization)
11. [Generate PL/SQL Report](#11-generate-plsql-report)
12. [Soft Delete Demo](#12-soft-delete-demo)
13. [Database Verification](#13-database-verification)

---

## 1. SETUP & PREPARATION

### **Prerequisites**

✅ **Start Flask Application**
```bash
cd D:\DM2_CW\webapp
python app.py
```

✅ **Open Browser**
- URL: `http://localhost:5000`

✅ **Open DB Browser for SQLite**
- File: `D:\DM2_CW\sqlite\finance_local.db`

✅ **Open Oracle SQL Developer** (Optional)
- Connection: `172.20.10.4:1521/xe`
- User: Your Oracle username

---

## 2. USER REGISTRATION

### **📝 Instructions**

1. Navigate to homepage
2. Click **"Register"** button
3. Fill registration form
4. Submit and verify account created

### **🧪 Test Data**

```
Username:       viva_demo
Email:          viva.demo@example.com
Full Name:      Viva Demo User
Password:       Demo123!
Confirm Password: Demo123!
```

### **✅ Expected Result**

- Success message: "Registration successful! Please login."
- Redirect to login page

### **🔍 SQLite Validation Queries**

```sql
-- Check user was created
SELECT user_id, username, email, full_name
FROM user 
WHERE username = 'viva_demo';

-- Expected: 1 record with viva_demo user
```

### **🔍 Oracle Validation Queries**

```sql
-- After first sync, check user in Oracle
SELECT user_id, username, email, full_name
FROM finance_user 
WHERE username = 'viva_demo';

-- Expected: Same user data as SQLite
```

---

## 3. USER LOGIN

### **📝 Instructions**

1. Enter username and password
2. Click **"Login"** button
3. Verify redirect to dashboard

### **🧪 Test Data**

```
Username: viva_demo
Password: Demo123!
```

### **✅ Expected Result**

- Success message: "Welcome back, Viva Demo User!"
- Redirect to dashboard
- Session created (check navbar shows username)

### **🔍 Session Validation**

```python
# In Flask app console, you should see:
# "User viva_demo logged in successfully"
```

### **🔍 SQLite Validation Queries**

```sql
-- Verify user logged in successfully
SELECT user_id, username, full_name
FROM user 
WHERE username = 'viva_demo';

-- Note the user_id for subsequent queries
```

---

## 4. ADD INCOME

### **📝 Instructions**

1. Navigate to **Income** page
2. Click **"Add Income"** button
3. Fill income form
4. Submit and verify income appears in list

### **🧪 Test Data #1 - Salary**

```
Income Source:  Salary
Amount:         75000
Date:           2025-11-01
Description:    November salary payment
```

### **🧪 Test Data #2 - Freelance**

```
Income Source:  Freelance
Amount:         25000
Date:           2025-11-05
Description:    Web development project
```

### **✅ Expected Result**

- Success message: "Income added successfully!"
- Income appears in income list table
- Total income updates

### **🔍 SQLite Validation Queries**

```sql
-- Check income records created
SELECT income_id, income_source, amount, income_date, description
FROM income 
WHERE user_id = (SELECT user_id FROM user WHERE username = 'viva_demo')
ORDER BY income_date DESC;

-- Expected: 2 records (Salary: ₹75,000, Freelance: ₹25,000)
```

---

## 5. ADD EXPENSE

### **📝 Instructions**

1. Navigate to **Expenses** page
2. Click **"Add Expense"** button
3. Fill expense form
4. Submit and verify expense appears

### **🧪 Test Data #1 - Food**

```
Category:       Food & Dining
Amount:         3500
Date:           2025-11-02
Description:    Groceries for the week
Payment Method: Credit Card
```

### **🧪 Test Data #2 - Transportation**

```
Category:       Transportation
Amount:         2000
Date:           2025-11-03
Description:    Fuel for car
Payment Method: Cash
```

### **🧪 Test Data #3 - Entertainment**

```
Category:       Entertainment
Amount:         1500
Date:           2025-11-06
Description:    Movie tickets
Payment Method: Debit Card
```

### **✅ Expected Result**

- Success message: "Expense added successfully!"
- Expenses appear in expense list
- Recent expenses show on dashboard

### **🔍 SQLite Validation Queries**

```sql
-- Check expense records
SELECT c.category_name, e.amount, e.expense_date, e.description
FROM expense e
JOIN category c ON e.category_id = c.category_id
WHERE e.user_id = (SELECT user_id FROM user WHERE username = 'viva_demo')
ORDER BY e.expense_date DESC;

-- Expected: 3 records (Food: ₹3,500, Transportation: ₹2,000, Entertainment: ₹1,500)

-- Verify total expenses
SELECT SUM(amount) as total_expenses
FROM expense
WHERE user_id = (SELECT user_id FROM user WHERE username = 'viva_demo');

-- Expected: ₹7,000
```

---

## 6. CREATE BUDGET

### **📝 Instructions**

1. Navigate to **Budgets** page
2. Click **"Add Budget"** button
3. Fill budget form
4. Submit and verify budget appears

### **🧪 Test Data #1 - Food Budget**

```
Category:       Food & Dining
Budget Amount:  15000
Start Date:     2025-11-01
End Date:       2025-11-30
```

### **🧪 Test Data #2 - Transportation Budget**

```
Category:       Transportation
Budget Amount:  10000
Start Date:     2025-11-01
End Date:       2025-11-30
```

### **✅ Expected Result**

- Success message: "Budget created successfully!"
- Budgets appear with progress bars
- Utilization percentages calculated:
  - Food: 23.3% (3500/15000)
  - Transportation: 20% (2000/10000)

### **🔍 SQLite Validation Queries**

```sql
-- Check budget records
SELECT c.category_name, b.budget_amount, b.start_date, b.end_date
FROM budget b
JOIN category c ON b.category_id = c.category_id
WHERE b.user_id = (SELECT user_id FROM user WHERE username = 'viva_demo')
ORDER BY b.start_date DESC;

-- Expected: 2 budgets (Food: ₹15,000, Transportation: ₹10,000)

-- Check budget utilization
SELECT c.category_name,
       b.budget_amount,
       COALESCE(SUM(e.amount), 0) as spent,
       ROUND(COALESCE(SUM(e.amount), 0) * 100.0 / b.budget_amount, 2) as utilization_pct
FROM budget b
JOIN category c ON b.category_id = c.category_id
LEFT JOIN expense e ON e.category_id = b.category_id 
    AND e.user_id = b.user_id
    AND e.expense_date BETWEEN b.start_date AND b.end_date
WHERE b.user_id = (SELECT user_id FROM user WHERE username = 'viva_demo')
GROUP BY c.category_name, b.budget_amount;

-- Expected: Food 23.33%, Transportation 20%
```

---

## 7. CREATE SAVINGS GOAL

### **📝 Instructions**

1. Navigate to **Goals** page
2. Click **"Add Goal"** button
3. Fill goal form
4. Submit and verify goal appears

### **🧪 Test Data #1 - Emergency Fund**

```
Goal Name:      Emergency Fund
Target Amount:  100000
Deadline:       2026-06-30
Description:    6 months of expenses
Priority:       High
Status:         Active
```

### **🧪 Test Data #2 - Vacation Fund**

```
Goal Name:      Dream Vacation
Target Amount:  50000
Deadline:       2026-03-31
Description:    Family trip to Maldives
Priority:       Medium
Status:         Active
```

### **✅ Expected Result**

- Success message: "Savings goal created successfully!"
- Goals appear with progress bars (0% initially)
- Target dates displayed

### **🔍 SQLite Validation Queries**

```sql
-- Check savings goal records
SELECT goal_name, target_amount, current_amount, deadline, priority, status
FROM savings_goal
WHERE user_id = (SELECT user_id FROM user WHERE username = 'viva_demo')
ORDER BY created_at DESC;

-- Expected: 2 goals (Emergency Fund: ₹100,000, Dream Vacation: ₹50,000)
-- current_amount = 0 (no contributions yet)
```

---

## 8. ADD GOAL CONTRIBUTION

### **📝 Instructions**

1. On **Goals** page, find a goal
2. Click **"Add Contribution"** button
3. Fill contribution form
4. Submit and verify progress updates

### **🧪 Test Data #1 - Emergency Fund Contribution**

```
Goal:           Emergency Fund
Amount:         10000
Date:           2025-11-07
Description:    Initial contribution
```

### **🧪 Test Data #2 - Vacation Contribution**

```
Goal:           Dream Vacation
Amount:         5000
Date:           2025-11-08
Description:    First installment
```

### **✅ Expected Result**

- Success message: "Contribution added successfully!"
- Goal current_amount updates
- Progress percentage updates:
  - Emergency Fund: 10% (10000/100000)
  - Dream Vacation: 10% (5000/50000)

### **🔍 SQLite Validation Queries**

```sql
-- Check contributions
SELECT sg.goal_name, sc.contribution_amount, sc.contribution_date
FROM savings_contribution sc
JOIN savings_goal sg ON sc.goal_id = sg.goal_id
WHERE sg.user_id = (SELECT user_id FROM user WHERE username = 'viva_demo')
ORDER BY sc.contribution_date DESC;

-- Expected: 2 contributions (₹10,000 and ₹5,000)

-- Verify goal progress updated
SELECT goal_name, target_amount, current_amount,
       ROUND(current_amount * 100.0 / target_amount, 2) as progress_pct
FROM savings_goal
WHERE user_id = (SELECT user_id FROM user WHERE username = 'viva_demo');

-- Expected: Emergency Fund 10%, Dream Vacation 10%
```

---

## 9. VIEW DASHBOARD

### **📝 Instructions**

1. Navigate to **Dashboard** page
2. Observe all summary cards
3. Check Chart.js visualizations
4. Verify recent transactions

### **✅ Expected Result**

**Financial Summary Cards:**
- **Total Income**: ₹100,000 (75,000 + 25,000)
- **Total Expenses**: ₹7,000 (3,500 + 2,000 + 1,500)
- **Net Savings**: ₹93,000 (100,000 - 7,000)
- **Savings Rate**: 93% (93,000 / 100,000 × 100)

**Budget Overview:**
- Food & Dining: 23.3% utilized
- Transportation: 20% utilized

**Goals Overview:**
- Emergency Fund: 10% complete
- Dream Vacation: 10% complete

**Chart:**
- Line chart showing income vs expenses for November

**Recent Transactions:**
- Last 5 expenses displayed

### **🔍 SQLite Validation Queries**

```sql
-- Verify dashboard calculations
SELECT 
    (SELECT SUM(amount) FROM income 
     WHERE user_id = (SELECT user_id FROM user WHERE username = 'viva_demo')) as total_income,
       
    (SELECT SUM(amount) FROM expense 
     WHERE user_id = (SELECT user_id FROM user WHERE username = 'viva_demo')) as total_expenses;

-- Expected: Income = ₹100,000, Expenses = ₹7,000, Net Savings = ₹93,000
```

---

## 10. SYNCHRONIZATION

### **📝 Instructions**

1. Navigate to **Sync** page
2. Observe pending sync count (should show records waiting)
3. Click **"Sync Now"** button
4. Watch sync process
5. Verify success message

### **✅ Expected Result**

- Sync status shows: "Syncing..."
- Progress indicator appears
- Success message: "Synchronization completed successfully!"
- Sync log entry created
- Duration: ~0.20 seconds
- Records synced:
  - 1 User
  - 2 Income records
  - 3 Expenses
  - 2 Budgets
  - 2 Goals
  - 2 Contributions
  - **Total: 12 records**

### **🔍 SQLite Validation Queries (BEFORE Sync)**

```sql
-- Check records pending sync
SELECT 
    (SELECT COUNT(*) FROM income WHERE user_id = (SELECT user_id FROM user WHERE username = 'viva_demo') AND is_synced = 0) as income_pending,
    (SELECT COUNT(*) FROM expense WHERE user_id = (SELECT user_id FROM user WHERE username = 'viva_demo') AND is_synced = 0) as expense_pending,
    (SELECT COUNT(*) FROM budget WHERE user_id = (SELECT user_id FROM user WHERE username = 'viva_demo') AND is_synced = 0) as budget_pending,
    (SELECT COUNT(*) FROM savings_goal WHERE user_id = (SELECT user_id FROM user WHERE username = 'viva_demo') AND is_synced = 0) as goal_pending;

-- Expected: All counts > 0 (not synced yet)
```

### **🔍 SQLite Validation Queries (AFTER Sync)**

```sql
-- Check all records are now synced
SELECT 
    (SELECT COUNT(*) FROM income WHERE user_id = (SELECT user_id FROM user WHERE username = 'viva_demo') AND is_synced = 1) as income_synced,
    (SELECT COUNT(*) FROM expense WHERE user_id = (SELECT user_id FROM user WHERE username = 'viva_demo') AND is_synced = 1) as expense_synced,
    (SELECT COUNT(*) FROM budget WHERE user_id = (SELECT user_id FROM user WHERE username = 'viva_demo') AND is_synced = 1) as budget_synced,
    (SELECT COUNT(*) FROM savings_goal WHERE user_id = (SELECT user_id FROM user WHERE username = 'viva_demo') AND is_synced = 1) as goal_synced;

-- Expected: All counts should match total records (everything synced)

-- Check sync log
SELECT records_synced, sync_status, sync_type
FROM sync_log
ORDER BY sync_log_id DESC
LIMIT 1;

-- Expected: sync_status = 'Success', records_synced ≈ 12
```

### **🔍 Oracle Validation Queries (AFTER Sync)**

```sql
-- Verify income synced
SELECT income_source, amount
FROM finance_income
WHERE user_id = (SELECT user_id FROM finance_user WHERE username = 'viva_demo');
-- Expected: 2 records (Salary ₹75,000, Freelance ₹25,000)

-- Verify expenses synced
SELECT c.category_name, e.amount
FROM finance_expense e
JOIN finance_category c ON e.category_id = c.category_id
WHERE e.user_id = (SELECT user_id FROM finance_user WHERE username = 'viva_demo');
-- Expected: 3 records (Food ₹3,500, Transportation ₹2,000, Entertainment ₹1,500)

-- Verify budgets synced
SELECT c.category_name, b.budget_amount
FROM finance_budget b
JOIN finance_category c ON b.category_id = c.category_id
WHERE b.user_id = (SELECT user_id FROM finance_user WHERE username = 'viva_demo');
-- Expected: 2 budgets (Food ₹15,000, Transportation ₹10,000)

-- Verify goals synced
SELECT goal_name, target_amount, current_amount
FROM finance_savings_goal
WHERE user_id = (SELECT user_id FROM finance_user WHERE username = 'viva_demo');
-- Expected: 2 goals with contributions updated
```

---

## 11. GENERATE PL/SQL REPORT

### **📝 Instructions**

1. Navigate to **Reports** page
2. Select report type: **"Monthly Expenditure Analysis"**
3. Fill report parameters
4. Click **"Generate Report"**
5. Review formatted output

### **🧪 Test Data**

```
Report Type:    Monthly Expenditure Analysis
User ID:        (Use the user_id for viva_demo from Oracle)
Year:           2025
Month:          11 (November)
```

### **✅ Expected Result**

**Report Output:**

```
============================================================
MONTHLY EXPENDITURE ANALYSIS
============================================================
User: viva_demo
Period: November 2025

FINANCIAL SUMMARY:
------------------------------------------------------------
Total Income:                    ₹100,000.00
Total Expenses:                  ₹7,000.00
Net Savings:                     ₹93,000.00
Savings Rate:                    93.00%

TRANSACTION STATISTICS:
------------------------------------------------------------
Number of Income Transactions:   2
Number of Expense Transactions:  3
Average Expense:                 ₹2,333.33
Maximum Single Expense:          ₹3,500.00

CATEGORY-WISE BREAKDOWN:
------------------------------------------------------------
1. Food & Dining                 ₹3,500.00    (50.00%)
2. Transportation                ₹2,000.00    (28.57%)
3. Entertainment                 ₹1,500.00    (21.43%)
------------------------------------------------------------
```

### **🔍 Oracle Report Queries (Manual Execution)**

```sql
-- Call the PL/SQL report procedure
SET SERVEROUTPUT ON SIZE 1000000;

DECLARE
    v_user_id NUMBER;
BEGIN
    SELECT user_id INTO v_user_id FROM finance_user WHERE username = 'viva_demo';
    
    pkg_finance_reports.display_monthly_expenditure(
        p_user_id => v_user_id,
        p_year => 2025,
        p_month => 11
    );
END;
/

-- Expected: Report showing income ₹100,000, expenses ₹7,000, breakdown by category
```

---

## 12. SOFT DELETE DEMO

### **📝 Instructions**

1. Navigate to **Expenses** page
2. Find one expense (e.g., Entertainment ₹1,500)
3. Click **"Delete"** button
4. Confirm deletion
5. Verify expense disappears from UI
6. Check database - record still exists!

### **🧪 Test Scenario**

```
Action: Delete "Entertainment - Movie tickets - ₹1,500"
```

### **✅ Expected Result**

- Confirmation dialog appears
- Success message: "Expense deleted successfully!"
- Expense disappears from expenses list
- Total expenses updates: ₹5,500 (was ₹7,000)
- Dashboard updates automatically

### **🔍 SQLite Validation Queries (AFTER Delete)**

```sql
-- Check expense is soft deleted
SELECT amount, description, is_deleted
FROM expense
WHERE user_id = (SELECT user_id FROM user WHERE username = 'viva_demo')
  AND description LIKE '%Movie tickets%';

-- Expected: is_deleted = 1 (marked as deleted, not physically removed)

-- Verify active expenses only
SELECT SUM(amount) as total_active
FROM expense
WHERE user_id = (SELECT user_id FROM user WHERE username = 'viva_demo')
  AND (is_deleted = 0 OR is_deleted IS NULL);

-- Expected: ₹5,500 (excluding the deleted ₹1,500)
```

### **🔍 Sync the Deletion**

```
1. Navigate to Sync page
2. Click "Sync Now"
3. Soft delete syncs to Oracle with is_deleted = 1
```

### **🔍 Oracle Validation Queries (AFTER Sync)**

```sql
-- Verify soft delete synced to Oracle
SELECT amount, description, is_deleted
FROM finance_expense
WHERE user_id = (SELECT user_id FROM finance_user WHERE username = 'viva_demo')
  AND description LIKE '%Movie tickets%';

-- Expected: is_deleted = 1 (same as SQLite)

-- Verify active expenses match
SELECT SUM(amount) as total_active
FROM finance_expense
WHERE user_id = (SELECT user_id FROM finance_user WHERE username = 'viva_demo')
  AND (is_deleted = 0 OR is_deleted IS NULL);

-- Expected: ₹5,500 (matches SQLite exactly)
```

---

## 13. DATABASE VERIFICATION

### **📝 Instructions**

Comprehensive verification of data consistency between SQLite and Oracle.

### **🔍 Complete Data Audit**

#### **SQLite Summary**

```sql
-- Complete summary for viva_demo user
SELECT 
    (SELECT COUNT(*) FROM income WHERE user_id = (SELECT user_id FROM user WHERE username = 'viva_demo')) as income_count,
    (SELECT SUM(amount) FROM income WHERE user_id = (SELECT user_id FROM user WHERE username = 'viva_demo')) as total_income,
    (SELECT COUNT(*) FROM expense WHERE user_id = (SELECT user_id FROM user WHERE username = 'viva_demo') AND (is_deleted = 0 OR is_deleted IS NULL)) as active_expenses,
    (SELECT SUM(amount) FROM expense WHERE user_id = (SELECT user_id FROM user WHERE username = 'viva_demo') AND (is_deleted = 0 OR is_deleted IS NULL)) as total_expenses,
    (SELECT COUNT(*) FROM budget WHERE user_id = (SELECT user_id FROM user WHERE username = 'viva_demo')) as budget_count,
    (SELECT COUNT(*) FROM savings_goal WHERE user_id = (SELECT user_id FROM user WHERE username = 'viva_demo')) as goal_count;

-- Expected: Income 2/₹100,000, Expenses 2/₹5,500, Budgets 2, Goals 2
```

#### **Oracle Summary**

```sql
-- Complete summary for viva_demo user in Oracle
SELECT 
    (SELECT COUNT(*) FROM finance_income WHERE user_id = (SELECT user_id FROM finance_user WHERE username = 'viva_demo')) as income_count,
    (SELECT SUM(amount) FROM finance_income WHERE user_id = (SELECT user_id FROM finance_user WHERE username = 'viva_demo')) as total_income,
    (SELECT COUNT(*) FROM finance_expense WHERE user_id = (SELECT user_id FROM finance_user WHERE username = 'viva_demo') AND (is_deleted = 0 OR is_deleted IS NULL)) as active_expenses,
    (SELECT SUM(amount) FROM finance_expense WHERE user_id = (SELECT user_id FROM finance_user WHERE username = 'viva_demo') AND (is_deleted = 0 OR is_deleted IS NULL)) as total_expenses
FROM dual;

-- Expected: EXACT SAME as SQLite (proves sync working!)
```

#### **Consistency Check**

```sql
-- SQLite: Verify everything is synced
SELECT 
    (SELECT COUNT(*) FROM income WHERE user_id = (SELECT user_id FROM user WHERE username = 'viva_demo') AND is_synced = 0) as income_pending,
    (SELECT COUNT(*) FROM expense WHERE user_id = (SELECT user_id FROM user WHERE username = 'viva_demo') AND is_synced = 0) as expense_pending,
    (SELECT COUNT(*) FROM budget WHERE user_id = (SELECT user_id FROM user WHERE username = 'viva_demo') AND is_synced = 0) as budget_pending,
    (SELECT COUNT(*) FROM savings_goal WHERE user_id = (SELECT user_id FROM user WHERE username = 'viva_demo') AND is_synced = 0) as goal_pending;

-- Expected: All 0 (everything synced)
```

---

## 📊 EXPECTED FINAL STATE

### **User Account**
- ✅ Username: viva_demo
- ✅ Email: viva.demo@example.com
- ✅ Password: Hashed with PBKDF2-SHA256

### **Financial Data (Active)**
| Entity | Count | Total Amount |
|--------|-------|--------------|
| Income | 2 | ₹100,000 |
| Expense (Active) | 2 | ₹5,500 |
| Expense (Deleted) | 1 | ₹1,500 |
| Budget | 2 | ₹25,000 |
| Savings Goal | 2 | Target: ₹150,000, Current: ₹15,000 |
| Contribution | 2 | ₹15,000 |

### **Dashboard Metrics**
- **Total Income**: ₹100,000
- **Total Expenses**: ₹5,500
- **Net Savings**: ₹94,500
- **Savings Rate**: 94.5%

### **Budget Utilization**
- Food & Dining: 23.3% (₹3,500 / ₹15,000)
- Transportation: 20% (₹2,000 / ₹10,000)

### **Goal Progress**
- Emergency Fund: 10% (₹10,000 / ₹100,000)
- Dream Vacation: 10% (₹5,000 / ₹50,000)

### **Synchronization**
- ✅ All records synced (is_synced = 1)
- ✅ SQLite and Oracle data match exactly
- ✅ Soft delete propagated to both databases
- ✅ Sync log created with success status

---

## 🎯 KEY TALKING POINTS DURING DEMO

### **1. Dual-Database Architecture**
> "Notice we're using SQLite for local operations - fast and offline-capable. After sync, the exact same data exists in Oracle for advanced reporting."

### **2. Soft Delete**
> "When I delete this expense, watch - it disappears from the UI, but the record still exists in the database with is_deleted=1. This enables data recovery and allows the deletion to sync to Oracle."

### **3. Triggers**
> "I didn't manually set created_at or fiscal_year - triggers automatically calculated these. The fiscal_month is 8 because my fiscal year starts in April, so November is the 8th month."

### **4. Synchronization Speed**
> "Notice the sync completed in 0.20 seconds for 12 records. I use batch operations and connection pooling for efficiency."

### **5. PL/SQL Reports**
> "This report is generated by Oracle PL/SQL stored procedure. It uses cursors, GROUP BY aggregations, and CASE statements to calculate category percentages."

### **6. Data Consistency**
> "Let me run these queries in both databases - you'll see the counts and totals match exactly. This proves bidirectional synchronization is working perfectly."

### **7. Security**
> "The password is hashed with PBKDF2-SHA256 with 600,000 iterations. All queries use parameterized statements to prevent SQL injection."

### **8. Performance**
> "I have 28 strategic indexes. Watch how fast this complex join query executes - about 6ms. Without indexes, it would take 145ms."

---

## ✅ DEMO COMPLETION CHECKLIST

- [ ] User registration successful
- [ ] Login working with session management
- [ ] Income records created and visible
- [ ] Expense records created and visible
- [ ] Budgets created with progress bars
- [ ] Savings goals created
- [ ] Contributions added and goals updated
- [ ] Dashboard showing correct calculations
- [ ] Synchronization completed successfully
- [ ] Oracle database has matching data
- [ ] PL/SQL report generated correctly
- [ ] Soft delete demonstrated
- [ ] Database consistency verified

---

## 🎬 DEMO SCRIPT SUMMARY

**Time: 15-20 minutes**

1. ⏱️ **Registration & Login** (2 min)
2. ⏱️ **Add Financial Data** (3 min)
   - 2 income, 3 expenses, 2 budgets, 2 goals, 2 contributions
3. ⏱️ **Dashboard Review** (2 min)
4. ⏱️ **Synchronization** (2 min)
5. ⏱️ **PL/SQL Report** (2 min)
6. ⏱️ **Soft Delete Demo** (2 min)
7. ⏱️ **Database Verification** (3 min)
   - Show SQLite vs Oracle consistency
8. ⏱️ **Q&A** (2 min)

---

**Good luck with your demonstration! 🎓✨**

*Created: November 11, 2025*  
*For: Personal Finance Management System Viva*
