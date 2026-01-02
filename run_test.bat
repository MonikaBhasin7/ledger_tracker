@echo off
REM Print Tracker - Automated Test Script (Windows)

echo ================================================
echo Print Tracker - Automated Testing
echo ================================================
echo.

REM Configuration
set CSV_FILE=%1
if "%CSV_FILE%"=="" set CSV_FILE=%USERPROFILE%\Desktop\test_scan.csv

set START_SHEET=%2
if "%START_SHEET%"=="" set START_SHEET=1

set END_SHEET=%3
if "%END_SHEET%"=="" set END_SHEET=50

set DELAY=%4
if "%DELAY%"=="" set DELAY=0.5

set SKIP_PROB=%5
if "%SKIP_PROB%"=="" set SKIP_PROB=0.15

echo Test Configuration:
echo   CSV File: %CSV_FILE%
echo   Sheet Range: %START_SHEET% - %END_SHEET%
echo   Delay: %DELAY% seconds
echo   Skip Probability: %SKIP_PROB% (15%%)
echo.
echo ================================================
echo.

REM Create CSV file if it doesn't exist
if not exist "%CSV_FILE%" (
    echo Creating new CSV file...
    echo sheet_number,timestamp,scanner_id > "%CSV_FILE%"
    echo Created: %CSV_FILE%
    echo.
)

echo Instructions:
echo 1. Open your Print Tracker app
echo 2. Create a new job:
echo    - Start: %START_SHEET%
echo    - End: %END_SHEET%
echo 3. Select this CSV file: %CSV_FILE%
echo 4. Press any key here to start simulation
echo.
pause

echo.
echo Starting scanner simulation...
echo.

REM Start Python simulator
python test_scanner.py "%CSV_FILE%" --start %START_SHEET% --end %END_SHEET% --delay %DELAY% --skip %SKIP_PROB%

echo.
echo Test complete! Check the app for missing sheets.
pause