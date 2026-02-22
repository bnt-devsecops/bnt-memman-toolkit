# BNT MemMan Toolkit – Usage Examples

This document provides practical scenarios for using the BNT MemMan Toolkit on Windows 10/11 workstations, especially for multi-monitor, multi-app, and multi-tenant workflows.

---

## 1. Post-close RAM cleanup for heavy sessions

### Scenario

You have just closed several heavy applications:

- Multiple Chrome profiles (client tenants)
- Microsoft Teams and Outlook
- Large Office documents (Word, Excel, PowerPoint)
- Resource-hungry tools such as VSCode with many extensions

You want to quickly reclaim RAM without rebooting or disturbing your monitor layout.

### Steps

1. Capture a baseline memory snapshot:

   ```powershell
   pwsh .\BNT-Get-MemoryReport.ps1 -Top 20
   ```

2. Trigger a standby memory clear:

   ```powershell
   pwsh .\BNT-Clear-StandbyMemory.ps1 -Type standbylist
   ```

3. Capture an after snapshot for comparison:

   ```powershell
   pwsh .\BNT-Get-MemoryReport.ps1 -Top 20
   ```

4. Optionally, review Task Manager (Ctrl+Shift+Esc) on the **Performance** tab to see the change in “In use” and “Available” RAM.

[Back to top](#bnt-memman-toolkit--usage-examples)

---

## 2. Pre-call optimization for Teams or Zoom

### Scenario

You are about to enter a critical Teams or Zoom call, with screen sharing of VSCode, browser tabs, and slides. You want to minimize the chance of lag or stutter.

### Steps

1. Close non-essential applications and browser tabs.

2. Run a gentle standby clear that targets low-priority pages:

   ```powershell
   pwsh .\BNT-Clear-StandbyMemory.ps1 -Type priority0standbylist
   ```

3. Optionally, run a quick report to confirm memory headroom:

   ```powershell
   pwsh .\BNT-Get-MemoryReport.ps1 -Top 15
   ```

4. Start your meeting with improved available memory and less risk of sudden slowdowns.

[Back to top](#bnt-memman-toolkit--usage-examples)

---

## 3. Fully automated background hygiene

### Scenario

You want the workstation to stay responsive throughout the day without thinking about memory. You are comfortable with the toolkit running in the background.

### Steps

1. Ensure `BNT-Setup-MemMan.ps1` has been run successfully and the scheduled task `ClearStandbyMemory` exists.

2. Configure ISLC as recommended for a 16 GB system:

   - Free memory threshold: 2048 MB  
   - Standby list size threshold: 3000 MB  
   - Enable start with Windows

3. Continue using your workstation normally:

   - Leave VSCode, PowerShell, multiple browsers, and Teams open as needed.
   - Let ISLC and the scheduled task perform background standby clears.

4. If you notice sluggishness, you can still trigger an on-demand clear via:

   - The desktop shortcut “Clear Standby Memory”, or  
   - A direct script call:

     ```powershell
     pwsh .\BNT-Clear-StandbyMemory.ps1 -Type standbylist
     ```

[Back to top](#bnt-memman-toolkit--usage-examples)

---

## 4. Baseline optimization on a freshly built workstation

### Scenario

You have rebuilt your Windows 10/11 workstation or received a new device and want to:

- Lower baseline RAM usage  
- Prepare the machine for long workdays with heavy workloads  

### Steps

1. Run the setup script:

   ```powershell
   pwsh .\BNT-Setup-MemMan.ps1
   ```

2. Run the optimization script in preview mode:

   ```powershell
   pwsh .\BNT-Optimize-StartupAndBackground.ps1 -WhatIf
   ```

3. Review the proposed changes. If acceptable, apply them:

   ```powershell
   pwsh .\BNT-Optimize-StartupAndBackground.ps1 -Force
   ```

4. Capture a baseline report for documentation:

   ```powershell
   pwsh .\BNT-Get-MemoryReport.ps1 -Top 20 -ExportCsv "$env:USERPROFILE\Documents\bnt-memman-baseline.csv"
   ```

5. Keep the CSV and console output as part of your “MY SYSTEM CONFIG” or workstation build notes.

[Back to top](#bnt-memman-toolkit--usage-examples)

---

## 5. Consulting and assessment workflow

### Scenario

You are using BNT MemMan Toolkit as part of a consulting engagement to improve workstation performance across a small team or client environment.

### Steps

1. On each target workstation:

   - Run `BNT-Setup-MemMan.ps1`.  
   - Run `BNT-Optimize-StartupAndBackground.ps1 -WhatIf` and agree a policy with the client before applying `-Force`.

2. Capture pre-optimization metrics:

   ```powershell
   pwsh .\BNT-Get-MemoryReport.ps1 -Top 25 -ExportCsv "C:\Logs\bnt-memman-pre.csv"
   ```

3. Apply optimization and run a standby clear:

   ```powershell
   pwsh .\BNT-Optimize-StartupAndBackground.ps1 -Force
   pwsh .\BNT-Clear-StandbyMemory.ps1 -Type standbylist
   ```

4. Capture post-optimization metrics:

   ```powershell
   pwsh .\BNT-Get-MemoryReport.ps1 -Top 25 -ExportCsv "C:\Logs\bnt-memman-post.csv"
   ```

5. Compare CSV outputs and summarize:

   - Average free RAM increase  
   - Reduction in standby cache  
   - Reduction in background or startup-intensive processes  

6. Include screenshots and summarized metrics in your consulting report or slideshow.

[Back to top](#bnt-memman-toolkit--usage-examples)