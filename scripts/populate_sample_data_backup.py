"""
Sample Data Population Script for Personal Finance Manager
Populates SQLite database with realistic test data for demonstration
"""

import sqlite3
from datetime import datetime, timedelta
import random

# Connect to SQLite database
db_path = 'D:/DM2_CW/sqlite/finance_local.db'
conn = sqlite3.connect(db_path)
cursor = conn.cursor()

print("Starting sample data population...")

# Sample data
categories = [
    ('Food & Dining', 'EXPENSE', 'Restaurants, groceries, takeout'),
    ('Transportation', 'EXPENSE', 'Gas, public transit, parking'),
    ('Housing', 'EXPENSE', 'Rent, mortgage, utilities'),
    ('Entertainment', 'EXPENSE', 'Movies, concerts, hobbies'),
    ('Healthcare', 'EXPENSE', 'Medical bills, prescriptions'),
    ('Shopping', 'EXPENSE', 'Clothing, electronics, misc'),
    ('Education', 'EXPENSE', 'Books, courses, tuition'),
    ('Bills & Utilities', 'EXPENSE', 'Internet, phone, electricity'),
]

# Insert categories (if not already exist)
print("Adding categories...")
for category in categories:
    try:
        cursor.execute('''
            INSERT INTO category (category_name, category_type, description)
            VALUES (?, ?, ?)
        ''', category)
    except sqlite3.IntegrityError:
        pass  # Category already exists

# Create sample users
print("Creating sample users...")
# Note: This schema doesn't have password_hash field
# Users need to register through the web app to get passwords set

users = [
    ('john_doe', 'john@example.com', 'John Doe'),
    ('jane_smith', 'jane@example.com', 'Jane Smith'),
]

user_ids = []
for user in users:
    try:
        cursor.execute('''
            INSERT INTO user (username, email, full_name)
            VALUES (?, ?, ?)
        ''', user)
        user_ids.append(cursor.lastrowid)
    except sqlite3.IntegrityError:
        # User already exists, get their ID
        cursor.execute('SELECT user_id FROM user WHERE username = ?', (user[0],))
        user_ids.append(cursor.fetchone()[0])

# Get category IDs
cursor.execute('SELECT category_id, category_name FROM category WHERE category_type = "EXPENSE"')
expense_categories = cursor.fetchall()

# Generate expenses for the last 3 months
print("Generating sample expenses...")
payment_methods = ['Cash', 'Credit Card', 'Debit Card', 'Online', 'Bank Transfer']
expense_descriptions = {
    'Food & Dining': ['Grocery shopping', 'Restaurant dinner', 'Coffee shop', 'Fast food lunch', 'Pizza delivery'],
    'Transportation': ['Gas station', 'Bus ticket', 'Parking fee', 'Uber ride', 'Car maintenance'],
    'Housing': ['Rent payment', 'Electricity bill', 'Water bill', 'Internet service', 'Home insurance'],
    'Entertainment': ['Movie tickets', 'Streaming service', 'Concert tickets', 'Video games', 'Hobby supplies'],
    'Healthcare': ['Doctor visit', 'Prescription medicine', 'Dental checkup', 'Vitamins', 'Health insurance'],
    'Shopping': ['New clothes', 'Electronics', 'Home decor', 'Gift purchase', 'Online shopping'],
    'Education': ['Textbooks', 'Online course', 'School supplies', 'Software subscription', 'Workshop fee'],
    'Bills & Utilities': ['Phone bill', 'Insurance premium', 'Gym membership', 'Subscription service', 'Cable TV'],
}

expenses_added = 0
for user_id in user_ids:
    for days_ago in range(90):  # Last 90 days
        # Add 1-3 expenses per day
        num_expenses = random.randint(1, 3)
        for _ in range(num_expenses):
            category_id, category_name = random.choice(expense_categories)
            
            # Get description for this category
            desc_list = expense_descriptions.get(category_name, ['Miscellaneous expense'])
            description = random.choice(desc_list)
            
            # Generate amount based on category
            if category_name in ['Housing', 'Education']:
                amount = round(random.uniform(500, 1500), 2)
            elif category_name in ['Healthcare', 'Shopping']:
                amount = round(random.uniform(50, 300), 2)
            else:
                amount = round(random.uniform(10, 150), 2)
            
            expense_date = (datetime.now() - timedelta(days=days_ago)).strftime('%Y-%m-%d')
            payment_method = random.choice(payment_methods)
            
            cursor.execute('''
                INSERT INTO expense (user_id, category_id, amount, expense_date, description, payment_method)
                VALUES (?, ?, ?, ?, ?, ?)
            ''', (user_id, category_id, amount, expense_date, description, payment_method))
            expenses_added += 1

print(f"Added {expenses_added} sample expenses")

# Generate income records
print("Generating sample income...")
income_sources = ['Salary', 'Freelance', 'Investment', 'Business', 'Gift']
income_descriptions = {
    'Salary': ['Monthly salary', 'Bi-weekly paycheck', 'Salary payment'],
    'Freelance': ['Project completion', 'Consulting work', 'Freelance gig'],
    'Investment': ['Dividend payment', 'Stock returns', 'Interest earned'],
    'Business': ['Client payment', 'Product sales', 'Service revenue'],
    'Gift': ['Birthday gift', 'Holiday bonus', 'Family support'],
}

income_added = 0
for user_id in user_ids:
    # Add monthly salary
    for month_ago in range(3):  # Last 3 months
        income_date = (datetime.now() - timedelta(days=month_ago * 30)).strftime('%Y-%m-%d')
        
        # Salary
        cursor.execute('''
            INSERT INTO income (user_id, income_source, amount, income_date, description)
            VALUES (?, ?, ?, ?, ?)
        ''', (user_id, 'Salary', round(random.uniform(3000, 5000), 2), income_date, 'Monthly salary payment'))
        income_added += 1
        
        # Occasional freelance
        if random.random() > 0.5:
            cursor.execute('''
                INSERT INTO income (user_id, income_source, amount, income_date, description)
                VALUES (?, ?, ?, ?, ?)
            ''', (user_id, 'Freelance', round(random.uniform(200, 800), 2), income_date, 'Freelance project'))
            income_added += 1

print(f"Added {income_added} sample income records")

# Create budgets
print("Creating sample budgets...")
budgets_added = 0
for user_id in user_ids:
    # Create budgets for top 4 categories
    top_categories = random.sample(expense_categories, 4)
    
    for category_id, category_name in top_categories:
        # Current month budget
        start_date = datetime.now().replace(day=1).strftime('%Y-%m-%d')
        last_day = (datetime.now().replace(day=28) + timedelta(days=4)).replace(day=1) - timedelta(days=1)
        end_date = last_day.strftime('%Y-%m-%d')
        
        if category_name in ['Housing', 'Education']:
            budget_amount = round(random.uniform(1000, 2000), 2)
        else:
            budget_amount = round(random.uniform(300, 800), 2)
        
        cursor.execute('''
            INSERT INTO budget (user_id, category_id, budget_amount, start_date, end_date)
            VALUES (?, ?, ?, ?, ?)
        ''', (user_id, category_id, budget_amount, start_date, end_date))
        budgets_added += 1

print(f"Added {budgets_added} sample budgets")

# Create savings goals
print("Creating sample savings goals...")
goals = [
    ('Emergency Fund', 10000, 365, 'High'),
    ('Vacation Trip', 3000, 180, 'Medium'),
    ('New Laptop', 1500, 120, 'Medium'),
    ('Car Down Payment', 5000, 270, 'High'),
    ('Home Renovation', 8000, 365, 'Low'),
]

goals_added = 0
for user_id in user_ids:
    # Add 2-3 goals per user
    user_goals = random.sample(goals, random.randint(2, 3))
    
    for goal_name, target, days, priority in user_goals:
        start_date = datetime.now().strftime('%Y-%m-%d')
        deadline = (datetime.now() + timedelta(days=days)).strftime('%Y-%m-%d')
        
        cursor.execute('''
            INSERT INTO savings_goal (user_id, goal_name, target_amount, start_date, deadline, priority)
            VALUES (?, ?, ?, ?, ?, ?)
        ''', (user_id, goal_name, target, start_date, deadline, priority))
        goal_id = cursor.lastrowid
        
        # Add some contributions
        num_contributions = random.randint(2, 5)
        for contrib_num in range(num_contributions):
            contrib_date = (datetime.now() - timedelta(days=random.randint(1, 60))).strftime('%Y-%m-%d')
            contrib_amount = round(random.uniform(50, 300), 2)
            
            cursor.execute('''
                INSERT INTO savings_contribution (goal_id, contribution_amount, contribution_date, description)
                VALUES (?, ?, ?, ?)
            ''', (goal_id, contrib_amount, contrib_date, f'Contribution {contrib_num + 1}'))
        
        goals_added += 1

print(f"Added {goals_added} sample savings goals")

# Commit all changes
conn.commit()
print("\nCommitting changes to database...")

# Print summary
print("\n" + "="*50)
print("Sample Data Population Complete!")
print("="*50)
print(f"Users: {len(user_ids)}")
print(f"Categories: {len(categories)}")
print(f"Expenses: {expenses_added}")
print(f"Income Records: {income_added}")
print(f"Budgets: {budgets_added}")
print(f"Savings Goals: {goals_added}")
print("="*50)

print("\nYou can now:")
print("1. Run the Flask app: python app.py")
print("2. Login with username: john_doe")
print("3. Explore the dashboard and features")
print("4. Click 'Sync to Oracle' to transfer data")

# Close connection
conn.close()
print("\nDatabase connection closed.")
