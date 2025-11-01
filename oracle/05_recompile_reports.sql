-- Recompile Reports Package Body to Fix Errors
-- Run this in SQL Developer after adding fiscal columns

-- First, check what errors exist
SELECT line, position, text
FROM user_errors
WHERE name = 'PKG_FINANCE_REPORTS'
  AND type = 'PACKAGE BODY'
ORDER BY sequence;

-- Recompile the package body
ALTER PACKAGE pkg_finance_reports COMPILE BODY;

-- Check status again
SELECT object_name, object_type, status 
FROM user_objects 
WHERE object_name = 'PKG_FINANCE_REPORTS'
ORDER BY object_type;

-- If still showing errors, display them
SELECT line, position, text
FROM user_errors
WHERE name = 'PKG_FINANCE_REPORTS'
  AND type = 'PACKAGE BODY'
ORDER BY sequence;

-- Final verification
SELECT 
    CASE 
        WHEN COUNT(*) = 2 AND MIN(status) = 'VALID' 
        THEN '✅ Package is VALID and ready to use'
        ELSE '❌ Package still has errors - see above'
    END as final_status
FROM user_objects
WHERE object_name = 'PKG_FINANCE_REPORTS'
  AND object_type IN ('PACKAGE', 'PACKAGE BODY');
