# SYNOPSIS BNT MemMan Toolkit – BRAIN NXTGEN TECHNOLOGIES (BNT)

<#
.SYNOPSIS
Generate a structured snapshot of current memory usage on Windows.

DESCRIPTION
BNT-Get-MemoryReport.ps1 produces a formatted memory diagnostic report, including:

- Total, used, and free physical memory.
- Selected memory performance counters (for example standby caches, modified page list).
- Top N processes by working set and private memory.
- Optional CSV export for further analysis or historical tracking.

The script is read-only and intended to be used:

- Before and after running BNT-Clear-StandbyMemory.ps1.
- During troubleshooting of workstation sluggishness.
- As part of consulting assessments and “MY SYSTEM CONFIG” style reports.

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
Initial diagnostic report script for BNT MemMan Toolkit:
- Collects system memory overview and key performance counters.
- Lists top processes by working set, with optional CSV export.

PARAMETER Top
Number of top memory-consuming processes to display.
Default: 15

PARAMETER ExportCsv
Optional CSV export path for process memory data.

INPUTS
None. This script does not accept pipeline input.

OUTPUTS
Text-based report to console and optional CSV file for process details.

EXAMPLE
pwsh .\BNT-Get-MemoryReport.ps1

Display a formatted memory report to the console.

EXAMPLE
pwsh .\BNT-Get-MemoryReport.ps1 -Top 20 -ExportCsv "C:\Logs\bnt-memman-report.csv"

Show the top 20 processes and export their memory usage to CSV.

NOTES
Requirements
- PowerShell 7+ recommended.
- Windows 10 or Windows 11.

Design principles
- Non-destructive, read-only diagnostics.
- Structured output suitable for script-based collection or copy/paste into reports.
- Optional CSV export for further processing in Excel or data analysis tools.
#>

[CmdletBinding()]
param(
    [int]$Top = 15,
    [string]$ExportCsv
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Simple progress control for a professional feel
$script:TotalSteps = 3
$script:CurrentStep = 0

function Set-BntReportProgress {
    param(
        [string]$Status
    )

    $script:CurrentStep++
    $percent = [math]::Round(($script:CurrentStep / $script:TotalSteps) * 100, 0)
    Write-Progress -Activity "Collecting memory diagnostics" -Status $Status -PercentComplete $percent
}

#region System memory overview

Set-BntReportProgress -Status "Gathering system memory overview..."

$os = Get-CimInstance -ClassName Win32_OperatingSystem

$totalGB = [math]::Round($os.TotalVisibleMemorySize / 1MB, 2)
$freeGB  = [math]::Round($os.FreePhysicalMemory / 1MB, 2)
$usedGB  = [math]::Round($totalGB - $freeGB, 2)
$usedPct = if ($totalGB -gt 0) {
    [math]::Round(($usedGB / $totalGB) * 100, 1)
} else {
    0
}

#endregion System memory overview

#region Performance counters

Set-BntReportProgress -Status "Collecting memory performance counters..."

$countersToRead = @(
    "\Memory\Available MBytes",
    "\Memory\Committed Bytes",
    "\Memory\Cache Bytes",
    "\Memory\Pool Nonpaged Bytes",
    "\Memory\Pool Paged Bytes",
    "\Memory\Modified Page List Bytes",
    "\Memory\Standby Cache Normal Priority Bytes",
    "\Memory\Standby Cache Reserve Bytes",
    "\Memory\Standby Cache Core Bytes"
)

$counterSamples = @()

try {
    $counterResult = Get-Counter -Counter $countersToRead -ErrorAction Stop
    $counterSamples = $counterResult.CounterSamples
}
catch {
    Write-Warning "Could not read memory performance counters: $_"
}

#endregion Performance counters

#region Top processes

Set-BntReportProgress -Status "Enumerating top processes..."

$procs = Get-Process |
    Sort-Object WorkingSet64 -Descending |
    Select-Object -First $Top |
    ForEach-Object {
        [PSCustomObject]@{
            Name        = $_.ProcessName
            PID         = $_.Id
            "WS_MB"     = [math]::Round($_.WorkingSet64 / 1MB, 1)
            "PM_MB"     = [math]::Round($_.PrivateMemorySize64 / 1MB, 1)
            Handles     = $_.HandleCount
            StartTime   = $(try { $_.StartTime } catch { $null })
        }
    }

# Clear progress
Write-Progress -Activity "Collecting memory diagnostics" -Status "Completed" -PercentComplete 100

#endregion Top processes

#region Render report

$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "  ║           BNT MemMan Toolkit – Report           ║" -ForegroundColor Cyan
Write-Host "  ║           $timestamp             ║" -ForegroundColor Cyan
Write-Host "  ╚══════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

Write-Host "  System Overview" -ForegroundColor White
Write-Host "  ────────────────────────────────────" -ForegroundColor DarkGray
Write-Host ("  Total RAM      : {0} GB" -f $totalGB) -ForegroundColor DarkGray
Write-Host ("  Used           : {0} GB ({1}%)" -f $usedGB, $usedPct) -ForegroundColor `
    (if ($usedPct -gt 85) { "Red" } elseif ($usedPct -gt 70) { "Yellow" } else { "Green" })
Write-Host ("  Free           : {0} GB" -f $freeGB) -ForegroundColor DarkGray

if ($counterSamples.Count -gt 0) {
    Write-Host ""
    Write-Host "  Performance Counters" -ForegroundColor White
    Write-Host "  ────────────────────────────────────" -ForegroundColor DarkGray

    foreach ($sample in $counterSamples) {
        $nameParts = $sample.Path -split "\\"
        $name      = $nameParts[-1]

        if ($name -eq "Available MBytes") {
            $val = [math]::Round($sample.CookedValue, 0)
            $unit = "MB"
        }
        else {
            $val = [math]::Round($sample.CookedValue / 1MB, 1)
            $unit = "MB"
        }

        $line = ("  {0,-40} : {1,8} {2}" -f $name, $val, $unit)
        Write-Host $line -ForegroundColor DarkGray
    }
}

Write-Host ""
Write-Host ("  Top {0} Processes by Memory (Working Set)" -f $Top) -ForegroundColor White
Write-Host "  ────────────────────────────────────" -ForegroundColor DarkGray
Write-Host ""

$procs | Format-Table -AutoSize | Out-String | Write-Host

#endregion Render report

#region Optional CSV export

if ($ExportCsv) {
    try {
        $exportDir = Split-Path -Path $ExportCsv -Parent
        if (-not (Test-Path -Path $exportDir)) {
            New-Item -ItemType Directory -Path $exportDir -Force | Out-Null
        }

        $procs |
            Select-Object Name, PID, WS_MB, PM_MB, Handles, StartTime |
            Export-Csv -Path $ExportCsv -NoTypeInformation -Encoding UTF8

        Write-Host ""
        Write-Host ("  Process data exported to: {0}" -f $ExportCsv) -ForegroundColor Green
    }
    catch {
        Write-Warning "  CSV export failed: $_"
    }
}

#endregion Optional CSV export
