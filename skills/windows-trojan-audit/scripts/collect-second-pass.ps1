[CmdletBinding()]
param(
    [string]$OutputDirectory = 'C:\Trojan_Audit'
)

$ErrorActionPreference = 'Continue'
$report = Join-Path $OutputDirectory 'SECOND_PASS_REPORT.txt'
$now = Get-Date
New-Item -ItemType Directory -Path $OutputDirectory -Force | Out-Null

function Get-ExePath([string]$CommandLine) {
    if ([string]::IsNullOrWhiteSpace($CommandLine)) { return $null }
    if ($CommandLine -match '^\s*"([^"]+)"') { return $Matches[1] }
    return ($CommandLine -split '\s+')[0]
}

function Get-FileEvidence([string]$Path) {
    if ([string]::IsNullOrWhiteSpace($Path) -or -not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        return [pscustomobject]@{ Exists=$false; SignatureStatus='MISSING_OR_UNAVAILABLE'; Publisher=$null; SHA256=$null }
    }
    try { $signature = Get-AuthenticodeSignature -LiteralPath $Path } catch { $signature = $null }
    try { $hash = (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash } catch { $hash = $null }
    [pscustomobject]@{
        Exists=$true
        SignatureStatus=if ($signature) { [string]$signature.Status } else { 'UNKNOWN' }
        Publisher=if ($signature -and $signature.SignerCertificate) { $signature.SignerCertificate.Subject } else { $null }
        SHA256=$hash
    }
}

function Append-Section([string]$Title, [object[]]$Rows) {
    "`r`n===== $Title =====" | Add-Content -LiteralPath $report -Encoding utf8
    if ($Rows -and $Rows.Count -gt 0) { $Rows | Format-Table -AutoSize -Wrap | Out-String -Width 300 | Add-Content -LiteralPath $report -Encoding utf8 }
    else { 'No entries.' | Add-Content -LiteralPath $report -Encoding utf8 }
}

$admin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
@(
    'WINDOWS TROJAN AUDIT - SECOND PASS'
    "Generated: $now"
    "Current user: $([Security.Principal.WindowsIdentity]::GetCurrent().Name)"
    "Administrator: $admin"
    'Read-only collection only. No files, services, tasks, registry keys, or Defender settings were changed.'
) | Set-Content -LiteralPath $report -Encoding utf8

try {
    $preference = Get-MpPreference -ErrorAction Stop
    $exclusions = [pscustomobject]@{
        ExclusionPath=($preference.ExclusionPath -join '; ')
        ExclusionProcess=($preference.ExclusionProcess -join '; ')
        ExclusionExtension=($preference.ExclusionExtension -join '; ')
    }
} catch {
    $exclusions = [pscustomobject]@{ ExclusionPath='UNAVAILABLE: requires elevation'; ExclusionProcess='UNAVAILABLE: requires elevation'; ExclusionExtension='UNAVAILABLE: requires elevation' }
}
Append-Section 'DEFENDER EXCLUSIONS' @($exclusions)

$processRows = foreach ($process in Get-CimInstance Win32_Process) {
    $evidence = Get-FileEvidence $process.ExecutablePath
    [pscustomobject]@{
        Name=$process.Name; PID=$process.ProcessId; ParentPID=$process.ParentProcessId
        Path=$process.ExecutablePath; CommandLine=$process.CommandLine
        Exists=$evidence.Exists; Signature=$evidence.SignatureStatus; Publisher=$evidence.Publisher; SHA256=$evidence.SHA256
    }
}
$processRows | Export-Csv -LiteralPath (Join-Path $OutputDirectory 'SECOND_PASS_RUNNING_EXECUTABLES.csv') -NoTypeInformation -Encoding utf8
Append-Section 'ALL RUNNING EXECUTABLES' $processRows
$unsignedProcesses = $processRows | Where-Object { $_.Exists -and $_.Signature -ne 'Valid' }
$windowsNonMicrosoft = $processRows | Where-Object { $_.Path -like 'C:\Windows\*' -and ($_.Signature -ne 'Valid' -or $_.Publisher -notmatch 'Microsoft') }
Append-Section 'UNSIGNED OR INVALID RUNNING EXECUTABLES' $unsignedProcesses
Append-Section 'SUSPICIOUS WINDOWS-DIRECTORY EXECUTABLES' $windowsNonMicrosoft

$serviceRows = foreach ($service in Get-CimInstance Win32_Service) {
    $path = Get-ExePath $service.PathName
    $evidence = Get-FileEvidence $path
    [pscustomobject]@{
        Name=$service.Name; DisplayName=$service.DisplayName; State=$service.State; StartMode=$service.StartMode
        StartName=$service.StartName; Path=$path; CommandLine=$service.PathName
        Exists=$evidence.Exists; Signature=$evidence.SignatureStatus; Publisher=$evidence.Publisher; SHA256=$evidence.SHA256
    }
}
$serviceRows | Export-Csv -LiteralPath (Join-Path $OutputDirectory 'SECOND_PASS_SERVICES.csv') -NoTypeInformation -Encoding utf8
Append-Section 'ALL SERVICES' $serviceRows
$suspiciousServices = $serviceRows | Where-Object { $_.Path -match '^C:\\Windows\\' -and ($_.Signature -ne 'Valid' -or $_.Publisher -notmatch 'Microsoft') }
Append-Section 'SUSPICIOUS WINDOWS-DIRECTORY SERVICES' $suspiciousServices

$roots = @("$env:LOCALAPPDATA", "$env:APPDATA", 'C:\ProgramData', $env:TEMP, "$env:USERPROFILE\Downloads")
$extensions = @('.exe','.dll','.ps1','.bat','.cmd','.vbs','.js','.scr','.lnk')
$recentFiles = foreach ($root in $roots) {
    if (-not (Test-Path -LiteralPath $root)) { continue }
    Get-ChildItem -LiteralPath $root -File -Recurse -Depth 5 -Force -ErrorAction SilentlyContinue |
        Select-Object -First 20000 |
        Where-Object { $_.Extension -in $extensions -and $_.LastWriteTime -ge $now.AddDays(-30) } |
        Select-Object -First 5000 |
        ForEach-Object {
            [pscustomobject]@{ Root=$root; Path=$_.FullName; Extension=$_.Extension; Length=$_.Length; CreationTime=$_.CreationTime; LastWriteTime=$_.LastWriteTime }
        }
}
$recentFiles | Export-Csv -LiteralPath (Join-Path $OutputDirectory 'SECOND_PASS_RECENT_EXECUTABLE_CONTENT.csv') -NoTypeInformation -Encoding utf8
Append-Section 'RECENT EXECUTABLE OR SCRIPT CONTENT (30 DAYS, DEPTH <= 5, MAX 5000 PER ROOT)' $recentFiles

$taskRows = Get-ScheduledTask -ErrorAction SilentlyContinue | Where-Object { $_.TaskPath -notlike '\Microsoft\*' } | ForEach-Object {
    [pscustomobject]@{ TaskPath=$_.TaskPath; TaskName=$_.TaskName; State=$_.State; Author=$_.Author; UserId=$_.Principal.UserId; RunLevel=$_.Principal.RunLevel; Actions=($_.Actions | Out-String).Trim() }
}
$suspiciousTasks = $taskRows | Where-Object { $_.Actions -match '(?i)powershell|cmd\.exe|wscript|cscript|mshta|rundll32|regsvr32|\\AppData\\|\\Temp\\|\\Downloads\\|\\ProgramData\\' }
Append-Section 'SUSPICIOUS SCHEDULED TASKS' $suspiciousTasks

@(
    ''
    '===== REQUIRED SUMMARY ====='
    "Defender exclusions: $(if($admin){'collected; see DEFENDER EXCLUSIONS'}else{'unavailable without Administrator elevation'})"
    "Unsigned/invalid running executables: $($unsignedProcesses.Count); see detailed section and CSV."
    "Suspicious Windows-directory executables: $($windowsNonMicrosoft.Count); see detailed section."
    "Suspicious Windows-directory services: $($suspiciousServices.Count); see detailed section."
    "Suspicious scheduled tasks: $($suspiciousTasks.Count); see detailed section."
    'No remediation was performed.'
) | Add-Content -LiteralPath $report -Encoding utf8

Write-Output "Second-pass report written to $report"
