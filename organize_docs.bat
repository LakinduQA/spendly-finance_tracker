@echo off
REM Organize documentation files into folders

echo Organizing documentation files...

REM Create folders if they don't exist
if not exist "docs\checklists" mkdir "docs\checklists"
if not exist "docs\guides" mkdir "docs\guides"
if not exist "docs\analysis" mkdir "docs\analysis"
if not exist "docs\summaries" mkdir "docs\summaries"
if not exist "docs\troubleshooting" mkdir "docs\troubleshooting"

REM Move checklists
move /Y "FULL_TESTING_CHECKLIST.md" "docs\checklists\" 2>nul
move /Y "TESTING_CHECKLIST.md" "docs\checklists\" 2>nul
move /Y "SUBMISSION_CHECKLIST.md" "docs\checklists\" 2>nul

REM Move guides
move /Y "DEMONSTRATION_GUIDE.md" "docs\guides\" 2>nul
move /Y "ORACLE_SETUP_GUIDE.md" "docs\guides\" 2>nul
move /Y "SYNC_INSTALLATION_GUIDE.md" "docs\guides\" 2>nul
move /Y "REPORT_GENERATION_GUIDE.md" "docs\guides\" 2>nul
move /Y "UI_DESIGN_OVERVIEW.md" "docs\guides\" 2>nul

REM Move analysis
move /Y "PROJECT_ANALYSIS.md" "docs\analysis\" 2>nul
move /Y "REQUIREMENTS_COMPLETION_ANALYSIS.md" "docs\analysis\" 2>nul

REM Move summaries
move /Y "PROJECT_SUMMARY.md" "docs\summaries\" 2>nul
move /Y "STATUS_REPORT.md" "docs\summaries\" 2>nul
move /Y "WELCOME_BACK.md" "docs\summaries\" 2>nul

REM Move troubleshooting
move /Y "ORACLE_CONNECTION_ISSUE.md" "docs\troubleshooting\" 2>nul
move /Y "FIXES_APPLIED.md" "docs\troubleshooting\" 2>nul

echo.
echo Documentation organized successfully!
echo.
echo Folders created:
echo   - docs\checklists      (Testing and submission checklists)
echo   - docs\guides          (Setup and usage guides)
echo   - docs\analysis        (Requirements and project analysis)
echo   - docs\summaries       (Status reports and summaries)
echo   - docs\troubleshooting (Issues and fixes)
echo.
pause
