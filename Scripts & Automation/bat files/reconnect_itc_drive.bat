@echo off
setlocal

:: Relaunch this script hidden one time, then exit the visible window
if /i not "%~1"=="hidden" (
    powershell -WindowStyle Hidden -Command "Start-Process cmd.exe -ArgumentList '/c','\"%~f0\" hidden' -WindowStyle Hidden"
    exit /b
)

:loop
net use M: | find "\\prd1nas.wwt.com\itc_lab" >nul

if %errorlevel%==0 (
    timeout /t 1200 >nul
    goto loop
)

net use M: \\prd1nas.wwt.com\itc_lab /persistent:yes >nul 2>&1

timeout /t 1200 >nul
goto loop