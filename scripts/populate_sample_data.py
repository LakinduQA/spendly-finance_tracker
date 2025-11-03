"""
Sample Data Population Script for Personal Finance Manager
Populates SQLite database with realistic test data for demonstration
"""

import sqlite3
from datetime import datetime, timedelta
import random
from werkzeug.security import generate_password_hash

# Connect to SQLite database
db_path = '../sqlite/finance_local.db'
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
# All users have password: fs123

password_hash = generate_password_hash('fs123')

users = [
    ('kavinda.silva', 'kavinda.silva@gmail.com', 'Kavinda Silva', password_hash),
    ('dilini.fernando', 'dilini.fernando@gmail.com', 'Dilini Fernando', password_hash),
    ('chamath.perera', 'chamath.perera@gmail.com', 'Chamath Perera', password_hash),
    ('nimali.jayawardena', 'nimali.jayawardena@gmail.com', 'Nimali Jayawardena', password_hash),
    ('tharindu.bandara', 'tharindu.bandara@gmail.com', 'Tharindu Bandara', password_hash),
]

user_ids = []
for user in users:
    try:
        cursor.execute('''
            INSERT INTO user (username, email, full_name, password_hash, created_at)
            VALUES (?, ?, ?, ?, datetime('now', 'localtime'))
        ''', user)
        user_ids.append(cursor.lastrowid)
    except sqlite3.IntegrityError:
        # User already exists, get their ID
        cursor.execute('SELECT user_id FROM user WHERE username = ?', (user[0],))
        user_ids.append(cursor.fetchone()[0])

# Get category IDs
cursor.execute('SELECT category_id, category_name FROM category WHERE category_type = "EXPENSE"')
expense_categories = cursor.fetchall()

# Generate expenses for the last 90 days
print("Generating sample expenses...")
payment_methods = ['Cash', 'Credit Card', 'Debit Card', 'Online', 'Bank Transfer']
expense_descriptions = {
    'Food & Dining': ['Keells groceries', 'Rice & curry lunch', 'Ministry of Crab dinner', 'Kottu roti', 'Pizza Hut', 'KFC', 'Burger King meal', 'Chinese restaurant', 'Cargills FoodCity', 'Seafood dinner'],
    'Transportation': ['Uber ride', 'PickMe to office', 'Bus fare', 'Fuel - Ceypetco', 'Three-wheeler', 'Train ticket', 'Highway toll', 'Taxi to airport', 'Bike repair', 'Parking fee'],
    'Housing': ['Monthly rent payment', 'LECO electricity bill', 'Water Board bill', 'Internet - SLT', 'Home insurance', 'Apartment maintenance', 'Property tax', 'Home repairs', 'Cleaning service', 'Security fee'],
    'Entertainment': ['Scope Cinema tickets', 'Netflix subscription', 'Spotify premium', 'Cricket match tickets', 'Concert at Nelum Pokuna', 'Gaming subscription', 'Books from Vijitha Yapa', 'Art supplies', 'Photography equipment', 'Music lessons'],
    'Healthcare': ['Doctor consultation', 'Prescription medicines', 'Lab tests at Nawaloka', 'Dental checkup', 'Eye test at Optical Center', 'Pharmacy - Osu Sala', 'Health insurance premium', 'Physiotherapy session', 'Medical scan', 'Vitamins & supplements'],
    'Shopping': ['Odel clothing', 'Cotton Collection shirt', 'Singer electronics', 'Daraz online order', 'Shoes from Bata', 'Mobile accessories', 'Home decor', 'Kitchen items', 'Furniture', 'Gift purchase'],
    'Education': ['Udemy course subscription', 'English class monthly fee', 'Books from Sarasavi', 'Tuition fees', 'Online certification', 'Conference registration', 'Workshop fee', 'Study materials', 'Software license', 'Professional course'],
    'Bills & Utilities': ['SLT internet & phone', 'Dialog mobile bill', 'Hutch data package', 'Gas cylinder', 'Insurance premium', 'Gym membership', 'Streaming services', 'Cloud storage', 'Magazine subscription', 'HOA fees'],
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
            
            # Generate realistic Sri Lankan amounts based on category (in LKR)
            if category_name == 'Food & Dining':
                amount = round(random.uniform(500, 15000), 2)
            elif category_name == 'Transportation':
                amount = round(random.uniform(200, 12000), 2)
            elif category_name == 'Housing':
                amount = round(random.uniform(800, 45000), 2)
            elif category_name == 'Entertainment':
                amount = round(random.uniform(850, 8000), 2)
            elif category_name == 'Healthcare':
                amount = round(random.uniform(1500, 15000), 2)
            elif category_name == 'Shopping':
                amount = round(random.uniform(1000, 50000), 2)
            elif category_name == 'Education':
                amount = round(random.uniform(2000, 20000), 2)
            elif category_name == 'Bills & Utilities':
                amount = round(random.uniform(800, 8000), 2)
            else:
                amount = round(random.uniform(500, 5000), 2)
            
            expense_date = (datetime.now() - timedelta(days=days_ago)).strftime('%Y-%m-%d')
            payment_method = random.choice(payment_methods)
            
            cursor.execute('''
                INSERT INTO expense (user_id, category_id, amount, expense_date, description, payment_method, created_at)
                VALUES (?, ?, ?, ?, ?, ?, datetime('now', 'localtime'))
            ''', (user_id, category_id, amount, expense_date, description, payment_method))
            expenses_added += 1

print(f"Added {expenses_added} sample expenses")

# Generate income records
print("Generating sample income...")
income_sources = ['Salary', 'Freelance', 'Investment', 'Business', 'Gift']
income_descriptions = {
    'Salary': ['Monthly salary payment', 'Bi-weekly paycheck', 'Salary transfer'],
    'Freelance': ['Web development project', 'Consulting work', 'Graphic design gig', 'Content writing', 'Software development'],
    'Investment': ['Dividend payment', 'Stock returns', 'Interest earned', 'Bond returns'],
    'Business': ['Client payment', 'Product sales', 'Service revenue', 'Commission'],
    'Gift': ['Birthday gift', 'Holiday bonus', 'Family support', 'Festival gift'],
}

income_added = 0
for user_id in user_ids:
    # Add monthly salary for the past 3 months
    for month_ago in range(3):
        income_date = (datetime.now() - timedelta(days=month_ago * 30)).strftime('%Y-%m-%d')
        
        # Monthly salary in LKR (80,000 - 180,000)
        cursor.execute('''
            INSERT INTO income (user_id, income_source, amount, income_date, description, created_at)
            VALUES (?, ?, ?, ?, ?, datetime('now', 'localtime'))
        ''', (user_id, 'Salary', round(random.uniform(80000, 180000), 2), income_date, 'Monthly salary payment'))
        income_added += 1
        
        # Occasional freelance work (25,000 - 80,000 LKR)
        if random.random() > 0.5:
            freelance_desc = random.choice(income_descriptions['Freelance'])
            cursor.execute('''
                INSERT INTO income (user_id, income_source, amount, income_date, description, created_at)
                VALUES (?, ?, ?, ?, ?, datetime('now', 'localtime'))
            ''', (user_id, 'Freelance', round(random.uniform(25000, 80000), 2), income_date, freelance_desc))
            income_added += 1

print(f"Added {income_added} sample income records")

# Create budgets
print("Creating sample budgets...")
budgets_added = 0
for user_id in user_ids:
    # Create budgets for all expense categories
    budget_amounts = {
        'Housing': round(random.uniform(30000, 50000), 2),
        'Food & Dining': round(random.uniform(20000, 35000), 2),
        'Transportation': round(random.uniform(10000, 20000), 2),
        'Bills & Utilities': round(random.uniform(10000, 20000), 2),
        'Entertainment': round(random.uniform(5000, 15000), 2),
        'Healthcare': round(random.uniform(5000, 15000), 2),
        'Shopping': round(random.uniform(5000, 15000), 2),
        'Education': round(random.uniform(5000, 15000), 2),
    }
    
    for category_id, category_name in expense_categories:
        # Current month budget
        start_date = datetime.now().replace(day=1).strftime('%Y-%m-%d')
        last_day = (datetime.now().replace(day=28) + timedelta(days=4)).replace(day=1) - timedelta(days=1)
        end_date = last_day.strftime('%Y-%m-%d')
        
        budget_amount = budget_amounts.get(category_name, round(random.uniform(5000, 15000), 2))
        
        cursor.execute('''
            INSERT INTO budget (user_id, category_id, budget_amount, start_date, end_date, created_at)
            VALUES (?, ?, ?, ?, ?, datetime('now', 'localtime'))
        ''', (user_id, category_id, budget_amount, start_date, end_date))
        budgets_added += 1

print(f"Added {budgets_added} sample budgets")

# Create savings goals
print("Creating sample savings goals...")
goals = [
    ('House Down Payment', 2000000, 730, 'High'),
    ('Emergency Fund', 750000, 365, 'High'),
    ('New Vehicle', 1500000, 540, 'High'),
    ('Wedding Expenses', 1800000, 450, 'High'),
    ('Higher Education', 1000000, 600, 'Medium'),
    ('Dream Vacation to Maldives', 500000, 240, 'Medium'),
    ('Home Renovation', 800000, 365, 'Low'),
]

goals_added = 0
for user_id in user_ids:
    # Add 3-4 goals per user
    user_goals = random.sample(goals, random.randint(3, 4))
    
    for goal_name, target, days, priority in user_goals:
        start_date = datetime.now().strftime('%Y-%m-%d')
        deadline = (datetime.now() + timedelta(days=days)).strftime('%Y-%m-%d')
        
        cursor.execute('''
            INSERT INTO savings_goal (user_id, goal_name, target_amount, start_date, deadline, priority, created_at)
            VALUES (?, ?, ?, ?, ?, ?, datetime('now', 'localtime'))
        ''', (user_id, goal_name, target, start_date, deadline, priority))
        goal_id = cursor.lastrowid
        
        # Add some contributions (5,000 - 50,000 LKR per contribution)
        num_contributions = random.randint(3, 6)
        for contrib_num in range(num_contributions):
            contrib_date = (datetime.now() - timedelta(days=random.randint(1, 80))).strftime('%Y-%m-%d')
            contrib_amount = round(random.uniform(5000, 50000), 2)
            
            cursor.execute('''
                INSERT INTO savings_contribution (goal_id, contribution_amount, contribution_date, description, created_at)
                VALUES (?, ?, ?, ?, datetime('now', 'localtime'))
            ''', (goal_id, contrib_amount, contrib_date, f'Monthly contribution {contrib_num + 1}'))
        
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
print("2. Login with any of these users:")
print("   - kavinda.silva / fs123")
print("   - dilini.fernando / fs123")
print("   - chamath.perera / fs123")
print("   - nimali.jayawardena / fs123")
print("   - tharindu.bandara / fs123")
print("3. Explore the dashboard and features")
print("4. Click 'Sync to Oracle' to transfer data")

# Close connection
conn.close()
print("\nDatabase connection closed.")
