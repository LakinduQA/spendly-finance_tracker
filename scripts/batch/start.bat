@echo off
echo ========================================
echo Starting Spendly Application
echo ========================================
echo.

cd /d "%~dp0..\..\webapp"
echo Working directory: %CD%
echo.
echo Application will be available at: http://127.0.0.1:5000
echo Press Ctrl+C to stop the server
echo.

python app.py

pause
