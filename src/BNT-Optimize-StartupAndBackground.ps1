# SYNOPSIS BNT MemMan Toolkit – BRAIN NXTGEN TECHNOLOGIES (BNT)

<#
.SYNOPSIS
Audit and optimize Windows startup and background app behavior to reduce baseline RAM usage.

DESCRIPTION
BNT-Optimize-StartupAndBackground.ps1 reviews registry-based startup items and selected UWP
background apps. It preserves security and core system components while identifying and
optionally disabling non-essential entries that inflate baseline memory and standby usage.

The script:
- Enumerates startup entries from standard Run locations (HKCU and HKLM).
- Classifies entries into “KEEP” and “DISABLE” based on a curated allowlist.
- Optionally removes non-essential startup entries (with -Force).
- Enumerates select UWP apps and disables their background access via registry settings.
- Supports -WhatIf / -Confirm semantics where meaningful.

Use this on single-operator workstations, lab systems, or as part of consulting engagements
to establish a lean baseline before applying active standby management.

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
Initial optimization script for startup and background apps aligned with BNT MemMan Toolkit:
- Audits startup entries and suggests safe removals.
- Disables background access for selected UWP apps that commonly consume resources.

PARAMETER Force
Apply changes without individual confirmation prompts.

INPUTS
None. This script does not accept pipeline input.

OUTPUTS
Human-readable text describing which startup entries and background apps are kept or disabled.

EXAMPLE
pwsh .\BNT-Optimize-StartupAndBackground.ps1 -WhatIf

Review recommended changes without applying them.

EXAMPLE
pwsh .\BNT-Optimize-StartupAndBackground.ps1 -Force

Apply all recommended changes without prompting, suitable after careful review.

NOTES
Requirements
- PowerShell 7+ recommended.
- Windows 10 or Windows 11.
- Local admin rights recommended for writing to HKLM and background access keys.

Design principles
- Support -WhatIf/-Confirm where meaningful via SupportsShouldProcess.
- Conservative allowlist of critical components (security, drivers, core services).
- Reversible: startup entries can be re-enabled via Task Manager or Settings GUI.

Operational notes
- Always run with -WhatIf the first time to validate impact.
- On corporate-managed devices with GPO, some keys may be read-only.
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

#region Configuration

# Apps to keep enabled at startup (case-insensitive partial matches)
$startupKeepList = @(
    "SecurityHealth",
    "WindowsDefender",
    "Defender",
    "PowerShell",
    "pwsh",
    "OneDrive",
    "Realtek",
    "Intel",
    "NVIDIA",
    "Synaptics",
    "Touchpad",
    "Audio",
    "Bluetooth"
)

# UWP packages for which to disable background access
$backgroundDisableList = @(
    "Microsoft.MicrosoftTeams*",
    "Microsoft.Office.Outlook*",
    "Microsoft.WindowsStore*",
    "Microsoft.YourPhone*",
    "Microsoft.People*",
    "Microsoft.WindowsMaps*",
    "Microsoft.GetHelp*",
    "Microsoft.Getstarted*",
    "Microsoft.WindowsFeedbackHub*",
    "Microsoft.MicrosoftStickyNotes*",
    "Microsoft.WindowsAlarms*",
    "Microsoft.BingWeather*",
    "Microsoft.BingNews*",
    "Microsoft.Todos*",
    "Clipchamp*",
    "Microsoft.549981C3F5F10*"   # Xbox app
)

$startupPaths = @(
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run",
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run"
)

#endregion Configuration

Write-Host ""
Write-Host "=== BNT MemMan Toolkit – Startup and Background Optimization ===" -ForegroundColor Cyan
Write-Host ""

#region Startup items audit and optimization

Write-Host "=== Startup Items Audit ===" -ForegroundColor Cyan
Write-Host ""

foreach ($regPath in $startupPaths) {
    Write-Host "Registry path: $regPath" -ForegroundColor White

    if (-not (Test-Path -Path $regPath)) {
        Write-Host "  (No entries found or key does not exist.)" -ForegroundColor DarkGray
        Write-Host ""
        continue
    }

    try {
        $items = Get-ItemProperty -Path $regPath -ErrorAction Stop
    }
    catch {
        Write-Warning "  Could not read $regPath: $_"
        Write-Host ""
        continue
    }

    $props = $items.PSObject.Properties | Where-Object { $_.Name -notmatch '^PS' }

    if (-not $props) {
        Write-Host "  (No startup entries defined here.)" -ForegroundColor DarkGray
        Write-Host ""
        continue
    }

    foreach ($prop in $props) {
        $name  = $prop.Name
        $value = [string]$prop.Value

        $keep = $false
        foreach ($pattern in $startupKeepList) {
            if ($name -match $pattern -or $value -match $pattern) {
                $keep = $true
                break
            }
        }

        if ($keep) {
            Write-Host "  [KEEP]    $name" -ForegroundColor Green
            Write-Host "           $value" -ForegroundColor DarkGray
        }
        else {
            Write-Host "  [DISABLE] $name" -ForegroundColor Yellow
            Write-Host "           $value" -ForegroundColor DarkGray

            if ($Force -or $PSCmdlet.ShouldProcess($name, "Remove startup entry from $regPath")) {
                try {
                    Remove-ItemProperty -Path $regPath -Name $name -Force
                    Write-Host "           Removed from $regPath" -ForegroundColor DarkGray
                }
                catch {
                    Write-Warning "           Failed to remove from $regPath: $_"
                }
            }
        }

        Write-Host ""
    }
}

#endregion Startup items audit and optimization

#region Background app permissions optimization

Write-Host ""
Write-Host "=== Background App Permissions ===" -ForegroundColor Cyan
Write-Host ""

foreach ($pattern in $backgroundDisableList) {
    try {
        $packages = Get-AppxPackage -Name $pattern -ErrorAction SilentlyContinue
        if (-not $packages) {
            continue
        }

        foreach ($pkg in $packages) {
            Write-Host "  [DISABLE BG] $($pkg.Name)" -ForegroundColor Yellow

            $regKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\$($pkg.PackageFamilyName)"

            if ($Force -or $PSCmdlet.ShouldProcess($pkg.Name, "Disable background access")) {
                try {
                    if (-not (Test-Path -Path $regKey)) {
                        New-Item -Path $regKey -Force | Out-Null
                    }

                    Set-ItemProperty -Path $regKey -Name "Disabled"       -Value 1 -Type DWord -Force
                    Set-ItemProperty -Path $regKey -Name "DisabledByUser" -Value 1 -Type DWord -Force

                    Write-Host "           Background access disabled via: $regKey" -ForegroundColor DarkGray
                }
                catch {
                    Write-Warning "           Failed to disable background access for $($pkg.Name): $_"
                }
            }

            Write-Host ""
        }
    }
    catch {
        # If we fail to query for a pattern, skip silently.
        continue
    }
}

#endregion Background app permissions optimization

#region Recommendations

Write-Host ""
Write-Host "=== Recommendations ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "  1. Open Task Manager > Startup tab to review which entries are now enabled or disabled." -ForegroundColor DarkGray
Write-Host "  2. Open Settings > Apps > Startup for an additional GUI-based review and fine tuning." -ForegroundColor DarkGray
Write-Host "  3. Open Settings > System > Power & battery > Energy recommendations to apply OS-level suggestions." -ForegroundColor DarkGray
Write-Host "  4. If needed, re-enable an entry that was removed by re-adding it via Task Manager or app settings." -ForegroundColor DarkGray
Write-Host ""

#endregion Recommendations
