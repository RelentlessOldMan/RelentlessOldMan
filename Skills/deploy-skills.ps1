# Deploys the skill folders in this directory to the live Claude Code skills dir
# (%USERPROFILE%\.claude\skills). This repo is the source of truth; re-run after
# editing a skill here so the change takes effect. Safe to run repeatedly.
#
#   pwsh -File .\deploy-skills.ps1 -Side home   (or -Side work; run from Windows PowerShell too)
#
# The relay-loop-home / relay-loop-work pair is one skill per machine: only this machine's
# side is deployed, and the other side is removed if present. -Side is remembered in
# %USERPROFILE%\.claude\relay-side.txt, so later runs need no argument. With no side known,
# neither relay loop is deployed.

param([ValidateSet('home', 'work')][string]$Side)

$src = $PSScriptRoot
$dest = Join-Path $env:USERPROFILE ".claude\skills"
$sideFile = Join-Path $env:USERPROFILE ".claude\relay-side.txt"
New-Item -ItemType Directory -Force $dest | Out-Null

if ($Side) { Set-Content -Path $sideFile -Value $Side -Encoding ascii }
elseif (Test-Path $sideFile) { $Side = (Get-Content $sideFile -TotalCount 1).Trim() }

$count = 0
Get-ChildItem -Path $src -Directory | ForEach-Object {
    $target = Join-Path $dest $_.Name
    if ($_.Name -like 'relay-loop-*' -and $_.Name -ne "relay-loop-$Side") {
        if (Test-Path $target) { Remove-Item $target -Recurse -Force; Write-Host "Removed skill: $($_.Name) (not this machine's side)" }
        return
    }
    if (Test-Path $target) { Remove-Item $target -Recurse -Force }
    Copy-Item -Path $_.FullName -Destination $target -Recurse
    Write-Host "Deployed skill: $($_.Name) -> $target"
    $count++
}

if (-not $Side) { Write-Host "No relay side set: run with -Side home or -Side work to deploy a relay loop." }
Write-Host "Done. $count skill(s) deployed."
