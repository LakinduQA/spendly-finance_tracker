"""
Sync Test with Extended Timeout
"""
import sys
import os

# Add synchronization folder to path
sys.path.insert(0, 'D:/DM2_CW/synchronization')

# Set Oracle connection timeout
os.environ['TNS_ADMIN'] = ''

print("\n" + "=" * 70)
print("SYNCHRONIZATION TEST - Extended Timeout")
print("=" * 70 + "\n")

try:
    from sync_manager import DatabaseSync
    
    print("📦 Initializing sync manager...")
    sync = DatabaseSync('D:/DM2_CW/synchronization/config.ini')
    
    print("🔗 Connecting to SQLite...")
    if not sync.connect_sqlite():
        print("❌ SQLite connection failed!")
        sys.exit(1)
    print("✅ SQLite connected")
    
    print("\n🔗 Connecting to Oracle (this may take 30-60 seconds)...")
    print("   Host: 172.20.10.4:1521/xe")
    print("   Please wait...")
    
    if not sync.connect_oracle():
        print("\n❌ Oracle connection failed!")
        print("\n⚠️  POSSIBLE REASONS:")
        print("   1. Oracle service not running on 172.20.10.4")
        print("   2. Wrong credentials (system/oracle123)")
        print("   3. SID 'xe' doesn't exist")
        print("\n📖 See SYNC_INSTALLATION_GUIDE.md for help")
        sys.exit(1)
    
    print("✅ Oracle connected successfully!")
    
    # Get user count
    cursor = sync.sqlite_conn.cursor()
    cursor.execute("SELECT COUNT(*) FROM user")
    user_count = cursor.fetchone()[0]
    
    cursor.execute("SELECT user_id, username FROM user LIMIT 1")
    user = cursor.fetchone()
    
    if user:
        user_id = user[0]
        username = user[1]
        
        print(f"\n🔄 Starting sync for User ID {user_id} ({username})...")
        print("=" * 70)
        
        success = sync.sync_all(user_id, 'Manual')
        
        if success:
            print("\n" + "=" * 70)
            print("✅ SYNCHRONIZATION COMPLETED SUCCESSFULLY!")
            print("=" * 70)
            print(f"\n📊 Total records synced: {sync.records_synced}")
            print("\n🎉 Data is now in Oracle database!")
            print("\n📖 Verify in SQL Developer:")
            print("   SELECT COUNT(*) FROM FINANCE_EXPENSE;")
            print("   SELECT COUNT(*) FROM FINANCE_INCOME;")
            print("   SELECT COUNT(*) FROM FINANCE_BUDGET;")
            print("=" * 70)
        else:
            print("\n❌ Synchronization failed - check logs above")
    else:
        print("⚠️  No users found in SQLite database")
        
except ImportError as e:
    print(f"❌ Import error: {e}")
    print("   Make sure cx_Oracle is installed: pip install cx_Oracle")
except Exception as e:
    print(f"❌ Unexpected error: {e}")
    import traceback
    traceback.print_exc()
finally:
    print("\n" + "=" * 70)
