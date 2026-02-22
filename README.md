# BNT MemMan Toolkit – Windows RAM & Standby List Optimizer

BNT MemMan Toolkit is a lightweight, PowerShell-native toolkit that keeps
Windows 11 workstations responsive by reclaiming RAM and standby memory
without reboots or layout disruption.

Optimized for:

- Multi-monitor Surface and laptop workstations
- Multi-cloud IaC workflows (Terraform, Bicep, ARM), VSCode, PowerShell
- Multi-profile Chrome, Teams, and Office across customer tenants

## Features

- One-click or scheduled clearing of the Windows Standby List
- Before/after RAM metrics with append-only logging
- Integration with EmptyStandbyList.exe, RAMMap, and ISLC
- Startup and background-app hardening to reduce baseline RAM usage
- Fast setup for new or rebuilt machines

## Components

- `Clear-StandbyMemory.ps1` – On-demand standby list clear and logging
- `Setup-MemoryManagement.ps1` – Download tools, create shortcuts and scheduled task
- `Optimize-StartupAndBackground.ps1` – Disable non-essential startup/background apps
- `Get-MemoryReport.ps1` – Memory diagnostic snapshot and CSV export

## Quick Start

1. Clone the repo:

   ```powershell
   git clone https://github.com/bnt-devsecops/bnt-memman-toolkit.git
   cd bnt-memman-toolkit\src
