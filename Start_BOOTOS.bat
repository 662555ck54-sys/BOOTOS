```bat
@echo off
setlocal EnableExtensions
title BOOTOS Launcher
cd /d "%~dp0"

:: ========================================
::                 BOOTOS
:: ========================================

cls
echo.
echo ========================================
echo               BOOTOS
echo ========================================
echo.
echo Welcome! BOOTOS is getting things ready.
echo.
echo Checking your computer...
echo.

:: ========================================
:: Check that main.py exists
:: ========================================

if not exist "%~dp0main.py" (
    cls
    echo.
    echo ========================================
    echo             BOOTOS ERROR
    echo ========================================
    echo.
    echo main.py was not found.
    echo.
    echo Make sure main.py and this BAT file
    echo are in the same folder.
    echo.
    pause
    exit /b 1
)

echo [1/3] Checking Python...
echo.

:: ========================================
:: Check Python Launcher
:: ========================================

where py >nul 2>&1
if not errorlevel 1 (
    py --version >nul 2>&1
    if not errorlevel 1 goto PYTHON_READY
)

:: ========================================
:: Check Python command
:: ========================================

where python >nul 2>&1
if not errorlevel 1 (
    python --version >nul 2>&1
    if not errorlevel 1 goto PYTHON_READY
)

:: ========================================
:: Python not found
:: ========================================

cls
echo.
echo ========================================
echo             BOOTOS
echo ========================================
echo.
echo Python is not installed.
echo.
echo BOOTOS needs Python to run.
echo.
echo Would you like BOOTOS to install Python
echo automatically?
echo.
echo [Y] Yes, install Python
echo [N] No, exit
echo.

choice /C YN /N /M "Choose Y or N: "

if errorlevel 2 goto CANCEL
if errorlevel 1 goto INSTALL_PYTHON


:: ========================================
:: Install Python
:: ========================================

:INSTALL_PYTHON

cls
echo.
echo ========================================
echo        BOOTOS - Python Setup
echo ========================================
echo.
echo Downloading Python...
echo.
echo Please wait...
echo.

:: Official Python installer
set "PYTHON_INSTALLER=%TEMP%\BOOTOS-Python-Installer.exe"
set "PYTHON_URL=https://www.python.org/ftp/python/3.13.7/python-3.13.7-amd64.exe"

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "$ProgressPreference='SilentlyContinue'; Invoke-WebRequest -Uri '%PYTHON_URL%' -OutFile '%PYTHON_INSTALLER%'"

if not exist "%PYTHON_INSTALLER%" (
    cls
    echo.
    echo ========================================
    echo          BOOTOS DOWNLOAD ERROR
    echo ========================================
    echo.
    echo Python could not be downloaded.
    echo.
    echo Please check your internet connection
    echo and try again.
    echo.
    pause
    exit /b 1
)

echo Download complete!
echo.
echo Installing Python...
echo.

"%PYTHON_INSTALLER%" /quiet InstallAllUsers=0 PrependPath=1 Include_launcher=1

if errorlevel 1 (
    echo.
    echo Python installation failed.
    echo.
    pause
    exit /b 1
)

del /q "%PYTHON_INSTALLER%" >nul 2>&1

echo Python installed successfully!
echo.
echo Checking Python...
echo.

:: ========================================
:: Find newly installed Python
:: ========================================

set "PYTHON_EXE=%LocalAppData%\Programs\Python\Python313\python.exe"

if exist "%PYTHON_EXE%" goto PYTHON_READY_DIRECT

where py >nul 2>&1
if not errorlevel 1 goto PYTHON_READY

where python >nul 2>&1
if not errorlevel 1 goto PYTHON_READY

cls
echo.
echo ========================================
echo          BOOTOS PYTHON ERROR
echo ========================================
echo.
echo Python was installed, but BOOTOS could
echo not find it yet.
echo.
echo Please restart your computer and try
echo again.
echo.
pause
exit /b 1


:: ========================================
:: Python ready
:: ========================================

:PYTHON_READY

cls
echo.
echo ========================================
echo               BOOTOS
echo ========================================
echo.
echo [1/3] Python ............ OK
echo [2/3] BOOTOS files ...... OK
echo [3/3] Starting BOOTOS...
echo.
echo Please wait...
echo.

py main.py

if not errorlevel 1 goto SUCCESS

echo.
echo The Python Launcher could not start BOOTOS.
echo.
echo Trying the python command...
echo.

python main.py

if not errorlevel 1 goto SUCCESS

goto ERROR


:: ========================================
:: Direct Python path
:: ========================================

:PYTHON_READY_DIRECT

cls
echo.
echo ========================================
echo               BOOTOS
echo ========================================
echo.
echo [1/3] Python ............ OK
echo [2/3] BOOTOS files ...... OK
echo [3/3] Starting BOOTOS...
echo.
echo Please wait...
echo.

"%PYTHON_EXE%" "%~dp0main.py"

if not errorlevel 1 goto SUCCESS

goto ERROR


:: ========================================
:: Success
:: ========================================

:SUCCESS

echo.
echo ========================================
echo          BOOTOS STARTED
echo ========================================
echo.
echo BOOTOS is running successfully!
echo.
exit /b 0


:: ========================================
:: Error
:: ========================================

:ERROR

cls
echo.
echo ========================================
echo             BOOTOS ERROR
echo ========================================
echo.
echo BOOTOS could not start.
echo.
echo Make sure all BOOTOS files are in
echo the same folder.
echo.
echo If the problem continues, try running
echo the launcher again.
echo.
pause
exit /b 1


:: ========================================
:: Cancel
:: ========================================

:CANCEL

cls
echo.
echo ========================================
echo             BOOTOS
echo ========================================
echo.
echo Python installation cancelled.
echo.
echo BOOTOS cannot start without Python.
echo.
pause
exit /b 0
```
