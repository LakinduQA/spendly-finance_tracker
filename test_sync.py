"""
Quick Sync Test Script
Runs synchronization for all users without prompts
"""
import sys
sys.path.append('d:/DM2_CW/synchronization')

from sync_manager import DatabaseSync

print("\n" + "=" * 60)
print("AUTOMATED SYNCHRONIZATION TEST")
print("=" * 60 + "\n")

print("Initializing synchronization...")
sync = DatabaseSync('d:/DM2_CW/synchronization/config.ini')

# Get all users from SQLite
if sync.connect_sqlite():
    cursor = sync.sqlite_conn.cursor()
    cursor.execute("SELECT user_id, username FROM user")
    users = cursor.fetchall()
    
    print(f"\nFound {len(users)} users to sync:")
    for user in users:
        print(f"  - User ID {user[0]}: {user[1]}")
    
    # Sync first user
    if users:
        user_id = users[0][0]
        print(f"\n🔄 Syncing User ID {user_id}...")
        success = sync.sync_all(user_id, 'Manual')
        
        if success:
            print("\n✅ SYNCHRONIZATION SUCCESSFUL!")
        else:
            print("\n❌ SYNCHRONIZATION FAILED - Check logs above")
    else:
        print("\n⚠️ No users found in database")
else:
    print("\n❌ Failed to connect to SQLite database")

print("\n" + "=" * 60)
