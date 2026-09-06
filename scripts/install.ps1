param(
    [Parameter(Mandatory=$false)]
    [string]$Target = "$HOME/.agents/skills"
)

$ErrorActionPreference = "Stop"
$RepoRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$SkillsSource = Join-Path $RepoRoot "skills"

New-Item -ItemType Directory -Force -Path $Target | Out-Null

Get-ChildItem -Path $SkillsSource -Directory | ForEach-Object {
    $dest = Join-Path $Target $_.Name
    if (Test-Path $dest) {
        Remove-Item -Recurse -Force $dest
    }
    Copy-Item -Recurse -Force $_.FullName $dest
    Write-Host "Installed $($_.Name) -> $dest"
}

Write-Host "Installed all Hung Data Agent Skills to $Target"
