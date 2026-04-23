using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Runtime.InteropServices;
using System.Security.Principal;
using System.Text;

internal static class PolarConsoleApp
{
    private static readonly string PolarHome = Path.Combine(
        Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData),
        "POLAR");
    private static readonly string PolarSoftware = Path.Combine(PolarHome, "Software");
    private static readonly string PolarFiles = Path.Combine(PolarHome, "Files");
    private static readonly string PolarLogs = Path.Combine(PolarHome, "Logs");
    private static readonly string PolarSettings = Path.Combine(PolarHome, "settings.ini");
    private static readonly string PolarVersion = "2.2.0";
    private static readonly string GitHubRepo = "spoopylocal/WWT-Shizzle";
    private static readonly string GitHubRef = "main";
    private static readonly string PolarUpdaterScript = Path.Combine(PolarHome, "PolarAutoUpdate.ps1");
    private static readonly string[] BannerLines =
    {
        DecodeBase64("ICAgICAgICAgICAg4paI4paI4paI4paI4paI4paI4pWXICDilojilojilojilojilojilojilZcg4paI4paI4pWXICAgICAg4paI4paI4paI4paI4paI4pWXIOKWiOKWiOKWiOKWiOKWiOKWiOKVlw=="),
        DecodeBase64("ICAgICAgICAgICAg4paI4paI4pWU4pWQ4pWQ4paI4paI4pWX4paI4paI4pWU4pWQ4pWQ4pWQ4paI4paI4pWX4paI4paI4pWRICAgICDilojilojilZTilZDilZDilojilojilZfilojilojilZTilZDilZDilojilojilZc="),
        DecodeBase64("ICAgICAgICAgICAg4paI4paI4paI4paI4paI4paI4pWU4pWd4paI4paI4pWRICAg4paI4paI4pWR4paI4paI4pWRICAgICDilojilojilojilojilojilojilojilZHilojilojilojilojilojilojilZTilZ0="),
        DecodeBase64("ICAgICAgICAgICAg4paI4paI4pWU4pWQ4pWQ4pWQ4pWdIOKWiOKWiOKVkSAgIOKWiOKWiOKVkeKWiOKWiOKVkSAgICAg4paI4paI4pWU4pWQ4pWQ4paI4paI4pWR4paI4paI4pWU4pWQ4pWQ4paI4paI4pWX"),
        DecodeBase64("ICAgICAgICAgICAg4paI4paI4pWRICAgICDilZrilojilojilojilojilojilojilZTilZ3ilojilojilojilojilojilojilojilZfilojilojilZEgIOKWiOKWiOKVkeKWiOKWiOKVkSAg4paI4paI4pWR"),
        DecodeBase64("ICAgICAgICAgICAg4pWa4pWQ4pWdICAgICAg4pWa4pWQ4pWQ4pWQ4pWQ4pWQ4pWdIOKVmuKVkOKVkOKVkOKVkOKVkOKVkOKVneKVmuKVkOKVnSAg4pWa4pWQ4pWd4pWa4pWQ4pWdICDilZrilZDilZ0=")
    };
    private static readonly string[] BannerColors =
    {
        "38;2;245;250;255",
        "38;2;220;240;255",
        "38;2;195;230;255",
        "38;2;170;220;255",
        "38;2;145;210;255",
        "38;2;120;200;255"
    };
    private static bool _ansiEnabled;

    private static bool _confirmCleanup = true;
    private static string _pingTarget = "google.com";
    private static int _pingCount = 4;
    private static string LogFilePath
    {
        get
        {
            return Path.Combine(PolarLogs, "polar-" + DateTime.Now.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture) + ".log");
        }
    }

    private sealed class CleanupTarget
    {
        public CleanupTarget(string label, string path)
        {
            Label = label;
            Path = path;
        }

        public string Label { get; private set; }
        public string Path { get; private set; }
        public bool Selected { get; set; }
    }

    private sealed class CleanupSummary
    {
        public int FileCount { get; set; }
        public int FolderCount { get; set; }
        public string SizeLabel { get; set; }
    }

    private static int Main(string[] args)
    {
        Console.OutputEncoding = Encoding.UTF8;
        Console.InputEncoding = Encoding.UTF8;
        Console.Title = "POLAR";
        _ansiEnabled = EnableVirtualTerminalProcessing();

        EnsureDirectories();
        LoadSettings();
        Log("POLAR console prototype started");
        if (!HasArgument(args, "--updated"))
        {
            if (RunExternalAutoUpdate())
            {
                return 0;
            }
        }

        while (true)
        {
            var choice = ShowMenu(
                "POLAR Arctic Toolkit",
                new[]
                {
                    "Network Tools",
                    "System Tools",
                    "Cleanup Tools",
                    "Software",
                    "Files/Directorys",
                    "Credits",
                    "Settings",
                    "Exit"
                },
                showBanner: true);

            switch (choice)
            {
                case 0:
                    ShowNetworkMenu();
                    break;
                case 1:
                    ShowSystemMenu();
                    break;
                case 2:
                    ShowCleanupMenu();
                    break;
                case 3:
                    ShowSoftwareMenu();
                    break;
                case 4:
                    ShowFilesDirectories();
                    break;
                case 5:
                    ShowCredits();
                    break;
                case 6:
                    ShowSettings();
                    break;
                default:
                    Log("POLAR console prototype exited");
                    return 0;
            }
        }
    }

    private static void EnsureDirectories()
    {
        Directory.CreateDirectory(PolarHome);
        Directory.CreateDirectory(PolarSoftware);
        Directory.CreateDirectory(PolarFiles);
        Directory.CreateDirectory(PolarLogs);
    }

    private static bool HasArgument(string[] args, string value)
    {
        if (args == null)
        {
            return false;
        }

        for (var i = 0; i < args.Length; i++)
        {
            if (string.Equals(args[i], value, StringComparison.OrdinalIgnoreCase))
            {
                return true;
            }
        }

        return false;
    }

    private static bool RunExternalAutoUpdate()
    {
        try
        {
            if (!File.Exists(PolarUpdaterScript))
            {
                Log("External updater skipped. Script not found: " + PolarUpdaterScript);
                return false;
            }

            var checkArgs =
                "-CheckOnly" +
                " -Repo " + QuoteArg(GitHubRepo) +
                " -AssetName " + QuoteArg("Polar.zip") +
                " -CurrentVersion " + QuoteArg(PolarVersion);

            var checkExitCode = RunUpdaterScript(checkArgs, hidden: true);

            Log("External updater check exit code: " + checkExitCode.ToString(CultureInfo.InvariantCulture));

            if (checkExitCode != 10)
            {
                return false;
            }

            var currentExe = GetCurrentExecutablePath();

            if (string.IsNullOrWhiteSpace(currentExe))
            {
                Log("External updater failed. Current executable path was empty.");
                return false;
            }

            var processId = Process.GetCurrentProcess().Id;

            var applyArgs =
                "-ApplyUpdate" +
                " -Repo " + QuoteArg(GitHubRepo) +
                " -AssetName " + QuoteArg("Polar.zip") +
                " -CurrentVersion " + QuoteArg(PolarVersion) +
                " -CurrentExe " + QuoteArg(currentExe) +
                " -ProcessId " + processId.ToString(CultureInfo.InvariantCulture);

            var applyExitCode = RunUpdaterScript(applyArgs, hidden: true);

            Log("External updater apply exit code: " + applyExitCode.ToString(CultureInfo.InvariantCulture));

            if (applyExitCode != 0)
            {
                return false;
            }

            Log("External updater launched.");
            return true;
        }
        catch (Exception ex)
        {
            Log("External updater failed: " + ex.Message);
            return false;
        }
    }

    private static void LoadSettings()
    {
        if (!File.Exists(PolarSettings))
        {
            SaveSettings();
            return;
        }

        foreach (var line in File.ReadAllLines(PolarSettings))
        {
            var index = line.IndexOf('=');
            if (index <= 0)
            {
                continue;
            }

            var key = line.Substring(0, index).Trim();
            var value = line.Substring(index + 1).Trim();

            switch (key.ToUpperInvariant())
            {
                case "CONFIRM_CLEANUP":
                    _confirmCleanup = value == "1";
                    break;
                case "PING_TARGET":
                    if (!string.IsNullOrWhiteSpace(value))
                    {
                        _pingTarget = value;
                    }

                    break;
                case "PING_COUNT":
                    int pingCount;
                    if (int.TryParse(value, NumberStyles.Integer, CultureInfo.InvariantCulture, out pingCount) && pingCount > 0)
                    {
                        _pingCount = pingCount;
                    }

                    break;
            }
        }

        SaveSettings();
    }

    private static void SaveSettings()
    {
        File.WriteAllLines(
            PolarSettings,
            new[]
            {
                "CONFIRM_CLEANUP=" + (_confirmCleanup ? "1" : "0"),
                "PING_TARGET=" + _pingTarget,
                "PING_COUNT=" + _pingCount.ToString(CultureInfo.InvariantCulture)
            });
    }

    private static void Log(string message)
    {
        try
        {
            Directory.CreateDirectory(PolarLogs);
            File.AppendAllText(
                LogFilePath,
                "[" + DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss", CultureInfo.InvariantCulture) + "] " + message + Environment.NewLine);
        }
        catch
        {
            // Swallow logging failures to keep the console responsive.
        }
    }

    private static void ShowNetworkMenu()
    {
        while (true)
        {
            var choice = ShowMenu("Network Tools", new[] { "Ping Target", "Show IP Config", "Back" });
            if (choice == 0)
            {
                ShowPingScreen();
            }
            else if (choice == 1)
            {
                RunProcessScreen("IP Configuration", "ipconfig", string.Empty);
            }
            else
            {
                return;
            }
        }
    }

    private static void ShowSystemMenu()
    {
        while (true)
        {
            var choice = ShowMenu("System Tools", new[] { "System Info", "Task List", "Back" });
            if (choice == 0)
            {
                RunProcessScreen("System Info", "systeminfo", string.Empty);
            }
            else if (choice == 1)
            {
                RunProcessScreen("Task List", "tasklist", string.Empty);
            }
            else
            {
                return;
            }
        }
    }

    private static void ShowPingScreen()
    {
        RenderHeader("Ping Target");
        WriteLineColored("                 Target [" + _pingTarget + "]: ", ConsoleColor.Cyan);
        var targetInput = Console.ReadLine();
        if (!string.IsNullOrWhiteSpace(targetInput))
        {
            _pingTarget = targetInput.Trim();
        }

        WriteLineColored(string.Empty, ConsoleColor.Cyan);
        WriteLineColored("                 Number of pings [" + _pingCount + "]: ", ConsoleColor.Cyan);
        var countInput = Console.ReadLine();
        int count;
        if (!string.IsNullOrWhiteSpace(countInput) && int.TryParse(countInput, out count) && count > 0)
        {
            _pingCount = count;
            SaveSettings();
        }

        Log("Network ping requested: target=" + _pingTarget + ", count=" + _pingCount);
        RunProcessScreen("Ping", "ping", "-n " + _pingCount.ToString(CultureInfo.InvariantCulture) + " " + QuoteArg(_pingTarget));
    }

    private static void ShowCleanupMenu()
    {
        var targets = new List<CleanupTarget>
        {
            new CleanupTarget("User Temp", Path.GetTempPath()),
            new CleanupTarget("Windows Temp", Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.Windows), "Temp")),
            new CleanupTarget("Prefetch", Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.Windows), "Prefetch"))
        };

        while (true)
        {
            var items = new[]
            {
                "[" + (targets[0].Selected ? "x" : " ") + "] " + targets[0].Label,
                "[" + (targets[1].Selected ? "x" : " ") + "] " + targets[1].Label,
                "[" + (targets[2].Selected ? "x" : " ") + "] " + targets[2].Label,
                "Run Selected",
                "Back"
            };

            var choice = ShowMenu(
                "Cleanup Tools",
                items,
                "Use Up/Down and Enter. Enter toggles targets or runs cleanup.");

            if (choice >= 0 && choice <= 2)
            {
                targets[choice].Selected = !targets[choice].Selected;
                continue;
            }

            if (choice == 3)
            {
                RunCleanupTargets(targets);
                continue;
            }

            if (choice == 4)
            {
                return;
            }
        }
    }

    private static void RunCleanupTargets(List<CleanupTarget> targets)
    {
        var selected = targets.Where(t => t.Selected).ToList();
        if (selected.Count == 0)
        {
            ShowMessage("Cleanup Tools", "Select at least one cleanup item.");
            return;
        }

        RenderHeader("Cleanup Preview");
        WriteLineColored("                 Selected cleanup targets:", ConsoleColor.White);
        WriteLineColored(string.Empty, ConsoleColor.White);

        foreach (var target in selected)
        {
            var summary = GetCleanupSummary(target.Path);
            WriteLineColored(
                string.Format(
                    CultureInfo.InvariantCulture,
                    "                 {0} - {1} files, {2} folders, {3}",
                    target.Label,
                    summary.FileCount,
                    summary.FolderCount,
                    summary.SizeLabel),
                ConsoleColor.Cyan);
            WriteLineColored("                    " + target.Path, ConsoleColor.DarkCyan);
        }

        WriteLineColored(string.Empty, ConsoleColor.White);
        if (_confirmCleanup && !AskYesNo("                 Delete files in these locations? Y/N: "))
        {
            Log("Cleanup cancelled at preview");
            return;
        }

        foreach (var target in selected)
        {
            RunCleanupTarget(target);
        }

        ShowMessage("Cleanup Tools", "Cleanup complete.");
    }

    private static CleanupSummary GetCleanupSummary(string path)
    {
        try
        {
            if (!Directory.Exists(path))
            {
                return new CleanupSummary { FileCount = 0, FolderCount = 0, SizeLabel = "0 B" };
            }

            var dir = new DirectoryInfo(path);
            var files = dir.EnumerateFiles("*", SearchOption.AllDirectories).ToList();
            var folders = dir.EnumerateDirectories("*", SearchOption.AllDirectories).Count();
            var totalBytes = files.Sum(f => f.Length);
            return new CleanupSummary
            {
                FileCount = files.Count,
                FolderCount = folders,
                SizeLabel = FormatSize(totalBytes)
            };
        }
        catch
        {
            return new CleanupSummary { FileCount = 0, FolderCount = 0, SizeLabel = "Unknown" };
        }
    }

    private static void RunCleanupTarget(CleanupTarget target)
    {
        RenderHeader("Cleanup Progress");
        WriteLineColored("                 Working on " + target.Label + "...", ConsoleColor.White);
        WriteLineColored(string.Empty, ConsoleColor.White);

        if (!Directory.Exists(target.Path))
        {
            WriteLineColored("                 Path not found.", ConsoleColor.Yellow);
            Log("Cleanup skipped, path not found: " + target.Label + " (" + target.Path + ")");
            Pause();
            return;
        }

        Log("Cleanup started: " + target.Label + " (" + target.Path + ")");

        try
        {
            foreach (var file in Directory.EnumerateFiles(target.Path, "*", SearchOption.AllDirectories))
            {
                try
                {
                    File.SetAttributes(file, FileAttributes.Normal);
                    File.Delete(file);
                }
                catch
                {
                }
            }

            var directories = Directory.EnumerateDirectories(target.Path, "*", SearchOption.AllDirectories)
                .OrderByDescending(p => p.Length)
                .ToList();

            foreach (var directory in directories)
            {
                try
                {
                    Directory.Delete(directory, true);
                }
                catch
                {
                }
            }

            Log("Cleanup finished: " + target.Label + " (" + target.Path + ")");
        }
        catch (Exception ex)
        {
            Log("Cleanup error: " + ex.Message);
        }
    }

    private static void ShowSettings()
    {
        while (true)
        {
            var choice = ShowMenu(
                "Settings",
                new[]
                {
                    "Cleanup confirmation: " + (_confirmCleanup ? "On" : "Off"),
                    "Default ping target: " + _pingTarget,
                    "Default ping count: " + _pingCount,
                    "Open Logs Folder",
                    "Back"
                });

            switch (choice)
            {
                case 0:
                    _confirmCleanup = !_confirmCleanup;
                    SaveSettings();
                    Log("Setting changed: cleanup confirmation=" + (_confirmCleanup ? "1" : "0"));
                    break;
                case 1:
                    RenderHeader("Settings");
                    WriteLineColored("                 New ping target: ", ConsoleColor.White);
                    var target = Console.ReadLine();
                    if (!string.IsNullOrWhiteSpace(target))
                    {
                        _pingTarget = target.Trim();
                        SaveSettings();
                        Log("Setting changed: ping target=" + _pingTarget);
                    }

                    break;
                case 2:
                    RenderHeader("Settings");
                    WriteLineColored("                 New ping count: ", ConsoleColor.White);
                    var countText = Console.ReadLine();
                    int newCount;
                    if (int.TryParse(countText, out newCount) && newCount > 0)
                    {
                        _pingCount = newCount;
                        SaveSettings();
                        Log("Setting changed: ping count=" + _pingCount);
                    }

                    break;
                case 3:
                    Process.Start("explorer.exe", QuoteArg(PolarLogs));
                    break;
                case 4:
                    return;
            }
        }
    }

    private static void ShowCredits()
    {
        RenderHeader("Credits");
        WriteLineColored("                 Made by:", ConsoleColor.White);
        WriteLineColored(string.Empty, ConsoleColor.White);
        WriteLineColored("                    Benjamin Cullum", ConsoleColor.Cyan);
        WriteLineColored("                    Thomas Carnell", ConsoleColor.Cyan);
        WriteLineColored(string.Empty, ConsoleColor.White);
        WriteLineColored("                 Polar is a WWT Friendly Software", ConsoleColor.White);
        WriteLineColored("                 that was made to access a GitHub Repo", ConsoleColor.White);
        WriteLineColored("                 that contains files and applications", ConsoleColor.White);
        WriteLineColored("                 used by L4 in NAIC1", ConsoleColor.White);
        Pause();
    }

    private static void ShowSoftwareMenu()
    {
        while (true)
        {
            var appDirectory = Path.Combine(PolarSoftware, "Outbound Auto OV");
            var appExe = Path.Combine(appDirectory, "Outbound Auto OV.exe");
            var installed = File.Exists(appExe);
            var choice = ShowMenu(
                "Software",
                new[]
                {
                    "Outbound Auto OV (" + (installed ? "Installed" : "Not Installed") + ")",
                    "Back"
                });

            if (choice == 0)
            {
                ShowSoftwareAppMenu(
                    "Outbound Auto OV",
                    appDirectory,
                    appExe,
                    Path.Combine(appDirectory, "version.txt"),
                    "Outbound.Auto.OV.exe");
            }
            else
            {
                return;
            }
        }
    }

    private static void ShowSoftwareAppMenu(string appName, string appDirectory, string appExe, string versionFile, string assetName)
    {
        while (true)
        {
            var installed = File.Exists(appExe);
            var choice = ShowMenu(
                appName,
                new[]
                {
                    "Launch",
                    "Check for Update / Install",
                    "Reinstall",
                    "Open Install Folder",
                    "Uninstall",
                    "Back"
                },
                "Status: " + (installed ? "Installed" : "Not Installed"));

            switch (choice)
            {
                case 0:
                    RunSoftwareAction(appName, appDirectory, appExe, versionFile, assetName, "launch");
                    break;
                case 1:
                    RunSoftwareAction(appName, appDirectory, appExe, versionFile, assetName, "update");
                    break;
                case 2:
                    if (AskYesNo("                 Reinstall " + appName + "? Y/N: "))
                    {
                        RunSoftwareAction(appName, appDirectory, appExe, versionFile, assetName, "reinstall");
                    }

                    break;
                case 3:
                    Directory.CreateDirectory(appDirectory);
                    Log("Opening software folder: " + appDirectory);
                    Process.Start("explorer.exe", QuoteArg(appDirectory));
                    break;
                case 4:
                    if (!Directory.Exists(appDirectory))
                    {
                        ShowMessage(appName, appName + " is not installed.");
                    }
                    else if (AskYesNo("                 Remove " + appName + " from POLAR? Y/N: "))
                    {
                        try
                        {
                            Directory.Delete(appDirectory, true);
                            Log("Uninstalled " + appName + " from " + appDirectory);
                        }
                        catch (Exception ex)
                        {
                            ShowMessage(appName, "Uninstall failed: " + ex.Message);
                            Log("Software uninstall failed: " + ex.Message);
                        }
                    }

                    break;
                case 5:
                    return;
            }
        }
    }

    private static void RunSoftwareAction(string appName, string appDirectory, string appExe, string versionFile, string assetName, string action)
    {
        RenderHeader("Software Manager");
        WriteLineColored("                 Working on " + appName + " (" + action + ")...", ConsoleColor.White);
        WriteLineColored(string.Empty, ConsoleColor.White);
        Log("Software action started: " + appName + " (" + action + ")");

        var script = "$ErrorActionPreference='Stop'; " +
                     "try { " +
                     "[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12; " +
                     "$action=$env:APP_ACTION; $repo=$env:GITHUB_REPO; $asset=$env:ASSET_NAME; $dir=$env:APP_DIR; $exe=$env:APP_EXE; $verFile=$env:APP_VERSION; $log=$env:POLAR_LOG_FILE; " +
                     "$headers=@{'User-Agent'='POLAR'}; New-Item -ItemType Directory -Force -Path $dir | Out-Null; " +
                     "if($action -eq 'launch'){ if(-not (Test-Path $exe)){ throw ($env:APP_NAME+' is not installed. Choose Check for Update / Install first.') }; Add-Content -Path $log -Value ((Get-Date -Format s)+' Launching '+$env:APP_NAME); Start-Process -FilePath $exe; Start-Sleep -Seconds 1; exit 0 }; " +
                     "if($action -eq 'reinstall'){ if(Test-Path $exe){ Remove-Item -LiteralPath $exe -Force -ErrorAction SilentlyContinue }; if(Test-Path $verFile){ Remove-Item -LiteralPath $verFile -Force -ErrorAction SilentlyContinue } }; " +
                     "Write-Host ('Checking GitHub release for '+$env:APP_NAME+'...'); " +
                     "$release=Invoke-RestMethod -Uri ('https://api.github.com/repos/'+$repo+'/releases/latest') -Headers $headers; " +
                     "$remoteVersion=[string]$release.tag_name; $localVersion=if(Test-Path $verFile){((Get-Content $verFile -Raw).Trim())}else{''}; " +
                     "$match=$null; foreach($a in $release.assets){ if($a.name -eq $asset){ $match=$a; break } }; if(-not $match){throw ('Release asset not found: '+$asset)}; " +
                     "$download=$match.browser_download_url; $badLocal=(Test-Path $exe) -and ((Get-Item $exe).Length -lt 100000); " +
                     "$needsDownload=(-not (Test-Path $exe)) -or $badLocal -or ($localVersion -ne $remoteVersion) -or ($action -eq 'reinstall'); " +
                     "if($needsDownload){ Write-Host ('Downloading '+$asset+' '+$remoteVersion+'...'); $tmp=Join-Path $env:TEMP ('polar_'+[guid]::NewGuid().ToString()+'.exe'); " +
                     "Invoke-WebRequest -Uri $download -OutFile $tmp -UseBasicParsing -Headers $headers; $item=Get-Item $tmp; if($item.Length -lt 100000){Remove-Item $tmp -Force; throw ('Downloaded file is too small: '+$item.Length+' bytes')}; " +
                     "$fs=[IO.File]::OpenRead($tmp); try{$b0=$fs.ReadByte(); $b1=$fs.ReadByte()}finally{$fs.Dispose()}; if($b0 -ne 77 -or $b1 -ne 90){Remove-Item $tmp -Force; throw 'Downloaded file is not a valid Windows EXE'}; " +
                     "Move-Item -Path $tmp -Destination $exe -Force; Set-Content -Path $verFile -Value $remoteVersion; Write-Host ('Installed '+$remoteVersion) } else { Write-Host ('Already up to date: '+$remoteVersion) }; " +
                     "Add-Content -Path $log -Value ((Get-Date -Format s)+' Software action '+$action+' completed for '+$env:APP_NAME); exit 0 } " +
                     "catch { if($env:POLAR_LOG_FILE){ Add-Content -Path $env:POLAR_LOG_FILE -Value ((Get-Date -Format s)+' ERROR '+$_.Exception.Message) }; Write-Host ''; Write-Host ('ERROR: '+$_.Exception.Message); exit 1 }";

        var exitCode = RunPowerShell(script, new Dictionary<string, string>
        {
            { "APP_NAME", appName },
            { "APP_ACTION", action },
            { "APP_DIR", appDirectory },
            { "APP_EXE", appExe },
            { "APP_VERSION", versionFile },
            { "ASSET_NAME", assetName },
            { "GITHUB_REPO", GitHubRepo },
            { "POLAR_LOG_FILE", LogFilePath }
        });

        if (exitCode != 0)
        {
            Log("Software action failed: " + appName + " (" + action + ")");
            Pause();
            return;
        }

        Log("Software action completed: " + appName + " (" + action + ")");
        WriteLineColored(string.Empty, ConsoleColor.White);
        WriteLineColored("                 " + appName + " action complete.", "38;2;180;255;210");
        System.Threading.Thread.Sleep(1200);
    }

    private static void ShowFilesDirectories()
    {
        Directory.CreateDirectory(PolarFiles);
        Log("Files/Directorys browser opened");

        var script = @"
$ErrorActionPreference='Stop'
try {
    [Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12
    $repo=$env:TEMPLATE_REPO
    $ref=$env:TEMPLATE_REF
    $root=$env:TEMPLATE_ROOT
    $local=$env:POLAR_FILES
    $log=$env:POLAR_LOG_FILE
    $headers=@{'User-Agent'='POLAR'}
    $esc=[char]27

    function K(){ $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown') }
    function Add-Log([string]$m){ if($log){ Add-Content -LiteralPath $log -Value ('[{0}] {1}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $m) } }
    function LocalPath([string]$p){ Join-Path $local $p.TrimStart('/') }
    function Open-ItemWithFallback([string]$path){
        try {
            Start-Process -FilePath $path -ErrorAction Stop
            Add-Log ('File opened: '+$path)
            return
        }
        catch {
            Add-Log ('Default open failed, showing Open With: '+$path)
            Start-Process -FilePath 'rundll32.exe' -ArgumentList ('shell32.dll,OpenAs_RunDLL '+[char]34+$path+[char]34)
        }
    }
    function Get-Width(){ [Math]::Max(20, [Console]::BufferWidth - 1) }
    function Paint([int]$row,[string]$text,[string]$color){
        $width=Get-Width
        if($null -eq $text){ $text='' }
        if($text.Length -gt $width){ $text=$text.Substring(0,$width) }
        $text=$text.PadRight($width)
        [Console]::SetCursorPosition(0,$row)
        [Console]::Write($esc+'['+$color+'m'+$text+$esc+'[0m')
    }
    function Get-RepoItems([string]$p){
        $apiPath=if([string]::IsNullOrWhiteSpace($p)){''}else{'/'+[uri]::EscapeDataString($p).Replace('%2F','/')}
        $uri='https://api.github.com/repos/'+$repo+'/contents'+$apiPath+'?ref='+$ref
        $all=@(Invoke-RestMethod -Uri $uri -Headers $headers | ForEach-Object { $_ })
        if([string]::IsNullOrWhiteSpace($p)){ $all=@($all | Where-Object { $_.type -eq 'dir' }) }
        $all | Sort-Object @{Expression={ if($_.type -eq 'dir'){0}else{1}}}, name
    }
    function Save-File($item){
        $dest=LocalPath $item.path
        New-Item -ItemType Directory -Force -Path (Split-Path -Path $dest -Parent) | Out-Null
        Invoke-WebRequest -Uri $item.download_url -OutFile $dest -UseBasicParsing -Headers $headers
        Add-Log ('File installed: '+$item.path+' -> '+$dest)
        return $dest
    }
    function DrawStaticFrame([string]$p){
        Clear-Host
        [Console]::WriteLine()
        [Console]::WriteLine($esc+'[38;2;220;240;255m                 =========================='+$esc+'[0m')
        [Console]::WriteLine($esc+'[38;2;230;245;255m                    Files/Directorys'+$esc+'[0m')
        [Console]::WriteLine($esc+'[38;2;220;240;255m                 =========================='+$esc+'[0m')
        [Console]::WriteLine()
        $show=if([string]::IsNullOrWhiteSpace($p)){'/'}else{$p}
        [Console]::WriteLine($esc+'[38;2;150;205;255m                 GitHub: '+$show+$esc+'[0m')
        [Console]::WriteLine($esc+'[38;2;150;205;255m                 Local:  '+$local+$esc+'[0m')
        [Console]::WriteLine()
        return [Console]::CursorTop
    }
    function DrawExplorer([string]$p,$items,[int]$sel,[int]$top){
        $row=$top
        if($items.Count -eq 0){
            Paint $row '                 No files or directories found.' '38;2;255;210;180'
            $row++
        } else {
            for($i=0; $i -lt $items.Count; $i++){
                $item=$items[$i]
                $kind=if($item.type -eq 'dir'){'Directory'}else{'File'}
                $suffix=if($item.type -eq 'dir'){
                    '('+$kind+')'
                } else {
                    $dest=LocalPath $item.path
                    $state=if(Test-Path -LiteralPath $dest){'Installed'}else{'Not Installed'}
                    '('+$kind+', '+$state+')'
                }
                $prefix=if($i -eq $sel){'              >  '}else{'                 '}
                $color=if($i -eq $sel){'38;2;230;245;255'}else{'38;2;180;220;255'}
                Paint $row ($prefix+$item.name+' '+$suffix) $color
                $row++
            }
        }
        Paint $row '' '38;2;225;242;255'; $row++
        Paint $row '                 Up/Down: Move   Enter: Open   Backspace: Up' '38;2;140;200;255'; $row++
        Paint $row '                 O: Open Local Files   B/Esc: Back' '38;2;140;200;255'; $row++
        [Console]::SetCursorPosition(0,$row)
    }
    function Header([string]$p){
        Clear-Host
        [Console]::WriteLine()
        [Console]::WriteLine($esc+'[38;2;220;240;255m                 =========================='+$esc+'[0m')
        [Console]::WriteLine($esc+'[38;2;230;245;255m                    Files/Directorys'+$esc+'[0m')
        [Console]::WriteLine($esc+'[38;2;220;240;255m                 =========================='+$esc+'[0m')
        [Console]::WriteLine()
        [Console]::WriteLine($esc+'[38;2;150;205;255m                 GitHub: '+$p+$esc+'[0m')
        [Console]::WriteLine($esc+'[38;2;150;205;255m                 Local:  '+$local+$esc+'[0m')
        [Console]::WriteLine()
    }
    function FileMenu($item){
        while($true){
            Header $item.path
            $dest=LocalPath $item.path
            $installed=Test-Path -LiteralPath $dest
            $state=if($installed){'Installed'}else{'Not Installed'}
            [Console]::WriteLine($esc+'[38;2;230;245;255m                 '+$item.name+$esc+'[0m')
            [Console]::WriteLine($esc+'[38;2;150;205;255m                 File | Status: '+$state+$esc+'[0m')
            [Console]::WriteLine()
            if($installed){
                [Console]::WriteLine($esc+'[38;2;180;220;255m                 [1] Open'+$esc+'[0m')
                [Console]::WriteLine($esc+'[38;2;180;220;255m                 [2] Reinstall'+$esc+'[0m')
                [Console]::WriteLine($esc+'[38;2;180;220;255m                 [3] Back'+$esc+'[0m')
            } else {
                [Console]::WriteLine($esc+'[38;2;180;220;255m                 [1] Install and Open'+$esc+'[0m')
                [Console]::WriteLine($esc+'[38;2;180;220;255m                 [2] Install Only'+$esc+'[0m')
                [Console]::WriteLine($esc+'[38;2;180;220;255m                 [3] Back'+$esc+'[0m')
            }
            $k=K
            $c=([string]$k.Character).ToUpper()
            if($c -eq '1'){
                if($installed){
                    Open-ItemWithFallback $dest
                } else {
                    [Console]::WriteLine($esc+'[38;2;210;235;255m                 Installing file...'+$esc+'[0m')
                    $saved=Save-File $item
                    Open-ItemWithFallback $saved
                }
            }
            if($c -eq '2'){
                [Console]::WriteLine($esc+'[38;2;210;235;255m                 Installing file...'+$esc+'[0m')
                $null=Save-File $item
            }
            if($c -eq '3' -or $k.VirtualKeyCode -eq 8 -or $k.VirtualKeyCode -eq 27){ return }
        }
    }

    New-Item -ItemType Directory -Force -Path $local | Out-Null
    $path=$root
    $selected=0
    $top=DrawStaticFrame $path
    while($true){
        $items=@(Get-RepoItems $path)
        if($selected -ge $items.Count){ $selected=[Math]::Max(0,$items.Count-1) }
        DrawExplorer $path $items $selected $top
        $key=K
        $char=([string]$key.Character).ToUpper()
        if($key.VirtualKeyCode -eq 38){ if($selected -gt 0){$selected--} else {$selected=[Math]::Max(0,$items.Count-1)}; continue }
        if($key.VirtualKeyCode -eq 40){ if($selected -lt ($items.Count-1)){$selected++} else {$selected=0}; continue }
        if($key.VirtualKeyCode -eq 8 -or $char -eq 'U'){
            if($path -ne $root){
                $slash=$path.LastIndexOf('/')
                if($slash -gt 0){ $path=$path.Substring(0,$slash) } else { $path=$root }
                $selected=0
                $top=DrawStaticFrame $path
            }
            continue
        }
        if($key.VirtualKeyCode -eq 27 -or $char -eq 'B'){ break }
        if($char -eq 'O'){ Start-Process -FilePath $local; continue }
        if($key.VirtualKeyCode -eq 13 -and $items.Count -gt 0){
            $item=$items[$selected]
            if($item.type -eq 'dir'){
                $path=$item.path
                $selected=0
                $top=DrawStaticFrame $path
            } else {
                FileMenu $item
                $top=DrawStaticFrame $path
            }
        }
    }
}
catch {
    [Console]::WriteLine()
    [Console]::WriteLine('ERROR: '+$_.Exception.Message)
    if($env:POLAR_LOG_FILE){
        Add-Content -LiteralPath $env:POLAR_LOG_FILE -Value ('[{0}] ERROR Files/Directorys browser: {1}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $_.Exception.Message)
    }
    $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown') | Out-Null
    exit 1
}
";

        var exitCode = RunPowerShell(script, new Dictionary<string, string>
        {
            { "TEMPLATE_REPO", GitHubRepo },
            { "TEMPLATE_REF", GitHubRef },
            { "TEMPLATE_ROOT", string.Empty },
            { "POLAR_FILES", PolarFiles },
            { "POLAR_LOG_FILE", LogFilePath }
        });

        if (exitCode != 0)
        {
            ShowMessage("Files/Directorys", "Files/Directorys browser failed. See log for details.");
        }
    }

    private static int ShowMenu(string title, IReadOnlyList<string> items, bool showBanner = false)
    {
        return ShowMenu(title, items, null, showBanner);
    }

    private static int ShowMenu(string title, IReadOnlyList<string> items, string statusLine, bool showBanner = false)
    {
        var selectedIndex = 0;
        var firstRender = true;
        var menuTop = 0;
        while (true)
        {
            if (firstRender)
            {
                if (showBanner)
                {
                    RenderMainMenuHeader();
                }
                else
                {
                    RenderHeader(title);
                }

                menuTop = Console.CursorTop;
                firstRender = false;
            }

            DrawMenuSurface(items, selectedIndex, statusLine, menuTop);

            var key = Console.ReadKey(true);
            if (key.Key == ConsoleKey.UpArrow)
            {
                selectedIndex = selectedIndex > 0 ? selectedIndex - 1 : items.Count - 1;
                continue;
            }

            if (key.Key == ConsoleKey.DownArrow)
            {
                selectedIndex = selectedIndex < items.Count - 1 ? selectedIndex + 1 : 0;
                continue;
            }

            if (key.Key == ConsoleKey.Enter)
            {
                return selectedIndex;
            }

            if (key.Key == ConsoleKey.Backspace || key.Key == ConsoleKey.Escape)
            {
                return items.Count - 1;
            }

            if (key.KeyChar >= '1' && key.KeyChar <= '9')
            {
                var index = key.KeyChar - '1';
                if (index < items.Count)
                {
                    return index;
                }
            }
        }
    }

    private static void DrawMenuSurface(IReadOnlyList<string> items, int selectedIndex, string statusLine, int topRow)
    {
        var row = topRow;
        for (var i = 0; i < items.Count; i++)
        {
            var prefix = i == selectedIndex ? "              > " : "                ";
            var color = i == selectedIndex ? "38;2;230;245;255" : "38;2;180;220;255";
            WriteAtColored(row++, prefix + items[i], color);
        }

        WriteAtColored(row++, string.Empty, MapConsoleColor(ConsoleColor.White));
        if (!string.IsNullOrEmpty(statusLine))
        {
            WriteAtColored(row++, "                 " + statusLine, "38;2;150;205;255");
            WriteAtColored(row++, string.Empty, MapConsoleColor(ConsoleColor.White));
        }

        WriteAtColored(row++, "                 Up/Down: Move   Enter: Select   Backspace/Esc: Back", MapConsoleColor(ConsoleColor.White));
        Console.SetCursorPosition(0, row);
    }

    private static void RenderMainMenuHeader()
    {
        SafeClear();
        Console.WriteLine();
        Console.WriteLine();
        DrawBannerExact();
        Console.WriteLine();
        DrawSeparator("POLAR Arctic Toolkit");
        Console.WriteLine();
        ShowStatus();
        Console.WriteLine();
    }

    private static void RenderHeader(string title)
    {
        SafeClear();
        Console.WriteLine();
        DrawSeparator(title);
        Console.WriteLine();
        ShowStatus();
        Console.WriteLine();
    }

    private static void DrawBanner()
    {
        WriteLineColored("            ██████╗  ██████╗ ██╗      █████╗ ██████╗", ConsoleColor.White);
        WriteLineColored("            ██╔══██╗██╔═══██╗██║     ██╔══██╗██╔══██╗", ConsoleColor.Cyan);
        WriteLineColored("            ██████╔╝██║   ██║██║     ███████║██████╔╝", ConsoleColor.Cyan);
        WriteLineColored("            ██╔═══╝ ██║   ██║██║     ██╔══██║██╔══██╗", ConsoleColor.Blue);
        WriteLineColored("            ██║     ╚██████╔╝███████╗██║  ██║██║  ██║", ConsoleColor.Blue);
        WriteLineColored("            ╚═╝      ╚═════╝ ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝", ConsoleColor.DarkCyan);
    }

    private static void DrawBannerExact()
    {
        for (var i = 0; i < BannerLines.Length; i++)
        {
            WriteLineColored(BannerLines[i], BannerColors[i]);
        }
    }

    private static void DrawSeparator(string title)
    {
        WriteLineColored("                 ==========================", "38;2;210;235;255");
        WriteLineColored("                    " + title, "38;2;230;245;255");
        WriteLineColored("                 ==========================", "38;2;210;235;255");
    }

    private static void ShowStatus()
    {
        var adminLabel = IsAdministrator() ? "Yes" : "No";
        WriteLineColored(
            "                 POLAR v" + PolarVersion + " | Admin: " + adminLabel,
            "38;2;150;205;255");
    }

    private static bool IsAdministrator()
    {
        try
        {
            var identity = WindowsIdentity.GetCurrent();
            var principal = new WindowsPrincipal(identity);
            return principal.IsInRole(WindowsBuiltInRole.Administrator);
        }
        catch
        {
            return false;
        }
    }

    private static bool AskYesNo(string prompt)
    {
        WriteLineColored(prompt, ConsoleColor.White);
        while (true)
        {
            var key = Console.ReadKey(true);
            if (key.Key == ConsoleKey.Y)
            {
                Console.WriteLine("Y");
                return true;
            }

            if (key.Key == ConsoleKey.N)
            {
                Console.WriteLine("N");
                return false;
            }
        }
    }

    private static void RunProcessScreen(string title, string fileName, string arguments)
    {
        RenderHeader(title);
        try
        {
            var process = new Process
            {
                StartInfo = new ProcessStartInfo
                {
                    FileName = fileName,
                    Arguments = arguments,
                    UseShellExecute = false
                }
            };

            process.Start();
            process.WaitForExit();
        }
        catch (Exception ex)
        {
            WriteLineColored("                 ERROR: " + ex.Message, ConsoleColor.Yellow);
        }

        Pause();
    }

    private static void ShowMessage(string title, string message)
    {
        RenderHeader(title);
        WriteLineColored("                 " + message, ConsoleColor.White);
        Pause();
    }

    private static void Pause()
    {
        WriteLineColored(string.Empty, ConsoleColor.White);
        WriteLineColored("                 Press any key to go back...", ConsoleColor.White);
        Console.ReadKey(true);
    }

    private static int RunUpdaterScript(string updaterArgs, bool hidden)
    {
        var startInfo = new ProcessStartInfo
        {
            FileName = "powershell.exe",
            Arguments = "-NoProfile -ExecutionPolicy Bypass -File " + QuoteArg(PolarUpdaterScript) + " " + updaterArgs,
            UseShellExecute = false,
            CreateNoWindow = hidden,
            WindowStyle = hidden ? ProcessWindowStyle.Hidden : ProcessWindowStyle.Normal
        };

        try
        {
            using (var process = new Process())
            {
                process.StartInfo = startInfo;
                process.Start();
                process.WaitForExit();
                return process.ExitCode;
            }
        }
        catch (Exception ex)
        {
            Log("RunUpdaterScript failed: " + ex.Message);
            return -1;
        }
    }

    private static void SafeClear()
    {
        try
        {
            Console.Clear();
        }
        catch (IOException)
        {
            try
            {
                Console.SetCursorPosition(0, 0);
            }
            catch
            {
            }

            try
            {
                var width = GetUsableConsoleWidth();
                var height = Math.Max(10, Console.WindowHeight);
                var blank = new string(' ', width);
                for (var i = 0; i < height; i++)
                {
                    Console.WriteLine(blank);
                }

                Console.SetCursorPosition(0, 0);
            }
            catch
            {
                Console.WriteLine();
                Console.WriteLine();
            }
        }
    }

    private static void WriteAtColored(int row, string text, string ansiColor)
    {
        var width = GetUsableConsoleWidth();
        var output = text ?? string.Empty;
        if (output.Length > width)
        {
            output = output.Substring(0, width);
        }

        output = output.PadRight(width);
        Console.SetCursorPosition(0, row);

        if (_ansiEnabled)
        {
            Console.Write("\u001b[");
            Console.Write(ansiColor);
            Console.Write("m");
            Console.Write(output);
            Console.Write("\u001b[0m");
            return;
        }

        Console.Write(output);
    }

    private static int GetUsableConsoleWidth()
    {
        try
        {
            return Math.Max(20, Console.BufferWidth - 1);
        }
        catch
        {
            return 119;
        }
    }

    private static int RunPowerShell(string script, IDictionary<string, string> environmentVariables)
    {
        var tempScriptPath = Path.Combine(Path.GetTempPath(), "polar_" + Guid.NewGuid().ToString("N", CultureInfo.InvariantCulture) + ".ps1");
        File.WriteAllText(tempScriptPath, script, new UTF8Encoding(false));

        var startInfo = new ProcessStartInfo
        {
            FileName = "powershell.exe",
            Arguments = "-NoProfile -ExecutionPolicy Bypass -File " + QuoteArg(tempScriptPath),
            UseShellExecute = false
        };

        foreach (var pair in environmentVariables)
        {
            startInfo.EnvironmentVariables[pair.Key] = pair.Value;
        }

        try
        {
            using (var process = new Process())
            {
                process.StartInfo = startInfo;
                process.Start();
                process.WaitForExit();
                return process.ExitCode;
            }
        }
        finally
        {
            try
            {
                if (File.Exists(tempScriptPath))
                {
                    File.Delete(tempScriptPath);
                }
            }
            catch
            {
            }
        }
    }

    private static void WriteLineColored(string text, ConsoleColor color)
    {
        WriteLineColored(text, MapConsoleColor(color));
    }

    private static void WriteLineColored(string text, string ansiColor)
    {
        if (_ansiEnabled)
        {
            Console.Write("\u001b[");
            Console.Write(ansiColor);
            Console.Write("m");
            Console.Write(text);
            Console.WriteLine("\u001b[0m");
            return;
        }

        Console.WriteLine(text);
    }

    private static string FormatSize(long bytes)
    {
        if (bytes >= 1024L * 1024L * 1024L)
        {
            return (bytes / (1024d * 1024d * 1024d)).ToString("N2", CultureInfo.InvariantCulture) + " GB";
        }

        if (bytes >= 1024L * 1024L)
        {
            return (bytes / (1024d * 1024d)).ToString("N2", CultureInfo.InvariantCulture) + " MB";
        }

        if (bytes >= 1024L)
        {
            return (bytes / 1024d).ToString("N2", CultureInfo.InvariantCulture) + " KB";
        }

        return bytes.ToString(CultureInfo.InvariantCulture) + " B";
    }

    private static string QuoteArg(string value)
    {
        return "\"" + value.Replace("\"", "\\\"") + "\"";
    }

    private static string QuotePowerShellArg(string value)
    {
        return "'" + value.Replace("'", "''") + "'";
    }

    private static string GetCurrentExecutablePath()
    {
        try
        {
            return Process.GetCurrentProcess().MainModule.FileName;
        }
        catch
        {
            return null;
        }
    }

    private static string DecodeBase64(string base64)
    {
        return Encoding.UTF8.GetString(Convert.FromBase64String(base64));
    }

    private static string MapConsoleColor(ConsoleColor color)
    {
        switch (color)
        {
            case ConsoleColor.White:
                return "38;2;230;245;255";
            case ConsoleColor.Cyan:
                return "38;2;180;220;255";
            case ConsoleColor.Blue:
                return "38;2;170;220;255";
            case ConsoleColor.DarkCyan:
                return "38;2;150;205;255";
            case ConsoleColor.Yellow:
                return "38;2;255;210;180";
            case ConsoleColor.DarkYellow:
                return "38;2;255;225;180";
            default:
                return "38;2;225;242;255";
        }
    }

    private static bool EnableVirtualTerminalProcessing()
    {
        const int StdOutputHandle = -11;
        const int EnableVtProcessing = 0x0004;

        IntPtr handle = GetStdHandle(StdOutputHandle);
        if (handle == IntPtr.Zero || handle == new IntPtr(-1))
        {
            return false;
        }

        int mode;
        if (!GetConsoleMode(handle, out mode))
        {
            return false;
        }

        if ((mode & EnableVtProcessing) != 0)
        {
            return true;
        }

        return SetConsoleMode(handle, mode | EnableVtProcessing);
    }

    [DllImport("kernel32.dll")]
    private static extern IntPtr GetStdHandle(int nStdHandle);

    [DllImport("kernel32.dll")]
    private static extern bool GetConsoleMode(IntPtr hConsoleHandle, out int lpMode);

    [DllImport("kernel32.dll")]
    private static extern bool SetConsoleMode(IntPtr hConsoleHandle, int dwMode);
}
