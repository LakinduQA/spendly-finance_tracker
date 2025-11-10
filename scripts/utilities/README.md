# Database Utilities

This folder contains one-time migration scripts and diagnostic utilities used during database maintenance and feature implementation.

## Migration Scripts (Already Executed)

### `apply_soft_delete_sqlite.py`
**Purpose**: Applied soft delete schema changes to SQLite database  
**Status**: ✅ Executed successfully  
**What it did**:
- Added `is_deleted` column to 4 tables (expense, income, budget, savings_goal)
- Verified data integrity (no records lost)
- Added CHECK constraint to ensure is_deleted is 0 or 1

**Do NOT run again** - columns already exist in database.

### `apply_view_updates.py`
**Purpose**: Updated database views to filter deleted records  
**Status**: ✅ Executed successfully  
**What it did**:
- Updated `v_budget_performance` view
- Updated `v_savings_progress` view
- Updated `v_expense_summary` view
- Added `is_deleted` filters to all views

**Do NOT run again** - views already updated.

## Diagnostic Utilities

### `check_structure.py`
**Purpose**: Verify SQLite database structure before making schema changes  
**Usage**: `python scripts/utilities/check_structure.py`  
**When to use**: Before applying major schema changes to verify current state

**Output**:
- Table structures with column details
- Record counts by user
- Checks if `is_deleted` column exists
- Full table schemas

### `check_current_structure.sql`
**Purpose**: SQL queries for manual database inspection  
**Usage**: Copy queries into DB Browser for SQLite or Oracle SQL Developer  
**Contains**:
- SQLite queries to check table structures and record counts
- Oracle queries to check table structures and record counts
- Verification queries to check if soft delete columns exist

## History

These files were created during the **Soft Delete Implementation** (November 2025):
- Implemented to fix critical bug where deletions didn't sync to Oracle
- Converted hard DELETE operations to soft delete (is_deleted flag)
- Ensured data integrity across SQLite and Oracle databases

## Notes

- These scripts use relative paths from project root (`sqlite/finance_local.db`)
- If you need to run them from this folder, update the paths accordingly
- Always backup your database before running any migration scripts
- Check git history for detailed implementation notes
