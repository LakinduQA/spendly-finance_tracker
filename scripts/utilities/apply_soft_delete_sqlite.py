"""
Apply Soft Delete Schema Changes to SQLite
"""

import sqlite3
import sys

print("=" * 70)
print("SOFT DELETE IMPLEMENTATION - SQLITE SCHEMA UPDATE")
print("=" * 70)

try:
    # Connect to database
    conn = sqlite3.connect('sqlite/finance_local.db')
    cursor = conn.cursor()
    
    print("\n[1/4] Backing up current record counts...")
    
    # Get baseline counts
    cursor.execute("SELECT COUNT(*) FROM expense")
    expense_count = cursor.fetchone()[0]
    
    cursor.execute("SELECT COUNT(*) FROM income")
    income_count = cursor.fetchone()[0]
    
    cursor.execute("SELECT COUNT(*) FROM budget")
    budget_count = cursor.fetchone()[0]
    
    cursor.execute("SELECT COUNT(*) FROM savings_goal")
    goal_count = cursor.fetchone()[0]
    
    print(f"   Expense: {expense_count} records")
    print(f"   Income: {income_count} records")
    print(f"   Budget: {budget_count} records")
    print(f"   Goals: {goal_count} records")
    
    print("\n[2/4] Adding is_deleted column to tables...")
    
    # Add is_deleted column to expense
    try:
        cursor.execute("""
            ALTER TABLE expense 
            ADD COLUMN is_deleted INTEGER DEFAULT 0 CHECK (is_deleted IN (0, 1))
        """)
        print("   ✓ expense table updated")
    except Exception as e:
        if "duplicate column name" in str(e).lower():
            print("   ⚠ expense.is_deleted already exists (skipping)")
        else:
            raise
    
    # Add is_deleted column to income
    try:
        cursor.execute("""
            ALTER TABLE income 
            ADD COLUMN is_deleted INTEGER DEFAULT 0 CHECK (is_deleted IN (0, 1))
        """)
        print("   ✓ income table updated")
    except Exception as e:
        if "duplicate column name" in str(e).lower():
            print("   ⚠ income.is_deleted already exists (skipping)")
        else:
            raise
    
    # Add is_deleted column to budget
    try:
        cursor.execute("""
            ALTER TABLE budget 
            ADD COLUMN is_deleted INTEGER DEFAULT 0 CHECK (is_deleted IN (0, 1))
        """)
        print("   ✓ budget table updated")
    except Exception as e:
        if "duplicate column name" in str(e).lower():
            print("   ⚠ budget.is_deleted already exists (skipping)")
        else:
            raise
    
    # Add is_deleted column to savings_goal
    try:
        cursor.execute("""
            ALTER TABLE savings_goal 
            ADD COLUMN is_deleted INTEGER DEFAULT 0 CHECK (is_deleted IN (0, 1))
        """)
        print("   ✓ savings_goal table updated")
    except Exception as e:
        if "duplicate column name" in str(e).lower():
            print("   ⚠ savings_goal.is_deleted already exists (skipping)")
        else:
            raise
    
    print("\n[3/4] Verifying no data was lost...")
    
    # Verify counts
    cursor.execute("SELECT COUNT(*) FROM expense")
    new_expense_count = cursor.fetchone()[0]
    
    cursor.execute("SELECT COUNT(*) FROM income")
    new_income_count = cursor.fetchone()[0]
    
    cursor.execute("SELECT COUNT(*) FROM budget")
    new_budget_count = cursor.fetchone()[0]
    
    cursor.execute("SELECT COUNT(*) FROM savings_goal")
    new_goal_count = cursor.fetchone()[0]
    
    if (expense_count == new_expense_count and 
        income_count == new_income_count and 
        budget_count == new_budget_count and 
        goal_count == new_goal_count):
        print("   ✓ All record counts match (no data lost)")
    else:
        print("   ✗ WARNING: Record counts changed!")
        print(f"     Expense: {expense_count} -> {new_expense_count}")
        print(f"     Income: {income_count} -> {new_income_count}")
        print(f"     Budget: {budget_count} -> {new_budget_count}")
        print(f"     Goals: {goal_count} -> {new_goal_count}")
        raise Exception("Data integrity check failed!")
    
    print("\n[4/4] Verifying column structures...")
    
    # Verify columns exist
    cursor.execute("PRAGMA table_info(expense)")
    expense_cols = [col[1] for col in cursor.fetchall()]
    
    cursor.execute("PRAGMA table_info(income)")
    income_cols = [col[1] for col in cursor.fetchall()]
    
    cursor.execute("PRAGMA table_info(budget)")
    budget_cols = [col[1] for col in cursor.fetchall()]
    
    cursor.execute("PRAGMA table_info(savings_goal)")
    goal_cols = [col[1] for col in cursor.fetchall()]
    
    if ('is_deleted' in expense_cols and 
        'is_deleted' in income_cols and 
        'is_deleted' in budget_cols and 
        'is_deleted' in goal_cols):
        print("   ✓ is_deleted column exists in all tables")
    else:
        print("   ✗ is_deleted column missing from some tables!")
        raise Exception("Column verification failed!")
    
    # Commit changes
    conn.commit()
    
    print("\n" + "=" * 70)
    print("SUCCESS: SQLite schema updated successfully!")
    print("=" * 70)
    print("\nChanges applied:")
    print("  ✓ expense table: Added is_deleted column")
    print("  ✓ income table: Added is_deleted column")
    print("  ✓ budget table: Added is_deleted column")
    print("  ✓ savings_goal table: Added is_deleted column")
    print(f"\nData integrity verified:")
    print(f"  ✓ {expense_count} expenses preserved")
    print(f"  ✓ {income_count} income records preserved")
    print(f"  ✓ {budget_count} budgets preserved")
    print(f"  ✓ {goal_count} goals preserved")
    
    conn.close()
    
except Exception as e:
    print(f"\n❌ Error: {str(e)}")
    if 'conn' in locals():
        conn.rollback()
        conn.close()
    sys.exit(1)
