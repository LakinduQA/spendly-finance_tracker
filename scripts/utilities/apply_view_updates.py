import sqlite3
import os

def apply_view_updates():
    """Apply view updates to SQLite database"""
    db_path = r'd:\DM2_CW\sqlite\finance_local.db'
    sql_file = r'd:\DM2_CW\sqlite\07_update_views.sql'
    
    if not os.path.exists(db_path):
        print(f"❌ Database not found: {db_path}")
        return
    
    if not os.path.exists(sql_file):
        print(f"❌ SQL file not found: {sql_file}")
        return
    
    print(f"📂 Connecting to: {db_path}")
    print(f"📄 Reading SQL from: {sql_file}")
    
    try:
        # Read SQL file
        with open(sql_file, 'r') as f:
            sql_script = f.read()
        
        # Connect and execute
        conn = sqlite3.connect(db_path)
        cursor = conn.cursor()
        
        # Execute the entire script
        cursor.executescript(sql_script)
        conn.commit()
        
        print("\n✅ View updates applied successfully!")
        
        # Verify views exist
        cursor.execute("""
            SELECT name FROM sqlite_master 
            WHERE type='view' 
            AND name IN ('v_budget_performance', 'v_savings_progress', 'v_expense_summary')
            ORDER BY name
        """)
        
        views = cursor.fetchall()
        print("\n📋 Updated views:")
        for view in views:
            print(f"   ✓ {view[0]}")
        
        # Test each view
        print("\n🔍 Testing views:")
        for view_name in ['v_budget_performance', 'v_savings_progress', 'v_expense_summary']:
            cursor.execute(f"SELECT COUNT(*) FROM {view_name}")
            count = cursor.fetchone()[0]
            print(f"   {view_name}: {count} rows")
        
        conn.close()
        print("\n✅ All done!")
        
    except Exception as e:
        print(f"\n❌ Error: {e}")
        raise

if __name__ == "__main__":
    apply_view_updates()
