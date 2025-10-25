-- ========================================
-- Oracle PL/SQL CRUD Operations Package
-- Personal Finance Management System
-- Comprehensive Procedures and Functions
-- ========================================

-- ========================================
-- PACKAGE SPECIFICATION
-- ========================================

CREATE OR REPLACE PACKAGE pkg_finance_crud AS
    
    -- USER CRUD Operations
    PROCEDURE create_user(
        p_username IN VARCHAR2,
        p_email IN VARCHAR2,
        p_full_name IN VARCHAR2,
        p_user_id OUT NUMBER
    );
    
    PROCEDURE update_user(
        p_user_id IN NUMBER,
        p_username IN VARCHAR2 DEFAULT NULL,
        p_email IN VARCHAR2 DEFAULT NULL,
        p_full_name IN VARCHAR2 DEFAULT NULL
    );
    
    PROCEDURE delete_user(p_user_id IN NUMBER);
    
    FUNCTION get_user(p_user_id IN NUMBER) RETURN SYS_REFCURSOR;
    
    FUNCTION get_all_users RETURN SYS_REFCURSOR;
    
    -- EXPENSE CRUD Operations
    PROCEDURE create_expense(
        p_user_id IN NUMBER,
        p_category_id IN NUMBER,
        p_amount IN NUMBER,
        p_expense_date IN DATE,
        p_description IN VARCHAR2 DEFAULT NULL,
        p_payment_method IN VARCHAR2,
        p_expense_id OUT NUMBER
    );
    
    PROCEDURE update_expense(
        p_expense_id IN NUMBER,
        p_category_id IN NUMBER DEFAULT NULL,
        p_amount IN NUMBER DEFAULT NULL,
        p_expense_date IN DATE DEFAULT NULL,
        p_description IN VARCHAR2 DEFAULT NULL,
        p_payment_method IN VARCHAR2 DEFAULT NULL
    );
    
    PROCEDURE delete_expense(p_expense_id IN NUMBER);
    
    FUNCTION get_expense(p_expense_id IN NUMBER) RETURN SYS_REFCURSOR;
    
    FUNCTION get_user_expenses(
        p_user_id IN NUMBER,
        p_start_date IN DATE DEFAULT NULL,
        p_end_date IN DATE DEFAULT NULL
    ) RETURN SYS_REFCURSOR;
    
    -- INCOME CRUD Operations
    PROCEDURE create_income(
        p_user_id IN NUMBER,
        p_income_source IN VARCHAR2,
        p_amount IN NUMBER,
        p_income_date IN DATE,
        p_description IN VARCHAR2 DEFAULT NULL,
        p_income_id OUT NUMBER
    );
    
    PROCEDURE update_income(
        p_income_id IN NUMBER,
        p_income_source IN VARCHAR2 DEFAULT NULL,
        p_amount IN NUMBER DEFAULT NULL,
        p_income_date IN DATE DEFAULT NULL,
        p_description IN VARCHAR2 DEFAULT NULL
    );
    
    PROCEDURE delete_income(p_income_id IN NUMBER);
    
    FUNCTION get_income(p_income_id IN NUMBER) RETURN SYS_REFCURSOR;
    
    FUNCTION get_user_income(
        p_user_id IN NUMBER,
        p_start_date IN DATE DEFAULT NULL,
        p_end_date IN DATE DEFAULT NULL
    ) RETURN SYS_REFCURSOR;
    
    -- BUDGET CRUD Operations
    PROCEDURE create_budget(
        p_user_id IN NUMBER,
        p_category_id IN NUMBER,
        p_budget_amount IN NUMBER,
        p_start_date IN DATE,
        p_end_date IN DATE,
        p_budget_id OUT NUMBER
    );
    
    PROCEDURE update_budget(
        p_budget_id IN NUMBER,
        p_budget_amount IN NUMBER DEFAULT NULL,
        p_start_date IN DATE DEFAULT NULL,
        p_end_date IN DATE DEFAULT NULL,
        p_is_active IN NUMBER DEFAULT NULL
    );
    
    PROCEDURE delete_budget(p_budget_id IN NUMBER);
    
    FUNCTION get_budget(p_budget_id IN NUMBER) RETURN SYS_REFCURSOR;
    
    FUNCTION get_user_budgets(p_user_id IN NUMBER) RETURN SYS_REFCURSOR;
    
    -- SAVINGS GOAL CRUD Operations
    PROCEDURE create_savings_goal(
        p_user_id IN NUMBER,
        p_goal_name IN VARCHAR2,
        p_target_amount IN NUMBER,
        p_start_date IN DATE,
        p_deadline IN DATE,
        p_priority IN VARCHAR2,
        p_goal_id OUT NUMBER
    );
    
    PROCEDURE update_savings_goal(
        p_goal_id IN NUMBER,
        p_goal_name IN VARCHAR2 DEFAULT NULL,
        p_target_amount IN NUMBER DEFAULT NULL,
        p_deadline IN DATE DEFAULT NULL,
        p_priority IN VARCHAR2 DEFAULT NULL,
        p_status IN VARCHAR2 DEFAULT NULL
    );
    
    PROCEDURE delete_savings_goal(p_goal_id IN NUMBER);
    
    FUNCTION get_savings_goal(p_goal_id IN NUMBER) RETURN SYS_REFCURSOR;
    
    FUNCTION get_user_goals(p_user_id IN NUMBER) RETURN SYS_REFCURSOR;
    
    -- SAVINGS CONTRIBUTION Operations
    PROCEDURE add_contribution(
        p_goal_id IN NUMBER,
        p_contribution_amount IN NUMBER,
        p_contribution_date IN DATE,
        p_description IN VARCHAR2 DEFAULT NULL,
        p_contribution_id OUT NUMBER
    );
    
    FUNCTION get_goal_contributions(p_goal_id IN NUMBER) RETURN SYS_REFCURSOR;
    
    -- SYNC LOG Operations
    PROCEDURE create_sync_log(
        p_user_id IN NUMBER,
        p_sync_type IN VARCHAR2,
        p_sync_log_id OUT NUMBER
    );
    
    PROCEDURE complete_sync_log(
        p_sync_log_id IN NUMBER,
        p_records_synced IN NUMBER,
        p_sync_status IN VARCHAR2,
        p_error_message IN VARCHAR2 DEFAULT NULL
    );
    
    -- Utility Functions
    FUNCTION get_monthly_summary(
        p_user_id IN NUMBER,
        p_year IN NUMBER,
        p_month IN NUMBER
    ) RETURN SYS_REFCURSOR;
    
    FUNCTION get_category_summary(
        p_user_id IN NUMBER,
        p_start_date IN DATE,
        p_end_date IN DATE
    ) RETURN SYS_REFCURSOR;
    
END pkg_finance_crud;
/

-- ========================================
-- PACKAGE BODY
-- ========================================

CREATE OR REPLACE PACKAGE BODY pkg_finance_crud AS
    
    -- ========================================
    -- USER PROCEDURES
    -- ========================================
    
    PROCEDURE create_user(
        p_username IN VARCHAR2,
        p_email IN VARCHAR2,
        p_full_name IN VARCHAR2,
        p_user_id OUT NUMBER
    ) AS
    BEGIN
        INSERT INTO finance_user (username, email, full_name)
        VALUES (p_username, p_email, p_full_name)
        RETURNING user_id INTO p_user_id;
        
        COMMIT;
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            RAISE_APPLICATION_ERROR(-20001, 'Username or email already exists');
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END create_user;
    
    PROCEDURE update_user(
        p_user_id IN NUMBER,
        p_username IN VARCHAR2 DEFAULT NULL,
        p_email IN VARCHAR2 DEFAULT NULL,
        p_full_name IN VARCHAR2 DEFAULT NULL
    ) AS
    BEGIN
        UPDATE finance_user
        SET username = NVL(p_username, username),
            email = NVL(p_email, email),
            full_name = NVL(p_full_name, full_name)
        WHERE user_id = p_user_id;
        
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20002, 'User not found');
        END IF;
        
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END update_user;
    
    PROCEDURE delete_user(p_user_id IN NUMBER) AS
    BEGIN
        DELETE FROM finance_user WHERE user_id = p_user_id;
        
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20002, 'User not found');
        END IF;
        
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END delete_user;
    
    FUNCTION get_user(p_user_id IN NUMBER) RETURN SYS_REFCURSOR AS
        l_cursor SYS_REFCURSOR;
    BEGIN
        OPEN l_cursor FOR
            SELECT user_id, username, email, full_name, created_at, last_sync, is_active
            FROM finance_user
            WHERE user_id = p_user_id;
        
        RETURN l_cursor;
    END get_user;
    
    FUNCTION get_all_users RETURN SYS_REFCURSOR AS
        l_cursor SYS_REFCURSOR;
    BEGIN
        OPEN l_cursor FOR
            SELECT user_id, username, email, full_name, created_at, is_active
            FROM finance_user
            ORDER BY username;
        
        RETURN l_cursor;
    END get_all_users;
    
    -- ========================================
    -- EXPENSE PROCEDURES
    -- ========================================
    
    PROCEDURE create_expense(
        p_user_id IN NUMBER,
        p_category_id IN NUMBER,
        p_amount IN NUMBER,
        p_expense_date IN DATE,
        p_description IN VARCHAR2 DEFAULT NULL,
        p_payment_method IN VARCHAR2,
        p_expense_id OUT NUMBER
    ) AS
    BEGIN
        INSERT INTO finance_expense (
            user_id, category_id, amount, expense_date, 
            description, payment_method
        ) VALUES (
            p_user_id, p_category_id, p_amount, p_expense_date,
            p_description, p_payment_method
        ) RETURNING expense_id INTO p_expense_id;
        
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END create_expense;
    
    PROCEDURE update_expense(
        p_expense_id IN NUMBER,
        p_category_id IN NUMBER DEFAULT NULL,
        p_amount IN NUMBER DEFAULT NULL,
        p_expense_date IN DATE DEFAULT NULL,
        p_description IN VARCHAR2 DEFAULT NULL,
        p_payment_method IN VARCHAR2 DEFAULT NULL
    ) AS
    BEGIN
        UPDATE finance_expense
        SET category_id = NVL(p_category_id, category_id),
            amount = NVL(p_amount, amount),
            expense_date = NVL(p_expense_date, expense_date),
            description = NVL(p_description, description),
            payment_method = NVL(p_payment_method, payment_method)
        WHERE expense_id = p_expense_id;
        
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20003, 'Expense not found');
        END IF;
        
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END update_expense;
    
    PROCEDURE delete_expense(p_expense_id IN NUMBER) AS
    BEGIN
        DELETE FROM finance_expense WHERE expense_id = p_expense_id;
        
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20003, 'Expense not found');
        END IF;
        
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END delete_expense;
    
    FUNCTION get_expense(p_expense_id IN NUMBER) RETURN SYS_REFCURSOR AS
        l_cursor SYS_REFCURSOR;
    BEGIN
        OPEN l_cursor FOR
            SELECT e.*, c.category_name, u.username
            FROM finance_expense e
            JOIN finance_category c ON e.category_id = c.category_id
            JOIN finance_user u ON e.user_id = u.user_id
            WHERE e.expense_id = p_expense_id;
        
        RETURN l_cursor;
    END get_expense;
    
    FUNCTION get_user_expenses(
        p_user_id IN NUMBER,
        p_start_date IN DATE DEFAULT NULL,
        p_end_date IN DATE DEFAULT NULL
    ) RETURN SYS_REFCURSOR AS
        l_cursor SYS_REFCURSOR;
    BEGIN
        OPEN l_cursor FOR
            SELECT e.expense_id, e.amount, e.expense_date, 
                   c.category_name, e.description, e.payment_method
            FROM finance_expense e
            JOIN finance_category c ON e.category_id = c.category_id
            WHERE e.user_id = p_user_id
              AND (p_start_date IS NULL OR e.expense_date >= p_start_date)
              AND (p_end_date IS NULL OR e.expense_date <= p_end_date)
            ORDER BY e.expense_date DESC;
        
        RETURN l_cursor;
    END get_user_expenses;
    
    -- ========================================
    -- INCOME PROCEDURES
    -- ========================================
    
    PROCEDURE create_income(
        p_user_id IN NUMBER,
        p_income_source IN VARCHAR2,
        p_amount IN NUMBER,
        p_income_date IN DATE,
        p_description IN VARCHAR2 DEFAULT NULL,
        p_income_id OUT NUMBER
    ) AS
    BEGIN
        INSERT INTO finance_income (
            user_id, income_source, amount, income_date, description
        ) VALUES (
            p_user_id, p_income_source, p_amount, p_income_date, p_description
        ) RETURNING income_id INTO p_income_id;
        
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END create_income;
    
    PROCEDURE update_income(
        p_income_id IN NUMBER,
        p_income_source IN VARCHAR2 DEFAULT NULL,
        p_amount IN NUMBER DEFAULT NULL,
        p_income_date IN DATE DEFAULT NULL,
        p_description IN VARCHAR2 DEFAULT NULL
    ) AS
    BEGIN
        UPDATE finance_income
        SET income_source = NVL(p_income_source, income_source),
            amount = NVL(p_amount, amount),
            income_date = NVL(p_income_date, income_date),
            description = NVL(p_description, description)
        WHERE income_id = p_income_id;
        
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20004, 'Income record not found');
        END IF;
        
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END update_income;
    
    PROCEDURE delete_income(p_income_id IN NUMBER) AS
    BEGIN
        DELETE FROM finance_income WHERE income_id = p_income_id;
        
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20004, 'Income record not found');
        END IF;
        
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END delete_income;
    
    FUNCTION get_income(p_income_id IN NUMBER) RETURN SYS_REFCURSOR AS
        l_cursor SYS_REFCURSOR;
    BEGIN
        OPEN l_cursor FOR
            SELECT i.*, u.username
            FROM finance_income i
            JOIN finance_user u ON i.user_id = u.user_id
            WHERE i.income_id = p_income_id;
        
        RETURN l_cursor;
    END get_income;
    
    FUNCTION get_user_income(
        p_user_id IN NUMBER,
        p_start_date IN DATE DEFAULT NULL,
        p_end_date IN DATE DEFAULT NULL
    ) RETURN SYS_REFCURSOR AS
        l_cursor SYS_REFCURSOR;
    BEGIN
        OPEN l_cursor FOR
            SELECT income_id, income_source, amount, income_date, description
            FROM finance_income
            WHERE user_id = p_user_id
              AND (p_start_date IS NULL OR income_date >= p_start_date)
              AND (p_end_date IS NULL OR income_date <= p_end_date)
            ORDER BY income_date DESC;
        
        RETURN l_cursor;
    END get_user_income;
    
    -- ========================================
    -- BUDGET PROCEDURES
    -- ========================================
    
    PROCEDURE create_budget(
        p_user_id IN NUMBER,
        p_category_id IN NUMBER,
        p_budget_amount IN NUMBER,
        p_start_date IN DATE,
        p_end_date IN DATE,
        p_budget_id OUT NUMBER
    ) AS
    BEGIN
        INSERT INTO finance_budget (
            user_id, category_id, budget_amount, start_date, end_date
        ) VALUES (
            p_user_id, p_category_id, p_budget_amount, p_start_date, p_end_date
        ) RETURNING budget_id INTO p_budget_id;
        
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END create_budget;
    
    PROCEDURE update_budget(
        p_budget_id IN NUMBER,
        p_budget_amount IN NUMBER DEFAULT NULL,
        p_start_date IN DATE DEFAULT NULL,
        p_end_date IN DATE DEFAULT NULL,
        p_is_active IN NUMBER DEFAULT NULL
    ) AS
    BEGIN
        UPDATE finance_budget
        SET budget_amount = NVL(p_budget_amount, budget_amount),
            start_date = NVL(p_start_date, start_date),
            end_date = NVL(p_end_date, end_date),
            is_active = NVL(p_is_active, is_active)
        WHERE budget_id = p_budget_id;
        
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20005, 'Budget not found');
        END IF;
        
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END update_budget;
    
    PROCEDURE delete_budget(p_budget_id IN NUMBER) AS
    BEGIN
        DELETE FROM finance_budget WHERE budget_id = p_budget_id;
        
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20005, 'Budget not found');
        END IF;
        
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END delete_budget;
    
    FUNCTION get_budget(p_budget_id IN NUMBER) RETURN SYS_REFCURSOR AS
        l_cursor SYS_REFCURSOR;
    BEGIN
        OPEN l_cursor FOR
            SELECT b.*, c.category_name, u.username
            FROM finance_budget b
            JOIN finance_category c ON b.category_id = c.category_id
            JOIN finance_user u ON b.user_id = u.user_id
            WHERE b.budget_id = p_budget_id;
        
        RETURN l_cursor;
    END get_budget;
    
    FUNCTION get_user_budgets(p_user_id IN NUMBER) RETURN SYS_REFCURSOR AS
        l_cursor SYS_REFCURSOR;
    BEGIN
        OPEN l_cursor FOR
            SELECT b.budget_id, c.category_name, b.budget_amount,
                   b.start_date, b.end_date, b.is_active
            FROM finance_budget b
            JOIN finance_category c ON b.category_id = c.category_id
            WHERE b.user_id = p_user_id
            ORDER BY b.is_active DESC, b.start_date DESC;
        
        RETURN l_cursor;
    END get_user_budgets;
    
    -- ========================================
    -- SAVINGS GOAL PROCEDURES
    -- ========================================
    
    PROCEDURE create_savings_goal(
        p_user_id IN NUMBER,
        p_goal_name IN VARCHAR2,
        p_target_amount IN NUMBER,
        p_start_date IN DATE,
        p_deadline IN DATE,
        p_priority IN VARCHAR2,
        p_goal_id OUT NUMBER
    ) AS
    BEGIN
        INSERT INTO finance_savings_goal (
            user_id, goal_name, target_amount, start_date, deadline, priority
        ) VALUES (
            p_user_id, p_goal_name, p_target_amount, p_start_date, p_deadline, p_priority
        ) RETURNING goal_id INTO p_goal_id;
        
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END create_savings_goal;
    
    PROCEDURE update_savings_goal(
        p_goal_id IN NUMBER,
        p_goal_name IN VARCHAR2 DEFAULT NULL,
        p_target_amount IN NUMBER DEFAULT NULL,
        p_deadline IN DATE DEFAULT NULL,
        p_priority IN VARCHAR2 DEFAULT NULL,
        p_status IN VARCHAR2 DEFAULT NULL
    ) AS
    BEGIN
        UPDATE finance_savings_goal
        SET goal_name = NVL(p_goal_name, goal_name),
            target_amount = NVL(p_target_amount, target_amount),
            deadline = NVL(p_deadline, deadline),
            priority = NVL(p_priority, priority),
            status = NVL(p_status, status)
        WHERE goal_id = p_goal_id;
        
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20006, 'Savings goal not found');
        END IF;
        
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END update_savings_goal;
    
    PROCEDURE delete_savings_goal(p_goal_id IN NUMBER) AS
    BEGIN
        DELETE FROM finance_savings_goal WHERE goal_id = p_goal_id;
        
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20006, 'Savings goal not found');
        END IF;
        
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END delete_savings_goal;
    
    FUNCTION get_savings_goal(p_goal_id IN NUMBER) RETURN SYS_REFCURSOR AS
        l_cursor SYS_REFCURSOR;
    BEGIN
        OPEN l_cursor FOR
            SELECT g.*, u.username
            FROM finance_savings_goal g
            JOIN finance_user u ON g.user_id = u.user_id
            WHERE g.goal_id = p_goal_id;
        
        RETURN l_cursor;
    END get_savings_goal;
    
    FUNCTION get_user_goals(p_user_id IN NUMBER) RETURN SYS_REFCURSOR AS
        l_cursor SYS_REFCURSOR;
    BEGIN
        OPEN l_cursor FOR
            SELECT goal_id, goal_name, target_amount, current_amount,
                   start_date, deadline, priority, status,
                   ROUND((current_amount / target_amount) * 100, 2) AS progress_percent
            FROM finance_savings_goal
            WHERE user_id = p_user_id
            ORDER BY 
                CASE priority 
                    WHEN 'High' THEN 1 
                    WHEN 'Medium' THEN 2 
                    WHEN 'Low' THEN 3 
                END,
                deadline;
        
        RETURN l_cursor;
    END get_user_goals;
    
    -- ========================================
    -- SAVINGS CONTRIBUTION PROCEDURES
    -- ========================================
    
    PROCEDURE add_contribution(
        p_goal_id IN NUMBER,
        p_contribution_amount IN NUMBER,
        p_contribution_date IN DATE,
        p_description IN VARCHAR2 DEFAULT NULL,
        p_contribution_id OUT NUMBER
    ) AS
    BEGIN
        INSERT INTO finance_savings_contribution (
            goal_id, contribution_amount, contribution_date, description
        ) VALUES (
            p_goal_id, p_contribution_amount, p_contribution_date, p_description
        ) RETURNING contribution_id INTO p_contribution_id;
        
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END add_contribution;
    
    FUNCTION get_goal_contributions(p_goal_id IN NUMBER) RETURN SYS_REFCURSOR AS
        l_cursor SYS_REFCURSOR;
    BEGIN
        OPEN l_cursor FOR
            SELECT contribution_id, contribution_amount, contribution_date, description
            FROM finance_savings_contribution
            WHERE goal_id = p_goal_id
            ORDER BY contribution_date DESC;
        
        RETURN l_cursor;
    END get_goal_contributions;
    
    -- ========================================
    -- SYNC LOG PROCEDURES
    -- ========================================
    
    PROCEDURE create_sync_log(
        p_user_id IN NUMBER,
        p_sync_type IN VARCHAR2,
        p_sync_log_id OUT NUMBER
    ) AS
    BEGIN
        INSERT INTO finance_sync_log (
            user_id, sync_start_time, sync_type, sync_status
        ) VALUES (
            p_user_id, SYSTIMESTAMP, p_sync_type, 'Partial'
        ) RETURNING sync_log_id INTO p_sync_log_id;
        
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END create_sync_log;
    
    PROCEDURE complete_sync_log(
        p_sync_log_id IN NUMBER,
        p_records_synced IN NUMBER,
        p_sync_status IN VARCHAR2,
        p_error_message IN VARCHAR2 DEFAULT NULL
    ) AS
    BEGIN
        UPDATE finance_sync_log
        SET sync_end_time = SYSTIMESTAMP,
            records_synced = p_records_synced,
            sync_status = p_sync_status,
            error_message = p_error_message
        WHERE sync_log_id = p_sync_log_id;
        
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END complete_sync_log;
    
    -- ========================================
    -- UTILITY FUNCTIONS
    -- ========================================
    
    FUNCTION get_monthly_summary(
        p_user_id IN NUMBER,
        p_year IN NUMBER,
        p_month IN NUMBER
    ) RETURN SYS_REFCURSOR AS
        l_cursor SYS_REFCURSOR;
    BEGIN
        OPEN l_cursor FOR
            SELECT 
                NVL(SUM(i.amount), 0) AS total_income,
                NVL(SUM(e.amount), 0) AS total_expenses,
                NVL(SUM(i.amount), 0) - NVL(SUM(e.amount), 0) AS net_savings,
                COUNT(DISTINCT e.expense_id) AS expense_count,
                COUNT(DISTINCT i.income_id) AS income_count
            FROM finance_user u
            LEFT JOIN finance_income i ON u.user_id = i.user_id 
                AND i.fiscal_year = p_year 
                AND i.fiscal_month = p_month
            LEFT JOIN finance_expense e ON u.user_id = e.user_id 
                AND e.fiscal_year = p_year 
                AND e.fiscal_month = p_month
            WHERE u.user_id = p_user_id
            GROUP BY u.user_id;
        
        RETURN l_cursor;
    END get_monthly_summary;
    
    FUNCTION get_category_summary(
        p_user_id IN NUMBER,
        p_start_date IN DATE,
        p_end_date IN DATE
    ) RETURN SYS_REFCURSOR AS
        l_cursor SYS_REFCURSOR;
    BEGIN
        OPEN l_cursor FOR
            SELECT 
                c.category_name,
                COUNT(e.expense_id) AS transaction_count,
                SUM(e.amount) AS total_spent,
                AVG(e.amount) AS avg_amount
            FROM finance_category c
            LEFT JOIN finance_expense e ON c.category_id = e.category_id
                AND e.user_id = p_user_id
                AND e.expense_date BETWEEN p_start_date AND p_end_date
            WHERE c.category_type = 'EXPENSE'
            GROUP BY c.category_name
            HAVING COUNT(e.expense_id) > 0
            ORDER BY total_spent DESC;
        
        RETURN l_cursor;
    END get_category_summary;
    
END pkg_finance_crud;
/

-- Show compilation errors if any
SHOW ERRORS PACKAGE pkg_finance_crud;
SHOW ERRORS PACKAGE BODY pkg_finance_crud;

-- Display success message
SELECT 'PL/SQL CRUD Package Created Successfully!' AS status FROM DUAL;
