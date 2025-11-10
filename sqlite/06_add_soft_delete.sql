-- ========================================
-- SOFT DELETE IMPLEMENTATION - SQLITE
-- Add is_deleted column to all relevant tables
-- Date: November 10, 2025
-- ========================================

-- Enable foreign key constraints
PRAGMA foreign_keys = ON;

-- ========================================
-- ADD is_deleted COLUMN TO TABLES
-- ========================================

-- EXPENSE Table
ALTER TABLE expense ADD COLUMN is_deleted INTEGER DEFAULT 0 CHECK (is_deleted IN (0, 1));

-- INCOME Table
ALTER TABLE income ADD COLUMN is_deleted INTEGER DEFAULT 0 CHECK (is_deleted IN (0, 1));

-- BUDGET Table
ALTER TABLE budget ADD COLUMN is_deleted INTEGER DEFAULT 0 CHECK (is_deleted IN (0, 1));

-- SAVINGS_GOAL Table
ALTER TABLE savings_goal ADD COLUMN is_deleted INTEGER DEFAULT 0 CHECK (is_deleted IN (0, 1));

-- ========================================
-- VERIFY CHANGES
-- ========================================

-- Check expense table
PRAGMA table_info(expense);

-- Check income table
PRAGMA table_info(income);

-- Check budget table
PRAGMA table_info(budget);

-- Check savings_goal table
PRAGMA table_info(savings_goal);

-- ========================================
-- VERIFY NO DATA LOST
-- ========================================

-- Count records (should match pre-implementation counts)
SELECT 'Expense count' as table_name, COUNT(*) as total, 
       SUM(CASE WHEN is_deleted = 0 THEN 1 ELSE 0 END) as active,
       SUM(CASE WHEN is_deleted = 1 THEN 1 ELSE 0 END) as deleted
FROM expense
UNION ALL
SELECT 'Income count', COUNT(*), 
       SUM(CASE WHEN is_deleted = 0 THEN 1 ELSE 0 END),
       SUM(CASE WHEN is_deleted = 1 THEN 1 ELSE 0 END)
FROM income
UNION ALL
SELECT 'Budget count', COUNT(*), 
       SUM(CASE WHEN is_deleted = 0 THEN 1 ELSE 0 END),
       SUM(CASE WHEN is_deleted = 1 THEN 1 ELSE 0 END)
FROM budget
UNION ALL
SELECT 'Goal count', COUNT(*), 
       SUM(CASE WHEN is_deleted = 0 THEN 1 ELSE 0 END),
       SUM(CASE WHEN is_deleted = 1 THEN 1 ELSE 0 END)
FROM savings_goal;

-- Expected results:
-- All records should have is_deleted = 0 (active)
-- Total counts should match: expense=909, income=25, budget=52, goal=20
