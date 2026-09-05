@echo off
setlocal EnableExtensions
cd /d "%~dp0"
title BOOTOS Launcher

cls
echo ========================================
echo                 BOOTOS
echo ========================================
echo.

if not exist "%~dp0main.py" (
  echo ERROR: main.py was not found.
  echo Put Start_BOOTOS.bat in the same folder as main.py.
  echo.
  pause
  exit /b 1
)

echo Checking Python...
echo.
set "PYEXE="

where py >nul 2>&1
if not errorlevel 1 (
  py --version >nul 2>&1
  if not errorlevel 1 set "PYEXE=py"
)

if not defined PYEXE (
  where python >nul 2>&1
  if not errorlevel 1 (
    python --version >nul 2>&1
    if not errorlevel 1 set "PYEXE=python"
  )
)

if not defined PYEXE goto INSTALL_PYTHON

goto SETUP

:INSTALL_PYTHON
cls
echo ========================================
echo          BOOTOS - Python Setup
echo ========================================
echo.
echo Python was not found.
echo BOOTOS needs Python to run.
echo.
choice /C YN /N /M "Install Python automatically? [Y/N]: "
if errorlevel 2 goto CANCEL

where winget >nul 2>&1
if errorlevel 1 (
  echo.
  echo Windows Package Manager ^(winget^) is not available.
  echo Please install Python from python.org, then run this again.
  echo.
  pause
  exit /b 1
)

echo.
echo Installing Python with Windows Package Manager...
winget install --id Python.Python.3.13 -e --accept-source-agreements --accept-package-agreements
if errorlevel 1 (
  echo.
  echo Python installation failed.
  pause
  exit /b 1
)

set "PATH=%LocalAppData%\Programs\Python\Python313;%LocalAppData%\Programs\Python\Python313\Scripts;%PATH%"

where py >nul 2>&1
if not errorlevel 1 set "PYEXE=py"
if not defined PYEXE (
  where python >nul 2>&1
  if not errorlevel 1 set "PYEXE=python"
)
if not defined PYEXE (
  echo.
  echo Python was installed, but Windows has not refreshed the command path.
  echo Close this window and run Start_BOOTOS.bat again.
  pause
  exit /b 1
)

goto SETUP

:SETUP
cls
echo ========================================
echo                 BOOTOS
echo ========================================
echo.
echo Python: OK
echo Project files: OK
echo.

if exist "%~dp0requirements.txt" (
  echo Checking required Python packages...
  "%PYEXE%" -m pip install -r "%~dp0requirements.txt"
  if errorlevel 1 (
    echo.
    echo Could not install the required packages.
    pause
    exit /b 1
  )
  echo.
echo Dependencies: OK
)

echo Starting BOOTOS...
echo.
"%PYEXE%" "%~dp0main.py"
set "RC=%errorlevel%"
if not "%RC%"=="0" (
  echo.
  echo ========================================
  echo              BOOTOS ERROR
  echo ========================================
  echo.
  echo BOOTOS stopped with error code %RC%.
  echo.
  pause
)
exit /b %RC%

:CANCEL
cls
echo Python installation cancelled.
echo BOOTOS cannot start without Python.
pause
exit /b 0
