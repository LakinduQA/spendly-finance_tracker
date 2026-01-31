@echo off
REM ============================================
REM Quick Install Script
REM Installs Python dependencies only
REM ============================================

echo.
echo ========================================
echo   Installing Python Dependencies...
echo ========================================
echo.

REM Check Python
python --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Python is not installed!
    echo Please install Python from: https://www.python.org/downloads/
    echo Make sure to check "Add Python to PATH" during installation!
    pause
    exit /b 1
)

echo Python found!
python --version
echo.

REM Upgrade pip
echo Upgrading pip...
python -m pip install --upgrade pip --quiet
echo.

REM Navigate to project root
cd /d "%~dp0..\.."

REM Install from requirements.txt
if exist requirements.txt (
    echo Installing packages from requirements.txt...
    pip install -r requirements.txt
) else (
    echo Installing packages manually...
    pip install Flask
    pip install cx_Oracle
    pip install werkzeug
)

echo.
echo ========================================
echo   Installation Complete!
echo ========================================
echo.
echo Next steps:
echo   1. Run setup.bat to configure and launch
echo   2. Or run: cd webapp ^&^& python app.py
echo.
pause
