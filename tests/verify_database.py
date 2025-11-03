"""
Database Verification Script
Checks SQLite database has all required data
"""
import sqlite3
import os

print("="*60)
print("DATABASE VERIFICATION REPORT")
print("="*60)

db_path = os.path.join(os.path.dirname(__file__), '..', 'sqlite', 'finance_local.db')
conn = sqlite3.connect(db_path)
cursor = conn.cursor()

# Check tables exist
print("\n📋 TABLES:")
cursor.execute("SELECT name FROM sqlite_master WHERE type='table' ORDER BY name")
tables = cursor.fetchall()
for table in tables:
    print(f"  ✅ {table[0]}")

# Check data counts
print("\n📊 DATA COUNTS:")

cursor.execute("SELECT COUNT(*) FROM user")
user_count = cursor.fetchone()[0]
print(f"  Users: {user_count}")

cursor.execute("SELECT COUNT(*) FROM category")
category_count = cursor.fetchone()[0]
print(f"  Categories: {category_count}")

cursor.execute("SELECT COUNT(*) FROM expense")
expense_count = cursor.fetchone()[0]
print(f"  Expenses: {expense_count}")

cursor.execute("SELECT COUNT(*) FROM income")
income_count = cursor.fetchone()[0]
print(f"  Income Records: {income_count}")

cursor.execute("SELECT COUNT(*) FROM budget")
budget_count = cursor.fetchone()[0]
print(f"  Budgets: {budget_count}")

cursor.execute("SELECT COUNT(*) FROM savings_goal")
goal_count = cursor.fetchone()[0]
print(f"  Savings Goals: {goal_count}")

cursor.execute("SELECT COUNT(*) FROM savings_contribution")
contrib_count = cursor.fetchone()[0]
print(f"  Goal Contributions: {contrib_count}")

# Check indexes
print("\n🔍 INDEXES:")
cursor.execute("SELECT COUNT(*) FROM sqlite_master WHERE type='index'")
index_count = cursor.fetchone()[0]
print(f"  Total Indexes: {index_count}")

# Check triggers
print("\n⚙️ TRIGGERS:")
cursor.execute("SELECT name FROM sqlite_master WHERE type='trigger' ORDER BY name")
triggers = cursor.fetchall()
for trigger in triggers:
    print(f"  ✅ {trigger[0]}")

# Check views
print("\n📈 VIEWS:")
cursor.execute("SELECT name FROM sqlite_master WHERE type='view' ORDER BY name")
views = cursor.fetchall()
for view in views:
    print(f"  ✅ {view[0]}")

# Sample data verification
print("\n👤 SAMPLE USERS:")
cursor.execute("SELECT user_id, username, email, full_name FROM user")
users = cursor.fetchall()
for user in users:
    print(f"  ID {user[0]}: {user[1]} ({user[2]}) - {user[3]}")

print("\n💰 EXPENSE SUMMARY (Last 7 Days):")
cursor.execute("""
    SELECT DATE(expense_date) as date, COUNT(*) as count, SUM(amount) as total
    FROM expense
    WHERE expense_date >= date('now', '-7 days')
    GROUP BY DATE(expense_date)
    ORDER BY date DESC
    LIMIT 7
""")
expenses = cursor.fetchall()
for exp in expenses:
    print(f"  {exp[0]}: {exp[1]} transactions, ${exp[2]:.2f}")

print("\n📊 TOP 5 EXPENSE CATEGORIES:")
cursor.execute("""
    SELECT c.category_name, COUNT(e.expense_id) as count, SUM(e.amount) as total
    FROM expense e
    JOIN category c ON e.category_id = c.category_id
    GROUP BY c.category_name
    ORDER BY total DESC
    LIMIT 5
""")
categories = cursor.fetchall()
for cat in categories:
    print(f"  {cat[0]}: {cat[1]} transactions, ${cat[2]:.2f}")

print("\n🎯 SAVINGS GOALS:")
cursor.execute("""
    SELECT goal_name, target_amount, current_amount, 
           ROUND(current_amount * 100.0 / target_amount, 1) as progress_pct
    FROM savings_goal
    ORDER BY goal_name
""")
goals = cursor.fetchall()
for goal in goals:
    print(f"  {goal[0]}: ${goal[2]:.2f} / ${goal[1]:.2f} ({goal[3]}%)")

# Sync status
print("\n🔄 SYNC STATUS:")
cursor.execute("SELECT COUNT(*) FROM expense WHERE is_synced = 0")
unsynced_exp = cursor.fetchone()[0]
cursor.execute("SELECT COUNT(*) FROM expense WHERE is_synced = 1")
synced_exp = cursor.fetchone()[0]
print(f"  Expenses Synced: {synced_exp}")
print(f"  Expenses Not Synced: {unsynced_exp}")

conn.close()

print("\n" + "="*60)
print("✅ DATABASE VERIFICATION COMPLETE")
print("="*60)
print(f"\n📌 Database Location: D:\\DM2_CW\\sqlite\\finance_local.db")
print(f"📌 Ready for demonstration and testing")
print(f"📌 {expense_count} transactions available for screenshots")
print("="*60)
