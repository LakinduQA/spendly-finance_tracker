@echo off
echo ========================================
echo Starting Spendly Application
echo ========================================
echo.

cd /d "%~dp0webapp"
echo Working directory: %CD%
echo.

echo Starting Flask server...
python app.py

pause
