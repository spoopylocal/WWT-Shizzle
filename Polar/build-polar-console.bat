@echo off
setlocal
cd /d "%~dp0"

set "CSC=C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe"
if not exist "%CSC%" set "CSC=C:\Windows\Microsoft.NET\Framework\v4.0.30319\csc.exe"
set "SIGNTOOL=%POLAR_SIGNTOOL%"
set "TIMESTAMP_URL=%POLAR_TIMESTAMP_URL%"
set "SIGN_DESC=%POLAR_SIGN_DESCRIPTION%"

if not defined TIMESTAMP_URL set "TIMESTAMP_URL=http://timestamp.digicert.com"
if not defined SIGN_DESC set "SIGN_DESC=POLAR"

if not exist "%CSC%" (
    echo Could not find csc.exe
    exit /b 1
)

"%CSC%" /nologo /target:exe /out:"Polar.exe" "PolarConsole.cs"
if errorlevel 1 exit /b %errorlevel%

if defined POLAR_PFX_PATH (
    if not exist "%POLAR_PFX_PATH%" (
        echo Signing enabled, but certificate file was not found:
        echo   %POLAR_PFX_PATH%
        exit /b 1
    )

    if not defined SIGNTOOL (
        for /f "usebackq delims=" %%I in (`where signtool.exe 2^>nul`) do (
            if not defined SIGNTOOL set "SIGNTOOL=%%I"
        )
    )

    if not defined SIGNTOOL (
        for /f "usebackq delims=" %%I in (`powershell -NoProfile -Command "$t=Get-ChildItem 'C:\Program Files (x86)\Windows Kits\10\bin' -Recurse -Filter signtool.exe -ErrorAction SilentlyContinue | Sort-Object FullName -Descending | Select-Object -First 1 -ExpandProperty FullName; if($t){$t}"`) do (
            if not defined SIGNTOOL set "SIGNTOOL=%%I"
        )
    )

    if not defined SIGNTOOL (
        echo Signing enabled, but signtool.exe was not found.
        echo Install the Windows SDK or set POLAR_SIGNTOOL to the full path.
        exit /b 1
    )

    echo Signing with:
    echo   %SIGNTOOL%

    if defined POLAR_PFX_PASSWORD (
        "%SIGNTOOL%" sign /f "%POLAR_PFX_PATH%" /p "%POLAR_PFX_PASSWORD%" /fd SHA256 /tr "%TIMESTAMP_URL%" /td SHA256 /d "%SIGN_DESC%" "Polar.exe"
    ) else (
        "%SIGNTOOL%" sign /f "%POLAR_PFX_PATH%" /fd SHA256 /tr "%TIMESTAMP_URL%" /td SHA256 /d "%SIGN_DESC%" "Polar.exe"
    )

    if errorlevel 1 exit /b %errorlevel%
    "%SIGNTOOL%" verify /pa /v "Polar.exe"
    if errorlevel 1 exit /b %errorlevel%
) else (
    echo Signing skipped. Set POLAR_PFX_PATH to enable Authenticode signing.
)

if not exist "%LOCALAPPDATA%\POLAR" mkdir "%LOCALAPPDATA%\POLAR" >nul 2>&1
copy /y "Polar.exe" "%LOCALAPPDATA%\POLAR\Polar.exe" >nul
copy /y "PolarAutoUpdate.ps1" "%LOCALAPPDATA%\POLAR\PolarAutoUpdate.ps1" >nul

if exist "Polar.zip" del /f /q "Polar.zip" >nul 2>&1
powershell -NoProfile -Command "Compress-Archive -LiteralPath 'Polar.exe','PolarAutoUpdate.ps1' -DestinationPath 'Polar.zip' -Force"
if errorlevel 1 exit /b %errorlevel%

echo Built: "%~dp0Polar.exe"
echo Release zip: "%~dp0Polar.zip"
echo Stable copy: "%LOCALAPPDATA%\POLAR\Polar.exe"
exit /b %errorlevel%
