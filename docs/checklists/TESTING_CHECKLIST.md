# Testing & Validation Checklist

## Pre-Launch Checks

### Environment Setup
- [ ] Python 3.8+ installed and in PATH
- [ ] SQLite3 available
- [ ] Oracle Instant Client installed (if using Oracle sync)
- [ ] All Python packages installed (`pip install -r requirements.txt`)
- [ ] SQLite database created (`finance_local.db`)
- [ ] Config file updated with Oracle credentials (`synchronization/config.ini`)

---

## Web Application Testing

### 1. Authentication Tests

#### Registration
- [ ] Navigate to http://localhost:5000
- [ ] Click "Create Account"
- [ ] Fill all required fields:
  - Username: `testuser1`
  - Email: `test@example.com`
  - Full Name: `Test User`
  - Password: `test123` (Note: not encrypted in demo)
- [ ] Submit form
- [ ] **Expected**: Success message and redirect to login

#### Login
- [ ] Enter username: `testuser1`
- [ ] Click "Sign In"
- [ ] **Expected**: Redirect to dashboard with welcome message

#### Session Management
- [ ] Verify username displays in navigation bar
- [ ] Click on user dropdown
- [ ] Click "Logout"
- [ ] **Expected**: Redirect to login with logout message
- [ ] Try accessing dashboard without login
- [ ] **Expected**: Redirect to login with warning message

---

### 2. Dashboard Tests

#### Summary Cards
- [ ] Login and navigate to dashboard
- [ ] Verify 4 summary cards display:
  - Income (This Month)
  - Expenses (This Month)
  - Net Savings
  - Active Goals
- [ ] Check values are $0.00 initially (or sample data amounts)
- [ ] Verify color coding:
  - Income: Green
  - Expenses: Red
  - Savings: Blue/Yellow (depending on positive/negative)
  - Goals: Purple

#### Recent Expenses Section
- [ ] If no data: Verify empty state shows
- [ ] If sample data: Verify last 5 expenses display
- [ ] Check table columns: Date, Category, Description, Amount

#### Budget Performance
- [ ] If no budgets: Verify empty state with "Create Budget" button
- [ ] If budgets exist: Verify progress bars show
- [ ] Check color coding:
  - Green: < 80% utilization
  - Yellow: 80-100% utilization
  - Red: > 100% utilization

#### Quick Actions
- [ ] Verify 6 quick action buttons display:
  - Add Expense (red)
  - Add Income (green)
  - Create Budget (blue)
  - Set Goal (cyan)
  - View Reports (yellow)
  - Sync to Oracle (gray)
- [ ] Click each button
- [ ] **Expected**: Navigate to correct page or trigger action

---

### 3. Expense Management Tests

#### Add Expense
- [ ] Navigate to Expenses page
- [ ] Click "Add Expense" button
- [ ] Verify modal opens
- [ ] Fill form:
  - Category: Select "Food & Dining"
  - Amount: `45.50`
  - Date: Today's date (auto-filled)
  - Payment Method: Select "Credit Card"
  - Description: `Dinner at restaurant`
- [ ] Click "Add Expense"
- [ ] **Expected**: Modal closes, success message, expense appears in table

#### View Expenses
- [ ] Verify expense table displays all expenses
- [ ] Check columns:
  - Date (formatted)
  - Category (badge)
  - Description
  - Payment Method (with icon)
  - Amount (red, formatted as currency)
  - Actions (delete button)
- [ ] Verify most recent expense appears at top

#### Delete Expense
- [ ] Click delete button (trash icon) on an expense
- [ ] **Expected**: Confirmation dialog appears
- [ ] Click "OK"
- [ ] **Expected**: Expense removed, success message

#### Edge Cases
- [ ] Try adding expense with negative amount
- [ ] **Expected**: HTML5 validation prevents submission
- [ ] Try adding expense without category
- [ ] **Expected**: Form validation requires selection
- [ ] Add expense for future date
- [ ] **Expected**: Should work (no date validation)

---

### 4. Income Management Tests

#### Add Income
- [ ] Navigate to Income page
- [ ] Click "Add Income" button
- [ ] Fill form:
  - Source: Select "Salary"
  - Amount: `3500.00`
  - Date: First day of current month
  - Description: `Monthly salary payment`
- [ ] Submit form
- [ ] **Expected**: Income appears in table

#### View Income
- [ ] Verify income table shows all records
- [ ] Check source badge (green)
- [ ] Check amount formatting (green color)
- [ ] Verify delete button present

#### Delete Income
- [ ] Delete an income record
- [ ] **Expected**: Confirmation and removal

---

### 5. Budget Management Tests

#### Create Budget
- [ ] Navigate to Budgets page
- [ ] Click "Create Budget"
- [ ] Fill form:
  - Category: Select "Food & Dining"
  - Amount: `500.00`
  - Start Date: First day of current month (auto-filled)
  - End Date: Last day of current month (auto-filled)
- [ ] Submit form
- [ ] **Expected**: Budget card appears

#### View Budget Cards
- [ ] Verify card shows:
  - Category name in header
  - Period (start to end date)
  - Budget amount
  - Spent amount
  - Remaining amount
  - Progress bar
  - Status indicator
- [ ] Check progress bar color:
  - Green header + green bar: < 80% used
  - Yellow header + yellow bar: 80-100% used
  - Red header + red bar: > 100% used

#### Budget Utilization
- [ ] Add expense in budgeted category
- [ ] Navigate back to Budgets
- [ ] **Expected**: Spent amount increases, progress bar updates

#### Delete Budget
- [ ] Click "Delete Budget" on a card
- [ ] Confirm deletion
- [ ] **Expected**: Card removed

---

### 6. Savings Goals Tests

#### Create Goal
- [ ] Navigate to Goals page
- [ ] Click "New Goal"
- [ ] Fill form:
  - Goal Name: `Emergency Fund`
  - Target Amount: `10000.00`
  - Target Date: One year from today (auto-filled)
  - Priority: Select "High"
- [ ] Submit form
- [ ] **Expected**: Goal card appears

#### View Goal Cards
- [ ] Verify card shows:
  - Goal name
  - Priority badge (High=red, Medium=yellow, Low=gray)
  - Target amount
  - Saved amount (initially $0.00)
  - Remaining amount
  - Deadline date
  - Progress bar
  - Days remaining counter
- [ ] Check progress bar color:
  - Gray: < 50%
  - Blue: 50-75%
  - Cyan: 75-100%
  - Green: 100%+

#### Add Contribution
- [ ] Click "Contribute" button on a goal
- [ ] Fill form:
  - Amount: `500.00`
  - Date: Today
  - Note: `Initial contribution`
- [ ] Submit form
- [ ] **Expected**: 
  - Modal closes
  - Saved amount increases to $500
  - Progress bar updates to 5% (500/10000)
  - Remaining amount decreases

#### Multiple Contributions
- [ ] Add 3 more contributions to same goal
- [ ] Verify saved amount accumulates correctly
- [ ] Verify progress bar percentage updates

#### Delete Goal
- [ ] Delete a goal
- [ ] **Expected**: Card removed with confirmation

---

### 7. Reports & Analytics Tests

#### Chart Rendering
- [ ] Navigate to Reports page
- [ ] Wait for charts to load
- [ ] **Expected**: Two charts display:
  1. Pie Chart (Expenses by Category)
  2. Line Chart (Monthly Expense Trend)

#### Pie Chart Validation
- [ ] Verify chart shows expense categories
- [ ] Check legend displays on right side
- [ ] Hover over segments
- [ ] **Expected**: Tooltip shows category and amount
- [ ] Check colors are distinct

#### Line Chart Validation
- [ ] Verify chart shows last 6 months
- [ ] Check X-axis shows month labels
- [ ] Check Y-axis shows dollar amounts
- [ ] Hover over data points
- [ ] **Expected**: Tooltip shows month and amount

#### Oracle Reports Section
- [ ] Verify 6 report cards display:
  - Monthly Expenditure
  - Budget Adherence
  - Savings Progress
  - Category Distribution
  - Expense Forecast
  - Export to CSV
- [ ] Check buttons are disabled (Oracle reports)
- [ ] Verify info text about SQL Developer

#### Sync to Oracle
- [ ] Click "Sync to Oracle" button
- [ ] **Expected**: One of two outcomes:
  - Success: "Data synchronized successfully" message
  - Failure: Error message (if Oracle not configured)
- [ ] Check browser console for sync logs

---

### 8. Navigation Tests

#### Menu Links
- [ ] Click each navigation item:
  - Dashboard
  - Expenses
  - Income
  - Budgets
  - Goals
  - Reports
- [ ] **Expected**: Navigate to correct page
- [ ] Verify active link highlighted

#### Breadcrumb Navigation
- [ ] Navigate through multiple pages
- [ ] Use browser back button
- [ ] **Expected**: Navigation works correctly

---

### 9. Responsive Design Tests

#### Desktop View (1920x1080)
- [ ] Open in full screen
- [ ] Verify layout looks professional
- [ ] Check all elements visible
- [ ] Verify cards display in grid

#### Tablet View (768x1024)
- [ ] Resize browser to tablet size (or use dev tools)
- [ ] **Expected**: 
  - Navigation collapses to hamburger menu
  - Cards stack vertically
  - Tables remain scrollable

#### Mobile View (375x667)
- [ ] Resize to mobile dimensions
- [ ] **Expected**:
  - All content accessible
  - Forms are usable
  - Buttons are tappable
  - No horizontal scroll

---

### 10. Data Validation Tests

#### Amount Fields
- [ ] Try entering negative amount: `-50`
- [ ] **Expected**: HTML5 prevents submission
- [ ] Try entering letters: `abc`
- [ ] **Expected**: Field rejects non-numeric input
- [ ] Try entering too many decimals: `45.999`
- [ ] **Expected**: Rounds to 2 decimals on blur

#### Date Fields
- [ ] Try entering invalid date
- [ ] **Expected**: Browser date picker prevents invalid dates
- [ ] Try leaving date empty
- [ ] **Expected**: Form validation requires date

#### Required Fields
- [ ] Submit form with empty required fields
- [ ] **Expected**: HTML5 validation messages appear

---

### 11. Sample Data Tests

#### Run Sample Data Script
```powershell
cd d:\DM2_CW\webapp
python populate_sample_data.py
```

- [ ] Script runs without errors
- [ ] **Expected Output**:
  ```
  Starting sample data population...
  Adding categories...
  Creating sample users...
  Generating sample expenses...
  Added 200+ sample expenses
  Generating sample income...
  Added 6+ sample income records
  Creating sample budgets...
  Added 8 sample budgets
  Creating sample savings goals...
  Added 4-6 sample savings goals
  Sample Data Population Complete!
  ```

#### Verify Sample Data
- [ ] Login as `john_doe`
- [ ] Dashboard shows realistic amounts
- [ ] Expenses page has 200+ entries
- [ ] Income page has multiple records
- [ ] Budgets show varying utilization
- [ ] Goals show progress
- [ ] Charts display real data

---

### 12. Performance Tests

#### Page Load Times
- [ ] Dashboard loads in < 2 seconds
- [ ] Expenses page loads in < 2 seconds (even with 200+ records)
- [ ] Charts render in < 3 seconds
- [ ] Forms open instantly

#### Database Queries
- [ ] Add 10 expenses quickly
- [ ] **Expected**: All save successfully
- [ ] Navigate between pages rapidly
- [ ] **Expected**: No delays or errors

---

### 13. Error Handling Tests

#### Database Errors
- [ ] Stop Flask server
- [ ] Rename `finance_local.db`
- [ ] Start Flask server
- [ ] Try adding expense
- [ ] **Expected**: Error page or flash message (not crash)

#### Missing Data
- [ ] Access dashboard with no data
- [ ] **Expected**: Empty states display correctly
- [ ] Access reports with no expenses
- [ ] **Expected**: Charts show empty message

#### Network Errors
- [ ] Disconnect internet
- [ ] Try syncing to Oracle
- [ ] **Expected**: Connection error message (not crash)

---

### 14. Security Tests (Basic)

#### Session Security
- [ ] Login
- [ ] Copy session cookie
- [ ] Logout
- [ ] Try pasting old cookie
- [ ] **Expected**: Redirected to login

#### Direct URL Access
- [ ] Logout
- [ ] Try accessing `/dashboard` directly
- [ ] **Expected**: Redirected to login
- [ ] Try accessing `/expenses`
- [ ] **Expected**: Redirected to login

#### SQL Injection Attempts
- [ ] Try username: `' OR '1'='1`
- [ ] **Expected**: Treated as literal string (fails login)
- [ ] Try expense description: `'; DROP TABLE expense; --`
- [ ] **Expected**: Saved as text (parameterized queries prevent injection)

---

### 15. Browser Compatibility Tests

#### Chrome/Edge
- [ ] All features work
- [ ] Charts render correctly
- [ ] Forms submit properly

#### Firefox
- [ ] All features work
- [ ] Charts render correctly
- [ ] Forms submit properly

#### Safari (if available)
- [ ] All features work
- [ ] Date pickers work
- [ ] Charts render

---

## Database Synchronization Tests

### SQLite to Oracle Sync

#### Setup Oracle (if available)
```powershell
cd d:\DM2_CW\oracle
# Run in SQL Developer or SQL*Plus:
@01_create_database.sql
@02_plsql_crud_package.sql
@03_reports_package.sql
```

#### Test Sync
- [ ] Add data in SQLite (via web app)
- [ ] Click "Sync to Oracle" button
- [ ] **Expected**: Success message
- [ ] Check sync_log table:
  ```sql
  SELECT * FROM sync_log ORDER BY sync_start_time DESC;
  ```
- [ ] Verify data in Oracle:
  ```sql
  SELECT COUNT(*) FROM expense;
  SELECT COUNT(*) FROM income;
  SELECT COUNT(*) FROM budget;
  SELECT COUNT(*) FROM savings_goal;
  ```

#### Test Conflict Resolution
- [ ] Modify same expense in both databases
- [ ] Run sync
- [ ] **Expected**: 
  - Conflict detected
  - Most recent timestamp wins
  - Sync log records conflict

---

## Oracle PL/SQL Reports Tests

### Test Report Execution

#### Monthly Expenditure
```sql
BEGIN
    finance_reports_pkg.display_monthly_expenditure(p_user_id => 1);
END;
/
```
- [ ] Report displays without errors
- [ ] Shows expenses grouped by month
- [ ] Includes category breakdown

#### Budget Adherence
```sql
BEGIN
    finance_reports_pkg.display_budget_adherence(p_user_id => 1);
END;
/
```
- [ ] Shows active budgets
- [ ] Displays utilization percentages
- [ ] Highlights over-budget categories

#### Savings Progress
```sql
BEGIN
    finance_reports_pkg.display_savings_progress(p_user_id => 1);
END;
/
```
- [ ] Lists all savings goals
- [ ] Shows contribution history
- [ ] Calculates progress percentages

#### Category Distribution
```sql
BEGIN
    finance_reports_pkg.display_category_distribution(p_user_id => 1);
END;
/
```
- [ ] Shows expense breakdown by category
- [ ] Includes percentages
- [ ] Sorted by amount

#### Expense Forecast
```sql
BEGIN
    finance_reports_pkg.display_expense_forecast(p_user_id => 1);
END;
/
```
- [ ] Shows 3-month predictions
- [ ] Based on historical averages
- [ ] Includes trend direction

---

## Visual Inspection Checklist

### UI/UX Quality
- [ ] All buttons have consistent styling
- [ ] Colors are professional (no clashing)
- [ ] Icons are aligned properly
- [ ] Text is readable (good contrast)
- [ ] Spacing is consistent
- [ ] Cards have shadows and depth
- [ ] Animations are smooth (not jerky)
- [ ] Forms are well-organized

### Professional Appearance
- [ ] Layout looks modern
- [ ] No broken images
- [ ] No console errors (check browser dev tools)
- [ ] Footer displays correctly
- [ ] Navigation is intuitive
- [ ] Loading states are present

---

## Documentation Review

### Code Documentation
- [ ] `app.py` has docstrings
- [ ] SQL files have comments
- [ ] README.md is comprehensive
- [ ] QUICKSTART.md is clear

### User Documentation
- [ ] Installation steps are complete
- [ ] Usage examples are provided
- [ ] Screenshots are referenced
- [ ] Troubleshooting section exists

---

## Final Checklist Before Submission

### Code Quality
- [ ] No debug statements in production code
- [ ] No hardcoded passwords (use config.ini)
- [ ] Error handling implemented
- [ ] Comments explain complex logic

### Functionality
- [ ] All CRUD operations work
- [ ] Synchronization works (or is documented as optional)
- [ ] Reports generate correctly
- [ ] Charts display data

### Documentation
- [ ] README.md complete
- [ ] PROJECT_SUMMARY.md updated
- [ ] Screenshots captured
- [ ] Installation guide tested

### Deliverables
- [ ] All SQL scripts included
- [ ] Python scripts included
- [ ] Web application files included
- [ ] Documentation files included
- [ ] Sample data script included

---

## Known Issues / Limitations

Document any issues found:

1. **Issue**: 
   - **Impact**: 
   - **Workaround**: 

2. **Issue**: 
   - **Impact**: 
   - **Workaround**: 

---

## Testing Summary

**Date Tested**: _________________

**Tester Name**: _________________

**Overall Status**: ☐ Pass  ☐ Pass with Minor Issues  ☐ Fail

**Critical Bugs Found**: _________

**Minor Issues Found**: _________

**Recommendations**: 

---

**Testing Complete! ✅**

If all checkboxes are marked, your application is ready for demonstration and submission!
