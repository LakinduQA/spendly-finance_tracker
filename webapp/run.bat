@echo off
REM Start script for Personal Finance Manager Web Application

echo ============================================
echo Personal Finance Manager - Web Application
echo ============================================
echo.

REM Check if Python is installed
python --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Python is not installed or not in PATH
    echo Please install Python 3.8 or higher
    pause
    exit /b 1
)

echo [1/4] Checking Python installation...
python --version
echo.

REM Check if database exists
if not exist "..\sqlite\finance_local.db" (
    echo [2/4] SQLite database not found!
    echo.
    echo Please create the database first by running:
    echo   cd ..\sqlite
    echo   sqlite3 finance_local.db
    echo   .read 01_create_database.sql
    echo   .exit
    echo.
    pause
    exit /b 1
) else (
    echo [2/4] SQLite database found: OK
)
echo.

REM Check if virtual environment exists
if not exist "venv" (
    echo [3/4] Virtual environment not found. Creating...
    python -m venv venv
    echo Virtual environment created!
) else (
    echo [3/4] Virtual environment found: OK
)
echo.

REM Activate virtual environment
echo Activating virtual environment...
call venv\Scripts\activate.bat

REM Install dependencies
echo [4/4] Installing Python dependencies...
pip install -r requirements.txt --quiet
echo Dependencies installed!
echo.

REM Check for sample data
echo Checking for sample data...
echo.
choice /C YN /M "Do you want to populate sample data for testing?"
if errorlevel 2 goto skip_sample_data
if errorlevel 1 goto populate_data

:populate_data
echo.
echo Populating sample data...
python populate_sample_data.py
echo.
goto start_server

:skip_sample_data
echo Skipping sample data population.
echo.

:start_server
echo ============================================
echo Starting Flask Development Server...
echo ============================================
echo.
echo Web Application will be available at:
echo   http://localhost:5000
echo.
echo Press Ctrl+C to stop the server
echo.
pause

REM Start Flask application
python app.py

REM Deactivate virtual environment on exit
deactivate
