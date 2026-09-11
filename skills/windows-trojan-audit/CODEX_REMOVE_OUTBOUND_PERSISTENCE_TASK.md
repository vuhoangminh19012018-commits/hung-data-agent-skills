# Codex task: remove non-essential outbound persistence found by the Windows Trojan audit

User authorization: destructive cleanup is approved for non-essential third-party persistence / scripts / scheduled tasks / services identified by the audit. If something is later needed, the user prefers to reinstall it rather than keep uncertain outbound persistence.

## Scope

Use the existing evidence under `C:\Trojan_Audit`, especially `SECOND_PASS_REPORT.txt`, `SECOND_PASS_RUNNING_EXECUTABLES.csv`, and `SECOND_PASS_SERVICES.csv`.

The goal is **not** to delete everything that can access the Internet. Do not break Windows or the user's VLTK VMware environment.

### Preserve

Do NOT delete or disable:

- Microsoft / Windows core services, Windows Update, Defender, networking stack, system drivers, signed Microsoft Windows components.
- VMware/Broadcom networking components required by the user's VLTK VMs, including `VMnetDHCP` and `VMware NAT Service`, unless there is separate evidence they are tampered with.
- Hardware drivers.
- Git, PowerShell, terminal, browser, and other basic tools solely because they can access the Internet.

### Remove / clean

Remove third-party or user-added persistence that is unnecessary, stale, unsigned, suspicious, or exists primarily to make outbound connections / recurring activation / updater traffic.

Start with the confirmed audit findings:

1. **Activation-Renewal**
   - Scheduled task: `Activation-Renewal`
   - File: `%ProgramData%\Activation-Renewal\Activation_task.cmd`
   - SHA-256 observed: `57842338DD0EF827197560D63951061DC0BC8421E9B13C4C9CF94398BD3CFC0D`
   - The script contains KMS-server discovery / outbound activation logic.
   - Remove the scheduled task and the `C:\ProgramData\Activation-Renewal` directory.
   - Do not replace it with another KMS activation mechanism.

2. **Apple Diagnostics**
   - If the scheduled task still points to a missing file, remove the stale scheduled task.

3. **Third-party updater / persistence tasks**
   - Review non-Microsoft scheduled tasks from the audit.
   - Remove stale or unnecessary updater/telemetry persistence that performs recurring outbound connections when it is not needed for the user's current work.
   - Do not delete the application itself unless the task/file is clearly part of the unwanted persistence and removal is safe.

4. **Unsigned / suspicious outbound binaries or scripts**
   - For non-Microsoft files referenced by startup, scheduled tasks, services, Run keys, Startup folders, WMI persistence, or other autoruns: if they are unsigned/invalid, located in `AppData`, `Temp`, `Downloads`, unusual `ProgramData` subdirectories, or otherwise suspicious and network-capable, stop the associated process/service, remove the persistence entry, then delete the file.
   - Before deletion, record path + SHA-256 + persistence source in the cleanup log.

5. **Defender exclusions**
   - Read all Defender exclusion paths/processes/extensions with Administrator rights.
   - Remove broad or unnecessary exclusions that weaken protection, especially exclusions covering whole drives, `Downloads`, `Temp`, `AppData`, or folders used for unknown executables/scripts.
   - Do not remove an exclusion if it is clearly required by a known development workflow without first documenting it in the final report.

## Validation after cleanup

Run another read-only collection pass after cleanup.

Verify:

- `Activation-Renewal` no longer exists.
- `C:\ProgramData\Activation-Renewal` no longer exists.
- stale `Apple Diagnostics` task is gone if it was still present.
- no suspicious non-Microsoft scheduled task/service/startup item remains from the current audit findings.
- Defender exclusions no longer contain broad/unnecessary paths from the audit.
- Windows networking still works.
- VMware services required by the VLTK VMs still work.

## Report

Write `C:\Trojan_Audit\CLEANUP_REPORT.txt` with:

- every task/service/startup entry removed
- every file deleted, with SHA-256 when available
- every Defender exclusion removed
- every item intentionally preserved and why
- any item that could not be removed and the exact error

Do not upload machine-specific logs, hashes, or audit data to GitHub. Commit only code/documentation changes to this repository.
