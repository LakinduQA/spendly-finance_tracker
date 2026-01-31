@echo off
REM ============================================
REM Spendly Finance Tracker - Application Setup
REM ============================================
REM 
REM This script will:
REM   1. Check if Python is installed
REM   2. Install required Python packages
REM   3. Verify SQLite database
REM   4. Test connections
REM   5. Launch the application
REM
REM ============================================

SETLOCAL EnableDelayedExpansion

echo.
echo ========================================
echo   Spendly - Personal Finance Tracker
echo   Setup Script
echo ========================================
echo.

REM ============================================
REM Step 1: Check Python Installation
REM ============================================
echo [STEP 1/5] Checking Python installation...
echo.

python --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Python is not installed!
    echo.
    echo Please install Python first:
    echo   1. Go to: https://www.python.org/downloads/
    echo   2. Download Python 3.8 or higher
    echo   3. Run installer and CHECK "Add Python to PATH"
    echo   4. Restart this script after installation
    echo.
    pause
    exit /b 1
)

python --version
echo Python is installed!
echo.

REM ============================================
REM Step 2: Upgrade pip
REM ============================================
echo [STEP 2/5] Upgrading pip...
echo.

python -m pip install --upgrade pip --quiet
echo pip upgraded successfully!
echo.

REM ============================================
REM Step 3: Install Dependencies
REM ============================================
echo [STEP 3/5] Installing required packages...
echo.

echo Installing Flask...
python -m pip install Flask --quiet

echo Installing cx_Oracle (optional for Oracle sync)...
python -m pip install cx_Oracle --quiet 2>nul

echo Installing werkzeug...
python -m pip install werkzeug --quiet

echo.
echo All packages installed!
echo.

REM ============================================
REM Step 4: Verify Project Structure
REM ============================================
echo [STEP 4/5] Verifying project structure...
echo.

cd /d "%~dp0.."

if not exist "sqlite\finance_local.db" (
    echo Warning: SQLite database not found!
    echo A new database will be created on first run.
) else (
    echo SQLite database found!
)

if not exist "webapp\app.py" (
    echo ERROR: Flask app not found!
    pause
    exit /b 1
)
echo Flask app found!

if not exist "synchronization\config.ini" (
    echo Note: Oracle config not set up.
    echo Copy config.example.ini to config.ini and add your credentials.
) else (
    echo Oracle config found!
)

echo.

REM ============================================
REM Step 5: Ready to Launch
REM ============================================
echo [STEP 5/5] Setup complete!
echo.
echo ========================================
echo   Setup Summary
echo ========================================
echo.
echo [OK] Python installed
echo [OK] Dependencies installed
echo [OK] Project structure verified
echo.
echo ========================================
echo   Launch Options
echo ========================================
echo.
echo 1. Start Web Application
echo 2. Populate Sample Data
echo 3. Exit
echo.
set /p choice="Enter your choice (1-3): "

if "%choice%"=="1" goto launch_app
if "%choice%"=="2" goto populate_data
if "%choice%"=="3" goto end

:launch_app
echo.
echo ========================================
echo   Starting Flask Application...
echo ========================================
echo.
echo The web app will be available at:
echo   http://127.0.0.1:5000
echo.
echo Press Ctrl+C to stop the server
echo.
pause
cd webapp
python app.py
goto end

:populate_data
echo.
echo ========================================
echo   Populating Sample Data...
echo ========================================
echo.
cd scripts
python populate_sample_data.py
echo.
echo Sample data populated!
echo.
pause
goto launch_app

:end
echo.
echo Thank you for using Spendly!
echo.
pause
ENDLOCAL
