#!/usr/bin/env bash
cd "$(dirname "$0")"
clear

echo "========================================"
echo "                BOOTOS"
echo "========================================"
echo

if [ ! -f "main.py" ]; then
  echo "ERROR: main.py was not found."
  echo "Put this launcher in the same folder as main.py."
  read -r -p "Press Enter to close..."
  exit 1
fi

PYTHON=""
if command -v python3 >/dev/null 2>&1 && python3 --version >/dev/null 2>&1; then PYTHON="python3"; fi
if [ -z "$PYTHON" ] && command -v python >/dev/null 2>&1 && python --version >/dev/null 2>&1; then PYTHON="python"; fi

if [ -z "$PYTHON" ]; then
  echo "Python was not found."
  echo
  read -r -p "Install Python automatically? [Y/N]: " answer
  if [[ "$answer" =~ ^[Yy]$ ]]; then
    if command -v apt-get >/dev/null 2>&1; then
      echo "Installing Python with apt..."
      sudo apt-get update && sudo apt-get install -y python3 python3-pip
    elif command -v dnf >/dev/null 2>&1; then
      echo "Installing Python with dnf..."
      sudo dnf install -y python3 python3-pip
    elif command -v pacman >/dev/null 2>&1; then
      echo "Installing Python with pacman..."
      sudo pacman -Sy --noconfirm python python-pip
    elif command -v zypper >/dev/null 2>&1; then
      echo "Installing Python with zypper..."
      sudo zypper --non-interactive install python3 python3-pip
    else
      echo "No supported package manager was found."
      read -r -p "Press Enter to close..."
      exit 1
    fi
  else
    echo "Installation cancelled."
    read -r -p "Press Enter to close..."
    exit 0
  fi
  command -v python3 >/dev/null 2>&1 && PYTHON="python3"
  [ -z "$PYTHON" ] && command -v python >/dev/null 2>&1 && PYTHON="python"
fi

if [ -z "$PYTHON" ]; then
  echo "Python could not be found after installation."
  read -r -p "Press Enter to close..."
  exit 1
fi

echo "Python: OK"
if [ -f "requirements.txt" ]; then
  echo "Installing/checking dependencies..."
  "$PYTHON" -m pip install -r requirements.txt || { read -r -p "Dependency installation failed. Press Enter..."; exit 1; }
fi

echo "Starting BOOTOS..."
"$PYTHON" main.py
RC=$?
if [ $RC -ne 0 ]; then
  echo
  echo "BOOTOS stopped with error code $RC."
  read -r -p "Press Enter to close..."
fi
exit $RC
