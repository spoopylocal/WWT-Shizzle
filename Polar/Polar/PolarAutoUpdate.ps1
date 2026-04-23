param(
    [switch]$CheckOnly,
    [switch]$ApplyUpdate,
    [string]$Repo = 'spoopylocal/WWT-Shizzle',
    [string]$AssetName = 'Polar.zip',
    [string]$CurrentVersion,
    [string]$CurrentExe,
    [int]$ProcessId
)

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

$Repo = $Repo.Trim("'`" ")
$AssetName = $AssetName.Trim("'`" ")
$CurrentVersion = $CurrentVersion.Trim("'`" ")

if (-not [string]::IsNullOrWhiteSpace($CurrentExe)) {
    $CurrentExe = $CurrentExe.Trim("'`" ")
}

$PolarHome = Join-Path $env:LOCALAPPDATA 'POLAR'
$PolarLogs = Join-Path $PolarHome 'Logs'
$UpdaterLog = Join-Path $PolarLogs 'polar-updater.log'

function Ensure-UpdaterFolders {
    New-Item -ItemType Directory -Force -Path $PolarHome | Out-Null
    New-Item -ItemType Directory -Force -Path $PolarLogs | Out-Null
}

function Write-UpdaterLog {
    param([string]$Message)

    try {
        Ensure-UpdaterFolders
        Add-Content -LiteralPath $UpdaterLog -Value ("[{0}] {1}" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $Message)
    }
    catch {
    }
}

function Quote-PS {
    param([string]$Value)

    if ($null -eq $Value) {
        return "''"
    }

    return "'" + $Value.Replace("'", "''") + "'"
}

function Try-ParseVersion {
    param([string]$Text)

    if ([string]::IsNullOrWhiteSpace($Text)) {
        return $null
    }

    $cleanText = $Text.Trim("'`" ")
    $match = [regex]::Match($cleanText, '(\d+)\.(\d+)\.(\d+)(?:\.(\d+))?')

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

    $Repository = $Repository.Trim("'`" ")
    $WantedAsset = $WantedAsset.Trim("'`" ")

    Write-UpdaterLog "Checking GitHub latest release."
    Write-UpdaterLog "Repo: $Repository"
    Write-UpdaterLog "Wanted asset: $WantedAsset"

    $headers = @{
        'User-Agent' = 'POLAR-Updater'
        'Accept' = 'application/vnd.github+json'
    }

    $releaseUrl = "https://api.github.com/repos/$Repository/releases/latest"

    Write-UpdaterLog "Release URL: $releaseUrl"

    $release = Invoke-RestMethod -Uri $releaseUrl -Headers $headers

    Write-UpdaterLog "Latest tag: $($release.tag_name)"

    foreach ($asset in $release.assets) {
        Write-UpdaterLog "Release asset found: $($asset.name)"

        if ($asset.name -eq $WantedAsset) {
            Write-UpdaterLog "Matched asset: $WantedAsset"

            return [pscustomobject]@{
                VersionTag = [string]$release.tag_name
                DownloadUrl = [string]$asset.browser_download_url
            }
        }
    }

    Write-UpdaterLog "No matching asset found."
    return $null
}

function Get-UpdateSourceDirectory {
    param([string]$ExtractDir)

    $newExe = Get-ChildItem -LiteralPath $ExtractDir -Recurse -File -Filter 'Polar.exe' |
        Select-Object -First 1

    if ($null -eq $newExe) {
        throw "Downloaded zip does not contain Polar.exe"
    }

    return $newExe.DirectoryName
}

function Start-ApplyUpdate {
    param(
        [string]$DownloadUrl,
        [string]$ExePath,
        [int]$RunningPid
    )

    $ExePath = $ExePath.Trim("'`" ")

    if ([string]::IsNullOrWhiteSpace($ExePath)) {
        throw "CurrentExe was empty."
    }

    if (-not (Test-Path -LiteralPath $ExePath)) {
        throw "Current executable was not found: $ExePath"
    }

    if ($RunningPid -le 0) {
        throw "Invalid ProcessId: $RunningPid"
    }

    Ensure-UpdaterFolders

    $targetDir = Split-Path -Path $ExePath -Parent
    $targetExe = $ExePath

    $tempRoot = Join-Path $env:TEMP ("polar-update-" + [guid]::NewGuid().ToString('N'))
    $zipPath = Join-Path $tempRoot 'Polar.zip'
    $extractDir = Join-Path $tempRoot 'extract'
    $applyScript = Join-Path $tempRoot 'apply-update.ps1'
    $copyLog = Join-Path $PolarLogs 'polar-update-copy.log'

    New-Item -ItemType Directory -Force -Path $tempRoot | Out-Null
    New-Item -ItemType Directory -Force -Path $extractDir | Out-Null

    Write-UpdaterLog "Preparing update."
    Write-UpdaterLog "DownloadUrl: $DownloadUrl"
    Write-UpdaterLog "TargetDir: $targetDir"
    Write-UpdaterLog "TargetExe: $targetExe"
    Write-UpdaterLog "RunningPid: $RunningPid"
    Write-UpdaterLog "TempRoot: $tempRoot"

    $headers = @{
        'User-Agent' = 'POLAR-Updater'
    }

    Write-UpdaterLog "Downloading zip."

    Invoke-WebRequest -Uri $DownloadUrl -OutFile $zipPath -UseBasicParsing -Headers $headers

    if (-not (Test-Path -LiteralPath $zipPath)) {
        throw "Zip download failed."
    }

    $zipSize = (Get-Item -LiteralPath $zipPath).Length

    Write-UpdaterLog "Zip size: $zipSize bytes"

    if ($zipSize -lt 1000) {
        throw "Downloaded zip is too small: $zipSize bytes"
    }

    Write-UpdaterLog "Extracting zip."

    Expand-Archive -LiteralPath $zipPath -DestinationPath $extractDir -Force

    $sourceDir = Get-UpdateSourceDirectory -ExtractDir $extractDir

    Write-UpdaterLog "SourceDir: $sourceDir"

    $applyCode = @"
`$ErrorActionPreference = 'Continue'

`$pidToWait = $RunningPid
`$sourceDir = $(Quote-PS $sourceDir)
`$targetDir = $(Quote-PS $targetDir)
`$targetExe = $(Quote-PS $targetExe)
`$tempRoot = $(Quote-PS $tempRoot)
`$mainLog = $(Quote-PS $UpdaterLog)
`$copyLog = $(Quote-PS $copyLog)

function Log {
    param([string]`$Message)

    try {
        Add-Content -LiteralPath `$mainLog -Value ("[{0}] {1}" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), `$Message)
    }
    catch {
    }
}

Log "Apply process started."
Log "Waiting for PID: `$pidToWait"

while (`$true) {
    `$process = Get-Process -Id `$pidToWait -ErrorAction SilentlyContinue

    if (`$null -eq `$process) {
        break
    }

    Start-Sleep -Milliseconds 500
}

Log "Original process closed."
Log "Copying update files."
Log "Source: `$sourceDir"
Log "Target: `$targetDir"

try {
    `$null = New-Item -ItemType Directory -Force -Path `$targetDir

    `$robocopy = Start-Process -FilePath "robocopy.exe" -ArgumentList @(
        "`$sourceDir",
        "`$targetDir",
        "/E",
        "/IS",
        "/IT",
        "/R:20",
        "/W:1",
        "/NFL",
        "/NDL",
        "/NP",
        "/LOG+:`$copyLog"
    ) -Wait -PassThru -WindowStyle Hidden

    `$exitCode = `$robocopy.ExitCode

    Log "Robocopy exit code: `$exitCode"

    if (`$exitCode -ge 8) {
        Log "Robocopy failed. See copy log: `$copyLog"
        exit `$exitCode
    }

    if (-not (Test-Path -LiteralPath `$targetExe)) {
        Log "Target exe missing after copy: `$targetExe"
        exit 20
    }

    `$newExeInfo = Get-Item -LiteralPath `$targetExe

    Log "Updated exe exists. Size: `$(`$newExeInfo.Length) bytes"
    Log "Starting updated POLAR."

    Start-Process -FilePath `$targetExe -ArgumentList "--updated"

    Start-Sleep -Seconds 2

    Log "Cleaning temp folder."

    Remove-Item -LiteralPath `$tempRoot -Recurse -Force -ErrorAction SilentlyContinue

    Log "Apply process complete."

    exit 0
}
catch {
    Log "APPLY ERROR: `$(`$_.Exception.Message)"
    exit 1
}
"@

    Set-Content -LiteralPath $applyScript -Value $applyCode -Encoding UTF8

    Write-UpdaterLog "Apply script created: $applyScript"

    $startInfo = New-Object System.Diagnostics.ProcessStartInfo
    $startInfo.FileName = 'powershell.exe'
    $startInfo.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$applyScript`""
    $startInfo.UseShellExecute = $false
    $startInfo.CreateNoWindow = $true

    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = $startInfo

    if (-not $process.Start()) {
        throw "Failed to start apply script."
    }

    Write-UpdaterLog "Apply script launched. PID: $($process.Id)"
}

try {
    Ensure-UpdaterFolders

    Write-UpdaterLog "=============================="
    Write-UpdaterLog "Updater started."
    Write-UpdaterLog "CheckOnly: $CheckOnly"
    Write-UpdaterLog "ApplyUpdate: $ApplyUpdate"
    Write-UpdaterLog "Repo: $Repo"
    Write-UpdaterLog "AssetName: $AssetName"
    Write-UpdaterLog "CurrentVersion: $CurrentVersion"
    Write-UpdaterLog "CurrentExe: $CurrentExe"
    Write-UpdaterLog "ProcessId: $ProcessId"

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    $release = Get-LatestReleaseInfo -Repository $Repo -WantedAsset $AssetName

    if ($null -eq $release) {
        Write-UpdaterLog "No matching release asset found. Exiting 0."
        exit 0
    }

    $remote = Try-ParseVersion $release.VersionTag
    $local = Try-ParseVersion $CurrentVersion

    if ($null -eq $remote) {
        Write-UpdaterLog "Remote version could not be parsed from tag: $($release.VersionTag)"
        exit 0
    }

    $needsUpdate = $true

    if ($null -ne $local) {
        $needsUpdate = $remote -gt $local
    }

    Write-UpdaterLog "Remote parsed: $remote"
    Write-UpdaterLog "Local parsed: $local"
    Write-UpdaterLog "Needs update: $needsUpdate"

    if ($CheckOnly) {
        if ($needsUpdate) {
            Write-UpdaterLog "CheckOnly exit 10."
            exit 10
        }

        Write-UpdaterLog "CheckOnly exit 0."
        exit 0
    }

    if ($ApplyUpdate) {
        if (-not $needsUpdate) {
            Write-UpdaterLog "ApplyUpdate requested, but no update needed. Exit 0."
            exit 0
        }

        Start-ApplyUpdate -DownloadUrl $release.DownloadUrl -ExePath $CurrentExe -RunningPid $ProcessId

        Write-UpdaterLog "ApplyUpdate launch complete. Exit 0."
        exit 0
    }

    Write-UpdaterLog "No action selected. Exit 0."
    exit 0
}
catch {
    Write-UpdaterLog "ERROR: $($_.Exception.Message)"
    exit 1
}