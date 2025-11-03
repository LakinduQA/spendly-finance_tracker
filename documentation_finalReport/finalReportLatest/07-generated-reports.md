# Section 7: Generated Reports

**Personal Finance Management System**  
**Five Comprehensive PL/SQL Reports**

---

## 6.1 Monthly Expenditure Analysis

### Purpose
Detailed analysis of monthly spending patterns by category

### PL/SQL Procedure

```sql
PROCEDURE generate_monthly_expenditure(
    p_user_id IN NUMBER,
    p_year IN NUMBER,
    p_month IN NUMBER,
    p_output_file IN VARCHAR2 DEFAULT 'monthly_expenditure.csv'
)
```

### Report Output

```
========================================
MONTHLY EXPENDITURE ANALYSIS REPORT
========================================
User: dilini.fernando
Period: October 2025
Generated: 20-OCT-2025 14:30:00
========================================

FINANCIAL SUMMARY:
----------------------------------------
Total Income:      $150,000.00
Total Expenses:    $135,000.00
Net Savings:       $15,000.00
Savings Rate:      10.00%

TRANSACTION STATISTICS:
----------------------------------------
Income Transactions:   3
Expense Transactions:  45
Average Expense:       $3,000.00
Largest Expense:       $15,000.00

CATEGORY-WISE BREAKDOWN:
----------------------------------------
Category            Count     Total           Avg             Percent
-------------------- ---------- --------------- --------------- ----------
Food & Dining       15         $45,000.00      $3,000.00       33.33%
Transportation      12         $36,000.00      $3,000.00       26.67%
Shopping            8          $24,000.00      $3,000.00       17.78%
Entertainment       5          $15,000.00      $3,000.00       11.11%
Healthcare          3          $9,000.00       $3,000.00       6.67%
Other               2          $6,000.00       $3,000.00       4.44%
========================================
```

---

## 6.2 Budget Adherence Tracking

### Purpose
Monitor budget performance and identify overspending

### PL/SQL Procedure

```sql
PROCEDURE generate_budget_adherence(
    p_user_id IN NUMBER,
    p_start_date IN DATE,
    p_end_date IN DATE,
    p_output_file IN VARCHAR2 DEFAULT 'budget_adherence.csv'
)
```

### Report Output

```
========================================
BUDGET ADHERENCE TRACKING REPORT
========================================
Period: 2025-10-01 to 2025-10-31
========================================

Category            Budget          Actual          Remaining       Utilization Status
-------------------- --------------- --------------- --------------- ----------- ---------------
Food & Dining       $50,000.00      $45,000.00      $5,000.00       90.00%      ✓ Within Budget
Transportation      $30,000.00      $36,000.00      -$6,000.00      120.00%     ✗ Over Budget
Shopping            $25,000.00      $24,000.00      $1,000.00       96.00%      ⚠ Near Limit
Entertainment       $20,000.00      $15,000.00      $5,000.00       75.00%      ✓ Within Budget

SUMMARY:
Total Budgeted:     $125,000.00
Total Spent:        $120,000.00
Overall Utilization: 96.00%
Budgets On Track:   2 of 4 (50%)
Budgets Over:       1 of 4 (25%)
========================================
```

---

## 6.3 Savings Goal Progress

### Purpose
Track progress towards savings goals

### PL/SQL Procedure

```sql
PROCEDURE generate_savings_progress(
    p_user_id IN NUMBER,
    p_output_file IN VARCHAR2 DEFAULT 'savings_progress.csv'
)
```

### Report Output

```
========================================
SAVINGS GOAL PROGRESS REPORT
========================================
User: dilini.fernando
Generated: 20-OCT-2025
========================================

Goal Name           Target          Current         Remaining       Progress    Days Left  Status
-------------------- --------------- --------------- --------------- ----------- ---------- ---------------
Emergency Fund      $500,000.00     $135,000.00     $365,000.00     27.00%      67         Active
New Laptop          $250,000.00     $90,000.00      $160,000.00     36.00%      67         Active
Vacation Fund       $300,000.00     $300,000.00     $0.00           100.00%     -          ✓ Completed
Home Deposit        $1,000,000.00   $250,000.00     $750,000.00     25.00%      365        Active

SUMMARY:
Total Goals:        4
Active Goals:       3
Completed Goals:    1
Total Target:       $2,050,000.00
Total Progress:     $775,000.00
Overall Progress:   37.80%
========================================
```

---

## 6.4 Category Distribution Analysis

### Purpose
Visualize spending distribution across categories

### PL/SQL Procedure

```sql
PROCEDURE generate_category_distribution(
    p_user_id IN NUMBER,
    p_start_date IN DATE,
    p_end_date IN DATE,
    p_output_file IN VARCHAR2 DEFAULT 'category_distribution.csv'
)
```

### Report Output

```
========================================
CATEGORY DISTRIBUTION ANALYSIS
========================================
Period: Last 90 Days
========================================

Category            Transactions    Amount          Percentage      Chart
-------------------- --------------- --------------- --------------- --------------------
Food & Dining       135             $405,000.00     33.33%          ████████████████████
Transportation      90              $270,000.00     22.22%          █████████████
Shopping            60              $180,000.00     14.81%          ████████
Entertainment       45              $135,000.00     11.11%          ██████
Healthcare          30              $90,000.00      7.41%           ████
Utilities           20              $60,000.00      4.94%           ███
Other               20              $75,000.00      6.17%           ███

TOTAL:              400             $1,215,000.00   100.00%

Top 3 Categories:
1. Food & Dining    - 33.33% of total spending
2. Transportation   - 22.22% of total spending
3. Shopping         - 14.81% of total spending
========================================
```

---

## 6.5 Savings Forecast Trends

### Purpose
Predict future savings based on historical trends

### PL/SQL Procedure

```sql
PROCEDURE generate_savings_forecast(
    p_user_id IN NUMBER,
    p_forecast_months IN NUMBER DEFAULT 6,
    p_output_file IN VARCHAR2 DEFAULT 'savings_forecast.csv'
)
```

### Report Output

```
========================================
SAVINGS FORECAST REPORT
========================================
Forecast Period: 6 months (Nov 2025 - Apr 2026)
========================================

HISTORICAL ANALYSIS (Last 3 months):
Month           Income          Expenses        Net Savings     Rate
--------------- --------------- --------------- --------------- -------
Aug 2025        $150,000.00     $140,000.00     $10,000.00      6.67%
Sep 2025        $150,000.00     $138,000.00     $12,000.00      8.00%
Oct 2025        $150,000.00     $135,000.00     $15,000.00      10.00%

Average Monthly Savings: $12,333.33
Trend: Improving (+$2,500/month)

FORECAST (Next 6 months):
Month           Projected Income Projected Expenses Forecasted Savings
--------------- ---------------- ------------------ ------------------
Nov 2025        $150,000.00      $132,500.00        $17,500.00
Dec 2025        $150,000.00      $130,000.00        $20,000.00
Jan 2026        $150,000.00      $127,500.00        $22,500.00
Feb 2026        $150,000.00      $125,000.00        $25,000.00
Mar 2026        $150,000.00      $122,500.00        $27,500.00
Apr 2026        $150,000.00      $120,000.00        $30,000.00

6-Month Forecast: $142,500.00 total savings
Current Savings:  $135,000.00
Projected Total:  $277,500.00
========================================
```

---

## Report Execution

### Command-Line Execution

```sql
-- Connect to Oracle
sqlplus username/password@hostname:port/service_name

-- Execute report
EXEC pkg_finance_reports.display_monthly_expenditure(2, 2025, 10);
EXEC pkg_finance_reports.display_budget_adherence(2, '01-OCT-2025', '31-OCT-2025');
EXEC pkg_finance_reports.display_savings_progress(2);
EXEC pkg_finance_reports.display_category_distribution(2, '01-AUG-2025', '31-OCT-2025');
EXEC pkg_finance_reports.display_savings_forecast(2, 6);
```

### CSV Export

```sql
-- Generate CSV files
EXEC pkg_finance_reports.generate_monthly_expenditure(2, 2025, 10, 'monthly_oct2025.csv');
-- Output saved to: /u01/app/oracle/admin/XE/dpdump/monthly_oct2025.csv
```

**Summary**: 5 comprehensive reports, 720 lines PL/SQL code, CSV export capability, formatted console output, business intelligence insights.
