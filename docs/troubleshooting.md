# BNT MemMan Toolkit – Troubleshooting

This document lists common issues, causes, and remediation steps for the BNT MemMan Toolkit – Windows RAM & Standby List Optimizer.

---

## 1. BNT-Clear-StandbyMemory.ps1 shows “requires Administrator privileges”

### Symptoms

- You see a warning that the script requires Administrator privileges.  
- The script attempts to relaunch, or exits without performing the clear.

### Likely causes

- PowerShell was started without elevation.  
- UAC or policy prevents elevation without confirmation.

### Resolution

1. Close the current PowerShell window.  
2. Open a new PowerShell session **as Administrator**:  
   - Start menu → type “PowerShell” → right-click → “Run as administrator”.  
3. Re-run the script:

   ```powershell
   pwsh .\BNT-Clear-StandbyMemory.ps1 -Type standbylist
   ```

4. For the desktop shortcut, ensure “Run as administrator” is enabled in **Properties > Advanced**.

[Back to top](#bnt-memman-toolkit--troubleshooting)

---

## 2. Error: EmptyStandbyList.exe not found in PATH

### Symptoms

- The script fails with an error indicating `EmptyStandbyList.exe` cannot be found.  

### Likely causes

- `BNT-Setup-MemMan.ps1` was not run successfully.  
- The download of EmptyStandbyList.exe failed.  
- The file was removed or relocated from `C:\Windows\System32`.

### Resolution

1. Check if `C:\Windows\System32\EmptyStandbyList.exe` exists.  
2. If not present, re-run the setup script as Administrator:

   ```powershell
   pwsh .\BNT-Setup-MemMan.ps1
   ```

3. If the problem persists:  
   - Verify network access.  
   - Temporarily disable restrictive security software that may be blocking the download.  

[Back to top](#bnt-memman-toolkit--troubleshooting)

---

## 3. Scheduled task “ClearStandbyMemory” does not run

### Symptoms

- The scheduled task exists but does not seem to clear memory.  
- Task Scheduler shows errors, or the last run time does not update.

### Likely causes

- The task was created but disabled.  
- The script path referenced by the task is incorrect or moved.  
- The scheduled task history is disabled, making it harder to see failures.

### Resolution

1. Open **Task Scheduler** and locate `ClearStandbyMemory`.  
2. Confirm:  
   - The task is **enabled**.  
   - The **Triggers** section shows the repeat configuration.  
   - The **Actions** section points to the correct `BNT-Clear-StandbyMemory.ps1` path.  
3. Right-click the task and choose **Run** to test.  
4. If it fails, re-run the setup with the same or updated settings:

   ```powershell
   pwsh .\BNT-Setup-MemMan.ps1 -ScheduleIntervalMinutes 30
   ```

[Back to top](#bnt-memman-toolkit--troubleshooting)

---

## 4. ISLC appears not to trigger

### Symptoms

- ISLC is open, but you rarely see standby size change.  
- Memory feels tight despite ISLC running.

### Likely causes

- Thresholds are set too high or too low for your workload.  
- ISLC is not configured to start with Windows.  
- ISLC is not running as expected after reboot.

### Resolution

1. Open ISLC and verify:  
   - “Start with Windows” is enabled.  
   - “Enable custom timer” (if available) is set to a reasonable interval.  
2. For a 16 GB system, start with:  
   - Free memory threshold: 2048 MB  
   - Standby list size threshold: 3000 MB  
3. Adjust thresholds after observing your workload for a full day:  
   - If standby rarely exceeds the threshold, lower it slightly.  
   - If standbys are cleared too often, raise the threshold.  

[Back to top](#bnt-memman-toolkit--troubleshooting)

---

## 5. BNT-Optimize-StartupAndBackground.ps1 fails to change some entries

### Symptoms

- Some startup entries remain enabled after running with `-Force`.  
- Warnings appear about access being denied or registry keys being controlled.

### Likely causes

- Group Policy or corporate management tools enforce specific startup entries.  
- The current user lacks rights to change HKLM entries.  
- Security or endpoint protection software locks certain keys.

### Resolution

1. Run PowerShell as Administrator.  
2. Re-run the script with `-Force`:

   ```powershell
   pwsh .\BNT-Optimize-StartupAndBackground.ps1 -Force
   ```

3. If entries still cannot be changed:  
   - Check with your IT/security team if GPO prohibits modification.  
   - Use Task Manager’s **Startup** tab to see if specific apps are managed.  

[Back to top](#bnt-memman-toolkit--troubleshooting)

---

## 6. BNT-Get-MemoryReport.ps1 cannot read performance counters

### Symptoms

- Warning: “Could not read memory performance counters”.  
- Report shows system overview and processes, but no counter details.

### Likely causes

- Performance counters are disabled or corrupted on the system.  
- Some security baselines remove or restrict access to certain counters.

### Resolution

1. Confirm that you are running as a user with sufficient privileges.  
2. Try refreshing performance counters using standard Windows procedures (for example `lodctr /R` in an elevated command prompt), if allowed in your environment.  
3. If you are on a locked-down corporate image, coordinate with your IT team before attempting any counter resets.

[Back to top](#bnt-memman-toolkit--troubleshooting)

---

## 7. No noticeable performance improvement after clears

### Symptoms

- Scripts run successfully.  
- Logs show reclaimed memory.  
- Subjective performance does not noticeably improve.

### Likely causes

- The bottleneck is CPU, disk, or network rather than RAM.  
- A specific application has its own internal memory management or leaks.  
- Standby is not the main contributor, or the workstation is under GPU or storage pressure.

### Resolution

1. Use Task Manager and Resource Monitor to confirm which resource is saturated:  
   - CPU, memory, disk, GPU, or network.  
2. Use `BNT-Get-MemoryReport.ps1` to compare free RAM and standby sizes before and after clears.  
3. For CPU-bound or disk-bound scenarios, consider:  
   - Closing or limiting specific apps.  
   - Reviewing VSCode extensions, container workloads, or local services.  
4. If needed, include additional diagnostics in your consulting workflow to identify the true bottleneck.

[Back to top](#bnt-memman-toolkit--troubleshooting)

---

## 8. Script execution policy prevents running toolkit scripts

### Symptoms

- Errors referencing script execution policy or blocked scripts.  

### Likely causes

- PowerShell execution policy is more restrictive than required.  
- Corporate policy enforces a specific script signing or policy level.

### Resolution

1. For local, interactive use, you can temporarily relax the policy **for the current process**:

   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
   ```

2. Then run your command, for example:

   ```powershell
   pwsh .\BNT-Setup-MemMan.ps1
   ```

3. Do not change local machine or remote scopes unless you understand enterprise security implications and have approvals.

[Back to top](#bnt-memman-toolkit--troubleshooting)
