@echo off
chcp 65001 >nul
title POLAR
color 0B
setlocal EnableDelayedExpansion

for /f %%a in ('echo prompt $E^| cmd') do set "ESC=%%a"

set "POLAR_HOME=%LOCALAPPDATA%\POLAR"
set "POLAR_SOFTWARE=%POLAR_HOME%\Software"
set "POLAR_LOGS=%POLAR_HOME%\Logs"
set "POLAR_SETTINGS=%POLAR_HOME%\settings.ini"
set "POLAR_VERSION=1.1.0"
set "POLAR_UPDATE_URL=https://raw.githubusercontent.com/spoopylocal/WWT-Shizzle/refs/heads/main/Polar.bat"
set "BAR_LENGTH=30"
set "POLAR_AUTO_UPDATE=1"
set "POLAR_CONFIRM_CLEANUP=1"
set "POLAR_PING_TARGET=google.com"
set "POLAR_PING_COUNT=4"

if not exist "%POLAR_HOME%" mkdir "%POLAR_HOME%" >nul 2>&1
if not exist "%POLAR_SOFTWARE%" mkdir "%POLAR_SOFTWARE%" >nul 2>&1
if not exist "%POLAR_LOGS%" mkdir "%POLAR_LOGS%" >nul 2>&1

for /f %%D in ('powershell -NoProfile -Command "Get-Date -Format yyyy-MM-dd"') do set "POLAR_LOG_DATE=%%D"
set "POLAR_LOG_FILE=%POLAR_LOGS%\polar-%POLAR_LOG_DATE%.log"

call :load_settings
call :detect_admin
call :log "POLAR started from %~f0"

if /i not "%~1"=="--updated" if "%POLAR_AUTO_UPDATE%"=="1" call :self_update
if /i not "%~1"=="--updated" if not "%POLAR_AUTO_UPDATE%"=="1" call :log "Auto-update skipped by settings"

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
call :show_status
echo.
<nul set /p ="%ESC%[38;2;220;240;255m              [1]%ESC%[0m %ESC%[38;2;190;225;255mNetwork Tools%ESC%[0m"
echo/
<nul set /p ="%ESC%[38;2;210;235;255m              [2]%ESC%[0m %ESC%[38;2;180;220;255mSystem Tools%ESC%[0m"
echo/
<nul set /p ="%ESC%[38;2;200;230;255m              [3]%ESC%[0m %ESC%[38;2;170;215;255mCleanup Tools%ESC%[0m"
echo/
<nul set /p ="%ESC%[38;2;190;225;255m              [4]%ESC%[0m %ESC%[38;2;160;210;255mSoftware%ESC%[0m"
echo/
<nul set /p ="%ESC%[38;2;180;220;255m              [5]%ESC%[0m %ESC%[38;2;150;205;255mCredits%ESC%[0m"
echo/
<nul set /p ="%ESC%[38;2;170;215;255m              [6]%ESC%[0m %ESC%[38;2;140;200;255mSettings%ESC%[0m"
echo/
<nul set /p ="%ESC%[38;2;160;210;255m              [7]%ESC%[0m %ESC%[38;2;130;195;255mExit%ESC%[0m"
echo/
echo.
<nul set /p ="%ESC%[38;2;225;242;255mPress a number to select:%ESC%[0m "
call :read_choice 1234567

if errorlevel 7 goto end
if errorlevel 6 goto settings
if errorlevel 5 goto credits
if errorlevel 4 goto software
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
call :show_status
echo.
<nul set /p ="%ESC%[38;2;190;225;255m                 [1]%ESC%[0m %ESC%[38;2;180;220;255mPing Target%ESC%[0m"
echo/
<nul set /p ="%ESC%[38;2;190;225;255m                 [2]%ESC%[0m %ESC%[38;2;180;220;255mShow IP Config%ESC%[0m"
echo/
<nul set /p ="%ESC%[38;2;190;225;255m                 [3]%ESC%[0m %ESC%[38;2;180;220;255mBack%ESC%[0m"
echo/
echo.
<nul set /p ="%ESC%[38;2;225;242;255mPress a number to select:%ESC%[0m "
call :read_choice 123

if errorlevel 3 goto banner
if errorlevel 2 goto showip
if errorlevel 1 goto pinggoogle

:pinggoogle
cls
echo.
<nul set /p ="%ESC%[38;2;230;245;255m                 Ping Target%ESC%[0m"
echo/
echo.
<nul set /p ="%ESC%[38;2;225;242;255m                 Target [!POLAR_PING_TARGET!]: %ESC%[0m"
set "PING_TARGET="
set /p "PING_TARGET="
if not defined PING_TARGET set "PING_TARGET=!POLAR_PING_TARGET!"
echo.
<nul set /p ="%ESC%[38;2;225;242;255m                 Number of pings [!POLAR_PING_COUNT!]: %ESC%[0m"
set "PING_COUNT="
set /p "PING_COUNT="
if not defined PING_COUNT set "PING_COUNT=!POLAR_PING_COUNT!"
call :validate_number "%PING_COUNT%"
if errorlevel 1 (
    echo.
    <nul set /p ="%ESC%[38;2;255;210;180m                 Not a valid number. Using !POLAR_PING_COUNT! pings.%ESC%[0m"
    echo/
    set "PING_COUNT=!POLAR_PING_COUNT!"
)
call :log "Network ping requested: target=!PING_TARGET!, count=!PING_COUNT!"
echo.
<nul set /p ="%ESC%[38;2;230;245;255m                 Pinging !PING_TARGET! !PING_COUNT! time(s)...%ESC%[0m"
echo/
echo.
ping -n !PING_COUNT! "!PING_TARGET!"
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
call :show_status
echo.
<nul set /p ="%ESC%[38;2;190;225;255m                 [1]%ESC%[0m %ESC%[38;2;180;220;255mSystem Info%ESC%[0m"
echo/
<nul set /p ="%ESC%[38;2;190;225;255m                 [2]%ESC%[0m %ESC%[38;2;180;220;255mTask List%ESC%[0m"
echo/
<nul set /p ="%ESC%[38;2;190;225;255m                 [3]%ESC%[0m %ESC%[38;2;180;220;255mBack%ESC%[0m"
echo/
echo.
<nul set /p ="%ESC%[38;2;225;242;255mPress a number to select:%ESC%[0m "
call :read_choice 123

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
set "CLEAN_USER=0"
set "CLEAN_WINTEMP=0"
set "CLEAN_PREFETCH=0"
:cleanup_menu
cls
echo.
<nul set /p ="%ESC%[38;2;220;240;255m                 ==========================%ESC%[0m"
echo/
<nul set /p ="%ESC%[38;2;230;245;255m                      Cleanup Tools%ESC%[0m"
echo/
<nul set /p ="%ESC%[38;2;220;240;255m                 ==========================%ESC%[0m"
echo/
echo.
call :show_status
echo.
set "USER_BOX= "
set "WINTEMP_BOX= "
set "PREFETCH_BOX= "
if "!CLEAN_USER!"=="1" set "USER_BOX=x"
if "!CLEAN_WINTEMP!"=="1" set "WINTEMP_BOX=x"
if "!CLEAN_PREFETCH!"=="1" set "PREFETCH_BOX=x"
<nul set /p ="%ESC%[38;2;190;225;255m                 [1]%ESC%[0m %ESC%[38;2;180;220;255m[!USER_BOX!] User Temp        (%TEMP%%)%ESC%[0m"
echo/
<nul set /p ="%ESC%[38;2;190;225;255m                 [2]%ESC%[0m %ESC%[38;2;180;220;255m[!WINTEMP_BOX!] Windows Temp     (%SystemRoot%\Temp)%ESC%[0m"
echo/
<nul set /p ="%ESC%[38;2;190;225;255m                 [3]%ESC%[0m %ESC%[38;2;180;220;255m[!PREFETCH_BOX!] Prefetch         (%SystemRoot%\Prefetch)%ESC%[0m"
echo/
echo.
<nul set /p ="%ESC%[38;2;190;225;255m                 [4]%ESC%[0m %ESC%[38;2;180;220;255mRun Selected%ESC%[0m"
echo/
<nul set /p ="%ESC%[38;2;190;225;255m                 [5]%ESC%[0m %ESC%[38;2;180;220;255mBack%ESC%[0m %ESC%[38;2;140;200;255m(Esc)%ESC%[0m"
echo/
echo.
<nul set /p ="%ESC%[38;2;225;242;255mToggle 1-3, Run with 4/Enter/R, Back with 5/Esc:%ESC%[0m "
call :read_cleanup_choice

if errorlevel 9 goto banner
if errorlevel 5 goto banner
if errorlevel 4 goto cleanup_selected
if errorlevel 3 (
    call :toggle_flag CLEAN_PREFETCH
    goto cleanup_menu
)
if errorlevel 2 (
    call :toggle_flag CLEAN_WINTEMP
    goto cleanup_menu
)
if errorlevel 1 (
    call :toggle_flag CLEAN_USER
    goto cleanup_menu
)
goto cleanup_menu

:cleanup_selected
set "CLEAN_SELECTED=0"
if "!CLEAN_SELECTED!"=="0" (
    if "!CLEAN_USER!"=="1" set "CLEAN_SELECTED=1"
    if "!CLEAN_WINTEMP!"=="1" set "CLEAN_SELECTED=1"
    if "!CLEAN_PREFETCH!"=="1" set "CLEAN_SELECTED=1"
)

if "!CLEAN_SELECTED!"=="0" (
    echo.
    <nul set /p ="%ESC%[38;2;255;210;180m                 Select at least one cleanup item.%ESC%[0m"
    echo/
    timeout /t 1 >nul
    goto cleanup_menu
)

call :cleanup_preview
if errorlevel 1 goto cleanup_menu

if "!CLEAN_USER!"=="1" call :run_cleanup "%TEMP%" "User Temp"
if "!CLEAN_WINTEMP!"=="1" call :run_cleanup "%SystemRoot%\Temp" "Windows Temp"
if "!CLEAN_PREFETCH!"=="1" call :run_cleanup "%SystemRoot%\Prefetch" "Prefetch"

goto cleanup_done

:cleanup_done
echo.
<nul set /p ="%ESC%[38;2;180;255;210m                 Cleanup complete. Press any key...%ESC%[0m"
echo/
pause >nul
goto cleanup

:cleanup_preview
cls
echo.
<nul set /p ="%ESC%[38;2;220;240;255m                 ==========================%ESC%[0m"
echo/
<nul set /p ="%ESC%[38;2;230;245;255m                      Cleanup Preview%ESC%[0m"
echo/
<nul set /p ="%ESC%[38;2;220;240;255m                 ==========================%ESC%[0m"
echo/
echo.
call :show_status
echo.
<nul set /p ="%ESC%[38;2;210;235;255m                 Selected cleanup targets:%ESC%[0m"
echo/
echo.
if "!CLEAN_USER!"=="1" call :show_cleanup_target "%TEMP%" "User Temp"
if "!CLEAN_WINTEMP!"=="1" call :show_cleanup_target "%SystemRoot%\Temp" "Windows Temp"
if "!CLEAN_PREFETCH!"=="1" call :show_cleanup_target "%SystemRoot%\Prefetch" "Prefetch"
if "!POLAR_ADMIN!"=="No" if "!CLEAN_WINTEMP!"=="1" (
    <nul set /p ="%ESC%[38;2;255;210;180m                 Admin is not enabled. Windows Temp may only partially clean.%ESC%[0m"
    echo/
)
if "!POLAR_ADMIN!"=="No" if "!CLEAN_PREFETCH!"=="1" (
    <nul set /p ="%ESC%[38;2;255;210;180m                 Admin is not enabled. Prefetch may only partially clean.%ESC%[0m"
    echo/
)
echo.
if "!POLAR_CONFIRM_CLEANUP!"=="1" (
    <nul set /p ="%ESC%[38;2;255;225;180m                 Delete files in these locations? Y/N: %ESC%[0m"
    call :read_yes_no
    if errorlevel 2 (
        call :log "Cleanup cancelled at preview"
        exit /b 1
    )
)
call :log "Cleanup approved"
exit /b 0

:show_cleanup_target
set "TARGET=%~1"
set "LABEL=%~2"
set "CLEAN_FILES=0"
set "CLEAN_FOLDERS=0"
set "CLEAN_SIZE=0 B"

if not exist "%TARGET%" (
    <nul set /p ="%ESC%[38;2;255;190;190m                 %LABEL% - path not found: %TARGET%%ESC%[0m"
    echo/
    call :log "Cleanup preview missing path: %LABEL% (%TARGET%)"
    exit /b
)

for /f "usebackq tokens=1,2,* delims=|" %%A in (`powershell -NoProfile -Command "$p=$env:TARGET; $items=Get-ChildItem -LiteralPath $p -Force -Recurse -ErrorAction SilentlyContinue; $files=@($items | Where-Object { -not $_.PSIsContainer }); $folders=@($items | Where-Object { $_.PSIsContainer }); $bytes=($files | Measure-Object -Property Length -Sum).Sum; if($null -eq $bytes){$bytes=0}; $size=if($bytes -ge 1GB){'{0:N2} GB' -f ($bytes/1GB)}elseif($bytes -ge 1MB){'{0:N2} MB' -f ($bytes/1MB)}elseif($bytes -ge 1KB){'{0:N2} KB' -f ($bytes/1KB)}else{('{0} B' -f $bytes)}; '{0}|{1}|{2}' -f $files.Count,$folders.Count,$size"`) do (
    set "CLEAN_FILES=%%A"
    set "CLEAN_FOLDERS=%%B"
    set "CLEAN_SIZE=%%C"
)

<nul set /p ="%ESC%[38;2;190;225;255m                 %LABEL% - !CLEAN_FILES! files, !CLEAN_FOLDERS! folders, !CLEAN_SIZE!%ESC%[0m"
echo/
<nul set /p ="%ESC%[38;2;140;200;255m                    %TARGET%%ESC%[0m"
echo/
call :log "Cleanup preview: %LABEL% files=!CLEAN_FILES!, folders=!CLEAN_FOLDERS!, size=!CLEAN_SIZE!, target=%TARGET%"
exit /b

:toggle_flag
if "!%~1!"=="1" (
    set "%~1=0"
) else (
    set "%~1=1"
)
exit /b

:read_cleanup_choice
set "KEY="
for /f "usebackq delims=" %%K in (`powershell -NoProfile -Command "$k=$Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown'); if($k.VirtualKeyCode -eq 27){'ESC'} elseif($k.VirtualKeyCode -eq 13){'ENTER'} else {[string]$k.Character}"`) do set "KEY=%%K"
if /i "!KEY!"=="ESC" exit /b 9
if /i "!KEY!"=="ENTER" exit /b 4
if /i "!KEY!"=="R" exit /b 4
if "!KEY!"=="5" exit /b 5
if "!KEY!"=="4" exit /b 4
if "!KEY!"=="3" exit /b 3
if "!KEY!"=="2" exit /b 2
if "!KEY!"=="1" exit /b 1
echo/
<nul set /p ="%ESC%[38;2;255;210;180m                 Not an option. Try again.%ESC%[0m"
echo/
timeout /t 1 >nul
exit /b 0

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
<nul set /p ="%ESC%[38;2;210;235;255m                 Preparing %LABEL%...%ESC%[0m"
echo/
echo.
<nul set /p ="%ESC%[38;2;120;200;255m                 [░░░░░░░░░░░░░░░░░░░░░░░░░░░░] 0%%%ESC%[0m"
echo/

if not exist "%TARGET%" (
    <nul set /p ="%ESC%[1A"
    <nul set /p ="%ESC%[2K%ESC%[38;2;255;190;190m                 %LABEL% path not found.%ESC%[0m"
    echo/
    call :log "Cleanup skipped, path not found: %LABEL% (%TARGET%)"
    timeout /t 1 >nul
    exit /b
)

call :log "Cleanup started: %LABEL% (%TARGET%)"
call :draw_progress 0 "Preparing %LABEL%..."
call :sleep 1
call :draw_progress 20 "Scanning %LABEL%..."
dir /a /s "%TARGET%" >nul 2>>"%POLAR_LOG_FILE%"
call :sleep 1
call :draw_progress 45 "Removing files from %LABEL%..."
del /f /q /s "%TARGET%\*" >nul 2>>"%POLAR_LOG_FILE%"
call :sleep 1
call :draw_progress 75 "Removing folders from %LABEL%..."
for /d %%D in ("%TARGET%\*") do rd /s /q "%%D" >nul 2>>"%POLAR_LOG_FILE%"
call :sleep 1
call :draw_progress 100 "Finished removing %LABEL%."
call :log "Cleanup finished: %LABEL% (%TARGET%)"
call :sleep 1
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

<nul set /p ="%ESC%[3A"
<nul set /p ="%ESC%[2K%ESC%[38;2;210;235;255m                 !STATUS!%ESC%[0m"
echo/
echo.
<nul set /p ="%ESC%[2K%ESC%[38;2;120;200;255m                 [!BAR!] !PERCENT!%%%ESC%[0m"
echo/
exit /b

:software
cls
echo.
<nul set /p ="%ESC%[38;2;220;240;255m                 ==========================%ESC%[0m"
echo/
<nul set /p ="%ESC%[38;2;230;245;255m                         Software%ESC%[0m"
echo/
<nul set /p ="%ESC%[38;2;220;240;255m                 ==========================%ESC%[0m"
echo/
echo.
call :show_status
echo.

set "OAOOV_DIR=%POLAR_SOFTWARE%\Outbound Auto OV"
set "OAOOV_EXE=%OAOOV_DIR%\Outbound Auto OV.exe"

if exist "%OAOOV_EXE%" (
    set "OAOOV_STATUS=Installed"
) else (
    set "OAOOV_STATUS=Not Installed"
)

<nul set /p ="%ESC%[38;2;190;225;255m                 [1]%ESC%[0m %ESC%[38;2;180;220;255mOutbound Auto OV%ESC%[0m %ESC%[38;2;140;200;255m(!OAOOV_STATUS!)%ESC%[0m"
echo/
<nul set /p ="%ESC%[38;2;190;225;255m                 [2]%ESC%[0m %ESC%[38;2;180;220;255mBack%ESC%[0m"
echo/
echo.
<nul set /p ="%ESC%[38;2;225;242;255mPress a number to select:%ESC%[0m "
call :read_choice 12

if errorlevel 2 goto banner
if errorlevel 1 goto outbound_auto_ov

:outbound_auto_ov
set "APP_NAME=Outbound Auto OV"
set "APP_DIR=%POLAR_SOFTWARE%\Outbound Auto OV"
set "APP_EXE=%APP_DIR%\Outbound Auto OV.exe"
set "APP_VERSION=%APP_DIR%\version.txt"
set "GITHUB_REPO=spoopylocal/WWT-Shizzle"
set "ASSET_NAME=Outbound.Auto.OV.exe"
goto software_app_menu

:software_app_menu
cls
echo.
<nul set /p ="%ESC%[38;2;220;240;255m                 ==========================%ESC%[0m"
echo/
<nul set /p ="%ESC%[38;2;230;245;255m                    %APP_NAME%%ESC%[0m"
echo/
<nul set /p ="%ESC%[38;2;220;240;255m                 ==========================%ESC%[0m"
echo/
echo.
call :show_status
echo.
if exist "%APP_EXE%" (
    set "APP_STATUS=Installed"
) else (
    set "APP_STATUS=Not Installed"
)
<nul set /p ="%ESC%[38;2;210;235;255m                 Status: !APP_STATUS!%ESC%[0m"
echo/
echo.
<nul set /p ="%ESC%[38;2;190;225;255m                 [1]%ESC%[0m %ESC%[38;2;180;220;255mLaunch%ESC%[0m"
echo/
<nul set /p ="%ESC%[38;2;190;225;255m                 [2]%ESC%[0m %ESC%[38;2;180;220;255mCheck for Update / Install%ESC%[0m"
echo/
<nul set /p ="%ESC%[38;2;190;225;255m                 [3]%ESC%[0m %ESC%[38;2;180;220;255mReinstall%ESC%[0m"
echo/
<nul set /p ="%ESC%[38;2;190;225;255m                 [4]%ESC%[0m %ESC%[38;2;180;220;255mOpen Install Folder%ESC%[0m"
echo/
<nul set /p ="%ESC%[38;2;190;225;255m                 [5]%ESC%[0m %ESC%[38;2;180;220;255mUninstall%ESC%[0m"
echo/
<nul set /p ="%ESC%[38;2;190;225;255m                 [6]%ESC%[0m %ESC%[38;2;180;220;255mBack%ESC%[0m"
echo/
echo.
<nul set /p ="%ESC%[38;2;225;242;255mPress a number to select:%ESC%[0m "
call :read_choice 123456

if errorlevel 6 goto software
if errorlevel 5 goto uninstall_app
if errorlevel 4 goto open_app_folder
if errorlevel 3 goto reinstall_app
if errorlevel 2 goto update_app
if errorlevel 1 goto launch_app

:launch_app
set "APP_ACTION=launch"
call :HandleReleaseExe
goto software_app_menu

:update_app
set "APP_ACTION=update"
call :HandleReleaseExe
goto software_app_menu

:reinstall_app
echo.
<nul set /p ="%ESC%[38;2;255;225;180m                 Reinstall %APP_NAME%? Y/N: %ESC%[0m"
call :read_yes_no
if errorlevel 2 goto software_app_menu
set "APP_ACTION=reinstall"
call :HandleReleaseExe
goto software_app_menu

:open_app_folder
if not exist "%APP_DIR%" mkdir "%APP_DIR%" >nul 2>&1
call :log "Opening software folder: %APP_DIR%"
start "" "%APP_DIR%"
goto software_app_menu

:uninstall_app
if not exist "%APP_DIR%" (
    echo.
    <nul set /p ="%ESC%[38;2;255;210;180m                 %APP_NAME% is not installed.%ESC%[0m"
    echo/
    timeout /t 1 >nul
    goto software_app_menu
)
echo.
<nul set /p ="%ESC%[38;2;255;225;180m                 Remove %APP_NAME% from POLAR? Y/N: %ESC%[0m"
call :read_yes_no
if errorlevel 2 goto software_app_menu
rd /s /q "%APP_DIR%" >nul 2>>"%POLAR_LOG_FILE%"
call :log "Uninstalled %APP_NAME% from %APP_DIR%"
goto software_app_menu

:HandleReleaseExe
cls
echo.
<nul set /p ="%ESC%[38;2;220;240;255m                 ==========================%ESC%[0m"
echo/
<nul set /p ="%ESC%[38;2;230;245;255m                    Software Manager%ESC%[0m"
echo/
<nul set /p ="%ESC%[38;2;220;240;255m                 ==========================%ESC%[0m"
echo/
echo.

if not exist "%APP_DIR%" mkdir "%APP_DIR%" >nul 2>&1

echo.
<nul set /p ="%ESC%[38;2;210;235;255m                 Working on %APP_NAME% (!APP_ACTION!)...%ESC%[0m"
echo/
call :log "Software action started: %APP_NAME% (!APP_ACTION!)"

powershell -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference='Stop'; try { [Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12; $action=$env:APP_ACTION; $repo=$env:GITHUB_REPO; $asset=$env:ASSET_NAME; $dir=$env:APP_DIR; $exe=$env:APP_EXE; $verFile=$env:APP_VERSION; $log=$env:POLAR_LOG_FILE; $headers=@{'User-Agent'='POLAR'}; New-Item -ItemType Directory -Force -Path $dir | Out-Null; if($action -eq 'launch'){ if(-not (Test-Path $exe)){ throw ($env:APP_NAME+' is not installed. Choose Check for Update / Install first.') }; Add-Content -Path $log -Value ((Get-Date -Format s)+' Launching '+$env:APP_NAME); Start-Process -FilePath $exe; Start-Sleep -Seconds 1; exit 0 }; if($action -eq 'reinstall'){ if(Test-Path $exe){ Remove-Item -LiteralPath $exe -Force -ErrorAction SilentlyContinue }; if(Test-Path $verFile){ Remove-Item -LiteralPath $verFile -Force -ErrorAction SilentlyContinue } }; Write-Host ('Checking GitHub release for '+$env:APP_NAME+'...'); $release=Invoke-RestMethod -Uri ('https://api.github.com/repos/'+$repo+'/releases/latest') -Headers $headers; $remoteVersion=[string]$release.tag_name; $localVersion=if(Test-Path $verFile){((Get-Content $verFile -Raw).Trim())}else{''}; $match=$null; foreach($a in $release.assets){ if($a.name -eq $asset){ $match=$a; break } }; if(-not $match){throw ('Release asset not found: '+$asset)}; $download=$match.browser_download_url; $badLocal=(Test-Path $exe) -and ((Get-Item $exe).Length -lt 100000); $needsDownload=(-not (Test-Path $exe)) -or $badLocal -or ($localVersion -ne $remoteVersion) -or ($action -eq 'reinstall'); if($needsDownload){ Write-Host ('Downloading '+$asset+' '+$remoteVersion+'...'); $tmp=Join-Path $env:TEMP ('polar_'+[guid]::NewGuid().ToString()+'.exe'); Invoke-WebRequest -Uri $download -OutFile $tmp -UseBasicParsing -Headers $headers; $item=Get-Item $tmp; if($item.Length -lt 100000){Remove-Item $tmp -Force; throw ('Downloaded file is too small: '+$item.Length+' bytes')}; $fs=[IO.File]::OpenRead($tmp); try{$b0=$fs.ReadByte(); $b1=$fs.ReadByte()}finally{$fs.Dispose()}; if($b0 -ne 77 -or $b1 -ne 90){Remove-Item $tmp -Force; throw 'Downloaded file is not a valid Windows EXE'}; Move-Item -Path $tmp -Destination $exe -Force; Set-Content -Path $verFile -Value $remoteVersion; Write-Host ('Installed '+$remoteVersion) } else { Write-Host ('Already up to date: '+$remoteVersion) }; Add-Content -Path $log -Value ((Get-Date -Format s)+' Software action '+$action+' completed for '+$env:APP_NAME); exit 0 } catch { if($env:POLAR_LOG_FILE){ Add-Content -Path $env:POLAR_LOG_FILE -Value ((Get-Date -Format s)+' ERROR '+$_.Exception.Message) }; Write-Host ''; Write-Host ('ERROR: '+$_.Exception.Message); exit 1 }"

if errorlevel 1 (
    echo.
    <nul set /p ="%ESC%[38;2;255;180;180m                 Software action failed. See log for details.%ESC%[0m"
    echo/
    pause
    call :log "Software action failed: %APP_NAME% (!APP_ACTION!)"
    exit /b
)

echo.
<nul set /p ="%ESC%[38;2;180;255;210m                 %APP_NAME% action complete.%ESC%[0m"
echo/
call :log "Software action completed: %APP_NAME% (!APP_ACTION!)"
timeout /t 2 >nul
exit /b

:settings
cls
echo.
<nul set /p ="%ESC%[38;2;220;240;255m                 ==========================%ESC%[0m"
echo/
<nul set /p ="%ESC%[38;2;230;245;255m                         Settings%ESC%[0m"
echo/
<nul set /p ="%ESC%[38;2;220;240;255m                 ==========================%ESC%[0m"
echo/
echo.
call :show_status
echo.
if "%POLAR_AUTO_UPDATE%"=="1" (set "AUTO_TEXT=On") else (set "AUTO_TEXT=Off")
if "%POLAR_CONFIRM_CLEANUP%"=="1" (set "CONFIRM_TEXT=On") else (set "CONFIRM_TEXT=Off")
<nul set /p ="%ESC%[38;2;190;225;255m                 [1]%ESC%[0m %ESC%[38;2;180;220;255mAuto-update: !AUTO_TEXT!%ESC%[0m"
echo/
<nul set /p ="%ESC%[38;2;190;225;255m                 [2]%ESC%[0m %ESC%[38;2;180;220;255mCleanup confirmation: !CONFIRM_TEXT!%ESC%[0m"
echo/
<nul set /p ="%ESC%[38;2;190;225;255m                 [3]%ESC%[0m %ESC%[38;2;180;220;255mDefault ping target: !POLAR_PING_TARGET!%ESC%[0m"
echo/
<nul set /p ="%ESC%[38;2;190;225;255m                 [4]%ESC%[0m %ESC%[38;2;180;220;255mDefault ping count: !POLAR_PING_COUNT!%ESC%[0m"
echo/
<nul set /p ="%ESC%[38;2;190;225;255m                 [5]%ESC%[0m %ESC%[38;2;180;220;255mOpen Logs Folder%ESC%[0m"
echo/
<nul set /p ="%ESC%[38;2;190;225;255m                 [6]%ESC%[0m %ESC%[38;2;180;220;255mBack%ESC%[0m"
echo/
echo.
<nul set /p ="%ESC%[38;2;225;242;255mPress a number to select:%ESC%[0m "
call :read_choice 123456

if errorlevel 6 goto banner
if errorlevel 5 goto settings_open_logs
if errorlevel 4 goto settings_ping_count
if errorlevel 3 goto settings_ping_target
if errorlevel 2 goto settings_confirm_cleanup
if errorlevel 1 goto settings_auto_update

:settings_auto_update
if "%POLAR_AUTO_UPDATE%"=="1" (set "POLAR_AUTO_UPDATE=0") else (set "POLAR_AUTO_UPDATE=1")
call :save_settings
call :log "Setting changed: auto-update=%POLAR_AUTO_UPDATE%"
goto settings

:settings_confirm_cleanup
if "%POLAR_CONFIRM_CLEANUP%"=="1" (set "POLAR_CONFIRM_CLEANUP=0") else (set "POLAR_CONFIRM_CLEANUP=1")
call :save_settings
call :log "Setting changed: cleanup confirmation=%POLAR_CONFIRM_CLEANUP%"
goto settings

:settings_ping_target
echo.
<nul set /p ="%ESC%[38;2;225;242;255m                 New ping target: %ESC%[0m"
set "NEW_TARGET="
set /p "NEW_TARGET="
if defined NEW_TARGET set "POLAR_PING_TARGET=!NEW_TARGET!"
echo(!POLAR_PING_TARGET!| findstr /r /c:"^[A-Za-z0-9][A-Za-z0-9.-]*$" >nul
if errorlevel 1 (
    echo.
    <nul set /p ="%ESC%[38;2;255;210;180m                 Use only letters, numbers, dots, and dashes.%ESC%[0m"
    echo/
    set "POLAR_PING_TARGET=google.com"
    timeout /t 1 >nul
)
call :save_settings
call :log "Setting changed: ping target=%POLAR_PING_TARGET%"
goto settings

:settings_ping_count
echo.
<nul set /p ="%ESC%[38;2;225;242;255m                 New ping count: %ESC%[0m"
set "NEW_COUNT="
set /p "NEW_COUNT="
call :validate_number "%NEW_COUNT%"
if errorlevel 1 (
    echo.
    <nul set /p ="%ESC%[38;2;255;210;180m                 Not a valid number.%ESC%[0m"
    echo/
    timeout /t 1 >nul
    goto settings
)
set "POLAR_PING_COUNT=!NEW_COUNT!"
call :save_settings
call :log "Setting changed: ping count=%POLAR_PING_COUNT%"
goto settings

:settings_open_logs
if not exist "%POLAR_LOGS%" mkdir "%POLAR_LOGS%" >nul 2>&1
start "" "%POLAR_LOGS%"
call :log "Opened logs folder"
goto settings

:credits
cls
echo.
<nul set /p ="%ESC%[38;2;220;240;255m                 ==========================%ESC%[0m"
echo/
<nul set /p ="%ESC%[38;2;230;245;255m                          Credits%ESC%[0m"
echo/
<nul set /p ="%ESC%[38;2;220;240;255m                 ==========================%ESC%[0m"
echo/
echo.
<nul set /p ="%ESC%[38;2;215;238;255m                 Made by:%ESC%[0m"
echo/
echo.
<nul set /p ="%ESC%[38;2;190;225;255m                    Benjamin Cullum%ESC%[0m"
echo/
<nul set /p ="%ESC%[38;2;175;218;255m                    Thomas Carnell%ESC%[0m"
echo/
echo.
<nul set /p ="%ESC%[38;2;205;232;255m                 Polar is a WWT Friendly Software%ESC%[0m"
echo/
<nul set /p ="%ESC%[38;2;195;226;255m                 that was made to access a GitHub Repo%ESC%[0m"
echo/
<nul set /p ="%ESC%[38;2;185;220;255m                 that contains files and applications%ESC%[0m"
echo/
<nul set /p ="%ESC%[38;2;175;214;255m                 used by L4 in NAIC1%ESC%[0m"
echo/
echo.
<nul set /p ="%ESC%[38;2;200;230;255m                 Press any key to go back...%ESC%[0m"
echo/

pause >nul
goto banner

:show_status
call :detect_admin
if "%POLAR_AUTO_UPDATE%"=="1" (set "AUTO_LABEL=On") else (set "AUTO_LABEL=Off")
<nul set /p ="%ESC%[38;2;150;205;255m                 POLAR v%POLAR_VERSION% ^| Admin: !POLAR_ADMIN! ^| Auto-update: !AUTO_LABEL!%ESC%[0m"
echo/
exit /b

:detect_admin
net session >nul 2>&1
if errorlevel 1 (
    set "POLAR_ADMIN=No"
) else (
    set "POLAR_ADMIN=Yes"
)
exit /b

:load_settings
if not exist "%POLAR_SETTINGS%" (
    call :save_settings
    exit /b
)
for /f "usebackq tokens=1,* delims==" %%A in ("%POLAR_SETTINGS%") do (
    if /i "%%A"=="AUTO_UPDATE" set "POLAR_AUTO_UPDATE=%%B"
    if /i "%%A"=="CONFIRM_CLEANUP" set "POLAR_CONFIRM_CLEANUP=%%B"
    if /i "%%A"=="PING_TARGET" set "POLAR_PING_TARGET=%%B"
    if /i "%%A"=="PING_COUNT" set "POLAR_PING_COUNT=%%B"
)
if not "%POLAR_AUTO_UPDATE%"=="1" if not "%POLAR_AUTO_UPDATE%"=="0" set "POLAR_AUTO_UPDATE=1"
if not "%POLAR_CONFIRM_CLEANUP%"=="1" if not "%POLAR_CONFIRM_CLEANUP%"=="0" set "POLAR_CONFIRM_CLEANUP=1"
call :validate_number "%POLAR_PING_COUNT%"
if errorlevel 1 set "POLAR_PING_COUNT=4"
if not defined POLAR_PING_TARGET set "POLAR_PING_TARGET=google.com"
call :save_settings
exit /b

:save_settings
> "%POLAR_SETTINGS%" echo AUTO_UPDATE=%POLAR_AUTO_UPDATE%
>> "%POLAR_SETTINGS%" echo CONFIRM_CLEANUP=%POLAR_CONFIRM_CLEANUP%
>> "%POLAR_SETTINGS%" echo PING_TARGET=%POLAR_PING_TARGET%
>> "%POLAR_SETTINGS%" echo PING_COUNT=%POLAR_PING_COUNT%
exit /b

:log
if not exist "%POLAR_LOGS%" mkdir "%POLAR_LOGS%" >nul 2>&1
set "LOG_MESSAGE=%~1"
powershell -NoProfile -Command "Add-Content -LiteralPath $env:POLAR_LOG_FILE -Value ('[{0}] {1}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $env:LOG_MESSAGE)" >nul 2>&1
exit /b

:read_yes_no
set "KEY="
for /f "usebackq delims=" %%K in (`powershell -NoProfile -Command "$k=$Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown'); [string]$k.Character"`) do set "KEY=%%K"
echo/
if /i "!KEY!"=="Y" exit /b 1
if /i "!KEY!"=="N" exit /b 2
echo.
<nul set /p ="%ESC%[38;2;255;210;180m                 Please choose Y or N.%ESC%[0m"
echo/
timeout /t 1 >nul
goto read_yes_no

:read_choice
set "CHOICES=%~1"
:read_choice_loop
set "KEY="
for /f "usebackq delims=" %%K in (`powershell -NoProfile -Command "$k=$Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown'); [string]$k.Character"`) do set "KEY=%%K"
if not defined KEY goto read_choice_invalid
for /l %%I in (0,1,9) do (
    set "CHOICE_CHAR=!CHOICES:~%%I,1!"
    if "!CHOICE_CHAR!"=="" goto read_choice_invalid
    if /i "!KEY!"=="!CHOICE_CHAR!" (
        set /a CHOICE_VALUE=%%I+1
        exit /b !CHOICE_VALUE!
    )
)
goto read_choice_invalid

:read_choice_invalid
echo/
<nul set /p ="%ESC%[38;2;255;210;180m                 Not an option. Try again.%ESC%[0m"
echo/
timeout /t 1 >nul
<nul set /p ="%ESC%[38;2;225;242;255mPress a number to select:%ESC%[0m "
goto read_choice_loop

:self_update
set "SELF_PATH=%~f0"
set "UPDATE_TMP=%TEMP%\polar_update_%RANDOM%.bat"
set "UPDATE_RUNNER=%TEMP%\polar_apply_update_%RANDOM%.cmd"

powershell -NoProfile -ExecutionPolicy Bypass -Command "$ProgressPreference='SilentlyContinue'; $ErrorActionPreference='Stop'; try { [Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri $env:POLAR_UPDATE_URL -OutFile $env:UPDATE_TMP -UseBasicParsing -Headers @{'User-Agent'='POLAR'}; if((Get-Item $env:UPDATE_TMP).Length -lt 1000){throw 'Downloaded update is too small'}; $q=[char]34; $pattern='set\s+'+$q+'POLAR_VERSION=([^'+$q+']+)'+$q; $remoteLine=Select-String -LiteralPath $env:UPDATE_TMP -Pattern $pattern | Select-Object -First 1; if(-not $remoteLine){Remove-Item -LiteralPath $env:UPDATE_TMP -Force; exit 0}; $remoteVersion=$remoteLine.Matches[0].Groups[1].Value; $localVersion=$env:POLAR_VERSION; if(([version]$remoteVersion) -le ([version]$localVersion)){Remove-Item -LiteralPath $env:UPDATE_TMP -Force; exit 0}; exit 2 } catch { if(Test-Path -LiteralPath $env:UPDATE_TMP){Remove-Item -LiteralPath $env:UPDATE_TMP -Force}; exit 1 }"

if errorlevel 2 (
    cls
    echo.
    <nul set /p ="%ESC%[38;2;210;235;255m                 Updating POLAR...%ESC%[0m"
    echo/
    > "%UPDATE_RUNNER%" echo @echo off
    >> "%UPDATE_RUNNER%" echo setlocal
    >> "%UPDATE_RUNNER%" echo set "UPDATE_TMP=%UPDATE_TMP%"
    >> "%UPDATE_RUNNER%" echo set "SELF_PATH=%SELF_PATH%"
    >> "%UPDATE_RUNNER%" echo timeout /t 2 /nobreak ^>nul
    >> "%UPDATE_RUNNER%" echo for /l %%%%I in ^(1,1,10^) do ^(
    >> "%UPDATE_RUNNER%" echo     move /y "%%UPDATE_TMP%%" "%%SELF_PATH%%" ^>nul 2^>^&1
    >> "%UPDATE_RUNNER%" echo     if not errorlevel 1 if exist "%%SELF_PATH%%" goto launch_updated
    >> "%UPDATE_RUNNER%" echo     timeout /t 1 /nobreak ^>nul
    >> "%UPDATE_RUNNER%" echo ^)
    >> "%UPDATE_RUNNER%" echo echo Failed to apply POLAR update.
    >> "%UPDATE_RUNNER%" echo pause
    >> "%UPDATE_RUNNER%" echo exit /b 1
    >> "%UPDATE_RUNNER%" echo :launch_updated
    >> "%UPDATE_RUNNER%" echo timeout /t 1 /nobreak ^>nul
    >> "%UPDATE_RUNNER%" echo start "" "%SELF_PATH%" --updated
    >> "%UPDATE_RUNNER%" echo del /f /q "%%~f0" ^>nul 2^>^&1
    start "" "%UPDATE_RUNNER%"
    exit
)

if exist "%UPDATE_TMP%" del /f /q "%UPDATE_TMP%" >nul 2>&1
if exist "%UPDATE_RUNNER%" del /f /q "%UPDATE_RUNNER%" >nul 2>&1
exit /b

:validate_number
set "VALUE=%~1"
if not defined VALUE exit /b 1
for /f "delims=0123456789" %%A in ("%VALUE%") do exit /b 1
if %VALUE% LSS 1 exit /b 1
exit /b 0

:sleep
>nul ping 127.0.0.1 -n %~1
exit /b

:end
cls
echo.
<nul set /p ="%ESC%[38;2;210;235;255m                 Thanks for using POLAR :)%ESC%[0m"
echo/
timeout /t 1 >nul
exit
