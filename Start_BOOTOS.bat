@echo off
title BOOTOS Launcher
cd /d "%~dp0"

echo Checking for Python...
echo.

where py >nul 2>nul
if %errorlevel%==0 goto RUN

where python >nul 2>nul
if %errorlevel%==0 goto RUN

echo Python was not found on this computer.
echo.
echo Opening the official Python download page...
start "" "https://www.python.org/downloads/windows/"
echo.
echo Install Python, then run Start_BOOTOS.bat again.
echo.
pause
exit /b

:RUN
echo Python found!
echo Starting BOOTOS...
echo.
py main.py
if %errorlevel%==0 exit /b

echo.
echo BOOTOS could not start with "py".
echo Trying "python"...
python main.py
if not %errorlevel%==0 (
    echo.
    echo BOOTOS could not start.
    pause
)
