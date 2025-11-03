"""
Create SQLite database from SQL script
"""
import sqlite3

# Connect to database (creates if doesn't exist)
conn = sqlite3.connect('finance_local.db')
cursor = conn.cursor()

print("Reading SQL script...")
with open('01_create_database.sql', 'r', encoding='utf-8') as f:
    sql_script = f.read()

print("Executing SQL script...")
cursor.executescript(sql_script)

conn.commit()
conn.close()

print("✅ Database created successfully!")
print("Location: D:\\DM2_CW\\sqlite\\finance_local.db")
