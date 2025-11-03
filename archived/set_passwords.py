"""
Set password 'fs123' for all existing users
"""
import sqlite3
from werkzeug.security import generate_password_hash

# Generate hash for password 'fs123'
password_hash = generate_password_hash('fs123')
print(f"Generated hash: {password_hash[:50]}...")

# Connect to database
conn = sqlite3.connect('finance_local.db')
cursor = conn.cursor()

# Get all users
cursor.execute("SELECT user_id, username FROM user")
users = cursor.fetchall()

print(f"\nFound {len(users)} users:")
for user_id, username in users:
    print(f"  - {username} (ID: {user_id})")

# Update all users with the new password hash
cursor.execute("UPDATE user SET password_hash = ?", (password_hash,))
conn.commit()

print(f"\n✅ Updated password for all {len(users)} users to: fs123")

# Verify the update
cursor.execute("SELECT user_id, username, LENGTH(password_hash) as hash_len FROM user")
results = cursor.fetchall()
print("\nVerification:")
for user_id, username, hash_len in results:
    print(f"  - {username}: password_hash length = {hash_len}")

conn.close()
print("\n✅ Done!")
