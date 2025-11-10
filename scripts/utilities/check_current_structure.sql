-- ========================================
-- CHECK CURRENT DATABASE STRUCTURE
-- Run BEFORE implementing soft delete
-- ========================================

-- ========================================
-- SQLITE QUERIES
-- ========================================
-- Run these in SQLite (DB Browser or command line)

-- Check current expense table structure
PRAGMA table_info(expense);

-- Check current income table structure
PRAGMA table_info(income);

-- Check current budget table structure
PRAGMA table_info(budget);

-- Check current savings_goal table structure
PRAGMA table_info(savings_goal);

-- Check if is_deleted column already exists (should return empty)
SELECT sql FROM sqlite_master WHERE type='table' AND name='expense';
SELECT sql FROM sqlite_master WHERE type='table' AND name='income';
SELECT sql FROM sqlite_master WHERE type='table' AND name='budget';
SELECT sql FROM sqlite_master WHERE type='table' AND name='savings_goal';

-- Count current records (to verify later nothing was lost)
SELECT 'Expense count:' as table_name, COUNT(*) as count FROM expense
UNION ALL
SELECT 'Income count:', COUNT(*) FROM income
UNION ALL
SELECT 'Budget count:', COUNT(*) FROM budget
UNION ALL
SELECT 'Goal count:', COUNT(*) FROM savings_goal;

-- Check for any records that would be affected
SELECT user_id, COUNT(*) as expense_count FROM expense GROUP BY user_id;
SELECT user_id, COUNT(*) as income_count FROM income GROUP BY user_id;
SELECT user_id, COUNT(*) as budget_count FROM budget GROUP BY user_id;
SELECT user_id, COUNT(*) as goal_count FROM savings_goal GROUP BY user_id;

-- ========================================
-- ORACLE QUERIES
-- ========================================
-- Run these in Oracle SQL Developer

-- Check current finance_expense table structure
SELECT column_name, data_type, data_length, nullable, data_default
FROM user_tab_columns
WHERE table_name = 'FINANCE_EXPENSE'
ORDER BY column_id;

-- Check current finance_income table structure
SELECT column_name, data_type, data_length, nullable, data_default
FROM user_tab_columns
WHERE table_name = 'FINANCE_INCOME'
ORDER BY column_id;

-- Check current finance_budget table structure
SELECT column_name, data_type, data_length, nullable, data_default
FROM user_tab_columns
WHERE table_name = 'FINANCE_BUDGET'
ORDER BY column_id;

-- Check current finance_savings_goal table structure
SELECT column_name, data_type, data_length, nullable, data_default
FROM user_tab_columns
WHERE table_name = 'FINANCE_SAVINGS_GOAL'
ORDER BY column_id;

-- Check if is_deleted column already exists (should return no rows)
SELECT column_name FROM user_tab_columns 
WHERE table_name = 'FINANCE_EXPENSE' AND column_name = 'IS_DELETED';

SELECT column_name FROM user_tab_columns 
WHERE table_name = 'FINANCE_INCOME' AND column_name = 'IS_DELETED';

SELECT column_name FROM user_tab_columns 
WHERE table_name = 'FINANCE_BUDGET' AND column_name = 'IS_DELETED';

SELECT column_name FROM user_tab_columns 
WHERE table_name = 'FINANCE_SAVINGS_GOAL' AND column_name = 'IS_DELETED';

-- Count current records in Oracle (to verify later nothing was lost)
SELECT 'Expense count:' as table_name, COUNT(*) as count FROM finance_expense
UNION ALL
SELECT 'Income count:', COUNT(*) FROM finance_income
UNION ALL
SELECT 'Budget count:', COUNT(*) FROM finance_budget
UNION ALL
SELECT 'Goal count:', COUNT(*) FROM finance_savings_goal;

-- Check for any records that would be affected
SELECT user_id, COUNT(*) as expense_count FROM finance_expense GROUP BY user_id;
SELECT user_id, COUNT(*) as income_count FROM finance_income GROUP BY user_id;
SELECT user_id, COUNT(*) as budget_count FROM finance_budget GROUP BY user_id;
SELECT user_id, COUNT(*) as goal_count FROM finance_savings_goal GROUP BY user_id;

-- ========================================
-- EXPECTED RESULTS
-- ========================================

/*
SQLITE:
- expense table: Should have columns like expense_id, user_id, category_id, amount, etc.
- Should NOT have is_deleted column yet
- Count should match your current data (probably hundreds of records)

ORACLE:
- finance_expense table: Should have similar columns
- Should NOT have IS_DELETED column yet
- Count should match SQLite if previously synced

If you see is_deleted/IS_DELETED columns, they already exist!
In that case, we'll modify the implementation plan.
*/
