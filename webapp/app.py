"""
Personal Finance Management System - Web Application
Flask-based web interface with SQLite (local) and Oracle (central) databases
"""

from flask import Flask, render_template, request, redirect, url_for, session, flash, jsonify
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
