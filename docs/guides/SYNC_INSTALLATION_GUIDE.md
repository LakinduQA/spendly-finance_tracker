# 🔧 PL/SQL Installation & Sync Testing Guide

## ⚠️ SYNCHRONIZATION TEST RESULT

**Status**: ❌ Oracle Connection Timeout  
**Error**: `ORA-12170: TNS:Connect timeout occurred`

### Possible Causes:
1. Oracle service not running on 172.20.10.4
2. Firewall blocking port 1521
3. Oracle database stopped/unavailable

---

## ✅ WHAT YOU NEED TO DO NOW

### Step 1: Check Oracle Service (5 minutes)

**On the Oracle server (172.20.10.4):**

```powershell
# Check if Oracle service is running
Get-Service | Where-Object {$_.DisplayName -like "*Oracle*"}

# If not running, start it:
Start-Service OracleServiceXE
```

**Or use Services GUI:**
1. Press `Win + R`, type `services.msc`
2. Find "OracleServiceXE"
3. If stopped, right-click → Start

### Step 2: Test Oracle Connection (2 minutes)

**Try connecting with SQL Developer:**
- Host: 172.20.10.4
- Port: 1521
- SID: xe
- Username: system
- Password: oracle123

**If connection fails:**
- Oracle service is down
- Need to check network connectivity
- Check firewall settings

---

## 📦 PL/SQL PACKAGE INSTALLATION

### Method 1: Using SQL Developer (Recommended) ⭐

#### Package 1: CRUD Operations (5 minutes)

1. **Open SQL Developer**
2. **Connect** to Oracle: `system/oracle123@172.20.10.4:1521/xe`
3. **File → Open**: `d:\DM2_CW\oracle\02_plsql_crud_package.sql`
4. **Press F5** (Run Script button) or **Ctrl+F5**
5. **Wait** for completion (may take 1-2 minutes)
6. **Look** for message: `Package created.` and `Package body created.`

#### Package 2: Reports (3 minutes)

1. **File → Open**: `d:\DM2_CW\oracle\03_reports_package.sql`
2. **Press F5** again
3. **Wait** for: `Package created.` and `Package body created.`

#### Verification (1 minute)

Run this query in SQL Developer:

```sql
-- Check packages exist
SELECT object_name, object_type, status 
FROM user_objects 
WHERE object_type IN ('PACKAGE', 'PACKAGE BODY')
ORDER BY object_name, object_type;
```

**Expected Output:**
```
PKG_FINANCE_CRUD      PACKAGE        VALID
PKG_FINANCE_CRUD      PACKAGE BODY   VALID
PKG_FINANCE_REPORTS   PACKAGE        VALID
PKG_FINANCE_REPORTS   PACKAGE BODY   VALID
```

---

### Method 2: Using SQL*Plus (Alternative)

If SQL Developer doesn't work:

```bash
sqlplus system/oracle123@172.20.10.4:1521/xe

SQL> @d:\DM2_CW\oracle\02_plsql_crud_package.sql
SQL> @d:\DM2_CW\oracle\03_reports_package.sql
SQL> exit
```

---

## 🔄 SYNCHRONIZATION TESTING

### Once Oracle Is Connected:

**Option 1: Automated Test (Quick)**

```powershell
cd d:\DM2_CW
python test_sync.py
```

This will:
- ✅ Connect to SQLite
- ✅ Connect to Oracle  
- ✅ Sync User ID 1 (john_doe)
- ✅ Transfer 367 expenses + 8 income + 8 budgets + 5 goals
- ✅ Show success message

**Option 2: Manual Test (Interactive)**

```powershell
cd d:\DM2_CW\synchronization
python sync_manager.py
# When prompted:
# User ID: 1 (press Enter)
# Sync type: Manual (press Enter)
```

### Verify Sync Success in SQL Developer:

```sql
-- Check data arrived
SELECT 'USERS' as table_name, COUNT(*) as count FROM FINANCE_USER
UNION ALL
SELECT 'EXPENSES', COUNT(*) FROM FINANCE_EXPENSE
UNION ALL
SELECT 'INCOME', COUNT(*) FROM FINANCE_INCOME
UNION ALL
SELECT 'BUDGETS', COUNT(*) FROM FINANCE_BUDGET
UNION ALL
SELECT 'GOALS', COUNT(*) FROM FINANCE_SAVINGS_GOAL;
```

**Expected Results:**
```
Table         Count
---------     -----
USERS         2      (john_doe, jane_smith)
EXPENSES      367    (all transactions)
INCOME        8      (salary + freelance)
BUDGETS       8      (monthly budgets)
GOALS         5      (savings goals)
```

---

## 🐛 TROUBLESHOOTING

### Issue: "ORA-12170: TNS:Connect timeout"

**Solution:**
1. Check Oracle service is running
2. Ping the server: `ping 172.20.10.4`
3. Test port: `Test-NetConnection 172.20.10.4 -Port 1521`
4. Check firewall settings

### Issue: "Package created with compilation errors"

**Solution:**
```sql
-- See what's wrong
SHOW ERRORS PACKAGE pkg_finance_crud;
SHOW ERRORS PACKAGE BODY pkg_finance_crud;
```

Common fixes:
- Table names must match (FINANCE_USER, FINANCE_EXPENSE, etc.)
- Sequences must exist (seq_user_id, seq_expense_id, etc.)
- Run `oracle/01_create_database.sql` first if tables missing

### Issue: "Table or view does not exist"

**Solution:**
- Make sure you ran `oracle/01_create_database.sql` first
- Check tables exist:
```sql
SELECT table_name FROM user_tables WHERE table_name LIKE 'FINANCE%';
```

### Issue: Sync hangs or takes too long

**Solution:**
- Check network speed to Oracle server
- Reduce batch size in `synchronization/config.ini`:
```ini
[sync]
batch_size = 50  # Change from 100 to 50
```

---

## 📊 WHAT WILL BE SYNCED

### From SQLite → Oracle:

| Table | Records | Notes |
|-------|---------|-------|
| user | 2 | john_doe, jane_smith |
| expense | 367 | Last 90 days transactions |
| income | 8 | Monthly salaries + freelance |
| budget | 8 | Current month budgets |
| savings_goal | 5 | Active goals |
| savings_contribution | 19 | Goal contributions |

**Total**: ~409 records

**Sync Time**: 30-60 seconds (depends on network)

---

## ✅ SUCCESS INDICATORS

### After PL/SQL Installation:
- ✅ "Package created." message (no errors)
- ✅ "Package body created." message
- ✅ Status shows "VALID" (not "INVALID")
- ✅ Can run: `SELECT pkg_finance_crud.get_user(1) FROM DUAL;`

### After Synchronization:
- ✅ Console shows: "Synchronization completed successfully!"
- ✅ Shows: "Total records synced: 409"
- ✅ No error messages in log
- ✅ SQLite expenses marked: `is_synced = 1`
- ✅ Oracle tables populated with data

---

## 📝 CURRENT STATUS

### Completed ✅:
- [x] SQLite database created
- [x] 367 expenses populated
- [x] PL/SQL scripts written (ready to install)
- [x] Sync script ready

### Pending ⚠️:
- [ ] Oracle connection (currently timeout)
- [ ] PL/SQL packages installation
- [ ] Synchronization test

### Next Steps:
1. **Check Oracle service** on 172.20.10.4
2. **Install PL/SQL packages** in SQL Developer
3. **Run sync test**: `python d:\DM2_CW\test_sync.py`
4. **Verify data** in Oracle tables

---

## 🎯 ESTIMATED TIME

If Oracle is running:
- PL/SQL installation: 10 minutes
- Sync test: 5 minutes
- Verification: 5 minutes
- **Total: 20 minutes**

If Oracle needs troubleshooting:
- Start Oracle service: 5 minutes
- Then above steps: 20 minutes
- **Total: 25 minutes**

---

## 📞 QUICK COMMANDS REFERENCE

```powershell
# Check Oracle service (on Oracle server)
Get-Service OracleServiceXE

# Test network connectivity
Test-NetConnection 172.20.10.4 -Port 1521

# Run sync test
cd d:\DM2_CW
python test_sync.py

# Verify database
python verify_database.py
```

```sql
-- SQL Developer queries

-- Check PL/SQL packages
SELECT object_name, object_type, status FROM user_objects 
WHERE object_type LIKE 'PACKAGE%';

-- Check synced data
SELECT COUNT(*) FROM FINANCE_EXPENSE;

-- View sync log
SELECT * FROM FINANCE_SYNC_LOG ORDER BY sync_start_time DESC;
```

---

**Status**: Waiting for Oracle connection  
**Next Action**: Start Oracle service, then install packages  
**Time Needed**: 20-25 minutes

---

*Last Updated: November 1, 2025 - 19:33*
