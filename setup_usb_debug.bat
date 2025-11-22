@echo off
echo ================================================
echo USB Debugging Setup Script
echo ================================================
echo.

echo [1/3] Checking ADB connection...
adb devices
if errorlevel 1 (
    echo ERROR: No device connected via USB
    echo Please connect your Android device and enable USB debugging
    pause
    exit /b 1
)

echo.
echo [2/3] Setting up port forwarding...
adb reverse tcp:5000 tcp:5000
if errorlevel 1 (
    echo ERROR: Failed to setup port forwarding
    pause
    exit /b 1
)

echo.
echo [3/3] Verifying setup...
adb reverse --list
echo.

echo ================================================
echo SUCCESS! USB debugging is ready
echo ================================================
echo.
echo Your Android device can now access the backend at:
echo   http://localhost:5000
echo.
echo NOTE: After disconnecting USB, run this script again
echo ================================================
pause
