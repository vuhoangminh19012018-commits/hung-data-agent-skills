---
name: windows-trojan-audit
description: Safely audit a Windows machine after a suspected Trojan or malware incident. Use when the user asks Codex to check whether malware remains, inspect persistence, Defender state, startup items, scheduled tasks, services, WMI, suspicious processes, network connections, proxy/DNS/hosts changes, browser extensions, or suspicious files. Collect evidence first and never delete or modify suspicious items without explicit user approval.
---

# Windows Trojan Audit

## Goal
Determine whether a Windows machine shows evidence of active malware, persistence, or malicious configuration changes after a suspected Trojan incident.

The first pass is **read-only investigation**. Do not delete, disable, quarantine, kill, or repair anything unless the user explicitly approves the exact action after reviewing the evidence.

Create an audit folder when possible:

```text
C:\Trojan_Audit
```

Store collected output and a final report there. If permissions prevent this, use a clearly named folder in the current user's Documents directory and report the actual path.

## Non-negotiable safety rules

- Do not delete files, registry keys, scheduled tasks, services, WMI subscriptions, startup entries, browser extensions, or Defender exclusions during the evidence-gathering phase.
- Do not terminate suspicious processes unless the user explicitly authorizes containment.
- Do not disable Windows Defender, Tamper Protection, firewall, UAC, or other security controls.
- Do not execute suspicious binaries/scripts to "test" them.
- Do not upload files, hashes, logs, or private data to external services without explicit permission.
- Do not treat `UNSIGNED` as equivalent to malware.
- Do not treat an unfamiliar process name as malicious by itself. Validate path, publisher, signature, hash, parent/child relationship, persistence, and network behavior.
- Preserve evidence. Record exact paths, command lines, timestamps, hashes, task/service names, and detection IDs before recommending remediation.
- Never claim a machine is "100% clean". State what was checked, what was not checked, and remaining uncertainty.

## Phase 1 — Establish system and Defender state

Collect:

```powershell
Get-ComputerInfo | Select-Object WindowsProductName,WindowsVersion,OsBuildNumber,OsArchitecture
whoami
whoami /groups
Get-MpComputerStatus
Get-MpThreat
Get-MpThreatDetection
Get-MpPreference
```

Record at minimum:

- Windows edition/build and architecture
- current user and whether the shell is elevated
- Defender antivirus/antispyware enabled state
- real-time protection state
- behavior monitoring state
- antivirus signature version/date
- recent Defender detections and whether any threat remains active
- Defender exclusions: `ExclusionPath`, `ExclusionProcess`, `ExclusionExtension`

Treat broad or unexplained exclusions as high-interest evidence, especially exclusions covering roots or common malware staging locations such as:

```text
C:\
C:\Users
%USERPROFILE%\AppData
C:\Windows
C:\ProgramData
Downloads
Temp
```

Do not remove exclusions in this phase.

## Phase 2 — Update signatures and run Defender scan

If Microsoft Defender is active and the user has not prohibited scanning:

```powershell
Update-MpSignature
Start-MpScan -ScanType FullScan
```

After the scan, collect again:

```powershell
Get-MpThreat
Get-MpThreatDetection
Get-MpComputerStatus
```

If the scan command cannot start because another antivirus owns real-time protection, report that instead of attempting to disable the other antivirus.

Do not automatically run `Start-MpWDOScan` during the evidence pass because it reboots the computer. Recommend Microsoft Defender Offline as a separate final verification step and require the user's explicit approval before triggering a reboot.

## Phase 3 — Inspect running processes

Collect process details with CIM so command lines and parent PIDs are visible:

```powershell
Get-CimInstance Win32_Process |
  Select-Object Name,ProcessId,ParentProcessId,ExecutablePath,CommandLine
```

For suspicious executable paths, inspect signature and SHA-256:

```powershell
Get-AuthenticodeSignature -FilePath '<path>'
Get-FileHash -Algorithm SHA256 -Path '<path>'
```

Prioritize processes executing from:

- `%TEMP%`
- `%APPDATA%`
- `%LOCALAPPDATA%`
- Downloads
- `C:\ProgramData`
- user-writable directories with random-looking names

Flag for deeper review when evidence includes one or more of:

- executable masquerades as a Windows component but runs from the wrong directory
- invalid digital signature
- strange or heavily obfuscated command line
- parent/child chain such as Office/browser -> PowerShell/cmd/script host
- unknown executable -> PowerShell, `rundll32`, `regsvr32`, `mshta`, `wscript`, or `cscript`
- executable is persisted by a startup mechanism
- executable also owns unusual network connections

Remember: legitimate Windows binaries such as `svchost.exe` must be judged by path, signature, command line, service association, and behavior rather than name alone.

## Phase 4 — Inspect network activity and network configuration

Collect active TCP connections and map them to PIDs/processes:

```powershell
Get-NetTCPConnection |
  Sort-Object State,RemoteAddress,RemotePort |
  Select-Object State,LocalAddress,LocalPort,RemoteAddress,RemotePort,OwningProcess

netstat -ano
```

For relevant PIDs, resolve the executable path using `Get-Process` and/or `Win32_Process`.

Also inspect:

```powershell
netsh winhttp show proxy
Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings' |
  Select-Object ProxyEnable,ProxyServer,AutoConfigURL
Get-DnsClientServerAddress
Get-Content "$env:SystemRoot\System32\drivers\etc\hosts"
```

Do not label a remote IP malicious solely because it is unfamiliar. Correlate it with the owning process, executable provenance, persistence, reputation available from existing local security products, and timing.

## Phase 5 — Inspect startup persistence

Read Run/RunOnce keys:

```powershell
$runKeys = @(
  'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run',
  'HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce',
  'HKLM:\Software\Microsoft\Windows\CurrentVersion\Run',
  'HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce',
  'HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Run',
  'HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\RunOnce'
)
foreach ($key in $runKeys) {
  if (Test-Path $key) {
    Get-ItemProperty $key
  }
}
```

Inspect Startup folders:

```powershell
Get-ChildItem "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup" -Force -ErrorAction SilentlyContinue
Get-ChildItem "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp" -Force -ErrorAction SilentlyContinue
```

High-interest startup commands include PowerShell, cmd, `wscript`, `cscript`, `mshta`, `rundll32`, `regsvr32`, or scripts/executables in user-writable locations.

## Phase 6 — Inspect Scheduled Tasks

Collect tasks with their actions and principals:

```powershell
Get-ScheduledTask | ForEach-Object {
  [PSCustomObject]@{
    TaskPath = $_.TaskPath
    TaskName = $_.TaskName
    State    = $_.State
    Author   = $_.Author
    Actions  = ($_.Actions | Out-String).Trim()
    Triggers = ($_.Triggers | Out-String).Trim()
    UserId   = $_.Principal.UserId
    RunLevel = $_.Principal.RunLevel
  }
}
```

Prioritize non-Microsoft tasks or tasks whose actions launch scripting/LOLBin tools or content from AppData, Temp, Downloads, or ProgramData.

Do not delete or disable tasks during the audit.

## Phase 7 — Inspect services and drivers

Collect services including their executable command lines:

```powershell
Get-CimInstance Win32_Service |
  Select-Object Name,DisplayName,State,StartMode,StartName,PathName
```

Collect system drivers when useful:

```powershell
Get-CimInstance Win32_SystemDriver |
  Select-Object Name,DisplayName,State,StartMode,PathName
```

Investigate services/drivers with:

- executable paths in user-writable directories
- missing executable targets
- invalid or unexpected signatures
- random or deceptive names
- recently created binaries around the incident window

Do not stop or delete a service/driver during the audit.

## Phase 8 — Inspect WMI permanent event subscriptions

Check for persistence in `root\subscription`:

```powershell
Get-CimInstance -Namespace root\subscription -ClassName __EventFilter
Get-CimInstance -Namespace root\subscription -ClassName CommandLineEventConsumer
Get-CimInstance -Namespace root\subscription -ClassName ActiveScriptEventConsumer
Get-CimInstance -Namespace root\subscription -ClassName __FilterToConsumerBinding
```

Treat a permanent consumer that launches PowerShell, cmd, scripts, or an unknown executable as high-priority evidence. Do not remove it automatically.

## Phase 9 — Inspect browser extensions and suspicious recent files

Inspect installed extension metadata for Chrome, Edge, and Firefox when present. Record extension IDs/names/paths and policies that force-install extensions. Do not remove extensions automatically.

Review recent files in likely staging locations, limiting scope so the scan does not freeze the machine:

- Downloads
- Desktop
- `%APPDATA%`
- `%LOCALAPPDATA%`
- `C:\ProgramData`
- `%TEMP%`

Prioritize extensions:

```text
.exe .dll .ps1 .bat .cmd .vbs .js .jse .wsf .scr .lnk .hta
```

Prefer time-bounded searches around the suspected infection window when that date is known. Avoid blind recursive scans of the entire system drive with `Get-ChildItem -Recurse`.

For candidate files, capture path, size, timestamps, signature, publisher, and SHA-256.

## Phase 10 — Use Sysinternals Autoruns when available

If Autoruns/Autorunsc is already installed, use it to review persistence surfaces including:

- Logon
- Services
- Drivers
- Scheduled Tasks
- WMI
- Winlogon
- Explorer extensions
- Image Hijacks

Prefer hiding Microsoft-signed entries only for triage; retain enough context to avoid false positives.

If Sysinternals is not installed, do not download arbitrary copies. Use only Microsoft's official Sysinternals source, and require explicit permission before downloading software.

Do not disable Autoruns entries during the audit.

## Evidence correlation

A single weak signal is usually not enough. Raise confidence when multiple independent signals point to the same artifact, for example:

- unsigned/invalid binary in AppData
- launched by a suspicious scheduled task
- makes an external connection
- appeared around the incident time
- command line is obfuscated
- Defender previously detected the same path/hash

Conversely, reduce concern when evidence shows a valid Microsoft/vendor signature, expected installation path, normal parent process, no persistence, and behavior consistent with installed software.

## Risk classification

Use these labels in the final report:

### CRITICAL
Strong evidence of active malicious execution, credential theft/ransomware behavior, security-control tampering, or confirmed malware that is still active.

### HIGH
Strong persistence or multi-signal evidence consistent with malware, but destructive/credential-impact behavior is not directly confirmed.

### MEDIUM
Suspicious artifact or configuration that warrants manual verification but lacks enough corroborating evidence for a malware conclusion.

### LOW
Unusual but plausibly legitimate item with little malicious evidence.

### CLEAN / NORMAL
Items reviewed and supported as legitimate/expected.

## Required report

Create:

```text
C:\Trojan_Audit\FINAL_REPORT.txt
```

For every suspicious finding include, where available:

```text
Name:
Type:
Path:
PID / Parent PID:
Command line:
Persistence mechanism:
Publisher:
Digital signature status:
SHA256:
Network connection:
Relevant timestamps:
Defender detection/history:
Reason suspicious:
Risk level:
Recommended next action:
```

Finish with exactly one overall conclusion category:

```text
A. No clear evidence of active malware/persistence was found in the checks performed.
B. Suspicious items remain and require deeper verification.
C. Evidence indicates malware/persistence is still active.
```

Then list:

- checks completed
- checks that could not be completed and why
- remaining uncertainty
- whether a Defender Offline scan is recommended
- whether credentials used during the suspected infection window should be rotated from a known-clean device

## Stop point

After the first-pass report is complete, stop. Show the user `CRITICAL`, `HIGH`, then `MEDIUM` findings first.

Do not remediate anything until the user explicitly approves the next actions.