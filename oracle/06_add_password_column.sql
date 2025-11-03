-- ========================================
-- Add password_hash column to finance_user table
-- Run this in SQL Developer as finance_admin user
-- ========================================

-- Add password_hash column to existing table
ALTER TABLE finance_user 
ADD password_hash VARCHAR2(255);

-- Make it NOT NULL with a default value for existing rows
UPDATE finance_user 
SET password_hash = 'TEMP_HASH_NEEDS_SYNC'
WHERE password_hash IS NULL;

-- Now make it NOT NULL
ALTER TABLE finance_user 
MODIFY password_hash VARCHAR2(255) NOT NULL;

-- Verify the change
SELECT column_name, data_type, data_length, nullable 
FROM user_tab_columns 
WHERE table_name = 'FINANCE_USER'
ORDER BY column_id;

-- Show current data
SELECT user_id, username, 
       SUBSTR(password_hash, 1, 30) as password_preview,
       email, full_name 
FROM finance_user;

-- Done
SELECT 'Password column added successfully!' as Status FROM dual;
