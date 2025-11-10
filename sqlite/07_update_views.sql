-- ========================================
-- UPDATE VIEWS TO EXCLUDE DELETED RECORDS
-- Part of soft delete implementation
-- ========================================

-- Drop existing views
DROP VIEW IF EXISTS v_budget_performance;
DROP VIEW IF EXISTS v_savings_progress;
DROP VIEW IF EXISTS v_expense_summary;

-- Recreate v_budget_performance with is_deleted filter
CREATE VIEW v_budget_performance AS
SELECT 
    b.budget_id,
    b.user_id,
    u.username,
    c.category_name,
    b.budget_amount,
    b.start_date,
    b.end_date,
    COALESCE(SUM(e.amount), 0) AS actual_spent,
    b.budget_amount - COALESCE(SUM(e.amount), 0) AS remaining,
    ROUND((COALESCE(SUM(e.amount), 0) / b.budget_amount) * 100, 2) AS utilization_percent,
    CASE 
        WHEN COALESCE(SUM(e.amount), 0) > b.budget_amount THEN 'Over Budget'
        WHEN (COALESCE(SUM(e.amount), 0) / b.budget_amount) * 100 >= 80 THEN 'Near Limit'
        ELSE 'Within Budget'
    END AS budget_status,
    COUNT(e.expense_id) AS transaction_count
FROM budget b
JOIN user u ON b.user_id = u.user_id
JOIN category c ON b.category_id = c.category_id
LEFT JOIN expense e ON e.user_id = b.user_id 
    AND e.category_id = b.category_id
    AND e.expense_date BETWEEN b.start_date AND b.end_date
    AND (e.is_deleted = 0 OR e.is_deleted IS NULL)
WHERE b.is_active = 1 
  AND (b.is_deleted = 0 OR b.is_deleted IS NULL)
GROUP BY b.budget_id, b.user_id, u.username, c.category_name, 
         b.budget_amount, b.start_date, b.end_date;

-- Recreate v_savings_progress with is_deleted filter
CREATE VIEW v_savings_progress AS
SELECT 
    sg.goal_id,
    sg.user_id,
    u.username,
    sg.goal_name,
    sg.target_amount,
    sg.current_amount,
    sg.target_amount - sg.current_amount AS remaining_amount,
    ROUND((sg.current_amount / sg.target_amount) * 100, 2) AS progress_percent,
    sg.start_date,
    sg.deadline,
    sg.priority,
    sg.status,
    CASE 
        WHEN sg.deadline < date('now') AND sg.status = 'Active' THEN 'Overdue'
        WHEN sg.current_amount >= sg.target_amount THEN 'Achieved'
        ELSE 'On Track'
    END AS achievement_status,
    COUNT(sc.contribution_id) AS contribution_count
FROM savings_goal sg
JOIN user u ON sg.user_id = u.user_id
LEFT JOIN savings_contribution sc ON sc.goal_id = sg.goal_id
WHERE (sg.is_deleted = 0 OR sg.is_deleted IS NULL)
GROUP BY sg.goal_id, sg.user_id, u.username, sg.goal_name, 
         sg.target_amount, sg.current_amount, sg.start_date, 
         sg.deadline, sg.priority, sg.status;

-- Recreate v_expense_summary with is_deleted filter
CREATE VIEW v_expense_summary AS
SELECT 
    e.expense_id,
    e.user_id,
    u.username,
    c.category_name,
    e.amount,
    e.expense_date,
    e.description,
    e.payment_method,
    e.created_at
FROM expense e
JOIN user u ON e.user_id = u.user_id
JOIN category c ON e.category_id = c.category_id
WHERE (e.is_deleted = 0 OR e.is_deleted IS NULL);

-- Verify views
SELECT 'View v_budget_performance updated' as status;
SELECT 'View v_savings_progress updated' as status;
SELECT 'View v_expense_summary updated' as status;
