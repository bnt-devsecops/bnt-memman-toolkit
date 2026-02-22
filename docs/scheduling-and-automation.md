# BNT MemMan Toolkit – Scheduling and Automation

This document describes how the BNT MemMan Toolkit integrates with Windows Task Scheduler, desktop shortcuts, and optional automation tools to provide a smooth, low-friction experience.

---

## 1. Scheduled task – ClearStandbyMemory

### 1.1 Overview

When you run `BNT-Setup-MemMan.ps1`, it creates a scheduled task named `ClearStandbyMemory` that:

- Runs as `SYSTEM` with highest privileges  
- Executes a silent standby clear at a fixed interval  
- Uses `BNT-Clear-StandbyMemory.ps1` with `-Type standbylist -Silent`  

This task is the main “background hygiene” mechanism of the toolkit.

### 1.2 Default configuration

- Task name: `ClearStandbyMemory`  
- Account: `SYSTEM`  
- Run level: Highest available  
- Trigger:  
  - Start: Immediately (one-time)  
  - Repeat: Every 30 minutes (default)  
- Action:

  ```text
  powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "C:\Users\<User>\Scripts\BNT-Clear-StandbyMemory.ps1" -Type standbylist -Silent
  ```

> Note: The exact script path depends on your `$ScriptsRoot` configuration in `BNT-Setup-MemMan.ps1`.

### 1.3 Changing the interval

To change the standby clear interval from the default 30 minutes to another value, re-run the setup script with a different `-ScheduleIntervalMinutes` value:

```powershell
pwsh .\BNT-Setup-MemMan.ps1 -ScheduleIntervalMinutes 15
```

This replaces the existing task and sets the new interval.

### 1.4 Verifying the scheduled task

1. Open **Task Scheduler** (`taskschd.msc`).  
2. Navigate to **Task Scheduler Library**.  
3. Locate the task `ClearStandbyMemory`.  
4. Confirm:  
   - `Triggers` show “Repeat task every X minutes”.  
   - `Actions` points to your `BNT-Clear-StandbyMemory.ps1` script.  
   - `History` (if enabled) shows successful runs.

[Back to top](#bnt-memman-toolkit--scheduling-and-automation)

---

## 2. Desktop shortcut – Clear Standby Memory

### 2.1 Overview

`BNT-Setup-MemMan.ps1` creates a desktop shortcut named **“Clear Standby Memory”** that allows you to trigger a standby clear with a double-click.

### 2.2 Shortcut properties

- Name: `Clear Standby Memory`  
- Target:

  ```text
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\Users\<User>\Scripts\BNT-Clear-StandbyMemory.ps1"
  ```

- Start in: `C:\Users\<User>\Scripts` (or your `$ScriptsRoot`)  
- Icon: A standard system icon from `shell32.dll`  

### 2.3 Run as administrator

To ensure the script has the required privileges:

1. Right-click the `Clear Standby Memory` shortcut.  
2. Click **Properties**.  
3. Click **Advanced**.  
4. Check **Run as administrator**.  
5. Click **OK**, then **OK** again.

Now each double-click will prompt for elevation (if UAC is enabled) and execute the clear.

[Back to top](#bnt-memman-toolkit--scheduling-and-automation)

---

## 3. Optional AutoHotkey integration

### 3.1 Why use a hotkey?

If you frequently trigger manual clears after closing heavy applications, a global keyboard shortcut can be faster than clicking a shortcut or opening PowerShell.

### 3.2 Example (AutoHotkey v2)

Create a file such as `BNT-MemMan-Hotkeys.ahk`:

```autohotkey
#Requires AutoHotkey v2.0

; Ctrl+Alt+M – Silent standbylist clear
^!m:: {
    Run '*RunAs powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "' A_MyDocuments '\Scripts\BNT-Clear-StandbyMemory.ps1" -Type standbylist -Silent'
}
```

Adjust the path if your scripts are not under `Documents\Scripts`.

Load the script and you will be able to press `Ctrl+Alt+M` to silently clear the standby list.

[Back to top](#bnt-memman-toolkit--scheduling-and-automation)

---

## 4. Integration with your own automation

### 4.1 Existing system-config scripts

If you maintain a “MY SYSTEM CONFIG” or system health script, you can integrate BNT MemMan Toolkit as follows:

1. Capture a pre-clear snapshot:

   ```powershell
   pwsh .\BNT-Get-MemoryReport.ps1 -Top 20 -ExportCsv "C:\Logs\bnt-memman-pre.csv"
   ```

2. Run a standby clear:

   ```powershell
   pwsh .\BNT-Clear-StandbyMemory.ps1 -Type standbylist -Silent
   ```

3. Capture a post-clear snapshot:

   ```powershell
   pwsh .\BNT-Get-MemoryReport.ps1 -Top 20 -ExportCsv "C:\Logs\bnt-memman-post.csv"
   ```

4. Parse or summarize the difference in your own script.

### 4.2 CI-style workstation checks

For lab or test systems you rebuild frequently, consider:

- Calling `BNT-Setup-MemMan.ps1` from your post-install automation.  
- Running `BNT-Optimize-StartupAndBackground.ps1 -Force` after discussing policy with stakeholders.  
- Using `BNT-Get-MemoryReport.ps1` at the end to generate a standard report.

[Back to top](#bnt-memman-toolkit--scheduling-and-automation)

---

## 5. ISLC cooperation

### 5.1 Purpose

Intelligent Standby List Cleaner (ISLC) runs as a companion to BNT MemMan Toolkit, using thresholds to auto-trigger standby clears based on free memory and standby size.

The combination of:

- ISLC threshold-based clearing  
- `ClearStandbyMemory` scheduled task  
- Manual clears via shortcut or hotkey  

creates a layered memory governance approach.

### 5.2 Recommended baseline for 16 GB systems

- Free memory threshold: 2048 MB  
- Standby list size threshold: 3000 MB  
- Enable at Windows startup  

If you notice too frequent clears or unnecessary churn, you can:

- Raise the free memory threshold slightly.  
- Raise the standby list threshold to match your typical workload.

[Back to top](#bnt-memman-toolkit--scheduling-and-automation)
