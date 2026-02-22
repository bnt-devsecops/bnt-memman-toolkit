# README BNT MemMan Toolkit – Windows RAM & Standby List Optimizer

```cli
  ____       _              __        ___ _ _ _                       ____  
 | __ ) _ __(_) __ _ _ __   \ \      / (_) | (_) __ _ _ __ ___  ___  / __ \ 
 |  _ \| '__| |/ _` | '_ \   \ \ /\ / /| | | | |/ _` | '_ ` _ \/ __|/ / _` |
 | |_) | |  | | (_| | | | |   \ V  V / | | | | | (_| | | | | | \__ \ | (_| |
 |____/|_|  |_|\\__,_|_| |_|    \_/\_/  |_|_|_|_|\__,_|_| |_| |_|___/ \__,_|
                                                                            
  ___ _  _ _____ 
 | _ ) \| |_   _|
 | _ \ .` | | |  
 |___/_|\_| |_|  
                
```

***

## Authors

<img src="https://i.imgur.com/2Z8o00l.png" alt="BNT-Brian W." width="150" height="150" style="border-radius:50%;">

**Brian Williams** – *(he/him)* – [Founder & Enterprise AI 🤖, Cybersecurity 🛡️, and Robotics Architect, Advisor & Digital Transformation Leader 👔 at **BRAIN NXTGEN TECHNOLOGIES (BNT)**](https://brainng.one/about-us/executive-board)  
**Languages (Fluent)** – *(DE/EN)*  
**Focus** – *(Applied AI, Machine Learning, Robotics, Cybersecurity, Ethical AI, and Secure Digital Systems consulting for enterprises, governments, and research-driven organizations)*  
**Core Domains** – *(Applied AI and Machine Learning, Robotics and Intelligent Systems, Cybersecurity, Zero Trust Architectures, Secure Automation, Responsible-Ethics-driven AI and Governance)*  
**Selected Capabilities** – *(AI and Robotics Strategy and Roadmapping, ML and GenAI Workflow Design and Optimization, Secure Cloud and Multi-Cloud Architectures, AI Risk, Safety, and Bias Mitigation Frameworks, Sustainability-aware AI and Data Center Optimization)*  

See also the list of [Contributors](#contributors) who participated in this project.

***

## Release Notes

We use [SemVer](https://semver.org/) for versioning.

- Version 1.0.0 (2026-02-22)  
  - Initial public release of the BNT MemMan Toolkit – Windows RAM & Standby List Optimizer for Windows 10/11 workstations.

***

## Table of contents

- [BNT MemMan Toolkit – Windows RAM & Standby List Optimizer](#readme-bnt-memman-toolkit--windows-ram--standby-list-optimizer)
  - [Authors](#authors)
  - [Release Notes](#release-notes)
  - [Table of contents](#table-of-contents)
  - [1 Overview](#1-overview)
  - [2 Features and Benefits](#2-features-and-benefits)
  - [3 Components](#3-components)
  - [4 Installation](#4-installation)
  - [5 Usage](#5-usage)
  - [6 Configuration and Tuning](#6-configuration-and-tuning)
  - [7 Roadmap](#7-roadmap)
  - [License](#license)
  - [Acknowledgments](#acknowledgments)
  - [Support](#support)
  - [Contributors](#contributors)
  - [Copyright](#copyright)

***

## 1 Overview

BNT MemMan Toolkit is a workstation-focused Windows 10/11 toolkit that keeps memory usage smooth and predictable for engineers, consultants, and power users.

It is optimized for multi-monitor, multi-app workflows that combine:

- Multi-cloud IaC tooling (for example Terraform, Bicep, ARM) and PowerShell  
- VSCode and long-running terminals  
- Multi-profile Chrome (client tenants), Teams, and Outlook  
- Office apps such as Word, Excel, and PowerPoint  

On such systems, the Windows Standby List often holds several gigabytes of cached pages, which can make the workstation feel sluggish even after closing heavy applications. BNT MemMan Toolkit provides an opinionated, script-driven way to:

- Clear standby memory safely on demand or on a schedule  
- Integrate with community tools such as EmptyStandbyList.exe, RAMMap, and ISLC  
- Reduce baseline memory overhead from startup and background apps  

This project is a **reusable digital product and consulting asset** of BRAIN NXTGEN TECHNOLOGIES (BNT).

[Back to top](#table-of-contents)

***

## 2 Features and Benefits

- **On-demand RAM reclamation**  
  One-click or hotkey-triggerable clear of the Windows Standby List, with before and after metrics.

- **Scheduled hygiene**  
  A Windows Task Scheduler job runs at configurable intervals to keep standby memory in a healthy range without manual intervention.

- **Visual and diagnostic insight**  
  Integration with RAMMap and a PowerShell memory report script helps you understand how RAM is used before and after clears.

- **Startup and background optimization**  
  Audit and optional disablement of non-essential startup entries and UWP background permissions to lower baseline RAM usage.

- **Portable and automation friendly**  
  Scripts are written in PowerShell, single-operator ready, and designed for inclusion in consulting workflows, lab builds, and golden images.

Benefits include smoother context switching across tenants, reduced “restart to feel fast again” cycles, and more predictable memory behavior during long workdays.

[Back to top](#table-of-contents)

***

## 3 Components

### 3.1 Core scripts (src/)

- `src/BNT-Clear-StandbyMemory.ps1`  
  On-demand standby list clear with before/after metrics and logging. Intended for manual use, shortcuts, hotkeys, and scheduled tasks.

- `src/BNT-Setup-MemMan.ps1`  
  One-shot installer and configurator that downloads EmptyStandbyList.exe and RAMMap, prepares an ISLC folder, deploys the clear script, creates a desktop shortcut, and registers a scheduled task.

- `src/BNT-Optimize-StartupAndBackground.ps1`  
  Audits and optionally disables non-essential startup items and selected background apps that inflate baseline RAM usage.

- `src/BNT-Get-MemoryReport.ps1`  
  Generates a structured memory diagnostic snapshot, including system totals, relevant performance counters, and top processes by working set, with optional CSV export.

### 3.2 Documentation (docs/)

- `docs/usage-examples.md`  
  Scenario-based walkthroughs (for example, post-close RAM cleanup, pre-call optimization, and fully automated use).

- `docs/scheduling-and-automation.md`  
  Details about the scheduled task, shortcut configuration, and optional integration with other automation tools such as AutoHotkey.

- `docs/troubleshooting.md`  
  Common issues, root causes, and recommended fixes.

### 3.3 Assets (assets/)

- `assets/logo-bnt-memman.png`  
  Toolkit logo suitable for README, GitHub, and product pages on brainng.one.

- `assets/screenshots/`  
  Example screenshots and diagrams, such as:
  - Task Manager RAM view before and after a clear  
  - RAMMap standby list views  
  - Sample console output from BNT-Get-MemoryReport.ps1  

[Back to top](#table-of-contents)

***

## 4 Installation

### 4.1 Prerequisites

- Windows 10 or Windows 11  
- PowerShell 7+ recommended  
- Local administrator privileges (for setup, scheduled task, and memory operations)  
- Internet access to download third-party utilities  

### 4.2 Clone the repository

```powershell
git clone https://github.com/<your-account>/bnt-memman-toolkit.git
cd bnt-memman-toolkit\src
```

### 4.3 Run the setup script (Administrator)

Open PowerShell **as Administrator** in the `src` folder:

```powershell
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
.\BNT-Setup-MemMan.ps1
```

The setup script will:

- Download `EmptyStandbyList.exe` into `C:\Windows\System32`  
- Download and extract Sysinternals RAMMap into `C:\Tools\MemoryManagement\RAMMap\`  
- Create or confirm script and tools folders  
- Copy `BNT-Clear-StandbyMemory.ps1` into your scripts folder  
- Create a desktop shortcut “Clear Standby Memory”  
- Register the `ClearStandbyMemory` scheduled task that runs as SYSTEM

### 4.4 Configure ISLC (manual step)

Download Intelligent Standby List Cleaner (ISLC) from the official WagnardSoft site and extract to:

```text
C:\Tools\MemoryManagement\ISLC\
```

Run ISLC as Administrator and configure:

- Free memory threshold: `2048 MB`  
- Standby list size threshold: `3000 MB`  
- Enable cleaner  
- Enable “Start with Windows”  

[Back to top](#table-of-contents)

***

## 5 Usage

### 5.1 Manual clear via desktop shortcut

After setup:

- Double-click the **“Clear Standby Memory”** desktop shortcut to run `BNT-Clear-StandbyMemory.ps1` with default settings.  
- Right-click the shortcut, open **Properties > Advanced**, and ensure **“Run as administrator”** is enabled.

Typical workflow:

1. Close heavy apps such as full Chrome profiles, Teams, and large Office documents.  
2. Run the shortcut.  
3. Enjoy reclaimed RAM and a smoother workstation without a reboot.

### 5.2 Manual clear via PowerShell

From the `src` or scripts directory:

```powershell
pwsh .\BNT-Clear-StandbyMemory.ps1 -Type standbylist
```

Supported types include:

- `standbylist` (default)  
- `priority0standbylist`  
- `workingsets`  
- `modifiedpagelist`  

### 5.3 Scheduled background hygiene

The `ClearStandbyMemory` scheduled task runs as SYSTEM at a configurable interval (default 30 minutes) and executes a silent standby clear.

You can adjust the interval by re-running:

```powershell
pwsh .\BNT-Setup-MemMan.ps1 -ScheduleIntervalMinutes 15
```

### 5.4 Memory diagnostics

To capture a snapshot of memory usage:

```powershell
pwsh .\BNT-Get-MemoryReport.ps1 -Top 20
```

To export process data:

```powershell
pwsh .\BNT-Get-MemoryReport.ps1 -Top 20 -ExportCsv "C:\Logs\bnt-memman-report.csv"
```

Use this before and after a clear to observe impact on free memory and process working sets.

[Back to top](#table-of-contents)

***

## 6 Configuration and Tuning

- **ISLC thresholds**  
  - Start with 2048 MB free and 3000 MB standby thresholds for 16 GB systems.  
  - On higher-memory systems, you can increase the standby threshold to better reflect your baseline usage.

- **Scheduled interval**  
  - 30 minutes is a conservative default.  
  - 10 to 15 minutes may be appropriate on systems with very heavy application churn.

- **Startup and background optimization**  
  - Run `BNT-Optimize-StartupAndBackground.ps1 -WhatIf` to preview changes.  
  - Use `-Force` only after reviewing which entries will be disabled.

- **Logging and observability**  
  - `BNT-Clear-StandbyMemory.ps1` writes append-only log entries including timestamps and before/after values.  
  - You can ship these logs into your existing logging pipeline or simply keep them as local diagnostics.

[Back to top](#table-of-contents)

***

## 7 Roadmap

Planned and potential enhancements:

- GUI front-end for non-technical users  
- Intune and enterprise deployment scripts for managed fleets  
- Extended presets for larger RAM configurations (32 GB, 64 GB)  
- Integration with central logging and observability platforms  
- Optional telemetry plug-ins (opt-in) for aggregated performance analysis across devices  

Roadmap items may evolve based on user feedback and consulting engagements.

[Back to top](#table-of-contents)

***

## License

- License type: **Proprietary – BRAIN NXTGEN TECHNOLOGIES (BNT)**, using donation-based, perpetual, and subscription models.  
- Refer to https://brainng.one/licenses for current BNT licensing and usage guidance.  
- See [LICENSE](LICENSE.md) in this repository for full details specific to BNT MemMan Toolkit.

[Back to top](#table-of-contents)

***

## Acknowledgments

- Community developers of `EmptyStandbyList.exe`.  
- Microsoft Sysinternals team for RAMMap.  
- WagnardSoft for Intelligent Standby List Cleaner (ISLC).  

[Back to top](#table-of-contents)

***

## Support

For assistance related to this project:

- **BRAIN NXTGEN TECHNOLOGIES (BNT)**  
  - Website: https://brainng.one  
  - Email: info@brainng.one  

Project-specific support options or commercial support plans may be described on the BNT website under this product’s page.

[Back to top](#table-of-contents)

***

## Contributors

- Brian Williams – Product design, architecture, and implementation  

[Back to top](#table-of-contents)

***

## Copyright

© 2026 BRAIN NXTGEN TECHNOLOGIES (BNT), All rights reserved.

[Back to top](#table-of-contents)
