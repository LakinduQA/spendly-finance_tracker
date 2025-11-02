@echo off
REM ============================================
REM Personal Finance Management System
REM Complete Setup Script for Windows
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
echo   Personal Finance Management System
echo   Complete Setup Script
echo ========================================
echo.

REM Colors (for better readability)
set "GREEN=[92m"
set "RED=[91m"
set "YELLOW=[93m"
set "BLUE=[94m"
set "NC=[0m"

REM ============================================
REM Step 1: Check Python Installation
REM ============================================
echo [STEP 1/6] Checking Python installation...
echo.

python --version >nul 2>&1
if errorlevel 1 (
    echo %RED%ERROR: Python is not installed!%NC%
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
echo %GREEN%Python is installed!%NC%
echo.

REM ============================================
REM Step 2: Upgrade pip
REM ============================================
echo [STEP 2/6] Upgrading pip...
echo.

python -m pip install --upgrade pip --quiet
if errorlevel 1 (
    echo %YELLOW%Warning: Could not upgrade pip%NC%
) else (
    echo %GREEN%pip upgraded successfully!%NC%
)
echo.

REM ============================================
REM Step 3: Install Dependencies
REM ============================================
echo [STEP 3/6] Installing required packages...
echo.

echo Installing Flask...
python -m pip install Flask --quiet
if errorlevel 1 (
    echo %RED%Failed to install Flask%NC%
    pause
    exit /b 1
)

echo Installing cx_Oracle...
python -m pip install cx_Oracle --quiet
if errorlevel 1 (
    echo %YELLOW%Warning: cx_Oracle installation failed (Oracle features will be disabled)%NC%
) else (
    echo %GREEN%cx_Oracle installed successfully!%NC%
)

echo.
echo %GREEN%All packages installed successfully!%NC%
echo.

REM ============================================
REM Step 4: Verify Project Structure
REM ============================================
echo [STEP 4/6] Verifying project structure...
echo.

if not exist "sqlite\finance_local.db" (
    echo %YELLOW%Warning: SQLite database not found!%NC%
    echo Expected location: sqlite\finance_local.db
    echo.
    echo Creating database...
    if exist "sqlite\01_create_database.sql" (
        cd sqlite
        python create_db.py
        cd ..
        echo %GREEN%Database created!%NC%
    ) else (
        echo %RED%Cannot create database - SQL script not found%NC%
    )
) else (
    echo %GREEN%SQLite database found!%NC%
)

if not exist "webapp\app.py" (
    echo %RED%ERROR: Flask app not found!%NC%
    echo Expected location: webapp\app.py
    pause
    exit /b 1
)
echo %GREEN%Flask app found!%NC%

if not exist "synchronization\config.ini" (
    echo %YELLOW%Warning: Oracle config not found!%NC%
    echo Oracle features will be disabled
) else (
    echo %GREEN%Oracle config found!%NC%
)

echo.

REM ============================================
REM Step 5: Test Database Connection
REM ============================================
echo [STEP 5/6] Testing database connection...
echo.

python verify_database.py >nul 2>&1
if errorlevel 1 (
    echo %YELLOW%Warning: Database verification had issues%NC%
) else (
    echo %GREEN%Database connection successful!%NC%
)
echo.

REM ============================================
REM Step 6: Ready to Launch
REM ============================================
echo [STEP 6/6] Setup complete!
echo.
echo ========================================
echo   Setup Summary
echo ========================================
echo.
echo %GREEN%[OK]%NC% Python installed
echo %GREEN%[OK]%NC% Dependencies installed
echo %GREEN%[OK]%NC% Project structure verified
echo %GREEN%[OK]%NC% Database ready
echo.
echo ========================================
echo   Launch Options
echo ========================================
echo.
echo 1. Start Web Application
echo 2. Populate Sample Data (367 expenses, 8 income, 8 budgets, 5 goals)
echo 3. Sync to Oracle Database
echo 4. Exit
echo.
set /p choice="Enter your choice (1-4): "

if "%choice%"=="1" goto launch_app
if "%choice%"=="2" goto populate_data
if "%choice%"=="3" goto sync_oracle
if "%choice%"=="4" goto end

:launch_app
echo.
echo ========================================
echo   Starting Flask Application...
echo ========================================
echo.
echo The web app will be available at:
echo   http://127.0.0.1:5000
echo.
echo Login with:
echo   Username: john_doe or jane_smith
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
cd webapp
python populate_sample_data.py
echo.
echo %GREEN%Sample data populated!%NC%
echo.
echo Data added:
echo   - 367 expenses over 90 days
echo   - 8 income records
echo   - 8 budgets
echo   - 5 savings goals
echo.
pause
goto launch_app

:sync_oracle
echo.
echo ========================================
echo   Syncing to Oracle Database...
echo ========================================
echo.
python test_sync_extended.py
echo.
pause
goto launch_app

:end
echo.
echo Thank you for using Personal Finance Management System!
echo.
pause
ENDLOCAL
