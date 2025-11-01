-- ========================================
-- QUICK FIX: Run this if you got errors
-- Personal Finance Oracle Database
-- ========================================

-- Step 1: Make sure you're connected as finance_admin or have proper privileges
-- If not, run: CONN finance_admin/FinanceSecure2025

-- Step 2: Check if tables already exist (from partial run)
SELECT table_name FROM user_tables WHERE table_name LIKE 'FINANCE_%' ORDER BY table_name;

-- Step 3: If categories table exists but is empty, populate it manually:

-- Clear any partial data
DELETE FROM finance_category;
COMMIT;

-- Insert Expense Categories
INSERT INTO finance_category (category_name, category_type, description, is_active, display_order) 
VALUES ('Food & Dining', 'EXPENSE', 'Groceries, restaurants, food delivery', 1, 1);

INSERT INTO finance_category (category_name, category_type, description, is_active, display_order) 
VALUES ('Transportation', 'EXPENSE', 'Fuel, public transport, vehicle maintenance', 1, 2);

INSERT INTO finance_category (category_name, category_type, description, is_active, display_order) 
VALUES ('Entertainment', 'EXPENSE', 'Movies, games, hobbies, subscriptions', 1, 3);

INSERT INTO finance_category (category_name, category_type, description, is_active, display_order) 
VALUES ('Bills & Utilities', 'EXPENSE', 'Electricity, water, internet, phone bills', 1, 4);

INSERT INTO finance_category (category_name, category_type, description, is_active, display_order) 
VALUES ('Healthcare', 'EXPENSE', 'Medical expenses, insurance, pharmacy', 1, 5);

INSERT INTO finance_category (category_name, category_type, description, is_active, display_order) 
VALUES ('Shopping', 'EXPENSE', 'Clothing, electronics, household items', 1, 6);

INSERT INTO finance_category (category_name, category_type, description, is_active, display_order) 
VALUES ('Education', 'EXPENSE', 'Books, courses, tuition fees', 1, 7);

INSERT INTO finance_category (category_name, category_type, description, is_active, display_order) 
VALUES ('Housing', 'EXPENSE', 'Rent, mortgage, home maintenance', 1, 8);

INSERT INTO finance_category (category_name, category_type, description, is_active, display_order) 
VALUES ('Personal Care', 'EXPENSE', 'Salon, gym, wellness', 1, 9);

INSERT INTO finance_category (category_name, category_type, description, is_active, display_order) 
VALUES ('Others', 'EXPENSE', 'Miscellaneous expenses', 1, 10);

-- Insert Income Categories
INSERT INTO finance_category (category_name, category_type, description, is_active, display_order) 
VALUES ('Salary', 'INCOME', 'Monthly salary income', 1, 1);

INSERT INTO finance_category (category_name, category_type, description, is_active, display_order) 
VALUES ('Freelance', 'INCOME', 'Freelance project income', 1, 2);

INSERT INTO finance_category (category_name, category_type, description, is_active, display_order) 
VALUES ('Investment', 'INCOME', 'Returns from investments', 1, 3);

INSERT INTO finance_category (category_name, category_type, description, is_active, display_order) 
VALUES ('Gift', 'INCOME', 'Money received as gifts', 1, 4);

INSERT INTO finance_category (category_name, category_type, description, is_active, display_order) 
VALUES ('Business', 'INCOME', 'Business revenue', 1, 5);

COMMIT;

-- Step 4: Verify data inserted
SELECT category_id, category_name, category_type, display_order 
FROM finance_category 
ORDER BY category_type, display_order;

-- Should show 15 rows (10 EXPENSE + 5 INCOME)
SELECT category_type, COUNT(*) as count 
FROM finance_category 
GROUP BY category_type;

-- Success message
SELECT 'Categories populated successfully!' AS status FROM DUAL;
