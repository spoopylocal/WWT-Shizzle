$ErrorActionPreference = 'Stop'

param(
    [switch]$CheckOnly,
    [switch]$ApplyUpdate,
    [string]$Repo = 'spoopylocal/WWT-Shizzle',
    [string]$AssetName = 'Polar.zip',
    [string]$CurrentVersion,
    [string]$CurrentExe,
    [int]$ProcessId
)

function Try-ParseVersion {
    param([string]$Text)

    if ([string]::IsNullOrWhiteSpace($Text)) {
        return $null
    }

    $match = [regex]::Match($Text, '(\d+)\.(\d+)\.(\d+)(?:\.(\d+))?')
    if (-not $match.Success) {
        return $null
    }

    $parts = New-Object System.Collections.Generic.List[int]
    for ($i = 1; $i -lt $match.Groups.Count; $i++) {
        if ($match.Groups[$i].Success) {
            $parts.Add([int]$match.Groups[$i].Value)
        }
    }

    while ($parts.Count -lt 4) {
        $parts.Add(0)
    }

    return New-Object Version($parts[0], $parts[1], $parts[2], $parts[3])
}

function Get-LatestReleaseInfo {
    param(
        [string]$Repository,
        [string]$WantedAsset
    )

    $headers = @{ 'User-Agent' = 'POLAR-Updater' }
    $release = Invoke-RestMethod -Uri ("https://api.github.com/repos/$Repository/releases/latest") -Headers $headers

    foreach ($asset in $release.assets) {
        if ($asset.name -eq $WantedAsset) {
            return [pscustomobject]@{
                VersionTag = [string]$release.tag_name
                DownloadUrl = [string]$asset.browser_download_url
            }
        }
    }

    return $null
}

function Start-ApplyUpdate {
    param(
        [string]$DownloadUrl,
        [string]$ExePath,
        [int]$RunningPid
    )

    if (-not (Test-Path -LiteralPath $ExePath)) {
        throw "Current executable was not found: $ExePath"
    }

    $targetDir = Split-Path -Path $ExePath -Parent
    $tempRoot = Join-Path $env:TEMP ("polar-update-" + [guid]::NewGuid().ToString('N'))
    $zipPath = Join-Path $tempRoot 'Polar.zip'
    $extractDir = Join-Path $tempRoot 'extract'
    $cmdPath = Join-Path $tempRoot 'apply-update.cmd'

    New-Item -ItemType Directory -Force -Path $extractDir | Out-Null

    $headers = @{ 'User-Agent' = 'POLAR-Updater' }
    Invoke-WebRequest -Uri $DownloadUrl -OutFile $zipPath -UseBasicParsing -Headers $headers

    Expand-Archive -LiteralPath $zipPath -DestinationPath $extractDir -Force

    $newExe = Join-Path $extractDir 'Polar.exe'
    if (-not (Test-Path -LiteralPath $newExe)) {
        throw "Downloaded zip does not contain Polar.exe"
    }

    $cmd = @"
@echo off
setlocal
set "PID=$RunningPid"
set "TARGET_DIR=$targetDir"
set "SOURCE_DIR=$extractDir"
set "TARGET_EXE=$ExePath"

:waitloop
tasklist /FI "PID eq %PID%" | find "%PID%" >nul
if not errorlevel 1 (
  timeout /t 1 /nobreak >nul
  goto waitloop
)

xcopy /y /e /i "%SOURCE_DIR%\*" "%TARGET_DIR%\" >nul
start "" "%TARGET_EXE%" --updated
rd /s /q "$tempRoot" >nul 2>&1
del /f /q "%~f0" >nul 2>&1
"@

    Set-Content -LiteralPath $cmdPath -Value $cmd -Encoding ASCII
    Start-Process -FilePath $cmdPath -WindowStyle Hidden
}

$release = Get-LatestReleaseInfo -Repository $Repo -WantedAsset $AssetName
if ($null -eq $release) {
    exit 0
}

$remote = Try-ParseVersion $release.VersionTag
$local = Try-ParseVersion $CurrentVersion
if ($null -eq $remote) {
    exit 0
}

$needsUpdate = $true
if ($null -ne $local) {
    $needsUpdate = $remote -gt $local
}

if ($CheckOnly) {
    if ($needsUpdate) {
        exit 10
    }

    exit 0
}

if ($ApplyUpdate) {
    if (-not $needsUpdate) {
        exit 0
    }

    Start-ApplyUpdate -DownloadUrl $release.DownloadUrl -ExePath $CurrentExe -RunningPid $ProcessId
    exit 0
}

exit 0
