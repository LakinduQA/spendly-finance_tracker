@echo off
echo ========================================
echo Restarting Spendly Application
echo ========================================
echo.

echo Step 1: Stopping existing processes...
taskkill /F /IM python.exe 2>nul

if %errorlevel% equ 0 (
    echo [SUCCESS] Stopped existing processes
) else (
    echo [INFO] No processes to stop
)

echo.
echo Waiting 2 seconds...
timeout /t 2 /nobreak >nul

echo.
echo Step 2: Starting Flask server...
cd /d "%~dp0webapp"
echo Working directory: %CD%
echo.

python app.py

pause
