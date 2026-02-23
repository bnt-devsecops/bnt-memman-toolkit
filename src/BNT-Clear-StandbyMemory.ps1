# SYNOPSIS BNT MemMan Toolkit – BRAIN NXTGEN TECHNOLOGIES (BNT)

<#
.SYNOPSIS
Clear Windows Standby List memory on demand for responsive Windows 10/11 workstations.

DESCRIPTION
Invokes EmptyStandbyList.exe to purge the Standby List, Working Sets, Modified Page List,
or Priority-0 Standby List on demand. Designed for workstation-class Windows 10/11 setups
running multi-cloud IaC tooling, VSCode, PowerShell, multi-profile Chrome, Teams, and Office
across multiple tenants.

The script:
- Verifies administrator privileges and relaunches elevated if needed.
- Verifies that EmptyStandbyList.exe is available in PATH.
- Captures memory metrics before and after the clear operation.
- Logs each run to an append-only log file with timestamps and reclaimed memory.
- Supports silent mode for scheduled tasks and hotkeys.

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
1.0.0

RELEASENOTES
Initial release of BNT-Clear-StandbyMemory.ps1 as part of BNT MemMan Toolkit – Windows RAM & Standby List Optimizer.

PARAMETER Type
Specifies the memory region to clear.
Valid values:
- standbylist          – Clears the full Standby List (priorities 0 to 7).
- workingsets          – Trims all process working sets.
- modifiedpagelist     – Flushes the Modified Page List to disk.
- priority0standbylist – Clears only priority 0 standby pages.

PARAMETER LogPath
Optional path for an append-only log file.
Defaults to: $env:USERPROFILE\Documents\StandbyMemory-Clear.log

PARAMETER Silent
If present, suppresses console output.
Useful for scheduled tasks and global hotkey integrations.

INPUTS
None. This script does not accept pipeline input.

OUTPUTS
System.String and structured text messages describing the operation result.
Log entries are written to the specified log file path.

EXAMPLE
pwsh .\BNT-Clear-StandbyMemory.ps1 -Type standbylist

Clears the full Standby List and prints before and after memory metrics.

EXAMPLE
pwsh .\BNT-Clear-StandbyMemory.ps1 -Type priority0standbylist -Silent

Clears only priority 0 standby pages silently, suitable for scheduled or hotkey use.

NOTES
Requirements
- PowerShell 7+ recommended.
- Windows 10 or Windows 11.
- Administrator privileges for memory operations.
- EmptyStandbyList.exe available in PATH (recommended: C:\Windows\System32).

Design principles
- Single-file implementation with clear separation between parameter handling, validation, metrics, and execution.
- Strict mode enabled.
- Explicit error handling and defensive checks for external dependencies.
- Append-only logging suitable for later aggregation or forensic review.
- No secrets or credentials are handled in this script.

Operational notes
- The operation is non-destructive with respect to files and user data; it affects memory state only.
- Working set trimming may briefly reduce responsiveness while the OS reloads pages on demand.
- Always test in a non-critical environment before broad deployment.
#>

[CmdletBinding()]
param(
    [ValidateSet("standbylist", "workingsets", "modifiedpagelist", "priority0standbylist")]
    [string]$Type = "standbylist",

    [string]$LogPath = "$env:USERPROFILE\Documents\StandbyMemory-Clear.log",

    [switch]$Silent
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

#region Helper functions

function Test-BntIsAdmin {
    try {
        $identity  = [Security.Principal.WindowsIdentity]::GetCurrent()
        $principal = New-Object Security.Principal.WindowsPrincipal($identity)
        return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    }
    catch {
        return $false
    }
}

function Get-BntMemoryMetrics {
    try {
        $os = Get-CimInstance -ClassName Win32_OperatingSystem
        $freeMB      = [math]::Round($os.FreePhysicalMemory / 1024, 0)
        $totalMB     = [math]::Round($os.TotalVisibleMemorySize / 1024, 0)
        $usedMB      = $totalMB - $freeMB
        $usedPercent = if ($totalMB -gt 0) {
            [math]::Round(($usedMB / $totalMB) * 100, 1)
        } else {
            0
        }

        return [PSCustomObject]@{
            TotalMB     = $totalMB
            UsedMB      = $usedMB
            FreeMB      = $freeMB
            UsedPercent = $usedPercent
        }
    }
    catch {
        Write-Warning "Could not retrieve memory metrics: $_"
        return $null
    }
}

function Write-BntLogEntry {
    param(
        [string]$Path,
        [string]$Entry
    )
    try {
        $logDir = Split-Path -Path $Path -Parent
        if (-not (Test-Path -Path $logDir)) {
            New-Item -ItemType Directory -Path $logDir -Force | Out-Null
        }
        Add-Content -Path $Path -Value $Entry -Encoding UTF8
    }
    catch {
        Write-Warning "Could not write to log file '$Path': $_"
    }
}

#endregion Helper functions

#region Elevation guard

if (-not (Test-BntIsAdmin)) {
    if (-not $Silent) {
        Write-Warning "This script requires Administrator privileges. Attempting to relaunch elevated..."
    }

    try {
        $argsList = @(
            "-NoProfile",
            "-ExecutionPolicy", "Bypass",
            "-File", "`"$PSCommandPath`"",
            "-Type", $Type
        )

        if ($LogPath) {
            $argsList += @("-LogPath", "`"$LogPath`"")
        }
        if ($Silent) {
            $argsList += "-Silent"
        }

        Start-Process -FilePath "powershell.exe" -ArgumentList $argsList -Verb RunAs | Out-Null
    }
    catch {
        Write-Error "Failed to elevate PowerShell session: $_"
    }

    return
}

#endregion Elevation guard

#region Validate dependency

$exeName = "EmptyStandbyList.exe"
$exePath = Get-Command -Name $exeName -ErrorAction SilentlyContinue

if (-not $exePath) {
    $msg = @"
Required dependency not found: $exeName

Expected:
- $exeName should be available in PATH, for example: C:\Windows\System32\EmptyStandbyList.exe

Resolution:
- Download EmptyStandbyList.exe from the official or trusted source.
- Place it into C:\Windows\System32 or another folder that is part of the system PATH.
"@
    Write-Error $msg
    return
}

#endregion Validate dependency

#region Capture metrics before operation

$beforeMetrics = Get-BntMemoryMetrics

#endregion Capture metrics before operation

#region Execute clear operation

$elapsedMs = 0
$success   = $false

try {
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

    Start-Process -FilePath $exePath.Source `
                  -ArgumentList $Type `
                  -Wait `
                  -NoNewWindow

    $stopwatch.Stop()
    $elapsedMs = $stopwatch.ElapsedMilliseconds
    $success   = $true
}
catch {
    Write-Error "EmptyStandbyList.exe execution failed: $_"
    return
}

#endregion Execute clear operation

#region Capture metrics after operation

Start-Sleep -Milliseconds 500
$afterMetrics = Get-BntMemoryMetrics

$reclaimedMB = 0
if ($beforeMetrics -and $afterMetrics) {
    $reclaimedMB = $afterMetrics.FreeMB - $beforeMetrics.FreeMB
}

#endregion Capture metrics after operation

#region Build and write log entry

$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

$beforeFree = if ($beforeMetrics) { $beforeMetrics.FreeMB } else { "<n/a>" }
$afterFree  = if ($afterMetrics)  { $afterMetrics.FreeMB }  else { "<n/a>" }

$logEntry = "$timestamp | Type=$Type | Before=$beforeFree MB free | After=$afterFree MB free | Reclaimed=${reclaimedMB}MB | Elapsed=${elapsedMs}ms | Success=$success"


if ($LogPath) {
    Write-BntLogEntry -Path $LogPath -Entry $logEntry
}

#endregion Build and write log entry

#region Console output

if (-not $Silent) {
    Write-Host ""
    Write-Host "  BNT MemMan Toolkit – Standby Memory Clear" -ForegroundColor Cyan
    Write-Host "  ─────────────────────────────────────────" -ForegroundColor DarkGray
    Write-Host ("  Clear Type   : {0}" -f $Type) -ForegroundColor Cyan

    if ($beforeMetrics) {
        Write-Host ("  Before       : {0} MB free  ({1}% used)" -f $beforeMetrics.FreeMB, $beforeMetrics.UsedPercent) -ForegroundColor Yellow
    }
    else {
        Write-Host "  Before       : <unavailable>" -ForegroundColor Yellow
    }

    if ($afterMetrics) {
        Write-Host ("  After        : {0} MB free  ({1}% used)" -f $afterMetrics.FreeMB, $afterMetrics.UsedPercent) -ForegroundColor Yellow
    }
    else {
        Write-Host "  After        : <unavailable>" -ForegroundColor Yellow
    }

    Write-Host ("  Reclaimed    : {0} MB" -f $reclaimedMB) -ForegroundColor Green
    Write-Host ("  Elapsed      : {0} ms" -f $elapsedMs) -ForegroundColor DarkGray
    Write-Host ("  Log          : {0}" -f $LogPath) -ForegroundColor DarkGray
    Write-Host ""
}


#endregion Console output
