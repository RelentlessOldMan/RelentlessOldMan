# Deploys the skill folders in this directory to the live Claude Code skills dir
# (%USERPROFILE%\.claude\skills). This repo is the source of truth; re-run after
# editing a skill here so the change takes effect. Safe to run repeatedly.
#
#   pwsh -File .\deploy-skills.ps1        (or run from Windows PowerShell)

$src = $PSScriptRoot
$dest = Join-Path $env:USERPROFILE ".claude\skills"
New-Item -ItemType Directory -Force $dest | Out-Null

Get-ChildItem -Path $src -Directory | ForEach-Object {
    $target = Join-Path $dest $_.Name
    if (Test-Path $target) { Remove-Item $target -Recurse -Force }
    Copy-Item -Path $_.FullName -Destination $target -Recurse
    Write-Host "Deployed skill: $($_.Name) -> $target"
}

Write-Host "Done. $((Get-ChildItem $src -Directory | Measure-Object).Count) skill(s) deployed."
