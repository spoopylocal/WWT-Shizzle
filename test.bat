@echo off
chcp 65001 >nul
title POLAR
color 0B
setlocal EnableDelayedExpansion

for /f %%a in ('echo prompt $E^| cmd') do set "ESC=%%a"

set "BAR_LENGTH=30"

:banner
cls
echo.
echo.
<nul set /p ="%ESC%[38;2;245;250;255m            ██████╗  ██████╗ ██╗      █████╗ ██████╗%ESC%[0m"
echo/
<nul set /p ="%ESC%[38;2;220;240;255m            ██╔══██╗██╔═══██╗██║     ██╔══██╗██╔══██╗%ESC%[0m"
echo/
<nul set /p ="%ESC%[38;2;195;230;255m            ██████╔╝██║   ██║██║     ███████║██████╔╝%ESC%[0m"
echo/
<nul set /p ="%ESC%[38;2;170;220;255m            ██╔═══╝ ██║   ██║██║     ██╔══██║██╔══██╗%ESC%[0m"
echo/
<nul set /p ="%ESC%[38;2;145;210;255m            ██║     ╚██████╔╝███████╗██║  ██║██║  ██║%ESC%[0m"
echo/
<nul set /p ="%ESC%[38;2;120;200;255m            ╚═╝      ╚═════╝ ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝%ESC%[0m"
echo/
echo.
<nul set /p ="%ESC%[38;2;210;235;255m                 ==========================%ESC%[0m"
echo/
<nul set /p ="%ESC%[38;2;230;245;255m                    POLAR Arctic Toolkit%ESC%[0m"
echo/
<nul set /p ="%ESC%[38;2;210;235;255m                 ==========================%ESC%[0m"
echo/
echo.
<nul set /p ="%ESC%[38;2;220;240;255m              [1]%ESC%[0m %ESC%[38;2;190;225;255mNetwork Tools%ESC%[0m"
echo/
<nul set /p ="%ESC%[38;2;210;235;255m              [2]%ESC%[0m %ESC%[38;2;180;220;255mSystem Tools%ESC%[0m"
echo/
<nul set /p ="%ESC%[38;2;200;230;255m              [3]%ESC%[0m %ESC%[38;2;170;215;255mCleanup Tools%ESC%[0m"
echo/
<nul set /p ="%ESC%[38;2;190;225;255m              [4]%ESC%[0m %ESC%[38;2;160;210;255mExit%ESC%[0m"
echo/
echo.
<nul set /p ="%ESC%[38;2;225;242;255mPress a number to select:%ESC%[0m "
choice /c 1234 /n >nul

if errorlevel 4 goto end
if errorlevel 3 goto cleanup
if errorlevel 2 goto system
if errorlevel 1 goto network

:network
cls
echo.
<nul set /p ="%ESC%[38;2;220;240;255m                 ==========================%ESC%[0m"
echo/
<nul set /p ="%ESC%[38;2;230;245;255m                      Network Tools%ESC%[0m"
echo/
<nul set /p ="%ESC%[38;2;220;240;255m                 ==========================%ESC%[0m"
echo/
echo.
<nul set /p ="%ESC%[38;2;190;225;255m                 [1]%ESC%[0m %ESC%[38;2;180;220;255mPing Google%ESC%[0m"
echo/
<nul set /p ="%ESC%[38;2;190;225;255m                 [2]%ESC%[0m %ESC%[38;2;180;220;255mShow IP Config%ESC%[0m"
echo/
<nul set /p ="%ESC%[38;2;190;225;255m                 [3]%ESC%[0m %ESC%[38;2;180;220;255mBack%ESC%[0m"
echo/
echo.
<nul set /p ="%ESC%[38;2;225;242;255mPress a number to select:%ESC%[0m "
choice /c 123 /n >nul

if errorlevel 3 goto banner
if errorlevel 2 goto showip
if errorlevel 1 goto pinggoogle

:pinggoogle
cls
echo.
<nul set /p ="%ESC%[38;2;230;245;255m                 Pinging google.com...%ESC%[0m"
echo/
echo.
ping google.com
echo.
pause
goto network

:showip
cls
echo.
<nul set /p ="%ESC%[38;2;230;245;255m                 Displaying IP configuration...%ESC%[0m"
echo/
echo.
ipconfig
echo.
pause
goto network

:system
cls
echo.
<nul set /p ="%ESC%[38;2;220;240;255m                 ==========================%ESC%[0m"
echo/
<nul set /p ="%ESC%[38;2;230;245;255m                       System Tools%ESC%[0m"
echo/
<nul set /p ="%ESC%[38;2;220;240;255m                 ==========================%ESC%[0m"
echo/
echo.
<nul set /p ="%ESC%[38;2;190;225;255m                 [1]%ESC%[0m %ESC%[38;2;180;220;255mSystem Info%ESC%[0m"
echo/
<nul set /p ="%ESC%[38;2;190;225;255m                 [2]%ESC%[0m %ESC%[38;2;180;220;255mTask List%ESC%[0m"
echo/
<nul set /p ="%ESC%[38;2;190;225;255m                 [3]%ESC%[0m %ESC%[38;2;180;220;255mBack%ESC%[0m"
echo/
echo.
<nul set /p ="%ESC%[38;2;225;242;255mPress a number to select:%ESC%[0m "
choice /c 123 /n >nul

if errorlevel 3 goto banner
if errorlevel 2 goto showtasks
if errorlevel 1 goto showsysinfo

:showsysinfo
cls
echo.
<nul set /p ="%ESC%[38;2;230;245;255m                 Displaying system info...%ESC%[0m"
echo/
echo.
systeminfo
echo.
pause
goto system

:showtasks
cls
echo.
<nul set /p ="%ESC%[38;2;230;245;255m                 Displaying running tasks...%ESC%[0m"
echo/
echo.
tasklist
echo.
pause
goto system

:cleanup
cls
echo.
<nul set /p ="%ESC%[38;2;220;240;255m                 ==========================%ESC%[0m"
echo/
<nul set /p ="%ESC%[38;2;230;245;255m                      Cleanup Tools%ESC%[0m"
echo/
<nul set /p ="%ESC%[38;2;220;240;255m                 ==========================%ESC%[0m"
echo/
echo.
<nul set /p ="%ESC%[38;2;190;225;255m                 [1]%ESC%[0m %ESC%[38;2;180;220;255mRemove User Temp        (%TEMP%%)%ESC%[0m"
echo/
<nul set /p ="%ESC%[38;2;190;225;255m                 [2]%ESC%[0m %ESC%[38;2;180;220;255mRemove Windows Temp     (%SystemRoot%\Temp)%ESC%[0m"
echo/
<nul set /p ="%ESC%[38;2;190;225;255m                 [3]%ESC%[0m %ESC%[38;2;180;220;255mRemove Prefetch         (%SystemRoot%\Prefetch)%ESC%[0m"
echo/
<nul set /p ="%ESC%[38;2;190;225;255m                 [4]%ESC%[0m %ESC%[38;2;180;220;255mRemove All Above%ESC%[0m"
echo/
<nul set /p ="%ESC%[38;2;190;225;255m                 [5]%ESC%[0m %ESC%[38;2;180;220;255mBack%ESC%[0m"
echo/
echo.
<nul set /p ="%ESC%[38;2;225;242;255mPress a number to select:%ESC%[0m "
choice /c 12345 /n >nul

if errorlevel 5 goto banner
if errorlevel 4 goto cleanup_all
if errorlevel 3 goto cleanup_prefetch
if errorlevel 2 goto cleanup_wintemp
if errorlevel 1 goto cleanup_usertemp

:cleanup_usertemp
call :run_cleanup "%TEMP%" "User Temp"
goto cleanup_done

:cleanup_wintemp
call :run_cleanup "%SystemRoot%\Temp" "Windows Temp"
goto cleanup_done

:cleanup_prefetch
call :run_cleanup "%SystemRoot%\Prefetch" "Prefetch"
goto cleanup_done

:cleanup_all
call :run_cleanup "%TEMP%" "User Temp"
call :run_cleanup "%SystemRoot%\Temp" "Windows Temp"
call :run_cleanup "%SystemRoot%\Prefetch" "Prefetch"
goto cleanup_done

:cleanup_done
echo.
<nul set /p ="%ESC%[38;2;180;255;210m                 Cleanup complete. Press any key...%ESC%[0m"
echo/
pause >nul
goto cleanup

:run_cleanup
set "TARGET=%~1"
set "LABEL=%~2"

cls
echo.
<nul set /p ="%ESC%[38;2;220;240;255m                 ==========================%ESC%[0m"
echo/
<nul set /p ="%ESC%[38;2;230;245;255m                      Cleanup Progress%ESC%[0m"
echo/
<nul set /p ="%ESC%[38;2;220;240;255m                 ==========================%ESC%[0m"
echo/
echo.

if not exist "%TARGET%" (
    <nul set /p ="%ESC%[38;2;255;190;190m                 %LABEL% path not found.%ESC%[0m"
    echo/
    timeout /t 1 >nul
    exit /b
)

call :draw_progress 0 "Preparing %LABEL%..."
timeout /t 1 >nul

call :draw_progress 20 "Scanning %LABEL%..."
dir /a /s "%TARGET%" >nul 2>&1
timeout /t 1 >nul

call :draw_progress 45 "Removing files from %LABEL%..."
del /f /q /s "%TARGET%\*" >nul 2>&1
timeout /t 1 >nul

call :draw_progress 75 "Removing folders from %LABEL%..."
for /d %%D in ("%TARGET%\*") do rd /s /q "%%D" >nul 2>&1
timeout /t 1 >nul

call :draw_progress 100 "Finished removing %LABEL%."
timeout /t 1 >nul
exit /b

:draw_progress
set "PERCENT=%~1"
set "STATUS=%~2"

set /a FILLED=(PERCENT*BAR_LENGTH)/100
set "BAR="

for /l %%I in (1,1,%BAR_LENGTH%) do (
    if %%I LEQ !FILLED! (
        set "BAR=!BAR!█"
    ) else (
        set "BAR=!BAR!░"
    )
)

cls
echo.
<nul set /p ="%ESC%[38;2;220;240;255m                 ==========================%ESC%[0m"
echo/
<nul set /p ="%ESC%[38;2;230;245;255m                      Cleanup Progress%ESC%[0m"
echo/
<nul set /p ="%ESC%[38;2;220;240;255m                 ==========================%ESC%[0m"
echo/
echo.
<nul set /p ="%ESC%[38;2;210;235;255m                 !STATUS!%ESC%[0m"
echo/
echo.
<nul set /p ="%ESC%[38;2;120;200;255m                 [!BAR!] !PERCENT!%%%ESC%[0m"
echo/
exit /b

:end
cls
echo.
<nul set /p ="%ESC%[38;2;210;235;255m                 Thanks for using POLAR.%ESC%[0m"
echo/
timeout /t 1 >nul
exit