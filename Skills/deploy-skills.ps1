# Deploys the skill folders in this directory to the live Claude Code skills dir
# (%USERPROFILE%\.claude\skills). This repo is the source of truth; re-run after
# editing a skill here so the change takes effect. Safe to run repeatedly.
#
#   pwsh -File .\deploy-skills.ps1        (or run from Windows PowerShell)
#
# This deploys the home PC's skills: relay-loop-work is the work PC's side of the relay
# loop, fetched there from GitHub, so it is never deployed here (and removed if present).

$src = $PSScriptRoot
$dest = Join-Path $env:USERPROFILE ".claude\skills"
New-Item -ItemType Directory -Force $dest | Out-Null

$count = 0
Get-ChildItem -Path $src -Directory | ForEach-Object {
    $target = Join-Path $dest $_.Name
    if ($_.Name -eq 'relay-loop-work') {
        if (Test-Path $target) { Remove-Item $target -Recurse -Force; Write-Host "Removed skill: $($_.Name) (work PC only)" }
        return
    }
    if (Test-Path $target) { Remove-Item $target -Recurse -Force }
    Copy-Item -Path $_.FullName -Destination $target -Recurse
    Write-Host "Deployed skill: $($_.Name) -> $target"
    $count++
}

Write-Host "Done. $count skill(s) deployed."
