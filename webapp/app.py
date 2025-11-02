"""
Personal Finance Management System - Web Application
Flask-based web interface with SQLite (local) and Oracle (central) databases
"""

from flask import Flask, render_template, request, redirect, url_for, session, flash, jsonify, send_file, Response
import sqlite3
try:
    import cx_Oracle
    ORACLE_AVAILABLE = True
except ImportError:
    ORACLE_AVAILABLE = False
    print("Warning: cx_Oracle not installed. Oracle features will be disabled.")
import os
from datetime import datetime, timedelta
from werkzeug.security import generate_password_hash, check_password_hash
import configparser
from functools import wraps
import csv
import io

app = Flask(__name__)
app.secret_key = 'finance_management_secret_key_2025'  # Change this in production!

# Database configuration
SQLITE_DB_PATH = os.path.join('..', 'sqlite', 'finance_local.db')
CONFIG_FILE = os.path.join('..', 'synchronization', 'config.ini')

# Load Oracle configuration
config = configparser.ConfigParser()
config.read(CONFIG_FILE)

# ============================================
# DATABASE CONNECTION HELPERS
# ============================================

def get_sqlite_db():
    """Connect to SQLite database"""
    conn = sqlite3.connect(SQLITE_DB_PATH)
    conn.row_factory = sqlite3.Row
    return conn

def get_oracle_db():
    """Connect to Oracle database"""
    if not ORACLE_AVAILABLE:
        return None
    try:
        username = config['oracle']['username']
        password = config['oracle']['password']
        host = config['oracle']['host']
        port = config['oracle']['port']
        
        # Check if using SID or service_name
        if 'sid' in config['oracle']:
            sid = config['oracle']['sid']
            dsn = cx_Oracle.makedsn(host, port, sid=sid)
        else:
            service_name = config['oracle']['service_name']
            dsn = cx_Oracle.makedsn(host, port, service_name=service_name)
        
        conn = cx_Oracle.connect(username, password, dsn)
        return conn
    except Exception as e:
        print(f"Oracle connection error: {e}")
        return None

# ============================================
# REPORT GENERATION FUNCTIONS (FROM ORACLE)
# ============================================

def generate_monthly_expenditure_report(user_id, year=None, month=None):
    """Generate monthly expenditure analysis report from Oracle database"""
    if not ORACLE_AVAILABLE:
        return None
    
    oracle_conn = get_oracle_db()
    if not oracle_conn:
        return None
    
    try:
        if year is None or month is None:
            now = datetime.now()
            year = now.year
            month = now.month
        
        cursor = oracle_conn.cursor()
        
        # Get user info
        cursor.execute('SELECT username FROM finance_user WHERE user_id = :1', [user_id])
        user_row = cursor.fetchone()
        if not user_row:
            oracle_conn.close()
            return None
        username = user_row[0]
        
        # Get summary statistics
        cursor.execute('''
            SELECT 
                NVL(SUM(amount), 0) as total_income,
                COUNT(*) as income_count
            FROM finance_income
            WHERE user_id = :1 AND fiscal_year = :2 AND fiscal_month = :3
        ''', [user_id, year, month])
        income_row = cursor.fetchone()
        
        cursor.execute('''
            SELECT 
                NVL(SUM(amount), 0) as total_expenses,
                COUNT(*) as expense_count,
                NVL(AVG(amount), 0) as avg_expense,
                NVL(MAX(amount), 0) as max_expense
            FROM finance_expense
            WHERE user_id = :1 AND fiscal_year = :2 AND fiscal_month = :3
        ''', [user_id, year, month])
        expense_row = cursor.fetchone()
        
        # Get category breakdown
        cursor.execute('''
            SELECT 
                c.category_name,
                COUNT(e.expense_id) AS transaction_count,
                NVL(SUM(e.amount), 0) AS total_amount,
                NVL(AVG(e.amount), 0) AS avg_amount,
                ROUND((NVL(SUM(e.amount), 0) / NULLIF(:1, 0)) * 100, 2) AS percentage
            FROM finance_category c
            LEFT JOIN finance_expense e ON c.category_id = e.category_id
                AND e.user_id = :2
                AND e.fiscal_year = :3
                AND e.fiscal_month = :4
            WHERE c.category_type = 'EXPENSE'
            GROUP BY c.category_name
            HAVING COUNT(e.expense_id) > 0
            ORDER BY total_amount DESC
        ''', [expense_row[0], user_id, year, month])
        categories = cursor.fetchall()
        
        oracle_conn.close()
        
        total_income = float(income_row[0])
        total_expenses = float(expense_row[0])
        net_savings = total_income - total_expenses
        savings_rate = (net_savings / total_income * 100) if total_income > 0 else 0
        
        return {
            'username': username,
            'year': year,
            'month': month,
            'month_name': datetime(year, month, 1).strftime('%B'),
            'generated_at': datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
            'summary': {
                'total_income': total_income,
                'total_expenses': total_expenses,
                'net_savings': net_savings,
                'savings_rate': savings_rate,
                'income_count': int(income_row[1]),
                'expense_count': int(expense_row[1]),
                'avg_expense': float(expense_row[2]),
                'max_expense': float(expense_row[3])
            },
            'categories': [
                {
                    'category_name': row[0],
                    'transaction_count': int(row[1]),
                    'total_amount': float(row[2]),
                    'avg_amount': float(row[3]),
                    'percentage': float(row[4])
                } for row in categories
            ]
        }
    except Exception as e:
        if oracle_conn:
            oracle_conn.close()
        print(f"Report error: {e}")
        return None

def generate_budget_adherence_report(user_id):
    """Generate budget adherence tracking report from Oracle database"""
    if not ORACLE_AVAILABLE:
        return None
    
    oracle_conn = get_oracle_db()
    if not oracle_conn:
        return None
    
    try:
        cursor = oracle_conn.cursor()
        
        # Get user info
        cursor.execute('SELECT username FROM finance_user WHERE user_id = :1', [user_id])
        user_row = cursor.fetchone()
        if not user_row:
            oracle_conn.close()
            return None
        username = user_row[0]
        
        # Get budget performance data (same logic as PL/SQL view)
        cursor.execute('''
            SELECT 
                b.budget_id,
                c.category_name,
                b.budget_amount,
                b.start_date,
                b.end_date,
                NVL(SUM(e.amount), 0) AS actual_spent,
                b.budget_amount - NVL(SUM(e.amount), 0) AS remaining,
                ROUND((NVL(SUM(e.amount), 0) / b.budget_amount) * 100, 2) AS utilization_percent,
                CASE 
                    WHEN NVL(SUM(e.amount), 0) > b.budget_amount THEN 'Over Budget'
                    WHEN (NVL(SUM(e.amount), 0) / b.budget_amount) * 100 >= 80 THEN 'Near Limit'
                    ELSE 'Within Budget'
                END AS budget_status,
                COUNT(e.expense_id) AS transaction_count
            FROM finance_budget b
            JOIN finance_category c ON b.category_id = c.category_id
            LEFT JOIN finance_expense e ON e.user_id = b.user_id 
                AND e.category_id = b.category_id
                AND e.expense_date BETWEEN b.start_date AND b.end_date
            WHERE b.user_id = :1 AND b.is_active = 1
            GROUP BY b.budget_id, c.category_name, b.budget_amount, b.start_date, b.end_date
            ORDER BY utilization_percent DESC
        ''', [user_id])
        budgets = cursor.fetchall()
        
        oracle_conn.close()
        
        return {
            'username': username,
            'generated_at': datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
            'budgets': [
                {
                    'budget_id': int(row[0]),
                    'category_name': row[1],
                    'budget_amount': float(row[2]),
                    'start_date': row[3].strftime('%Y-%m-%d') if row[3] else '',
                    'end_date': row[4].strftime('%Y-%m-%d') if row[4] else '',
                    'actual_spent': float(row[5]),
                    'remaining': float(row[6]),
                    'utilization_percent': float(row[7]),
                    'budget_status': row[8],
                    'transaction_count': int(row[9])
                } for row in budgets
            ]
        }
    except Exception as e:
        if oracle_conn:
            oracle_conn.close()
        print(f"Report error: {e}")
        return None

def generate_savings_progress_report(user_id):
    """Generate savings goal progress report from Oracle database"""
    if not ORACLE_AVAILABLE:
        print("Oracle not available")
        return None
    
    oracle_conn = get_oracle_db()
    if not oracle_conn:
        print("Could not connect to Oracle")
        return None
    
    try:
        cursor = oracle_conn.cursor()
        
        # Get user info
        cursor.execute('SELECT username FROM finance_user WHERE user_id = :1', [user_id])
        user_row = cursor.fetchone()
        if not user_row:
            print(f"User {user_id} not found in Oracle")
            oracle_conn.close()
            return None
        username = user_row[0]
        
        # Get savings goal data (same logic as PL/SQL view)
        cursor.execute('''
            SELECT 
                goal_id,
                goal_name,
                target_amount,
                current_amount,
                deadline,
                status,
                CASE 
                    WHEN target_amount = 0 THEN 0 
                    ELSE ROUND((current_amount / target_amount) * 100, 2) 
                END AS progress_percent,
                target_amount - current_amount AS remaining_amount
            FROM finance_savings_goal
            WHERE user_id = :1
            ORDER BY 7 DESC
        ''', [user_id])
        goals = cursor.fetchall()
        
        print(f"Found {len(goals)} savings goals for user {user_id}")
        
        oracle_conn.close()
        
        # Return even if no goals found (empty list)
        return {
            'username': username,
            'generated_at': datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
            'goals': [
                {
                    'goal_id': int(row[0]),
                    'goal_name': row[1],
                    'target_amount': float(row[2]),
                    'current_amount': float(row[3]),
                    'target_date': row[4].strftime('%Y-%m-%d') if row[4] else '',
                    'status': row[5],
                    'progress_percent': float(row[6]) if row[6] else 0.0,
                    'remaining_amount': float(row[7]) if row[7] else 0.0
                } for row in goals
            ]
        }
    except Exception as e:
        print(f"Savings progress report error: {e}")
        import traceback
        traceback.print_exc()
        if oracle_conn:
            try:
                oracle_conn.close()
            except:
                pass
        return None

def generate_category_distribution_report(user_id, days=30):
    """Generate category-wise expense distribution report from Oracle database"""
    if not ORACLE_AVAILABLE:
        return None
    
    oracle_conn = get_oracle_db()
    if not oracle_conn:
        return None
    
    try:
        cursor = oracle_conn.cursor()
        
        # Get user info
        cursor.execute('SELECT username FROM finance_user WHERE user_id = :1', [user_id])
        user_row = cursor.fetchone()
        if not user_row:
            oracle_conn.close()
            return None
        username = user_row[0]
        
        # Calculate date range
        end_date = datetime.now()
        start_date = end_date - timedelta(days=days)
        
        # Get category distribution (same logic as PL/SQL)
        cursor.execute('''
            SELECT 
                c.category_name,
                COUNT(e.expense_id) AS transaction_count,
                NVL(SUM(e.amount), 0) AS total_amount,
                NVL(AVG(e.amount), 0) AS avg_amount,
                NVL(MIN(e.amount), 0) AS min_amount,
                NVL(MAX(e.amount), 0) AS max_amount
            FROM finance_category c
            LEFT JOIN finance_expense e ON c.category_id = e.category_id
                AND e.user_id = :1
                AND e.expense_date BETWEEN :2 AND :3
            WHERE c.category_type = 'EXPENSE'
            GROUP BY c.category_name
            HAVING COUNT(e.expense_id) > 0
            ORDER BY total_amount DESC
        ''', [user_id, start_date, end_date])
        categories = cursor.fetchall()
        
        oracle_conn.close()
        
        total_expenses = sum(float(row[2]) for row in categories)
        
        return {
            'username': username,
            'start_date': start_date.strftime('%Y-%m-%d'),
            'end_date': end_date.strftime('%Y-%m-%d'),
            'days': days,
            'generated_at': datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
            'total_expenses': total_expenses,
            'categories': [
                {
                    'category_name': row[0],
                    'transaction_count': int(row[1]),
                    'total_amount': float(row[2]),
                    'avg_amount': float(row[3]),
                    'min_amount': float(row[4]),
                    'max_amount': float(row[5]),
                    'percentage': (float(row[2]) / total_expenses * 100) if total_expenses > 0 else 0
                } for row in categories
            ]
        }
    except Exception as e:
        if oracle_conn:
            oracle_conn.close()
        print(f"Report error: {e}")
        return None

def generate_savings_forecast_report(user_id, months=6):
    """Generate savings forecast report from Oracle database"""
    if not ORACLE_AVAILABLE:
        return None
    
    oracle_conn = get_oracle_db()
    if not oracle_conn:
        return None
    
    try:
        cursor = oracle_conn.cursor()
        
        # Get user info
        cursor.execute('SELECT username FROM finance_user WHERE user_id = :1', [user_id])
        user_row = cursor.fetchone()
        if not user_row:
            oracle_conn.close()
            return None
        username = user_row[0]
        
        # Get historical averages for forecasting
        cursor.execute('''
            SELECT 
                AVG(monthly_income) as avg_income,
                AVG(monthly_expense) as avg_expense
            FROM (
                SELECT 
                    fiscal_year,
                    fiscal_month,
                    NVL(SUM(CASE WHEN amount > 0 THEN amount ELSE 0 END), 0) as monthly_income,
                    0 as monthly_expense
                FROM finance_income
                WHERE user_id = :1
                GROUP BY fiscal_year, fiscal_month
                UNION ALL
                SELECT 
                    fiscal_year,
                    fiscal_month,
                    0 as monthly_income,
                    NVL(SUM(amount), 0) as monthly_expense
                FROM finance_expense
                WHERE user_id = :1
                GROUP BY fiscal_year, fiscal_month
            )
        ''', [user_id, user_id])
        avg_row = cursor.fetchone()
        
        avg_income = float(avg_row[0]) if avg_row[0] else 0
        avg_expense = float(avg_row[1]) if avg_row[1] else 0
        avg_savings = avg_income - avg_expense
        
        # Generate forecast
        forecast_data = []
        current_date = datetime.now()
        cumulative_savings = 0
        
        for i in range(months):
            month_date = current_date + timedelta(days=30 * i)
            cumulative_savings += avg_savings
            forecast_data.append({
                'month': month_date.strftime('%B %Y'),
                'projected_income': avg_income,
                'projected_expense': avg_expense,
                'projected_savings': avg_savings,
                'cumulative_savings': cumulative_savings
            })
        
        oracle_conn.close()
        
        return {
            'username': username,
            'generated_at': datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
            'forecast_months': months,
            'avg_monthly_income': avg_income,
            'avg_monthly_expense': avg_expense,
            'avg_monthly_savings': avg_savings,
            'forecast': forecast_data
        }
    except Exception as e:
        if oracle_conn:
            oracle_conn.close()
        print(f"Report error: {e}")
        return None

# ============================================
# AUTHENTICATION DECORATOR
# ============================================

def login_required(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if 'user_id' not in session:
            flash('Please log in to access this page.', 'warning')
            return redirect(url_for('login'))
        return f(*args, **kwargs)
    return decorated_function

# ============================================
# AUTHENTICATION ROUTES
# ============================================

@app.route('/')
def index():
    """Landing page - redirect based on login status"""
    if 'user_id' in session:
        return redirect(url_for('dashboard'))
    return redirect(url_for('login'))

@app.route('/register', methods=['GET', 'POST'])
def register():
    """User registration"""
    if request.method == 'POST':
        username = request.form.get('username')
        email = request.form.get('email')
        full_name = request.form.get('full_name')
        password = request.form.get('password')
        
        # Validate input
        if not all([username, email, full_name, password]):
            flash('All fields are required!', 'danger')
            return redirect(url_for('register'))
        
        db = get_sqlite_db()
        
        # Check if username already exists
        existing_user = db.execute('SELECT * FROM user WHERE username = ?', (username,)).fetchone()
        if existing_user:
            flash('Username already exists!', 'danger')
            return redirect(url_for('register'))
        
        # Create user account (note: storing password directly for simplicity)
        # In production, use proper password hashing!
        try:
            db.execute('''
                INSERT INTO user (username, email, full_name) 
                VALUES (?, ?, ?)
            ''', (username, email, full_name))
            db.commit()
            flash('Account created successfully! Please log in.', 'success')
            return redirect(url_for('login'))
        except Exception as e:
            flash(f'Error creating account: {str(e)}', 'danger')
            return redirect(url_for('register'))
        finally:
            db.close()
    
    return render_template('register.html')

@app.route('/login', methods=['GET', 'POST'])
def login():
    """User login"""
    if request.method == 'POST':
        username = request.form.get('username')
        
        db = get_sqlite_db()
        user = db.execute('SELECT * FROM user WHERE username = ?', (username,)).fetchone()
        db.close()
        
        if user:
            session['user_id'] = user['user_id']
            session['username'] = user['username']
            session['full_name'] = user['full_name']
            flash(f'Welcome back, {user["full_name"]}!', 'success')
            return redirect(url_for('dashboard'))
        else:
            flash('Invalid username. Please try again.', 'danger')
    
    return render_template('login.html')

@app.route('/logout')
def logout():
    """User logout"""
    session.clear()
    flash('You have been logged out successfully.', 'info')
    return redirect(url_for('login'))

# ============================================
# DASHBOARD
# ============================================

@app.route('/dashboard')
@login_required
def dashboard():
    """Main dashboard with financial overview"""
    db = get_sqlite_db()
    user_id = session['user_id']
    
    # Get current month's data
    current_month = datetime.now().strftime('%Y-%m')
    
    # Total expenses this month
    total_expenses = db.execute('''
        SELECT COALESCE(SUM(amount), 0) as total
        FROM expense
        WHERE user_id = ? AND strftime('%Y-%m', expense_date) = ?
    ''', (user_id, current_month)).fetchone()['total']
    
    # Total income this month
    total_income = db.execute('''
        SELECT COALESCE(SUM(amount), 0) as total
        FROM income
        WHERE user_id = ? AND strftime('%Y-%m', income_date) = ?
    ''', (user_id, current_month)).fetchone()['total']
    
    # Active budgets
    active_budgets = db.execute('''
        SELECT COUNT(*) as count FROM budget
        WHERE user_id = ? AND is_active = 1
    ''', (user_id,)).fetchone()['count']
    
    # Active savings goals
    active_goals = db.execute('''
        SELECT COUNT(*) as count FROM savings_goal
        WHERE user_id = ? AND status = 'Active'
    ''', (user_id,)).fetchone()['count']
    
    # Recent expenses (last 5)
    recent_expenses = db.execute('''
        SELECT e.*, c.category_name
        FROM expense e
        JOIN category c ON e.category_id = c.category_id
        WHERE e.user_id = ?
        ORDER BY e.expense_date DESC, e.created_at DESC
        LIMIT 5
    ''', (user_id,)).fetchall()
    
    # Budget performance
    budget_performance = db.execute('''
        SELECT * FROM v_budget_performance
        WHERE user_id = ?
        LIMIT 5
    ''', (user_id,)).fetchall()
    
    db.close()
    
    # Calculate net savings
    net_savings = total_income - total_expenses
    savings_rate = (net_savings / total_income * 100) if total_income > 0 else 0
    
    return render_template('dashboard.html',
                         total_expenses=total_expenses,
                         total_income=total_income,
                         net_savings=net_savings,
                         savings_rate=savings_rate,
                         active_budgets=active_budgets,
                         active_goals=active_goals,
                         recent_expenses=recent_expenses,
                         budget_performance=budget_performance)

# ============================================
# EXPENSE MANAGEMENT
# ============================================

@app.route('/expenses')
@login_required
def expenses():
    """Expense tracking page"""
    db = get_sqlite_db()
    user_id = session['user_id']
    
    # Get all expenses
    expenses_list = db.execute('''
        SELECT e.*, c.category_name
        FROM expense e
        JOIN category c ON e.category_id = c.category_id
        WHERE e.user_id = ?
        ORDER BY e.expense_date DESC, e.created_at DESC
    ''', (user_id,)).fetchall()
    
    # Get categories for form
    categories = db.execute('''
        SELECT * FROM category 
        WHERE category_type = 'EXPENSE' AND is_active = 1
        ORDER BY category_name
    ''').fetchall()
    
    db.close()
    
    return render_template('expenses.html', 
                         expenses=expenses_list, 
                         categories=categories)

@app.route('/add_expense', methods=['POST'])
@login_required
def add_expense():
    """Add new expense"""
    user_id = session['user_id']
    category_id = request.form.get('category_id')
    amount = request.form.get('amount')
    expense_date = request.form.get('expense_date')
    description = request.form.get('description', '')
    payment_method = request.form.get('payment_method')
    
    db = get_sqlite_db()
    try:
        db.execute('''
            INSERT INTO expense (user_id, category_id, amount, expense_date, 
                               description, payment_method)
            VALUES (?, ?, ?, ?, ?, ?)
        ''', (user_id, category_id, amount, expense_date, description, payment_method))
        db.commit()
        flash('Expense added successfully!', 'success')
    except Exception as e:
        flash(f'Error adding expense: {str(e)}', 'danger')
    finally:
        db.close()
    
    return redirect(url_for('expenses'))

@app.route('/delete_expense/<int:expense_id>')
@login_required
def delete_expense(expense_id):
    """Delete expense"""
    db = get_sqlite_db()
    try:
        db.execute('DELETE FROM expense WHERE expense_id = ? AND user_id = ?', 
                  (expense_id, session['user_id']))
        db.commit()
        flash('Expense deleted successfully!', 'success')
    except Exception as e:
        flash(f'Error deleting expense: {str(e)}', 'danger')
    finally:
        db.close()
    
    return redirect(url_for('expenses'))

# ============================================
# INCOME MANAGEMENT
# ============================================

@app.route('/income')
@login_required
def income():
    """Income tracking page"""
    db = get_sqlite_db()
    user_id = session['user_id']
    
    # Get all income records
    income_list = db.execute('''
        SELECT * FROM income
        WHERE user_id = ?
        ORDER BY income_date DESC
    ''', (user_id,)).fetchall()
    
    db.close()
    
    return render_template('income.html', income_list=income_list)

@app.route('/add_income', methods=['POST'])
@login_required
def add_income():
    """Add new income"""
    user_id = session['user_id']
    income_source = request.form.get('income_source')
    amount = request.form.get('amount')
    income_date = request.form.get('income_date')
    description = request.form.get('description', '')
    
    db = get_sqlite_db()
    try:
        db.execute('''
            INSERT INTO income (user_id, income_source, amount, income_date, description)
            VALUES (?, ?, ?, ?, ?)
        ''', (user_id, income_source, amount, income_date, description))
        db.commit()
        flash('Income added successfully!', 'success')
    except Exception as e:
        flash(f'Error adding income: {str(e)}', 'danger')
    finally:
        db.close()
    
    return redirect(url_for('income'))

@app.route('/delete_income/<int:income_id>')
@login_required
def delete_income(income_id):
    """Delete income record"""
    db = get_sqlite_db()
    try:
        db.execute('DELETE FROM income WHERE income_id = ? AND user_id = ?', 
                  (income_id, session['user_id']))
        db.commit()
        flash('Income deleted successfully!', 'success')
    except Exception as e:
        flash(f'Error deleting income: {str(e)}', 'danger')
    finally:
        db.close()
    
    return redirect(url_for('income'))

# ============================================
# BUDGET MANAGEMENT
# ============================================

@app.route('/budgets')
@login_required
def budgets():
    """Budget management page"""
    db = get_sqlite_db()
    user_id = session['user_id']
    
    # Get budget performance from view
    budget_list = db.execute('''
        SELECT * FROM v_budget_performance
        WHERE user_id = ?
        ORDER BY utilization_percent DESC
    ''', (user_id,)).fetchall()
    
    # Get categories for form
    categories = db.execute('''
        SELECT * FROM category 
        WHERE category_type = 'EXPENSE' AND is_active = 1
        ORDER BY category_name
    ''').fetchall()
    
    db.close()
    
    return render_template('budgets.html', 
                         budgets=budget_list, 
                         categories=categories)

@app.route('/add_budget', methods=['POST'])
@login_required
def add_budget():
    """Add new budget"""
    user_id = session['user_id']
    category_id = request.form.get('category_id')
    budget_amount = request.form.get('budget_amount')
    start_date = request.form.get('start_date')
    end_date = request.form.get('end_date')
    
    db = get_sqlite_db()
    try:
        db.execute('''
            INSERT INTO budget (user_id, category_id, budget_amount, start_date, end_date)
            VALUES (?, ?, ?, ?, ?)
        ''', (user_id, category_id, budget_amount, start_date, end_date))
        db.commit()
        flash('Budget created successfully!', 'success')
    except Exception as e:
        flash(f'Error creating budget: {str(e)}', 'danger')
    finally:
        db.close()
    
    return redirect(url_for('budgets'))

@app.route('/delete_budget/<int:budget_id>')
@login_required
def delete_budget(budget_id):
    """Delete budget"""
    db = get_sqlite_db()
    try:
        db.execute('DELETE FROM budget WHERE budget_id = ? AND user_id = ?', 
                  (budget_id, session['user_id']))
        db.commit()
        flash('Budget deleted successfully!', 'success')
    except Exception as e:
        flash(f'Error deleting budget: {str(e)}', 'danger')
    finally:
        db.close()
    
    return redirect(url_for('budgets'))

# ============================================
# SAVINGS GOALS
# ============================================

@app.route('/goals')
@login_required
def goals():
    """Savings goals page"""
    db = get_sqlite_db()
    user_id = session['user_id']
    
    # Get savings goals with progress
    goals_list = db.execute('''
        SELECT * FROM v_savings_progress
        WHERE user_id = ?
        ORDER BY 
            CASE priority WHEN 'High' THEN 1 WHEN 'Medium' THEN 2 ELSE 3 END,
            deadline
    ''', (user_id,)).fetchall()
    
    db.close()
    
    return render_template('goals.html', goals=goals_list)

@app.route('/add_goal', methods=['POST'])
@login_required
def add_goal():
    """Add new savings goal"""
    user_id = session['user_id']
    goal_name = request.form.get('goal_name')
    target_amount = request.form.get('target_amount')
    deadline = request.form.get('deadline')
    priority = request.form.get('priority')
    
    db = get_sqlite_db()
    try:
        db.execute('''
            INSERT INTO savings_goal (user_id, goal_name, target_amount, 
                                     start_date, deadline, priority)
            VALUES (?, ?, ?, date('now'), ?, ?)
        ''', (user_id, goal_name, target_amount, deadline, priority))
        db.commit()
        flash('Savings goal created successfully!', 'success')
    except Exception as e:
        flash(f'Error creating goal: {str(e)}', 'danger')
    finally:
        db.close()
    
    return redirect(url_for('goals'))

@app.route('/contribute_goal/<int:goal_id>', methods=['POST'])
@login_required
def contribute_goal(goal_id):
    """Add contribution to savings goal"""
    contribution_amount = request.form.get('contribution_amount')
    contribution_date = request.form.get('contribution_date')
    description = request.form.get('description', '')
    
    db = get_sqlite_db()
    try:
        db.execute('''
            INSERT INTO savings_contribution (goal_id, contribution_amount, 
                                             contribution_date, description)
            VALUES (?, ?, ?, ?)
        ''', (goal_id, contribution_amount, contribution_date, description))
        db.commit()
        flash('Contribution added successfully!', 'success')
    except Exception as e:
        flash(f'Error adding contribution: {str(e)}', 'danger')
    finally:
        db.close()
    
    return redirect(url_for('goals'))

@app.route('/delete_goal/<int:goal_id>')
@login_required
def delete_goal(goal_id):
    """Delete savings goal"""
    db = get_sqlite_db()
    try:
        db.execute('DELETE FROM savings_goal WHERE goal_id = ? AND user_id = ?', 
                  (goal_id, session['user_id']))
        db.commit()
        flash('Savings goal deleted successfully!', 'success')
    except Exception as e:
        flash(f'Error deleting goal: {str(e)}', 'danger')
    finally:
        db.close()
    
    return redirect(url_for('goals'))

# ============================================
# REPORTS (Using Oracle Database)
# ============================================

@app.route('/reports')
@login_required
def reports():
    """Financial reports page"""
    return render_template('reports.html')

@app.route('/sync_to_oracle', methods=['POST'])
@login_required
def sync_to_oracle():
    """Synchronize data from SQLite to Oracle"""
    try:
        # Import and use the sync manager
        import sys
        sys.path.append(os.path.join('..', 'synchronization'))
        from sync_manager import DatabaseSync
        
        sync = DatabaseSync(CONFIG_FILE)
        success = sync.sync_all(session['user_id'], 'Manual')
        
        if success:
            flash('Data synchronized successfully to Oracle database!', 'success')
        else:
            flash('Synchronization failed. Check logs for details.', 'danger')
    except Exception as e:
        flash(f'Sync error: {str(e)}', 'danger')
    
    return redirect(url_for('reports'))

# ============================================
# REPORT GENERATION AND DOWNLOAD ROUTES
# ============================================

@app.route('/report/monthly_expenditure')
@login_required
def view_monthly_expenditure():
    """View monthly expenditure report"""
    year = request.args.get('year', type=int)
    month = request.args.get('month', type=int)
    
    report_data = generate_monthly_expenditure_report(session['user_id'], year, month)
    if not report_data:
        flash('Unable to generate report. Please sync data to Oracle first.', 'danger')
        return redirect(url_for('reports'))
    
    return render_template('report_monthly_expenditure.html', data=report_data)

@app.route('/report/budget_adherence')
@login_required
def view_budget_adherence():
    """View budget adherence report"""
    report_data = generate_budget_adherence_report(session['user_id'])
    if not report_data:
        flash('Unable to generate report. Please sync data to Oracle first.', 'danger')
        return redirect(url_for('reports'))
    
    return render_template('report_budget_adherence.html', data=report_data)

@app.route('/report/savings_progress')
@login_required
def view_savings_progress():
    """View savings progress report"""
    report_data = generate_savings_progress_report(session['user_id'])
    if not report_data:
        flash('Unable to generate report. Please sync data to Oracle first.', 'danger')
        return redirect(url_for('reports'))
    
    return render_template('report_savings_progress.html', data=report_data)

@app.route('/report/category_distribution')
@login_required
def view_category_distribution():
    """View category distribution report"""
    days = request.args.get('days', 30, type=int)
    report_data = generate_category_distribution_report(session['user_id'], days)
    if not report_data:
        flash('Unable to generate report. Please sync data to Oracle first.', 'danger')
        return redirect(url_for('reports'))
    
    return render_template('report_category_distribution.html', data=report_data)

@app.route('/report/savings_forecast')
@login_required
def view_savings_forecast():
    """View savings forecast report"""
    months = request.args.get('months', 6, type=int)
    report_data = generate_savings_forecast_report(session['user_id'], months)
    if not report_data:
        flash('Unable to generate report. Please sync data to Oracle first.', 'danger')
        return redirect(url_for('reports'))
    
    return render_template('report_savings_forecast.html', data=report_data)

@app.route('/download/monthly_expenditure')
@login_required
def download_monthly_expenditure():
    """Download monthly expenditure report as CSV"""
    year = request.args.get('year', type=int)
    month = request.args.get('month', type=int)
    
    report_data = generate_monthly_expenditure_report(session['user_id'], year, month)
    if not report_data:
        flash('Unable to generate report', 'danger')
        return redirect(url_for('reports'))
    
    # Create CSV
    output = io.StringIO()
    writer = csv.writer(output)
    
    writer.writerow(['Monthly Expenditure Analysis Report'])
    writer.writerow(['User', report_data['username']])
    writer.writerow(['Period', f"{report_data['month_name']} {report_data['year']}"])
    writer.writerow(['Generated', report_data['generated_at']])
    writer.writerow([])
    writer.writerow(['FINANCIAL SUMMARY'])
    writer.writerow(['Total Income', f"LKR {report_data['summary']['total_income']:.2f}"])
    writer.writerow(['Total Expenses', f"LKR {report_data['summary']['total_expenses']:.2f}"])
    writer.writerow(['Net Savings', f"LKR {report_data['summary']['net_savings']:.2f}"])
    writer.writerow(['Savings Rate', f"{report_data['summary']['savings_rate']:.2f}%"])
    writer.writerow([])
    writer.writerow(['CATEGORY BREAKDOWN'])
    writer.writerow(['Category', 'Transactions', 'Total Amount', 'Average', 'Percentage'])
    
    for cat in report_data['categories']:
        writer.writerow([
            cat['category_name'],
            cat['transaction_count'],
            f"LKR {cat['total_amount']:.2f}",
            f"LKR {cat['avg_amount']:.2f}",
            f"{cat['percentage']:.2f}%"
        ])
    
    output.seek(0)
    return Response(
        output.getvalue(),
        mimetype='text/csv',
        headers={'Content-Disposition': f'attachment; filename=monthly_expenditure_{year}_{month:02d}.csv'}
    )

@app.route('/download/budget_adherence')
@login_required
def download_budget_adherence():
    """Download budget adherence report as CSV"""
    report_data = generate_budget_adherence_report(session['user_id'])
    if not report_data:
        flash('Unable to generate report', 'danger')
        return redirect(url_for('reports'))
    
    output = io.StringIO()
    writer = csv.writer(output)
    
    writer.writerow(['Budget Adherence Report'])
    writer.writerow(['User', report_data['username']])
    writer.writerow(['Generated', report_data['generated_at']])
    writer.writerow([])
    writer.writerow(['Category', 'Budget Amount', 'Spent', 'Remaining', 'Utilization %', 'Status', 'Transactions'])
    
    for budget in report_data['budgets']:
        writer.writerow([
            budget['category_name'],
            f"LKR {budget['budget_amount']:.2f}",
            f"LKR {budget['actual_spent']:.2f}",
            f"LKR {budget['remaining']:.2f}",
            f"{budget['utilization_percent']:.2f}%",
            budget['budget_status'],
            budget['transaction_count']
        ])
    
    output.seek(0)
    return Response(
        output.getvalue(),
        mimetype='text/csv',
        headers={'Content-Disposition': 'attachment; filename=budget_adherence.csv'}
    )

@app.route('/download/savings_progress')
@login_required
def download_savings_progress():
    """Download savings progress report as CSV"""
    report_data = generate_savings_progress_report(session['user_id'])
    if not report_data:
        flash('Unable to generate report', 'danger')
        return redirect(url_for('reports'))
    
    output = io.StringIO()
    writer = csv.writer(output)
    
    writer.writerow(['Savings Progress Report'])
    writer.writerow(['User', report_data['username']])
    writer.writerow(['Generated', report_data['generated_at']])
    writer.writerow([])
    writer.writerow(['Goal Name', 'Target', 'Current', 'Remaining', 'Progress %', 'Status', 'Target Date'])
    
    for goal in report_data['goals']:
        writer.writerow([
            goal['goal_name'],
            f"LKR {goal['target_amount']:.2f}",
            f"LKR {goal['current_amount']:.2f}",
            f"LKR {goal['remaining_amount']:.2f}",
            f"{goal['progress_percent']:.2f}%",
            goal['status'],
            goal['target_date']
        ])
    
    output.seek(0)
    return Response(
        output.getvalue(),
        mimetype='text/csv',
        headers={'Content-Disposition': 'attachment; filename=savings_progress.csv'}
    )

@app.route('/download/category_distribution')
@login_required
def download_category_distribution():
    """Download category distribution report as CSV"""
    days = request.args.get('days', 30, type=int)
    report_data = generate_category_distribution_report(session['user_id'], days)
    if not report_data:
        flash('Unable to generate report', 'danger')
        return redirect(url_for('reports'))
    
    output = io.StringIO()
    writer = csv.writer(output)
    
    writer.writerow(['Category Distribution Report'])
    writer.writerow(['User', report_data['username']])
    writer.writerow(['Period', f"{report_data['start_date']} to {report_data['end_date']}"])
    writer.writerow(['Generated', report_data['generated_at']])
    writer.writerow([])
    writer.writerow(['Category', 'Transactions', 'Total', 'Average', 'Min', 'Max', 'Percentage'])
    
    for cat in report_data['categories']:
        writer.writerow([
            cat['category_name'],
            cat['transaction_count'],
            f"LKR {cat['total_amount']:.2f}",
            f"LKR {cat['avg_amount']:.2f}",
            f"LKR {cat['min_amount']:.2f}",
            f"LKR {cat['max_amount']:.2f}",
            f"{cat['percentage']:.2f}%"
        ])
    
    output.seek(0)
    return Response(
        output.getvalue(),
        mimetype='text/csv',
        headers={'Content-Disposition': f'attachment; filename=category_distribution_{days}days.csv'}
    )

@app.route('/download/savings_forecast')
@login_required
def download_savings_forecast():
    """Download savings forecast report as CSV"""
    months = request.args.get('months', 6, type=int)
    report_data = generate_savings_forecast_report(session['user_id'], months)
    if not report_data:
        flash('Unable to generate report', 'danger')
        return redirect(url_for('reports'))
    
    output = io.StringIO()
    writer = csv.writer(output)
    
    writer.writerow(['Savings Forecast Report'])
    writer.writerow(['User', report_data['username']])
    writer.writerow(['Generated', report_data['generated_at']])
    writer.writerow([])
    writer.writerow(['Average Monthly Income', f"LKR {report_data['avg_monthly_income']:.2f}"])
    writer.writerow(['Average Monthly Expense', f"LKR {report_data['avg_monthly_expense']:.2f}"])
    writer.writerow(['Average Monthly Savings', f"LKR {report_data['avg_monthly_savings']:.2f}"])
    writer.writerow([])
    writer.writerow(['Month', 'Projected Income', 'Projected Expense', 'Projected Savings', 'Cumulative Savings'])
    
    for forecast in report_data['forecast']:
        writer.writerow([
            forecast['month'],
            f"LKR {forecast['projected_income']:.2f}",
            f"LKR {forecast['projected_expense']:.2f}",
            f"LKR {forecast['projected_savings']:.2f}",
            f"LKR {forecast['cumulative_savings']:.2f}"
        ])
    
    output.seek(0)
    return Response(
        output.getvalue(),
        mimetype='text/csv',
        headers={'Content-Disposition': f'attachment; filename=savings_forecast_{months}months.csv'}
    )

# ============================================
# API ENDPOINTS FOR CHARTS
# ============================================

@app.route('/api/expense_by_category')
@login_required
def api_expense_by_category():
    """API endpoint for category-wise expense chart"""
    db = get_sqlite_db()
    user_id = session['user_id']
    
    data = db.execute('''
        SELECT c.category_name, COALESCE(SUM(e.amount), 0) as total
        FROM category c
        LEFT JOIN expense e ON c.category_id = e.category_id AND e.user_id = ?
        WHERE c.category_type = 'EXPENSE'
        GROUP BY c.category_name
        HAVING total > 0
        ORDER BY total DESC
    ''', (user_id,)).fetchall()
    
    db.close()
    
    return jsonify({
        'labels': [row['category_name'] for row in data],
        'values': [float(row['total']) for row in data]
    })

@app.route('/api/monthly_trend')
@login_required
def api_monthly_trend():
    """API endpoint for monthly expense trend"""
    db = get_sqlite_db()
    user_id = session['user_id']
    
    data = db.execute('''
        SELECT strftime('%Y-%m', expense_date) as month, 
               SUM(amount) as total
        FROM expense
        WHERE user_id = ?
        GROUP BY month
        ORDER BY month DESC
        LIMIT 6
    ''', (user_id,)).fetchall()
    
    db.close()
    
    return jsonify({
        'labels': [row['month'] for row in reversed(data)],
        'values': [float(row['total']) for row in reversed(data)]
    })

# ============================================
# RUN APPLICATION
# ============================================

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
