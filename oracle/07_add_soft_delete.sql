-- ========================================
-- SOFT DELETE IMPLEMENTATION - ORACLE
-- Add IS_DELETED column to all relevant tables
-- Date: November 10, 2025
-- ========================================

-- ========================================
-- ADD IS_DELETED COLUMN TO TABLES
-- ========================================

-- EXPENSE Table
ALTER TABLE finance_expense 
ADD (is_deleted NUMBER(1) DEFAULT 0 NOT NULL CHECK (is_deleted IN (0, 1)));

-- INCOME Table
ALTER TABLE finance_income 
ADD (is_deleted NUMBER(1) DEFAULT 0 NOT NULL CHECK (is_deleted IN (0, 1)));

-- BUDGET Table
ALTER TABLE finance_budget 
ADD (is_deleted NUMBER(1) DEFAULT 0 NOT NULL CHECK (is_deleted IN (0, 1)));

-- SAVINGS_GOAL Table
ALTER TABLE finance_savings_goal 
ADD (is_deleted NUMBER(1) DEFAULT 0 NOT NULL CHECK (is_deleted IN (0, 1)));

-- ========================================
-- VERIFY CHANGES
-- ========================================

-- Check columns were added
SELECT 'finance_expense' as table_name, column_name, data_type, data_default
FROM user_tab_columns
WHERE table_name = 'FINANCE_EXPENSE' AND column_name = 'IS_DELETED'
UNION ALL
SELECT 'finance_income', column_name, data_type, data_default
FROM user_tab_columns
WHERE table_name = 'FINANCE_INCOME' AND column_name = 'IS_DELETED'
UNION ALL
SELECT 'finance_budget', column_name, data_type, data_default
FROM user_tab_columns
WHERE table_name = 'FINANCE_BUDGET' AND column_name = 'IS_DELETED'
UNION ALL
SELECT 'finance_savings_goal', column_name, data_type, data_default
FROM user_tab_columns
WHERE table_name = 'FINANCE_SAVINGS_GOAL' AND column_name = 'IS_DELETED';

-- ========================================
-- VERIFY NO DATA LOST
-- ========================================

-- Count records (should match current Oracle data)
SELECT 'Expense count' as table_name, 
       COUNT(*) as total,
       SUM(CASE WHEN is_deleted = 0 THEN 1 ELSE 0 END) as active,
       SUM(CASE WHEN is_deleted = 1 THEN 1 ELSE 0 END) as deleted
FROM finance_expense
UNION ALL
SELECT 'Income count', 
       COUNT(*),
       SUM(CASE WHEN is_deleted = 0 THEN 1 ELSE 0 END),
       SUM(CASE WHEN is_deleted = 1 THEN 1 ELSE 0 END)
FROM finance_income
UNION ALL
SELECT 'Budget count', 
       COUNT(*),
       SUM(CASE WHEN is_deleted = 0 THEN 1 ELSE 0 END),
       SUM(CASE WHEN is_deleted = 1 THEN 1 ELSE 0 END)
FROM finance_budget
UNION ALL
SELECT 'Goal count', 
       COUNT(*),
       SUM(CASE WHEN is_deleted = 0 THEN 1 ELSE 0 END),
       SUM(CASE WHEN is_deleted = 1 THEN 1 ELSE 0 END)
FROM finance_savings_goal;

-- Expected: All records should have is_deleted = 0 (active)

-- Commit changes
COMMIT;

SELECT 'Soft delete columns added successfully!' as status FROM DUAL;
