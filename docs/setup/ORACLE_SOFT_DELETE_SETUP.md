# Oracle Soft Delete Implementation Guide

## ⚠️ CRITICAL: This Must Be Done Before Syncing

The Oracle database schema MUST be updated before you can sync deleted records. Without this update, the sync will fail when trying to write the `is_deleted` field.

---

## Steps to Apply Oracle Changes

### 1. Open SQL Developer
- Launch Oracle SQL Developer
- Connect to your Oracle database using the connection you created

### 2. Open the SQL Script
- In SQL Developer: File → Open
- Navigate to: `d:\DM2_CW\oracle\07_add_soft_delete.sql`
- Or copy-paste the content below

### 3. Review the Script
```sql
-- ========================================
-- ADD SOFT DELETE COLUMN TO ALL TABLES
-- Part of soft delete implementation
-- ========================================

-- Add IS_DELETED column to finance_expense
ALTER TABLE finance_expense 
ADD IS_DELETED NUMBER(1) DEFAULT 0;

-- Add IS_DELETED column to finance_income
ALTER TABLE finance_income 
ADD IS_DELETED NUMBER(1) DEFAULT 0;

-- Add IS_DELETED column to finance_budget
ALTER TABLE finance_budget 
ADD IS_DELETED NUMBER(1) DEFAULT 0;

-- Add IS_DELETED column to finance_savings_goal
ALTER TABLE finance_savings_goal 
ADD IS_DELETED NUMBER(1) DEFAULT 0;

-- Add NOT NULL constraint after default is set
ALTER TABLE finance_expense 
MODIFY IS_DELETED NUMBER(1) DEFAULT 0 NOT NULL;

ALTER TABLE finance_income 
MODIFY IS_DELETED NUMBER(1) DEFAULT 0 NOT NULL;

ALTER TABLE finance_budget 
MODIFY IS_DELETED NUMBER(1) DEFAULT 0 NOT NULL;

ALTER TABLE finance_savings_goal 
MODIFY IS_DELETED NUMBER(1) DEFAULT 0 NOT NULL;

-- Verify columns were added
SELECT 'IS_DELETED column added to finance_expense' as status FROM dual;
SELECT 'IS_DELETED column added to finance_income' as status FROM dual;
SELECT 'IS_DELETED column added to finance_budget' as status FROM dual;
SELECT 'IS_DELETED column added to finance_savings_goal' as status FROM dual;
```

### 4. Execute the Script
- Click the "Run Script" button (F5) - NOT the "Run Statement" button
- Wait for all statements to execute
- Check the Script Output tab for success messages

### 5. Verify the Changes
Run this verification query:
```sql
-- Verify all columns exist
SELECT 
    table_name,
    column_name,
    data_type,
    data_default,
    nullable
FROM user_tab_columns
WHERE table_name IN ('FINANCE_EXPENSE', 'FINANCE_INCOME', 'FINANCE_BUDGET', 'FINANCE_SAVINGS_GOAL')
  AND column_name = 'IS_DELETED'
ORDER BY table_name;
```

**Expected Result**: 4 rows showing:
- TABLE_NAME: FINANCE_EXPENSE, FINANCE_INCOME, FINANCE_BUDGET, FINANCE_SAVINGS_GOAL
- COLUMN_NAME: IS_DELETED
- DATA_TYPE: NUMBER
- DATA_DEFAULT: 0
- NULLABLE: N (not null)

### 6. Test with Sample Data
```sql
-- Check current record count
SELECT 'Expense' as entity, COUNT(*) as total FROM finance_expense
UNION ALL
SELECT 'Income', COUNT(*) FROM finance_income
UNION ALL
SELECT 'Budget', COUNT(*) FROM finance_budget
UNION ALL
SELECT 'Goal', COUNT(*) FROM finance_savings_goal;

-- Check that all IS_DELETED values are 0 (none deleted yet)
SELECT 
    'Expense' as entity,
    COUNT(*) as total,
    SUM(CASE WHEN IS_DELETED = 0 THEN 1 ELSE 0 END) as active,
    SUM(CASE WHEN IS_DELETED = 1 THEN 1 ELSE 0 END) as deleted
FROM finance_expense
UNION ALL
SELECT 'Income', COUNT(*), 
    SUM(CASE WHEN IS_DELETED = 0 THEN 1 ELSE 0 END),
    SUM(CASE WHEN IS_DELETED = 1 THEN 1 ELSE 0 END)
FROM finance_income
UNION ALL
SELECT 'Budget', COUNT(*),
    SUM(CASE WHEN IS_DELETED = 0 THEN 1 ELSE 0 END),
    SUM(CASE WHEN IS_DELETED = 1 THEN 1 ELSE 0 END)
FROM finance_budget
UNION ALL
SELECT 'Goal', COUNT(*),
    SUM(CASE WHEN IS_DELETED = 0 THEN 1 ELSE 0 END),
    SUM(CASE WHEN IS_DELETED = 1 THEN 1 ELSE 0 END)
FROM finance_savings_goal;
```

**Expected Result**: 
- All DELETED counts should be 0
- All ACTIVE counts should equal TOTAL

---

## What This Does

1. **Adds IS_DELETED Column**: Adds a new column to track deletion status
   - Type: NUMBER(1) - single digit (0 or 1)
   - Default: 0 (active/not deleted)
   - Values: 0 = Active, 1 = Deleted

2. **Sets Default Value**: All existing records get IS_DELETED = 0 automatically

3. **Adds NOT NULL Constraint**: Ensures every record has a value (no NULLs)

4. **Preserves Data**: No records are deleted, no data is lost

---

## Troubleshooting

### Error: "Column already exists"
**Cause**: Script was already run  
**Solution**: Column already exists, no action needed. Verify with step 5.

### Error: "Table does not exist"
**Cause**: Wrong schema or connection  
**Solution**: Verify you're connected to the correct Oracle database

### Error: "Insufficient privileges"
**Cause**: User doesn't have ALTER TABLE permission  
**Solution**: Connect as a user with DDL privileges or contact DBA

### Error: "Cannot add NOT NULL constraint"
**Cause**: Some records have NULL in IS_DELETED  
**Solution**: Update NULLs to 0 first:
```sql
UPDATE finance_expense SET IS_DELETED = 0 WHERE IS_DELETED IS NULL;
UPDATE finance_income SET IS_DELETED = 0 WHERE IS_DELETED IS NULL;
UPDATE finance_budget SET IS_DELETED = 0 WHERE IS_DELETED IS NULL;
UPDATE finance_savings_goal SET IS_DELETED = 0 WHERE IS_DELETED IS NULL;
COMMIT;
```

---

## After Oracle Update

Once this is complete, you can:

1. ✅ Test soft delete in the web application
2. ✅ Sync deleted records to Oracle
3. ✅ Verify deleted records are hidden from UI
4. ✅ Run reports that exclude deleted records

---

## Testing the Implementation

### 1. In Web Application
```
1. Login to the app
2. Go to Expenses
3. Add a test expense: "Test Delete" - $1.00
4. Note the expense appears in the list
5. Click Delete on that expense
6. Verify it disappears from the list
7. Check Dashboard - verify it's NOT counted in totals
```

### 2. Verify in SQLite
```sql
-- Should show is_deleted = 1
SELECT expense_id, description, amount, is_deleted, is_synced
FROM expense
WHERE description = 'Test Delete';
```

### 3. Sync to Oracle
```
1. In the app, click "Sync to Oracle" button
2. Wait for success message
3. Check sync logs
```

### 4. Verify in Oracle
```sql
-- Should show IS_DELETED = 1
SELECT EXPENSE_ID, DESCRIPTION, AMOUNT, IS_DELETED
FROM finance_expense
WHERE DESCRIPTION = 'Test Delete';
```

### 5. Verify Reports
```sql
-- This expense should NOT appear in reports
SELECT 
    c.CATEGORY_NAME,
    SUM(e.AMOUNT) as total
FROM finance_expense e
JOIN finance_category c ON e.CATEGORY_ID = c.CATEGORY_ID
WHERE e.IS_DELETED = 0  -- Only active records
GROUP BY c.CATEGORY_NAME;
```

---

## Important Notes

⚠️ **Before Sync**: Oracle schema MUST be updated  
⚠️ **Data Safety**: No records will be lost  
⚠️ **Backwards Compatibility**: Existing records automatically get IS_DELETED = 0  
⚠️ **Sync Required**: Deleted records must be synced to appear in Oracle  

✅ **SQLite**: Already updated and working  
✅ **Views**: Already updated to filter deleted records  
✅ **Sync Manager**: Already updated to handle is_deleted  
✅ **Web App**: Already updated to use soft delete  

---

## Next Action

**Run the Oracle script now**, then proceed with testing!

File location: `d:\DM2_CW\oracle\07_add_soft_delete.sql`
