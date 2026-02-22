# SYNOPSIS BNT MemMan Toolkit – BRAIN NXTGEN TECHNOLOGIES (BNT)

<#
.SYNOPSIS
Automate installation and configuration of the BNT MemMan Toolkit on Windows 10/11.

DESCRIPTION
BNT-Setup-MemMan.ps1 prepares a Windows 10/11 workstation for the BNT MemMan Toolkit –
Windows RAM & Standby List Optimizer.

The script:
- Verifies administrator privileges.
- Creates a standardized tools directory for memory utilities.
- Downloads and installs EmptyStandbyList.exe to C:\Windows\System32.
- Downloads and extracts Sysinternals RAMMap to a tools folder.
- Prepares a folder for Intelligent Standby List Cleaner (ISLC) and prints configuration guidance.
- Copies BNT-Clear-StandbyMemory.ps1 into a user scripts folder.
- Creates a desktop shortcut “Clear Standby Memory”.
- Registers a scheduled task (ClearStandbyMemory) that periodically clears the standby list.

Intended for single-operator workstations and consulting use where fast, repeatable setup is required.

AUTHOR
Brian Williams
Founder & Enterprise AI 🤖, Cybersecurity 🛡️, and Robotics Architect, Advisor & Digital Transformation Leader 👔
BRAIN NXTGEN TECHNOLOGIES (BNT)
Website: https://brainng.one
Location: St. Petersburg, FL, USA
Languages (Fluent): DE, EN
Focus: Applied AI, Machine Learning, Robotics, Cybersecurity, Ethical AI, and Secure Digital Systems consulting for enterprises, governments, and research-driven organizations
Core Domains: Applied AI and Machine Learning, Robotics and Intelligent Systems, Cybersecurity, Zero Trust Architectures, Secure Automation, Responsible-Ethics-driven AI and Governance
Selected Capabilities: AI and Robotics Strategy and Roadmapping, ML and GenAI Workflow Design and Optimization, Secure Cloud and Multi-Cloud Architectures, AI Risk, Safety, and Bias Mitigation Frameworks, Sustainability-aware AI and Data Center Optimization

COMPANYNAME
BRAIN NXTGEN TECHNOLOGIES (BNT)

COPYRIGHT
© 2026 BRAIN NXTGEN TECHNOLOGIES (BNT). All rights reserved under licensing agreements found here: https://brainng.one/licenses

VERSION
1.0.1

RELEASENOTES
- Added a high-level progress bar to indicate progress across the main setup steps.
- No behavior changes to installation logic.

PARAMETER ToolsRoot
Root folder for downloaded tools.
Default: C:\Tools\MemoryManagement

PARAMETER ScriptsRoot
Root folder for PowerShell scripts.
Default: $env:USERPROFILE\Scripts

PARAMETER ScheduleIntervalMinutes
Interval in minutes for the scheduled-task standby-list clear.
Default: 30

PARAMETER SkipISLC
If present, skip ISLC folder guidance and manual configuration output.

INPUTS
None. This script does not accept pipeline input.

OUTPUTS
Status messages describing setup progress, created folders, and final configuration.

EXAMPLE
pwsh .\BNT-Setup-MemMan.ps1

Runs the default setup, installing tools under C:\Tools\MemoryManagement, creating scripts under
$env:USERPROFILE\Scripts, and scheduling a standby clear every 30 minutes.

EXAMPLE
pwsh .\BNT-Setup-MemMan.ps1 -ScheduleIntervalMinutes 15

Same as above, but registers the scheduled task to run every 15 minutes.

NOTES
Requirements
- PowerShell 7+ recommended.
- Windows 10 or Windows 11.
- Administrator privileges.
- Internet access for downloading dependencies.

Design principles
- Idempotent where practical.
- Explicit error handling and clear status messages.
- Minimal assumptions beyond standard Windows workstation environments.
#>

[CmdletBinding()]
param(
    [string]$ToolsRoot               = "C:\Tools\MemoryManagement",
    [string]$ScriptsRoot             = "$env:USERPROFILE\Scripts",
    [int]   $ScheduleIntervalMinutes = 30,
    [switch]$SkipISLC
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Progress metadata
$script:TotalSteps = 7
$script:CurrentStep = 0

function Set-BntProgress {
    param(
        [string]$Activity,
        [string]$Status
    )

    $script:CurrentStep++
    $percent = [math]::Round(($script:CurrentStep / $script:TotalSteps) * 100, 0)

    Write-Progress -Activity $Activity -Status $Status -PercentComplete $percent
}

#region Helper functions

function Assert-BntAdmin {
    $identity  = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        throw "This script must run as Administrator. Please re-launch PowerShell as Administrator and re-run BNT-Setup-MemMan.ps1."
    }
}

function Get-BntFileWithRetry {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][string]$Uri,
        [Parameter(Mandatory = $true)][string]$OutFile,
        [int]$MaxRetries = 3
    )

    for ($i = 1; $i -le $MaxRetries; $i++) {
        try {
            Write-Host "  Downloading: $Uri (attempt $i/$MaxRetries)" -ForegroundColor DarkGray
            Invoke-WebRequest -Uri $Uri -OutFile $OutFile -UseBasicParsing -ErrorAction Stop
            Write-Host "  Saved to: $OutFile" -ForegroundColor Green
            return
        }
        catch {
            Write-Warning "  Attempt $i failed: $_"
            if ($i -eq $MaxRetries) {
                throw "Download failed after $MaxRetries attempts: $Uri"
            }
            Start-Sleep -Seconds 2
        }
    }
}

#endregion Helper functions

#region Admin check

Set-BntProgress -Activity "BNT MemMan Toolkit setup" -Status "Validating administrator privileges..."
Assert-BntAdmin

#endregion Admin check

#region Create directory structure

Set-BntProgress -Activity "BNT MemMan Toolkit setup" -Status "Creating folders for tools and scripts..."

Write-Host ""
Write-Host "[1/7] Creating directories..." -ForegroundColor Cyan

$dirs = @(
    $ToolsRoot,
    Join-Path $ToolsRoot "ISLC",
    Join-Path $ToolsRoot "RAMMap",
    $ScriptsRoot
)

foreach ($d in $dirs) {
    if (-not (Test-Path -Path $d)) {
        New-Item -ItemType Directory -Path $d -Force | Out-Null
        Write-Host "  Created: $d" -ForegroundColor Green
    }
    else {
        Write-Host "  Exists : $d" -ForegroundColor Yellow
    }
}

#endregion Create directory structure

#region Download EmptyStandbyList.exe

Set-BntProgress -Activity "BNT MemMan Toolkit setup" -Status "Downloading and installing EmptyStandbyList.exe..."

Write-Host ""
Write-Host "[2/7] Setting up EmptyStandbyList.exe..." -ForegroundColor Cyan

$eslSource = "https://github.com/stefanpejcic/EmptyStandbyList/raw/master/EmptyStandbyList.exe"
$eslTarget = "C:\Windows\System32\EmptyStandbyList.exe"

if (-not (Test-Path -Path $eslTarget)) {
    Get-BntFileWithRetry -Uri $eslSource -OutFile $eslTarget
}
else {
    Write-Host "  Already exists: $eslTarget" -ForegroundColor Yellow
}

#endregion Download EmptyStandbyList.exe

#region Download RAMMap

Set-BntProgress -Activity "BNT MemMan Toolkit setup" -Status "Downloading and extracting RAMMap..."

Write-Host ""
Write-Host "[3/7] Setting up Sysinternals RAMMap..." -ForegroundColor Cyan

$ramMapFolder = Join-Path $ToolsRoot "RAMMap"
$ramMapExe    = Join-Path $ramMapFolder "RAMMap.exe"
$ramMapZip    = Join-Path $ramMapFolder "RAMMap.zip"
$ramMapUrl    = "https://download.sysinternals.com/files/RAMMap.zip"

if (-not (Test-Path -Path $ramMapExe)) {
    Get-BntFileWithRetry -Uri $ramMapUrl -OutFile $ramMapZip
    Expand-Archive -Path $ramMapZip -DestinationPath $ramMapFolder -Force
    Remove-Item -Path $ramMapZip -Force -ErrorAction SilentlyContinue
    Write-Host "  Extracted RAMMap to: $ramMapFolder" -ForegroundColor Green
}
else {
    Write-Host "  Already exists: $ramMapExe" -ForegroundColor Yellow
}

#endregion Download RAMMap

#region ISLC guidance

Set-BntProgress -Activity "BNT MemMan Toolkit setup" -Status "Preparing ISLC folder and configuration guidance..."

Write-Host ""
Write-Host "[4/7] ISLC folder and configuration guidance..." -ForegroundColor Cyan

$islcFolder = Join-Path $ToolsRoot "ISLC"

if (-not $SkipISLC) {
    Write-Host "  ISLC must be downloaded manually due to distribution model." -ForegroundColor Yellow
    Write-Host "  Recommended steps:" -ForegroundColor White
    Write-Host "    1. Download Intelligent Standby List Cleaner (ISLC) from WagnardSoft:" -ForegroundColor DarkGray
    Write-Host "       https://www.wagnardsoft.com/content/Download-Intelligent-standby-list-cleaner-ISLC-1037" -ForegroundColor DarkGray
    Write-Host "    2. Extract the contents into: $islcFolder" -ForegroundColor DarkGray
    Write-Host "    3. Run ISLC as Administrator and configure for a 16 GB workstation:" -ForegroundColor DarkGray
    Write-Host "         - Free memory threshold      : 2048 MB" -ForegroundColor DarkGray
    Write-Host "         - Standby list size threshold: 3000 MB" -ForegroundColor DarkGray
    Write-Host "         - Enable at Windows startup  : Enabled" -ForegroundColor DarkGray
}
else {
    Write-Host "  ISLC guidance intentionally skipped (SkipISLC specified)." -ForegroundColor Yellow
}

#endregion ISLC guidance

#region Deploy BNT-Clear-StandbyMemory.ps1

Set-BntProgress -Activity "BNT MemMan Toolkit setup" -Status "Deploying BNT-Clear-StandbyMemory.ps1..."

Write-Host ""
Write-Host "[5/7] Deploying BNT-Clear-StandbyMemory.ps1..." -ForegroundColor Cyan

$sourceScript = Join-Path $PSScriptRoot "BNT-Clear-StandbyMemory.ps1"
$clearScript  = Join-Path $ScriptsRoot  "BNT-Clear-StandbyMemory.ps1"

if (Test-Path -Path $sourceScript) {
    Copy-Item -Path $sourceScript -Destination $clearScript -Force
    Write-Host "  Deployed to: $clearScript" -ForegroundColor Green
}
else {
    Write-Host "  WARNING: Source script not found at: $sourceScript" -ForegroundColor Red
    Write-Host "  Ensure BNT-Clear-StandbyMemory.ps1 is present in the same folder as BNT-Setup-MemMan.ps1 and re-run." -ForegroundColor Yellow
}

#endregion Deploy BNT-Clear-StandbyMemory.ps1

#region Create desktop shortcut

Set-BntProgress -Activity "BNT MemMan Toolkit setup" -Status "Creating desktop shortcut..."

Write-Host ""
Write-Host "[6/7] Creating desktop shortcut..." -ForegroundColor Cyan

try {
    $desktopPath  = [Environment]::GetFolderPath("Desktop")
    $shortcutPath = Join-Path $desktopPath "Clear Standby Memory.lnk"

    $wshShell = New-Object -ComObject WScript.Shell
    $shortcut = $wshShell.CreateShortcut($shortcutPath)

    $shortcut.TargetPath       = "powershell.exe"
    $shortcut.Arguments        = "-NoProfile -ExecutionPolicy Bypass -File `"$clearScript`""
    $shortcut.WorkingDirectory = $ScriptsRoot
    $shortcut.WindowStyle      = 1
    $shortcut.Description      = "BNT MemMan Toolkit – Clear Windows Standby List to reclaim RAM."
    $shortcut.IconLocation     = "shell32.dll,145"
    $shortcut.Save()

    Write-Host "  Shortcut created: $shortcutPath" -ForegroundColor Green
    Write-Host "  IMPORTANT: Right-click the shortcut > Properties > Advanced > enable 'Run as administrator'." -ForegroundColor Yellow
}
catch {
    Write-Warning "  Could not create desktop shortcut: $_"
}

#endregion Create desktop shortcut

#region Create scheduled task

Set-BntProgress -Activity "BNT MemMan Toolkit setup" -Status "Creating scheduled task for periodic standby clears..."

Write-Host ""
Write-Host "[7/7] Creating scheduled task..." -ForegroundColor Cyan

$taskName = "ClearStandbyMemory"

try {
    $existingTask = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
    if ($existingTask) {
        Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
        Write-Host "  Removed existing task: $taskName" -ForegroundColor Yellow
    }

    $action = New-ScheduledTaskAction `
        -Execute "powershell.exe" `
        -Argument "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$clearScript`" -Type standbylist -Silent"

    $trigger = New-ScheduledTaskTrigger `
        -Once `
        -At (Get-Date) `
        -RepetitionInterval (New-TimeSpan -Minutes $ScheduleIntervalMinutes) `
        -RepetitionDuration ([TimeSpan]::MaxValue)

    $principal = New-ScheduledTaskPrincipal `
        -UserId "SYSTEM" `
        -LogonType ServiceAccount `
        -RunLevel Highest

    $settings = New-ScheduledTaskSettingsSet `
        -AllowStartIfOnBatteries `
        -DontStopIfGoingOnBatteries `
        -StartWhenAvailable `
        -ExecutionTimeLimit (New-TimeSpan -Minutes 5)

    Register-ScheduledTask `
        -TaskName $taskName `
        -Action $action `
        -Trigger $trigger `
        -Principal $principal `
        -Settings $settings `
        -Description "BNT MemMan Toolkit – Automatically clear Windows Standby List every $ScheduleIntervalMinutes minutes to reclaim RAM." `
        -Force | Out-Null

    Write-Host "  Scheduled task '$taskName' created (every $ScheduleIntervalMinutes minutes, runs as SYSTEM)." -ForegroundColor Green
}
catch {
    Write-Warning "  Could not create scheduled task: $_"
    Write-Host "  You can manually configure a task in Task Scheduler to run BNT-Clear-StandbyMemory.ps1 on your preferred schedule." -ForegroundColor Yellow
}

#endregion Create scheduled task

# Clear final progress
Write-Progress -Activity "BNT MemMan Toolkit setup" -Status "Completed" -PercentComplete 100

#region Summary

Write-Host ""
Write-Host "══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  BNT MemMan Toolkit – Setup Complete" -ForegroundColor Green
Write-Host "══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Tools installed:" -ForegroundColor White
Write-Host "    EmptyStandbyList.exe : $eslTarget" -ForegroundColor DarkGray
Write-Host "    RAMMap               : $ramMapFolder" -ForegroundColor DarkGray
Write-Host "    ISLC folder          : $islcFolder (manual download/config required)" -ForegroundColor DarkGray
Write-Host ""
Write-Host "  Scripts deployed:" -ForegroundColor White
Write-Host "    BNT-Clear-StandbyMemory.ps1 : $clearScript" -ForegroundColor DarkGray
Write-Host ""
Write-Host "  Automation:" -ForegroundColor White
Write-Host "    Desktop shortcut     : Clear Standby Memory.lnk" -ForegroundColor DarkGray
Write-Host "    Scheduled task       : $taskName (every $ScheduleIntervalMinutes minutes)" -ForegroundColor DarkGray
Write-Host ""
Write-Host "  Next steps:" -ForegroundColor White
Write-Host "    1. Download and extract ISLC to: $islcFolder" -ForegroundColor DarkGray
Write-Host "    2. Configure ISLC thresholds (2048 MB free / 3000 MB standby) and enable at startup." -ForegroundColor DarkGray
Write-Host "    3. Right-click the desktop shortcut > Properties > Advanced > enable 'Run as administrator'." -ForegroundColor DarkGray
Write-Host "    4. Test a manual clear: pwsh $clearScript -Type standbylist" -ForegroundColor DarkGray
Write-Host ""

#endregion Summary
