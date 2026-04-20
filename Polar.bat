@echo off
chcp 65001 >nul
title POLAR
color 0B
setlocal EnableDelayedExpansion

for /f %%a in ('echo prompt $E^| cmd') do set "ESC=%%a"

set "POLAR_HOME=%LOCALAPPDATA%\POLAR"
set "POLAR_SOFTWARE=%POLAR_HOME%\Software"
set "POLAR_UPDATE_URL=https://raw.githubusercontent.com/spoopylocal/WWT-Shizzle/refs/heads/main/Polar.bat"
set "BAR_LENGTH=30"

if not exist "%POLAR_HOME%" mkdir "%POLAR_HOME%" >nul 2>&1
if not exist "%POLAR_SOFTWARE%" mkdir "%POLAR_SOFTWARE%" >nul 2>&1

if /i not "%~1"=="--updated" call :self_update

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
<nul set /p ="%ESC%[38;2;190;225;255m              [4]%ESC%[0m %ESC%[38;2;160;210;255mSoftware%ESC%[0m"
echo/
<nul set /p ="%ESC%[38;2;180;220;255m              [5]%ESC%[0m %ESC%[38;2;150;205;255mCredits%ESC%[0m"
echo/
<nul set /p ="%ESC%[38;2;170;215;255m              [6]%ESC%[0m %ESC%[38;2;140;200;255mExit%ESC%[0m"
echo/
echo.
<nul set /p ="%ESC%[38;2;225;242;255mPress a number to select:%ESC%[0m "
call :read_choice 123456

if errorlevel 6 goto end
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
<nul set /p ="%ESC%[38;2;190;225;255m                 [1]%ESC%[0m %ESC%[38;2;180;220;255mPing Google%ESC%[0m"
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
call :read_choice 12345

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
<nul set /p ="%ESC%[38;2;210;235;255m                 Preparing %LABEL%...%ESC%[0m"
echo/
echo.
<nul set /p ="%ESC%[38;2;120;200;255m                 [░░░░░░░░░░░░░░░░░░░░░░░░░░░░] 0%%%ESC%[0m"
echo/

if not exist "%TARGET%" (
    <nul set /p ="%ESC%[1A"
    <nul set /p ="%ESC%[2K%ESC%[38;2;255;190;190m                 %LABEL% path not found.%ESC%[0m"
    echo/
    timeout /t 1 >nul
    exit /b
)

call :draw_progress 0 "Preparing %LABEL%..."
call :sleep 1
call :draw_progress 20 "Scanning %LABEL%..."
dir /a /s "%TARGET%" >nul 2>&1
call :sleep 1
call :draw_progress 45 "Removing files from %LABEL%..."
del /f /q /s "%TARGET%\*" >nul 2>&1
call :sleep 1
call :draw_progress 75 "Removing folders from %LABEL%..."
for /d %%D in ("%TARGET%\*") do rd /s /q "%%D" >nul 2>&1
call :sleep 1
call :draw_progress 100 "Finished removing %LABEL%."
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

call :HandleReleaseExe
goto software

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
<nul set /p ="%ESC%[38;2;210;235;255m                 Checking GitHub release for %APP_NAME%...%ESC%[0m"
echo/

powershell -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference='Stop'; try { [Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12; $repo=$env:GITHUB_REPO; $asset=$env:ASSET_NAME; $dir=$env:APP_DIR; $exe=$env:APP_EXE; $verFile=$env:APP_VERSION; $headers=@{'User-Agent'='POLAR'}; New-Item -ItemType Directory -Force -Path $dir | Out-Null; $release=Invoke-RestMethod -Uri ('https://api.github.com/repos/'+$repo+'/releases/latest') -Headers $headers; $remoteVersion=[string]$release.tag_name; $localVersion=if(Test-Path $verFile){((Get-Content $verFile -Raw).Trim())}else{''}; $match=$null; foreach($a in $release.assets){ if($a.name -eq $asset){ $match=$a; break } }; if(-not $match){throw ('Release asset not found: '+$asset)}; $download=$match.browser_download_url; $badLocal=(Test-Path $exe) -and ((Get-Item $exe).Length -lt 100000); $needsDownload=(-not (Test-Path $exe)) -or $badLocal -or ($localVersion -ne $remoteVersion); if($needsDownload){ Write-Host ('Downloading '+$asset+' '+$remoteVersion+'...'); $tmp=Join-Path $env:TEMP ('polar_'+[guid]::NewGuid().ToString()+'.exe'); Invoke-WebRequest -Uri $download -OutFile $tmp -UseBasicParsing -Headers $headers; $item=Get-Item $tmp; if($item.Length -lt 100000){Remove-Item $tmp -Force; throw ('Downloaded file is too small: '+$item.Length+' bytes')}; $fs=[IO.File]::OpenRead($tmp); try{$b0=$fs.ReadByte(); $b1=$fs.ReadByte()}finally{$fs.Dispose()}; if($b0 -ne 77 -or $b1 -ne 90){Remove-Item $tmp -Force; throw 'Downloaded file is not a valid Windows EXE'}; Move-Item -Path $tmp -Destination $exe -Force; Set-Content -Path $verFile -Value $remoteVersion } else { Write-Host ('Already up to date: '+$remoteVersion) }; Write-Host ('Launching '+$env:APP_NAME+'...'); Start-Process -FilePath $exe; Start-Sleep -Seconds 2; exit 0 } catch { Write-Host ''; Write-Host ('ERROR: '+$_.Exception.Message); exit 1 }"

if errorlevel 1 (
    echo.
    <nul set /p ="%ESC%[38;2;255;180;180m                 Update or launch failed.%ESC%[0m"
    echo/
    pause
    exit /b
)

echo.
<nul set /p ="%ESC%[38;2;180;255;210m                 %APP_NAME% is ready.%ESC%[0m"
echo/
timeout /t 1 >nul
exit /b

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

powershell -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference='Stop'; try { [Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri $env:POLAR_UPDATE_URL -OutFile $env:UPDATE_TMP -UseBasicParsing -Headers @{'User-Agent'='POLAR'}; if((Get-Item $env:UPDATE_TMP).Length -lt 1000){throw 'Downloaded update is too small'}; $local=(Get-FileHash -Algorithm SHA256 -LiteralPath $env:SELF_PATH).Hash; $remote=(Get-FileHash -Algorithm SHA256 -LiteralPath $env:UPDATE_TMP).Hash; if($local -eq $remote){Remove-Item -LiteralPath $env:UPDATE_TMP -Force; exit 0}; exit 2 } catch { if(Test-Path -LiteralPath $env:UPDATE_TMP){Remove-Item -LiteralPath $env:UPDATE_TMP -Force}; exit 1 }"

if errorlevel 2 (
    cls
    echo.
    <nul set /p ="%ESC%[38;2;210;235;255m                 Updating POLAR...%ESC%[0m"
    echo/
    move /y "%UPDATE_TMP%" "%SELF_PATH%" >nul 2>&1
    start "" "%SELF_PATH%" --updated
    exit
)

if exist "%UPDATE_TMP%" del /f /q "%UPDATE_TMP%" >nul 2>&1
exit /b

:sleep
>nul ping 127.0.0.1 -n %~1
exit /b

:end
cls
echo.
<nul set /p ="%ESC%[38;2;210;235;255m                 Thanks for using POLAR.%ESC%[0m"
echo/
timeout /t 1 >nul
exit
