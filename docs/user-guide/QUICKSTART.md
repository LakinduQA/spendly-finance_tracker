# Spendly - Quick Start Guide

A quick guide to get Spendly up and running.

## 5-Minute Setup

### Step 1: Install Dependencies
```bash
pip install -r requirements.txt
```

### Step 2: Run the Application
```bash
cd webapp
python app.py
```

### Step 3: Open Your Browser
Navigate to: **http://127.0.0.1:5000**

### Step 4: Get Started
1. Click **"Create Account"**
2. Register with username, email, and password
3. Login and start tracking!

## Using Sample Data

To populate the database with sample data:
```bash
cd scripts
python populate_sample_data.py
```

Then login with:
- **Username**: `dilini.fernando`
- **Password**: `Password123!`

## Features Overview

### Dashboard
- Financial summary cards (income, expenses, savings)
- Recent transactions
- Budget progress indicators
- Quick action buttons

### Expense Tracking
- Add expenses with categories and payment methods
- View and filter all expenses
- Delete expenses

### Income Management
- Record income from various sources
- Track income over time

### Budget Planning
- Set monthly budgets by category
- Visual progress bars
- Color-coded alerts (green/yellow/red)

### Savings Goals
- Create goals with target amounts
- Track contributions
- Monitor progress with percentages

### Reports & Analytics
- Pie chart for expense categories
- Monthly trend analysis
- Oracle PL/SQL reports (if configured)

## Optional: Oracle Setup

For Oracle synchronization:

1. Copy the example config:
   ```bash
   cp synchronization/config.example.ini synchronization/config.ini
   ```

2. Edit `config.ini` with your Oracle credentials

3. Click "Sync to Oracle" in the app

## Troubleshooting

### Port 5000 in use?
```python
# In webapp/app.py, change the port:
app.run(debug=True, port=5001)
```

### Database not found?
The database is created automatically on first run.

### Missing modules?
```bash
pip install Flask werkzeug
```

## Need More Help?

- Setup Guide: `docs/setup/COMPLETE_SETUP_GUIDE.md`
- Troubleshooting: `docs/troubleshooting/`
- Project Structure: `PROJECT_STRUCTURE.md`
