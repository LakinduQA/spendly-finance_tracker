@echo off
echo ========================================
echo Stopping Spendly Application
echo ========================================
echo.

echo Stopping all Python processes...
taskkill /F /IM python.exe 2>nul

if %errorlevel% equ 0 (
    echo.
    echo [SUCCESS] All Python processes stopped successfully!
) else (
    echo.
    echo [INFO] No Python processes were running.
)

echo.
pause
