# Personal Finance Manager - Web Application

A modern, professional web-based personal finance management system with dual-database architecture (SQLite + Oracle).

## Features

### ✨ Core Functionality
- **User Authentication** - Simple login/registration system
- **Expense Tracking** - Record and categorize expenses with payment methods
- **Income Management** - Track multiple income sources
- **Budget Planning** - Set monthly budgets and monitor spending
- **Savings Goals** - Create goals with progress tracking and contributions
- **Financial Reports** - Visual analytics with charts and PL/SQL reports

### 🎨 UI Design
- **Bootstrap 5** - Modern, responsive design
- **Professional Styling** - Gradient colors, smooth animations, card-based layouts
- **Interactive Charts** - Pie charts and trend lines using Chart.js
- **Mobile-Friendly** - Fully responsive across all devices

### 🗄️ Database Architecture
- **SQLite (Local)** - Fast, offline data storage for daily operations
- **Oracle (Central)** - Enterprise database for analytics and reporting
- **Bidirectional Sync** - Python synchronization script with conflict resolution
- **PL/SQL Reports** - Five comprehensive financial reports in Oracle

## Technology Stack

- **Backend**: Python 3.x + Flask
- **Frontend**: HTML5, Bootstrap 5, JavaScript
- **Charts**: Chart.js
- **Local Database**: SQLite 3
- **Central Database**: Oracle Database
- **Synchronization**: cx_Oracle, custom Python sync manager

## Installation

### Prerequisites
1. Python 3.8 or higher
2. Oracle Database (with connection details)
3. Oracle Instant Client (for cx_Oracle)

### Step 1: Install Python Dependencies
```powershell
cd webapp
pip install -r requirements.txt
```

### Step 2: Configure Oracle Connection
Edit `../synchronization/config.ini` with your Oracle database credentials:
```ini
[oracle]
username = your_username
password = your_password
host = localhost
port = 1521
service_name = your_service
```

### Step 3: Initialize Databases
Run the SQL scripts to create the databases:

**SQLite:**
```powershell
cd ../sqlite
sqlite3 finance_local.db < 01_create_database.sql
```

**Oracle:**
```sql
-- Connect to Oracle via SQL Developer or SQL*Plus
@../oracle/01_create_database.sql
@../oracle/02_plsql_crud_package.sql
@../oracle/03_reports_package.sql
```

## Running the Application

### Start the Flask Server
```powershell
cd webapp
python app.py
```

The application will be available at: **http://localhost:5000**

### First-Time Setup
1. Open your browser and go to `http://localhost:5000`
2. Click "Create Account" to register a new user
3. Log in with your username
4. Start adding expenses, income, budgets, and goals
5. Click "Sync to Oracle" to transfer data to the central database

## Application Structure

```
webapp/
├── app.py                  # Main Flask application
├── requirements.txt        # Python dependencies
├── templates/              # HTML templates (Jinja2)
│   ├── base.html          # Base template with navigation
│   ├── login.html         # Login page
│   ├── register.html      # Registration page
│   ├── dashboard.html     # Main dashboard
│   ├── expenses.html      # Expense management
│   ├── income.html        # Income tracking
│   ├── budgets.html       # Budget planning
│   ├── goals.html         # Savings goals
│   └── reports.html       # Analytics and reports
├── static/                 # Static assets
│   ├── css/
│   │   └── style.css      # Custom CSS styles
│   └── js/
│       └── main.js        # JavaScript utilities
```

## User Guide

### Dashboard
- View financial summary cards (income, expenses, savings)
- See recent expenses and budget performance
- Quick action buttons for common tasks

### Expenses
- Add new expenses with category, amount, date, payment method
- View all expenses in a table
- Delete expenses as needed

### Income
- Record income from various sources (salary, freelance, etc.)
- Track income dates and descriptions
- Delete income records

### Budgets
- Create monthly budgets for expense categories
- Visual progress bars showing utilization
- Color-coded alerts (green = on track, yellow = warning, red = exceeded)

### Savings Goals
- Set financial goals with target amounts and deadlines
- Add contributions to goals
- Track progress with percentage indicators
- Priority-based organization

### Reports
- **Local Analytics**: Pie charts and trend lines from SQLite data
- **Oracle Reports**: Five PL/SQL-based financial reports
  1. Monthly Expenditure
  2. Budget Adherence
  3. Savings Progress
  4. Category Distribution
  5. Expense Forecast
- **Sync Button**: Transfer data from SQLite to Oracle

## Database Synchronization

The application uses a dual-database architecture:
- **SQLite** stores data locally for fast access and offline capability
- **Oracle** serves as the central repository for analytics and reporting

To synchronize data:
1. Click the "Sync to Oracle" button on the Dashboard or Reports page
2. The synchronization script (`../synchronization/sync_manager.py`) will transfer:
   - User accounts
   - Expenses
   - Income records
   - Budgets
   - Savings goals and contributions
3. Check the console for sync logs and status

## API Endpoints

The application provides internal API endpoints for charts:

- **GET** `/api/expense_by_category` - Returns category-wise expense data for pie chart
- **GET** `/api/monthly_trend` - Returns last 6 months expense trend for line chart

## Security Notes

⚠️ **For Academic/Development Use Only**

This application is designed for coursework demonstration and includes simplified security:
- Passwords are NOT hashed (use `werkzeug.security` in production)
- Session secret key is hardcoded (use environment variables in production)
- No CSRF protection (use Flask-WTF in production)
- No input sanitization (validate all user input in production)

For production deployment, implement proper security measures.

## Troubleshooting

### Database Connection Errors
- Verify SQLite database path in `app.py` (line 14)
- Check Oracle configuration in `config.ini`
- Ensure Oracle Instant Client is installed and in PATH

### Port Already in Use
```powershell
# Change the port in app.py (last line):
app.run(debug=True, host='0.0.0.0', port=5001)
```

### Module Not Found Errors
```powershell
pip install -r requirements.txt
```

### cx_Oracle Installation Issues
1. Download Oracle Instant Client from Oracle website
2. Extract to a directory (e.g., `C:\oracle\instantclient_21_3`)
3. Add to PATH environment variable
4. Restart PowerShell and reinstall cx_Oracle

## Oracle PL/SQL Reports

To execute the five financial reports in Oracle:

```sql
-- 1. Monthly Expenditure Report
BEGIN
    finance_reports_pkg.display_monthly_expenditure(p_user_id => 1);
END;
/

-- 2. Budget Adherence Report
BEGIN
    finance_reports_pkg.display_budget_adherence(p_user_id => 1);
END;
/

-- 3. Savings Goals Progress
BEGIN
    finance_reports_pkg.display_savings_progress(p_user_id => 1);
END;
/

-- 4. Category-wise Distribution
BEGIN
    finance_reports_pkg.display_category_distribution(p_user_id => 1);
END;
/

-- 5. Expense Forecast
BEGIN
    finance_reports_pkg.display_expense_forecast(p_user_id => 1);
END;
/

-- Export to CSV (example)
BEGIN
    finance_reports_pkg.export_monthly_expenditure_csv(
        p_user_id => 1,
        p_file_path => '/path/to/output.csv'
    );
END;
/
```

## Project Context

This web application is part of a **Data Management 2 Coursework** assignment demonstrating:
- Database design and normalization
- SQL and PL/SQL programming
- Multi-database architecture
- Data synchronization strategies
- Web application development with database integration

## License

Academic Project © 2025 - For Educational Purposes Only

## Support

For issues or questions related to this coursework project, refer to:
- Database design documentation: `../database_designs/`
- SQL scripts: `../sqlite/` and `../oracle/`
- Synchronization logic: `../synchronization/`
- Coursework requirements: `../cw.md`
