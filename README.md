# OSBoot 🖥️

A simple Python operating-system launcher / boot-picker style project.

## Features
- Windows versions from Windows 1.0 through Windows 11
- macOS / OS X versions, including macOS 26 Tahoe
- Ubuntu, Debian, Fedora, Linux Mint, Kali, Parrot OS, Arch, openSUSE and Pop!_OS
- FreeBSD
- Add Custom OS
- Add ISO / IMG / EFI / VHD / VHDX
- Online OS database update support
- Simple Tkinter interface

## Run
```bash
python main.py
```

## Build a Windows EXE
```bash
py -m pip install pyinstaller
pyinstaller --onefile --windowed main.py --name OSBoot
```

The executable will be in `dist/OSBoot.exe`.

## GitHub database updates
After creating your GitHub repository, replace `YOURNAME` in `main.py` with your GitHub username.

## Important
This version is a UI/helper project. The Continue button does not repartition disks, install an OS, or modify the bootloader.
Back up important files before experimenting with real boot configurations.
