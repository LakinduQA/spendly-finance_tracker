# 📊 Report Generation Guide

**Personal Finance Management System**  
**Date**: November 2, 2025

---

## 🎯 Overview

Your system has **TWO types of reports**:

1. **📱 Web Application Reports** (Real-time, SQLite-based)
2. **🗄️ Oracle PL/SQL Reports** (Advanced analytics, Oracle-based)

---

## PART 1: WEB APPLICATION REPORTS 🌐

### A. How They Work

**Architecture:**
```
User Browser → Flask App → SQLite Database → API Endpoints → JSON Data → Chart.js → Visual Charts
```

**Process Flow:**
1. User visits `/reports` page
2. Page loads with two empty chart placeholders
3. JavaScript runs automatically on page load
4. JavaScript fetches data from API endpoints
5. Flask queries SQLite database
6. Returns JSON data
7. Chart.js renders interactive charts

---

### B. Available Web Reports

#### Report 1: Expenses by Category (Doughnut Chart)
**What it shows:** Distribution of your expenses across different categories

**Data Source:** SQLite `expense` table

**SQL Query:**
```sql
SELECT c.category_name, COALESCE(SUM(e.amount), 0) as total
FROM category c
LEFT JOIN expense e ON c.category_id = e.category_id AND e.user_id = ?
WHERE c.category_type = 'EXPENSE'
GROUP BY c.category_name
HAVING total > 0
ORDER BY total DESC
```

**API Endpoint:** `GET /api/expense_by_category`

**Chart Type:** Doughnut (Pie chart variation)

---

#### Report 2: Monthly Expense Trend (Line Chart)
**What it shows:** Your spending over the last 6 months

**Data Source:** SQLite `expense` table

**SQL Query:**
```sql
SELECT strftime('%Y-%m', expense_date) as month, 
       SUM(amount) as total
FROM expense
WHERE user_id = ?
GROUP BY month
ORDER BY month DESC
LIMIT 6
```

**API Endpoint:** `GET /api/monthly_trend`

**Chart Type:** Line chart with area fill

---

### C. How to View Web Reports

**Step-by-Step:**

1. **Start Flask App:**
   ```powershell
   cd d:\DM2_CW\webapp
   python app.py
   ```

2. **Login:**
   - Open browser: http://127.0.0.1:5000
   - Login as `john_doe` or `jane_smith`

3. **Navigate to Reports:**
   - Click "Reports" in navigation menu
   - Or go directly to: http://127.0.0.1:5000/reports

4. **View Charts:**
   - Charts load automatically
   - Interactive - hover to see values
   - No sync required (uses SQLite data)

**Features:**
- ✅ Real-time (always up-to-date)
- ✅ Interactive charts
- ✅ Fast (local database)
- ✅ No Oracle connection needed

---

### D. Technical Details

**File Locations:**
```
webapp/
├── app.py                    ← Flask backend (lines 539-625)
│   ├── @app.route('/reports')           ← Main reports page
│   ├── @app.route('/api/expense_by_category')  ← Category API
│   └── @app.route('/api/monthly_trend')        ← Trend API
│
└── templates/
    └── reports.html          ← Frontend template
        ├── Chart containers
        ├── JavaScript to fetch data
        └── Chart.js rendering
```

**JavaScript Flow:**
```javascript
// On page load
document.addEventListener('DOMContentLoaded', function() {
    
    // Fetch category data
    fetch('/api/expense_by_category')
        .then(response => response.json())
        .then(data => {
            // Create doughnut chart
            new Chart(ctx, {
                type: 'doughnut',
                data: {
                    labels: data.labels,      // Category names
                    datasets: [{ data: data.values }]  // Amounts
                }
            });
        });
    
    // Fetch monthly trend data
    fetch('/api/monthly_trend')
        .then(response => response.json())
        .then(data => {
            // Create line chart
            new Chart(ctx, {
                type: 'line',
                data: {
                    labels: data.labels,      // Months (YYYY-MM)
                    datasets: [{ data: data.values }]  // Totals
                }
            });
        });
});
```

---

## PART 2: ORACLE PL/SQL REPORTS 🗄️

### A. How They Work

**Architecture:**
```
SQL Developer → Oracle Database → PL/SQL Package → Procedures Execute → 
Results to Console (DBMS_OUTPUT) OR CSV File Export
```

**Process Flow:**
1. Data synced from SQLite to Oracle
2. User opens SQL Developer
3. Connects to Oracle database
4. Runs PL/SQL procedure call
5. Package executes complex queries
6. Results displayed in console or exported to CSV

---

### B. Five Advanced Reports

All reports are in the **`PKG_FINANCE_REPORTS`** package.

#### Report 1: Monthly Expenditure Analysis 📅
**What it shows:**
- Total income for the month
- Total expenses for the month
- Net savings
- Expense breakdown by category
- Average transaction amount
- Highest expense

**Procedure:** `generate_monthly_expenditure()`

**SQL Features Used:**
- `GROUP BY` - Group expenses by category
- `SUM()` aggregate function
- `COUNT()` for transaction counts
- `AVG()` for average amounts
- `MAX()` for highest expense
- Date filtering with `WHERE`

**How to Run:**
```sql
SET SERVEROUTPUT ON SIZE UNLIMITED;

-- Display in console
BEGIN
    pkg_finance_reports.display_monthly_expenditure(
        p_user_id => 1,
        p_year => 2024,
        p_month => 11
    );
END;
/

-- Export to CSV
BEGIN
    pkg_finance_reports.generate_monthly_expenditure(
        p_user_id => 1,
        p_year => 2024,
        p_month => 11,
        p_output_file => 'nov_2024_expenses.csv'
    );
END;
/
```

**Sample Output:**
```
==========================================
   MONTHLY EXPENDITURE ANALYSIS
==========================================
User: john_doe
Period: November 2024

SUMMARY:
  Total Income:    $3,000.00
  Total Expenses:  $2,450.75
  Net Savings:     $549.25
  Savings Rate:    18.31%

EXPENSE BREAKDOWN:
  Food & Dining:        $650.00  (26.5%)
  Transportation:       $320.50  (13.1%)
  Housing:             $900.00  (36.7%)
  Entertainment:        $180.25  (7.4%)
  ...

STATISTICS:
  Number of Transactions: 42
  Average Expense:        $58.35
  Highest Expense:        $900.00 (Rent)
```

---

#### Report 2: Budget Adherence Tracking 🎯
**What it shows:**
- Each budget vs actual spending
- Over/under budget status
- Percentage of budget used
- Remaining budget amounts

**Procedure:** `generate_budget_adherence()`

**SQL Features Used:**
- `CASE` statements for status
- `JOIN` between budgets and expenses
- `GROUP BY` category
- `HAVING` clause for filtering
- Percentage calculations

**How to Run:**
```sql
SET SERVEROUTPUT ON SIZE UNLIMITED;

BEGIN
    pkg_finance_reports.display_budget_adherence(
        p_user_id => 1,
        p_start_date => DATE '2024-11-01',
        p_end_date => DATE '2024-11-30'
    );
END;
/
```

**Sample Output:**
```
==========================================
   BUDGET ADHERENCE REPORT
==========================================
Period: Nov 1, 2024 - Nov 30, 2024

BUDGET PERFORMANCE:
  Category          Budget    Actual    Remaining  Status
  -------------------------------------------------------
  Food & Dining     $600.00   $650.00   -$50.00   OVER
  Transportation    $400.00   $320.50    $79.50   OK
  Housing           $900.00   $900.00     $0.00   EXACT
  Entertainment     $200.00   $180.25    $19.75   OK
  Healthcare        $300.00   $150.00   $150.00   UNDER
  
OVERALL:
  Total Budgeted:   $2,400.00
  Total Spent:      $2,200.75
  Overall Status:   UNDER BUDGET by $199.25
  Success Rate:     75% (3/4 budgets met)
```

---

#### Report 3: Savings Goal Progress 💰
**What it shows:**
- All savings goals
- Current vs target amounts
- Progress percentage
- Contributions history
- Estimated completion date

**Procedure:** `generate_savings_progress()`

**SQL Features Used:**
- `CURSOR` and `FOR` loops
- Multiple joins (goals + contributions)
- Date calculations
- Conditional logic

**How to Run:**
```sql
SET SERVEROUTPUT ON SIZE UNLIMITED;

BEGIN
    pkg_finance_reports.display_savings_progress(p_user_id => 1);
END;
/
```

**Sample Output:**
```
==========================================
   SAVINGS GOALS PROGRESS
==========================================

GOAL: Emergency Fund
  Target Amount:      $10,000.00
  Current Amount:      $3,250.00
  Remaining:           $6,750.00
  Progress:            32.5%
  Priority:            High
  Target Date:         Dec 31, 2024
  Status:             ON TRACK

  Recent Contributions:
    - Nov 15, 2024:    $500.00
    - Nov 1, 2024:     $500.00
    - Oct 15, 2024:    $500.00

GOAL: Vacation Fund
  Target Amount:       $3,000.00
  Current Amount:      $2,100.00
  Remaining:             $900.00
  Progress:             70.0%
  Priority:             Medium
  Target Date:          Jun 30, 2025
  Status:              ON TRACK

...

SUMMARY:
  Total Goals:         5
  Total Target:        $27,500.00
  Total Saved:         $8,350.00
  Overall Progress:    30.4%
```

---

#### Report 4: Category-wise Expense Distribution 📊
**What it shows:**
- Expenses grouped by category
- Amount and percentage per category
- Number of transactions per category
- Min/Max/Average transaction amounts

**Procedure:** `generate_category_distribution()`

**SQL Features Used:**
- `GROUP BY` category
- Multiple aggregate functions (`SUM`, `COUNT`, `AVG`, `MIN`, `MAX`)
- `ORDER BY` amount descending
- Percentage calculations

**How to Run:**
```sql
SET SERVEROUTPUT ON SIZE UNLIMITED;

BEGIN
    pkg_finance_reports.display_category_distribution(
        p_user_id => 1,
        p_start_date => ADD_MONTHS(SYSDATE, -3),
        p_end_date => SYSDATE
    );
END;
/
```

**Sample Output:**
```
==========================================
   CATEGORY DISTRIBUTION ANALYSIS
==========================================
Period: Aug 2, 2024 - Nov 2, 2024

EXPENSE BREAKDOWN:
  Category         Total      %      Txns  Avg      Min      Max
  ---------------------------------------------------------------
  Housing        $2,700.00  36.7%    3    $900.00  $900.00  $900.00
  Food & Dining  $1,950.00  26.5%   65    $30.00   $5.00    $120.00
  Transportation $1,100.50  15.0%   22    $50.02   $3.50    $150.00
  Bills          $  800.00  10.9%    8    $100.00  $50.00   $200.00
  Shopping       $  550.75   7.5%   18    $30.60   $10.00   $85.50
  Entertainment  $  245.00   3.3%   12    $20.42   $8.00    $50.00

TOTAL:           $7,346.25  100%    128   $57.39   $3.50    $900.00

TOP SPENDING CATEGORY: Housing (36.7%)
MOST FREQUENT:         Food & Dining (65 transactions)
```

---

#### Report 5: Forecasted Savings Trends 📈
**What it shows:**
- Historical income vs expenses (last 6 months)
- Average monthly savings
- Projected savings for next 6 months
- Forecasted account balance

**Procedure:** `generate_savings_forecast()`

**SQL Features Used:**
- Nested subqueries
- `UNION` to combine income and expense months
- Date arithmetic
- Trend calculations
- `CASE` statements

**How to Run:**
```sql
SET SERVEROUTPUT ON SIZE UNLIMITED;

BEGIN
    pkg_finance_reports.display_savings_forecast(
        p_user_id => 1,
        p_forecast_months => 6
    );
END;
/
```

**Sample Output:**
```
==========================================
   SAVINGS FORECAST ANALYSIS
==========================================

HISTORICAL DATA (Last 6 months):
  Month       Income      Expenses    Savings   Rate
  ----------------------------------------------------
  May 2024   $3,000.00   $2,800.00   $200.00   6.7%
  Jun 2024   $3,500.00   $2,650.00   $850.00   24.3%
  Jul 2024   $3,000.00   $2,900.00   $100.00   3.3%
  Aug 2024   $3,200.00   $2,450.00   $750.00   23.4%
  Sep 2024   $3,000.00   $2,700.00   $300.00   10.0%
  Oct 2024   $3,100.00   $2,550.00   $550.00   17.7%

AVERAGES:
  Avg Monthly Income:    $3,133.33
  Avg Monthly Expenses:  $2,675.00
  Avg Monthly Savings:   $  458.33
  Avg Savings Rate:      14.6%

FORECAST (Next 6 months):
  Month       Projected Income  Projected Expenses  Projected Savings
  -------------------------------------------------------------------
  Nov 2024         $3,133.33          $2,675.00          $458.33
  Dec 2024         $3,133.33          $2,675.00          $458.33
  Jan 2025         $3,133.33          $2,675.00          $458.33
  Feb 2025         $3,133.33          $2,675.00          $458.33
  Mar 2025         $3,133.33          $2,675.00          $458.33
  Apr 2025         $3,133.33          $2,675.00          $458.33

6-MONTH FORECAST:
  Total Projected Savings: $2,750.00
  Current Balance:         $8,350.00
  Projected Balance:       $11,100.00

INSIGHTS:
  - Maintain current savings rate to meet Emergency Fund goal
  - Consider increasing income or reducing expenses for faster savings
  - On track to save $5,500 annually at current rate
```

---

### C. CSV Export Feature

All reports can be exported to CSV files for:
- Excel analysis
- Data backup
- Sharing with others
- Long-term records

**Export Procedure:**
```sql
BEGIN
    pkg_finance_reports.generate_monthly_expenditure(
        p_user_id => 1,
        p_year => 2024,
        p_month => 11,
        p_output_file => 'expenses_nov_2024.csv'
    );
END;
/
```

**CSV Output Location:**
```
Oracle Server Directory (configured with UTL_FILE)
Default: /u01/app/oracle/admin/XE/csvexport/
```

**CSV Format Example:**
```csv
Category,Amount,Transactions,Percentage
"Food & Dining",650.00,42,26.5
"Transportation",320.50,18,13.1
"Housing",900.00,1,36.7
...
```

---

## PART 3: SYNCHRONIZATION 🔄

### Why Sync is Important

**The Architecture:**
```
SQLite (Local)  ←→  Synchronization  ←→  Oracle (Central)
   │                                            │
   ├─ Web app uses this                        ├─ PL/SQL reports use this
   ├─ Real-time CRUD                           ├─ Advanced analytics
   ├─ Fast access                              ├─ Complex queries
   └─ Offline capable                          └─ Enterprise features
```

### When to Sync

**Sync is required when:**
- ✅ You want to run Oracle PL/SQL reports
- ✅ You've added new data in the web app
- ✅ You want centralized backup
- ✅ You need data in Oracle for analysis

**Sync is NOT required for:**
- ❌ Viewing web app charts (uses SQLite)
- ❌ Daily CRUD operations
- ❌ Dashboard statistics

---

### How to Sync

#### Method 1: Via Web Interface
1. Login to web app
2. Go to Reports page
3. Click "Sync to Oracle" button
4. Wait for success message
5. Oracle database now has latest data

#### Method 2: Via Python Script
```powershell
cd d:\DM2_CW
python test_sync_extended.py
```

**Output:**
```
Connecting to SQLite database...
Connected successfully!

Connecting to Oracle database...
Connected successfully! (0.13s)

Step 1: Syncing users...
Synced 2 users

Step 2: Syncing expenses...
Synced 367 expenses

Step 3: Syncing income...
Synced 8 income records

Step 4: Syncing budgets...
Synced 8 budgets

Step 5: Syncing savings goals...
Synced 5 goals

==========================================
SYNCHRONIZATION COMPLETED SUCCESSFULLY!
Total records synced: 390
Time taken: 0.22 seconds
==========================================
```

#### Method 3: Via Sync Manager Module
```python
from synchronization.sync_manager import DatabaseSync

sync = DatabaseSync('synchronization/config.ini')
success = sync.sync_all(user_id=1, sync_type='Manual')

if success:
    print("Sync completed!")
```

---

## PART 4: COMPLETE WORKFLOW 🔄

### Typical Report Generation Workflow

#### For Real-time Quick Reports:
```
1. Open web app (http://127.0.0.1:5000)
2. Login
3. Go to Reports page
4. Charts appear automatically
5. ✅ Done!
```

#### For Advanced PL/SQL Reports:
```
1. Add/update data in web app
   └─ Add expenses, income, budgets, goals

2. Sync to Oracle
   ├─ Click "Sync to Oracle" button, OR
   └─ Run: python test_sync_extended.py

3. Open SQL Developer
   └─ Connect: system/oracle123@172.20.10.4:1521/xe

4. Enable output
   └─ SET SERVEROUTPUT ON SIZE UNLIMITED;

5. Run report procedure
   └─ BEGIN pkg_finance_reports.display_XXX(...); END;

6. View results in console
   └─ Check "Script Output" tab

7. (Optional) Export to CSV
   └─ Use generate_XXX(...) procedures

8. ✅ Done!
```

---

## PART 5: TESTING YOUR REPORTS 🧪

### Test Web Reports

```powershell
# 1. Start Flask
cd d:\DM2_CW\webapp
python app.py

# 2. Open browser
# http://127.0.0.1:5000

# 3. Login as john_doe

# 4. Navigate to Reports
# Should see:
#   ✓ Doughnut chart with categories
#   ✓ Line chart with monthly trend
#   ✓ Both charts have data
```

### Test Oracle Reports

```sql
-- 1. Connect to Oracle in SQL Developer
-- Connection: system/oracle123@172.20.10.4:1521/xe

-- 2. Enable output
SET SERVEROUTPUT ON SIZE UNLIMITED;

-- 3. Test each report

-- Test Report 1
BEGIN
    pkg_finance_reports.display_monthly_expenditure(
        p_user_id => 1,
        p_year => 2024,
        p_month => 11
    );
END;
/

-- Test Report 2
BEGIN
    pkg_finance_reports.display_budget_adherence(
        p_user_id => 1,
        p_start_date => DATE '2024-11-01',
        p_end_date => DATE '2024-11-30'
    );
END;
/

-- Test Report 3
BEGIN
    pkg_finance_reports.display_savings_progress(p_user_id => 1);
END;
/

-- Test Report 4
BEGIN
    pkg_finance_reports.display_category_distribution(
        p_user_id => 1,
        p_start_date => ADD_MONTHS(SYSDATE, -3),
        p_end_date => SYSDATE
    );
END;
/

-- Test Report 5
BEGIN
    pkg_finance_reports.display_savings_forecast(
        p_user_id => 1,
        p_forecast_months => 6
    );
END;
/
```

**Expected Result:** Each report displays formatted output with data

---

## PART 6: TROUBLESHOOTING 🔧

### Web Reports Not Loading

**Problem:** Charts are empty or not displaying

**Solutions:**
1. Check browser console (F12 → Console) for errors
2. Verify Flask app is running
3. Test API endpoints directly:
   - http://127.0.0.1:5000/api/expense_by_category
   - http://127.0.0.1:5000/api/monthly_trend
4. Check if user has expense data in SQLite
5. Verify Chart.js library is loaded

---

### Oracle Reports No Output

**Problem:** PL/SQL procedure runs but shows nothing

**Solutions:**
1. Enable DBMS_OUTPUT:
   ```sql
   SET SERVEROUTPUT ON SIZE UNLIMITED;
   ```
2. Check "Script Output" tab in SQL Developer (not "Results")
3. Verify user has synced data:
   ```sql
   SELECT COUNT(*) FROM FINANCE_EXPENSE WHERE user_id = 1;
   ```
4. Check package status:
   ```sql
   SELECT status FROM user_objects WHERE object_name = 'PKG_FINANCE_REPORTS';
   ```
   Should show: VALID

---

### No Data in Reports

**Problem:** Reports run but show "No data"

**Solutions:**
1. Verify data exists in SQLite:
   ```sql
   SELECT COUNT(*) FROM expense;
   ```
2. Sync data to Oracle:
   ```powershell
   python test_sync_extended.py
   ```
3. Verify sync worked:
   ```sql
   SELECT COUNT(*) FROM FINANCE_EXPENSE;
   ```
4. Check date ranges in report parameters

---

### CSV Export Not Working

**Problem:** CSV files not created

**Solutions:**
1. Verify Oracle directory exists:
   ```sql
   SELECT * FROM dba_directories WHERE directory_name = 'CSVEXPORT';
   ```
2. Check directory permissions
3. Create directory if missing:
   ```sql
   CREATE OR REPLACE DIRECTORY csvexport AS '/u01/app/oracle/admin/XE/csvexport/';
   GRANT READ, WRITE ON DIRECTORY csvexport TO PUBLIC;
   ```

---

## PART 7: QUICK REFERENCE 📝

### Commands Cheat Sheet

```bash
# Start web app
cd d:\DM2_CW\webapp
python app.py

# Sync to Oracle
cd d:\DM2_CW
python test_sync_extended.py

# View web reports
# http://127.0.0.1:5000/reports
```

```sql
-- Enable output
SET SERVEROUTPUT ON SIZE UNLIMITED;

-- All 5 reports (quick test)
BEGIN
    -- Report 1: Monthly Expenditure
    pkg_finance_reports.display_monthly_expenditure(1, 2024, 11);
    
    -- Report 2: Budget Adherence
    pkg_finance_reports.display_budget_adherence(1, DATE '2024-11-01', DATE '2024-11-30');
    
    -- Report 3: Savings Progress
    pkg_finance_reports.display_savings_progress(1);
    
    -- Report 4: Category Distribution
    pkg_finance_reports.display_category_distribution(1, ADD_MONTHS(SYSDATE, -3), SYSDATE);
    
    -- Report 5: Savings Forecast
    pkg_finance_reports.display_savings_forecast(1, 6);
END;
/
```

---

## PART 8: FILE LOCATIONS 📁

```
d:\DM2_CW\
├── webapp/
│   ├── app.py                     ← Web reports backend
│   └── templates/
│       └── reports.html           ← Web reports frontend
│
├── oracle/
│   └── 03_reports_package.sql     ← PL/SQL reports package (718 lines)
│
├── synchronization/
│   ├── sync_manager.py            ← Sync logic
│   ├── config.ini                 ← Oracle connection config
│   └── test_sync_extended.py      ← Test sync script
│
└── FULL_TESTING_CHECKLIST.md      ← Testing guide
```

---

## SUMMARY 📊

### Web Reports (SQLite-based)
- ✅ Real-time, automatic
- ✅ Interactive charts
- ✅ No sync needed
- ✅ Fast & simple
- 🎯 Best for: Daily monitoring

### Oracle Reports (PL/SQL-based)
- ✅ Advanced analytics
- ✅ Complex calculations
- ✅ CSV export
- ✅ Enterprise features
- 🎯 Best for: Detailed analysis, historical trends, forecasting

### Both systems work together!
- Web app for daily use
- Oracle for deep analysis
- Sync keeps them in harmony

---

**🎉 You now know everything about generating reports in your system!**

**Questions? Check:**
- `FULL_TESTING_CHECKLIST.md` - Complete testing guide
- `oracle/03_reports_package.sql` - Full PL/SQL code
- `webapp/app.py` (lines 539-625) - Web reports code

**Happy reporting! 📈✨**
