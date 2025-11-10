"""
Check Current Database Structure
Verify table schemas before implementing soft delete
"""

import sqlite3
import sys

# Connect to SQLite database
try:
    conn = sqlite3.connect('sqlite/finance_local.db')
    cursor = conn.cursor()
    
    print("=" * 70)
    print("SQLITE DATABASE STRUCTURE CHECK")
    print("=" * 70)
    print()
    
    # Tables to check
    tables = ['expense', 'income', 'budget', 'savings_goal']
    
    for table in tables:
        print(f"\n{'=' * 70}")
        print(f"TABLE: {table}")
        print('=' * 70)
        
        # Get table structure
        cursor.execute(f"PRAGMA table_info({table})")
        columns = cursor.fetchall()
        
        print(f"\n{'Column Name':<20} {'Type':<15} {'NotNull':<10} {'Default':<15}")
        print('-' * 70)
        
        has_is_deleted = False
        for col in columns:
            cid, name, type_, notnull, default, pk = col
            print(f"{name:<20} {type_:<15} {str(notnull):<10} {str(default):<15}")
            if name == 'is_deleted':
                has_is_deleted = True
        
        if has_is_deleted:
            print(f"\n⚠️  WARNING: 'is_deleted' column already exists in {table}!")
        else:
            print(f"\n✓ OK: 'is_deleted' column does NOT exist yet in {table}")
        
        # Count records
        cursor.execute(f"SELECT COUNT(*) FROM {table}")
        count = cursor.fetchone()[0]
        print(f"Total records: {count}")
    
    print("\n" + "=" * 70)
    print("RECORD COUNTS BY USER")
    print("=" * 70)
    
    for table in tables:
        print(f"\n{table.upper()}:")
        cursor.execute(f"SELECT user_id, COUNT(*) as count FROM {table} GROUP BY user_id")
        user_counts = cursor.fetchall()
        for user_id, count in user_counts:
            print(f"  User {user_id}: {count} records")
    
    print("\n" + "=" * 70)
    print("FULL TABLE SCHEMAS")
    print("=" * 70)
    
    for table in tables:
        print(f"\n{table.upper()}:")
        cursor.execute(f"SELECT sql FROM sqlite_master WHERE type='table' AND name='{table}'")
        schema = cursor.fetchone()
        if schema:
            print(schema[0])
    
    conn.close()
    
    print("\n" + "=" * 70)
    print("CHECK COMPLETE")
    print("=" * 70)
    print("\n✓ If no 'is_deleted' columns found, we're ready to proceed!")
    print("✓ Record counts noted for verification after changes")
    
except Exception as e:
    print(f"\n❌ Error: {str(e)}")
    sys.exit(1)
