-- Fix for Missing fiscal_year and fiscal_month columns
-- Run this in SQL Developer if you get ORA-00904 error

-- Check if columns exist
SELECT column_name 
FROM user_tab_columns 
WHERE table_name = 'FINANCE_INCOME'
ORDER BY column_name;

-- If fiscal_year and fiscal_month are missing, add them:
ALTER TABLE finance_income ADD (
    fiscal_year NUMBER(4),
    fiscal_month NUMBER(2)
);

-- Update existing records to populate fiscal columns
UPDATE finance_income
SET fiscal_year = EXTRACT(YEAR FROM income_date),
    fiscal_month = EXTRACT(MONTH FROM income_date)
WHERE fiscal_year IS NULL;

COMMIT;

-- Verify
SELECT COUNT(*) as total_records,
       COUNT(fiscal_year) as with_fiscal_year,
       COUNT(fiscal_month) as with_fiscal_month
FROM finance_income;

-- Also check finance_expense table
SELECT column_name 
FROM user_tab_columns 
WHERE table_name = 'FINANCE_EXPENSE'
ORDER BY column_name;

-- If needed for expense table too:
-- UPDATE finance_expense
-- SET fiscal_year = EXTRACT(YEAR FROM expense_date),
--     fiscal_month = EXTRACT(MONTH FROM expense_date)
-- WHERE fiscal_year IS NULL;
-- COMMIT;

SELECT 'Columns added successfully!' AS status FROM DUAL;

