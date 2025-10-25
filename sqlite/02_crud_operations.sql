-- ========================================
-- SQLite CRUD Operations Script
-- Personal Finance Management System
-- Complete Create, Read, Update, Delete Operations
-- ========================================

-- ========================================
-- USER OPERATIONS
-- ========================================

-- CREATE: Insert new user
INSERT INTO user (username, email, full_name) 
VALUES ('john_doe', 'john.doe@email.com', 'John Doe');

-- READ: Get all users
SELECT * FROM user;

-- READ: Get specific user
SELECT * FROM user WHERE user_id = 1;

-- UPDATE: Update user information
UPDATE user 
SET full_name = 'John Smith Doe', 
    email = 'john.smith@email.com'
WHERE user_id = 1;

-- DELETE: Delete user (will cascade to related records)
-- DELETE FROM user WHERE user_id = 1;

-- ========================================
-- CATEGORY OPERATIONS
-- ========================================

-- CREATE: Insert custom category
INSERT INTO category (category_name, category_type, description, is_active)
VALUES ('Travel', 'EXPENSE', 'Travel and vacation expenses', 1);

-- READ: Get all expense categories
SELECT * FROM category WHERE category_type = 'EXPENSE' AND is_active = 1;

-- READ: Get all income categories
SELECT * FROM category WHERE category_type = 'INCOME' AND is_active = 1;

-- UPDATE: Update category
UPDATE category 
SET description = 'Updated: Travel, vacation, and holiday expenses'
WHERE category_name = 'Travel';

-- UPDATE: Deactivate category
UPDATE category 
SET is_active = 0
WHERE category_name = 'Travel';

-- DELETE: Delete category (restricted if used in expenses)
-- DELETE FROM category WHERE category_id = 11;

-- ========================================
-- EXPENSE OPERATIONS
-- ========================================

-- CREATE: Insert single expense
INSERT INTO expense (user_id, category_id, amount, expense_date, description, payment_method)
VALUES (1, 1, 45.50, date('now'), 'Lunch at restaurant', 'Credit Card');

-- CREATE: Insert multiple expenses
INSERT INTO expense (user_id, category_id, amount, expense_date, description, payment_method)
VALUES 
(1, 1, 85.20, date('now', '-1 day'), 'Weekly groceries', 'Debit Card'),
(1, 2, 30.00, date('now', '-2 days'), 'Gas refill', 'Cash'),
(1, 3, 15.99, date('now', '-3 days'), 'Netflix subscription', 'Credit Card'),
(1, 4, 120.00, date('now', '-5 days'), 'Electricity bill', 'Online'),
(1, 5, 50.00, date('now', '-7 days'), 'Pharmacy purchase', 'Debit Card'),
(1, 6, 250.00, date('now', '-10 days'), 'New shoes', 'Credit Card'),
(1, 7, 100.00, date('now', '-15 days'), 'Online course', 'Online'),
(1, 8, 800.00, date('now', '-30 days'), 'Monthly rent', 'Bank Transfer'),
(1, 9, 40.00, date('now', '-12 days'), 'Gym membership', 'Debit Card'),
(1, 10, 25.00, date('now', '-8 days'), 'Miscellaneous', 'Cash');

-- READ: Get all expenses for a user
SELECT 
    e.expense_id,
    e.amount,
    e.expense_date,
    c.category_name,
    e.description,
    e.payment_method
FROM expense e
JOIN category c ON e.category_id = c.category_id
WHERE e.user_id = 1
ORDER BY e.expense_date DESC;

-- READ: Get expenses by date range
SELECT 
    e.expense_id,
    e.amount,
    e.expense_date,
    c.category_name,
    e.description
FROM expense e
JOIN category c ON e.category_id = c.category_id
WHERE e.user_id = 1 
    AND e.expense_date BETWEEN date('now', '-30 days') AND date('now')
ORDER BY e.expense_date DESC;

-- READ: Get expenses by category
SELECT 
    c.category_name,
    COUNT(e.expense_id) AS transaction_count,
    SUM(e.amount) AS total_spent,
    AVG(e.amount) AS average_amount
FROM expense e
JOIN category c ON e.category_id = c.category_id
WHERE e.user_id = 1
GROUP BY c.category_name
ORDER BY total_spent DESC;

-- READ: Get today's expenses
SELECT * FROM expense 
WHERE user_id = 1 AND expense_date = date('now');

-- READ: Get this month's expenses
SELECT 
    SUM(amount) AS total_monthly_expense,
    COUNT(expense_id) AS transaction_count,
    AVG(amount) AS average_expense
FROM expense
WHERE user_id = 1 
    AND strftime('%Y-%m', expense_date) = strftime('%Y-%m', 'now');

-- READ: Get unsynced expenses
SELECT * FROM expense WHERE is_synced = 0;

-- UPDATE: Update specific expense
UPDATE expense 
SET amount = 48.75,
    description = 'Lunch at restaurant - Updated'
WHERE expense_id = 1;

-- UPDATE: Mark expense as synced
UPDATE expense 
SET is_synced = 1,
    sync_timestamp = datetime('now')
WHERE expense_id = 1;

-- UPDATE: Bulk mark as synced
UPDATE expense 
SET is_synced = 1,
    sync_timestamp = datetime('now')
WHERE is_synced = 0;

-- DELETE: Delete specific expense
DELETE FROM expense WHERE expense_id = 1;

-- DELETE: Delete expenses older than 1 year
DELETE FROM expense 
WHERE expense_date < date('now', '-1 year');

-- ========================================
-- INCOME OPERATIONS
-- ========================================

-- CREATE: Insert income record
INSERT INTO income (user_id, income_source, amount, income_date, description)
VALUES (1, 'Salary', 5000.00, date('now', 'start of month'), 'Monthly salary for October');

-- CREATE: Insert multiple income records
INSERT INTO income (user_id, income_source, amount, income_date, description)
VALUES 
(1, 'Freelance', 750.00, date('now', '-5 days'), 'Website development project'),
(1, 'Investment', 120.50, date('now', '-10 days'), 'Stock dividend'),
(1, 'Gift', 200.00, date('now', '-15 days'), 'Birthday gift');

-- READ: Get all income for a user
SELECT 
    income_id,
    income_source,
    amount,
    income_date,
    description
FROM income
WHERE user_id = 1
ORDER BY income_date DESC;

-- READ: Get income by source
SELECT 
    income_source,
    COUNT(*) AS count,
    SUM(amount) AS total_income,
    AVG(amount) AS avg_income
FROM income
WHERE user_id = 1
GROUP BY income_source;

-- READ: Get monthly income summary
SELECT 
    strftime('%Y-%m', income_date) AS month,
    SUM(amount) AS total_income,
    COUNT(*) AS income_count
FROM income
WHERE user_id = 1
GROUP BY strftime('%Y-%m', income_date)
ORDER BY month DESC;

-- READ: Get this month's total income
SELECT SUM(amount) AS monthly_income
FROM income
WHERE user_id = 1 
    AND strftime('%Y-%m', income_date) = strftime('%Y-%m', 'now');

-- UPDATE: Update income record
UPDATE income 
SET amount = 5200.00,
    description = 'Monthly salary for October - with bonus'
WHERE income_id = 1;

-- UPDATE: Mark income as synced
UPDATE income 
SET is_synced = 1,
    sync_timestamp = datetime('now')
WHERE income_id = 1;

-- DELETE: Delete income record
DELETE FROM income WHERE income_id = 1;

-- ========================================
-- BUDGET OPERATIONS
-- ========================================

-- CREATE: Create monthly budget for category
INSERT INTO budget (user_id, category_id, budget_amount, start_date, end_date, is_active)
VALUES (1, 1, 500.00, date('now', 'start of month'), date('now', 'start of month', '+1 month', '-1 day'), 1);

-- CREATE: Create multiple budgets
INSERT INTO budget (user_id, category_id, budget_amount, start_date, end_date, is_active)
VALUES 
(1, 2, 200.00, date('now', 'start of month'), date('now', 'start of month', '+1 month', '-1 day'), 1),
(1, 3, 100.00, date('now', 'start of month'), date('now', 'start of month', '+1 month', '-1 day'), 1),
(1, 4, 300.00, date('now', 'start of month'), date('now', 'start of month', '+1 month', '-1 day'), 1),
(1, 6, 400.00, date('now', 'start of month'), date('now', 'start of month', '+1 month', '-1 day'), 1);

-- READ: Get all active budgets
SELECT 
    b.budget_id,
    c.category_name,
    b.budget_amount,
    b.start_date,
    b.end_date
FROM budget b
JOIN category c ON b.category_id = c.category_id
WHERE b.user_id = 1 AND b.is_active = 1;

-- READ: Get budget with spending details (using view)
SELECT * FROM v_budget_performance WHERE user_id = 1;

-- READ: Get budget alerts (near limit or over budget)
SELECT * FROM v_budget_performance 
WHERE user_id = 1 
    AND budget_status IN ('Near Limit', 'Over Budget');

-- UPDATE: Update budget amount
UPDATE budget 
SET budget_amount = 550.00
WHERE budget_id = 1;

-- UPDATE: Deactivate old budgets
UPDATE budget 
SET is_active = 0
WHERE end_date < date('now');

-- UPDATE: Mark budget as synced
UPDATE budget 
SET is_synced = 1
WHERE budget_id = 1;

-- DELETE: Delete budget
DELETE FROM budget WHERE budget_id = 1;

-- ========================================
-- SAVINGS GOAL OPERATIONS
-- ========================================

-- CREATE: Create savings goal
INSERT INTO savings_goal (user_id, goal_name, target_amount, current_amount, start_date, deadline, priority, status)
VALUES (1, 'Emergency Fund', 10000.00, 0, date('now'), date('now', '+1 year'), 'High', 'Active');

-- CREATE: Create multiple savings goals
INSERT INTO savings_goal (user_id, goal_name, target_amount, current_amount, start_date, deadline, priority, status)
VALUES 
(1, 'Vacation Trip', 3000.00, 500.00, date('now'), date('now', '+6 months'), 'Medium', 'Active'),
(1, 'New Laptop', 1500.00, 200.00, date('now'), date('now', '+3 months'), 'High', 'Active'),
(1, 'Home Renovation', 15000.00, 0, date('now'), date('now', '+2 years'), 'Low', 'Active');

-- READ: Get all active savings goals
SELECT * FROM savings_goal WHERE user_id = 1 AND status = 'Active';

-- READ: Get savings progress (using view)
SELECT * FROM v_savings_progress WHERE user_id = 1;

-- READ: Get high priority goals
SELECT * FROM savings_goal 
WHERE user_id = 1 AND priority = 'High' AND status = 'Active'
ORDER BY deadline;

-- READ: Get overdue goals
SELECT * FROM v_savings_progress 
WHERE user_id = 1 AND achievement_status = 'Overdue';

-- UPDATE: Update goal details
UPDATE savings_goal 
SET target_amount = 11000.00,
    deadline = date(deadline, '+2 months')
WHERE goal_id = 1;

-- UPDATE: Cancel a goal
UPDATE savings_goal 
SET status = 'Cancelled'
WHERE goal_id = 4;

-- UPDATE: Mark goal as synced
UPDATE savings_goal 
SET is_synced = 1
WHERE goal_id = 1;

-- DELETE: Delete goal (will cascade to contributions)
-- DELETE FROM savings_goal WHERE goal_id = 4;

-- ========================================
-- SAVINGS CONTRIBUTION OPERATIONS
-- ========================================

-- CREATE: Add contribution to goal
INSERT INTO savings_contribution (goal_id, contribution_amount, contribution_date, description)
VALUES (1, 500.00, date('now'), 'Initial contribution to emergency fund');

-- CREATE: Add multiple contributions
INSERT INTO savings_contribution (goal_id, contribution_amount, contribution_date, description)
VALUES 
(1, 300.00, date('now', '-7 days'), 'Weekly savings'),
(2, 250.00, date('now', '-5 days'), 'Vacation fund contribution'),
(3, 200.00, date('now', '-3 days'), 'Laptop fund');

-- READ: Get all contributions for a goal
SELECT * FROM savings_contribution 
WHERE goal_id = 1
ORDER BY contribution_date DESC;

-- READ: Get contribution summary by goal
SELECT 
    sg.goal_name,
    COUNT(sc.contribution_id) AS contribution_count,
    SUM(sc.contribution_amount) AS total_contributed,
    AVG(sc.contribution_amount) AS avg_contribution
FROM savings_goal sg
LEFT JOIN savings_contribution sc ON sg.goal_id = sc.goal_id
WHERE sg.user_id = 1
GROUP BY sg.goal_id, sg.goal_name;

-- READ: Get recent contributions (last 30 days)
SELECT 
    sg.goal_name,
    sc.contribution_amount,
    sc.contribution_date,
    sc.description
FROM savings_contribution sc
JOIN savings_goal sg ON sc.goal_id = sg.goal_id
WHERE sg.user_id = 1 
    AND sc.contribution_date >= date('now', '-30 days')
ORDER BY sc.contribution_date DESC;

-- UPDATE: Update contribution (rare operation)
UPDATE savings_contribution 
SET contribution_amount = 550.00,
    description = 'Initial contribution to emergency fund - Updated'
WHERE contribution_id = 1;

-- DELETE: Delete contribution (will decrease goal current_amount via trigger)
-- Note: Need to manually adjust goal amount if trigger doesn't handle deletion
-- DELETE FROM savings_contribution WHERE contribution_id = 1;

-- ========================================
-- SYNC LOG OPERATIONS
-- ========================================

-- CREATE: Log sync start
INSERT INTO sync_log (user_id, sync_start_time, sync_type, sync_status)
VALUES (1, datetime('now'), 'Manual', 'Success');

-- CREATE: Log sync with details
INSERT INTO sync_log (user_id, sync_start_time, sync_end_time, records_synced, sync_status, sync_type)
VALUES (1, datetime('now', '-5 minutes'), datetime('now'), 25, 'Success', 'Automatic');

-- CREATE: Log failed sync
INSERT INTO sync_log (user_id, sync_start_time, sync_end_time, records_synced, sync_status, error_message, sync_type)
VALUES (1, datetime('now', '-10 minutes'), datetime('now', '-9 minutes'), 0, 'Failed', 'Connection timeout', 'Automatic');

-- READ: Get all sync logs
SELECT * FROM sync_log WHERE user_id = 1 ORDER BY sync_start_time DESC;

-- READ: Get successful syncs
SELECT * FROM sync_log WHERE user_id = 1 AND sync_status = 'Success';

-- READ: Get failed syncs
SELECT * FROM sync_log WHERE user_id = 1 AND sync_status = 'Failed';

-- READ: Get sync statistics
SELECT 
    sync_status,
    COUNT(*) AS count,
    SUM(records_synced) AS total_records_synced
FROM sync_log
WHERE user_id = 1
GROUP BY sync_status;

-- UPDATE: Update sync end time and status
UPDATE sync_log 
SET sync_end_time = datetime('now'),
    records_synced = 30,
    sync_status = 'Success'
WHERE sync_log_id = 1;

-- DELETE: Delete old sync logs (cleanup)
DELETE FROM sync_log 
WHERE sync_start_time < datetime('now', '-90 days');

-- ========================================
-- COMPLEX QUERIES
-- ========================================

-- Get financial summary for current month
SELECT 
    (SELECT SUM(amount) FROM income WHERE user_id = 1 AND strftime('%Y-%m', income_date) = strftime('%Y-%m', 'now')) AS total_income,
    (SELECT SUM(amount) FROM expense WHERE user_id = 1 AND strftime('%Y-%m', expense_date) = strftime('%Y-%m', 'now')) AS total_expenses,
    (SELECT SUM(amount) FROM income WHERE user_id = 1 AND strftime('%Y-%m', income_date) = strftime('%Y-%m', 'now')) -
    (SELECT SUM(amount) FROM expense WHERE user_id = 1 AND strftime('%Y-%m', expense_date) = strftime('%Y-%m', 'now')) AS net_savings;

-- Get top 5 spending categories this month
SELECT 
    c.category_name,
    SUM(e.amount) AS total_spent,
    COUNT(e.expense_id) AS transaction_count
FROM expense e
JOIN category c ON e.category_id = c.category_id
WHERE e.user_id = 1 
    AND strftime('%Y-%m', e.expense_date) = strftime('%Y-%m', 'now')
GROUP BY c.category_name
ORDER BY total_spent DESC
LIMIT 5;

-- Get daily average spending
SELECT 
    AVG(daily_total) AS avg_daily_spending
FROM (
    SELECT 
        expense_date,
        SUM(amount) AS daily_total
    FROM expense
    WHERE user_id = 1 
        AND expense_date >= date('now', '-30 days')
    GROUP BY expense_date
);

-- Get savings rate (percentage of income saved)
SELECT 
    ROUND(((total_income - total_expenses) / total_income) * 100, 2) AS savings_rate_percent
FROM (
    SELECT 
        (SELECT COALESCE(SUM(amount), 0) FROM income WHERE user_id = 1 AND strftime('%Y-%m', income_date) = strftime('%Y-%m', 'now')) AS total_income,
        (SELECT COALESCE(SUM(amount), 0) FROM expense WHERE user_id = 1 AND strftime('%Y-%m', expense_date) = strftime('%Y-%m', 'now')) AS total_expenses
);

-- ========================================
-- UTILITY OPERATIONS
-- ========================================

-- Get database statistics
SELECT 
    'Total Users' AS metric, COUNT(*) AS value FROM user
UNION ALL
SELECT 'Total Expenses', COUNT(*) FROM expense
UNION ALL
SELECT 'Total Income Records', COUNT(*) FROM income
UNION ALL
SELECT 'Active Budgets', COUNT(*) FROM budget WHERE is_active = 1
UNION ALL
SELECT 'Active Goals', COUNT(*) FROM savings_goal WHERE status = 'Active'
UNION ALL
SELECT 'Total Contributions', COUNT(*) FROM savings_contribution;

-- Check for unsynced records
SELECT 
    'Unsynced Expenses' AS table_name, COUNT(*) AS count FROM expense WHERE is_synced = 0
UNION ALL
SELECT 'Unsynced Income', COUNT(*) FROM income WHERE is_synced = 0
UNION ALL
SELECT 'Unsynced Budgets', COUNT(*) FROM budget WHERE is_synced = 0
UNION ALL
SELECT 'Unsynced Goals', COUNT(*) FROM savings_goal WHERE is_synced = 0;

-- Database integrity check
PRAGMA integrity_check;

-- Optimize database
VACUUM;
ANALYZE;

SELECT 'CRUD Operations Script Completed Successfully!' AS Status;
