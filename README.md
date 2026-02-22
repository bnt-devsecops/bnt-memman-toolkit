# BNT MemMan Toolkit – Windows RAM & Standby List Optimizer

BNT MemMan Toolkit is a lightweight, PowerShell-native collection of scripts and
configs that reclaim RAM in real time on Windows 11 workstations without
restarts or layout disruption.

Optimized for:
- Multi-monitor Surface-class laptops and desktops
- Multi-cloud IaC (Terraform/Bicep), VSCode, PowerShell
- Multi-profile Chrome, Teams, Outlook, Office

## Features

- On-demand standby list clear with before/after metrics and logging
- Scheduled standby list hygiene (SYSTEM scheduled task)
- Integration with RAMMap and Intelligent Standby List Cleaner (ISLC)
- Startup and background-app hardening to drop baseline RAM usage
- One-command setup for new workstations

## Components

- `BNT-Clear-StandbyMemory.ps1` – One-click or hotkey standby list clear
- `BNT-Setup-MemoryManagement.ps1` – Download tools, create shortcuts & tasks
- `BNT-Optimize-StartupAndBackground.ps1` – Disable non-essential startup/background apps
- `BNT-Get-MemoryReport.ps1` – Memory diagnostic report and CSV export

## Licensing & Support

BNT MemMan Toolkit is available under a commercial-friendly license suitable for:

- Subscription access with updates and priority support
- Perpetual consulting licenses for client environments
- Donation-based licenses (PayPal, Stripe, etc.)

See **LICENSE** and visit [https://brainng.one](https://brainng.one/licenses/) for details.
