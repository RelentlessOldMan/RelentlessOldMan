---
name: start-remote-session
description: Launch a Claude Code Remote Control session in a target directory from inside an existing session (Windows), for when the user is remote and no session is running there yet.
---

# Start a remote-control Claude session

Use when the user is remote (driving via the app) and needs a NEW Claude Code
session started in some directory so it shows up in the app's Remote Control list.
They can't open a terminal themselves — you launch it for them.

## The one command that works

```powershell
Start-Process -FilePath "cmd.exe" `
  -ArgumentList '/k','claude --remote-control "<SessionName>"' `
  -WorkingDirectory "<TargetDir>" `
  -WindowStyle Normal
```

`--remote-control [name]` starts an *interactive* session with Remote Control on.
`Start-Process cmd.exe` spawns an independent process that gets its OWN console,
which gives that interactive session the TTY it needs.

## Verify it launched (don't assume)

```powershell
Start-Sleep -Seconds 8
Get-Process | ? { $_.ProcessName -match 'claude' -and $_.StartTime -gt (Get-Date).AddMinutes(-2) } |
  Select Id,ProcessName,StartTime
```
A fresh `claude` process should appear and persist. Confirm the flag with
`(Get-CimInstance Win32_Process -Filter "ProcessId=<PID>").CommandLine`.

## Why the obvious approaches fail

- **Bash/background launch (`run_in_background`) has NO TTY** → `claude` degrades to
  `--print` mode and dies with "Input must be provided … when using --print".
  The new console from `Start-Process` is the whole trick.
- **Don't chain `cd /d "<dir>" && claude` inside `cmd /k`** — escaping `&&` as
  `^&^&` makes cmd treat it as a *literal* `&&`, so claude never runs. Use
  `-WorkingDirectory` and pass args as an array (`'/k','claude …'`) — no `cd`, no `&&`.

## If it doesn't appear in the app

The process running + correct command line means the CLI side is fine; the
remaining gate is Remote Control being enabled/authorized on the account. To stop
it: `Stop-Process -Id <PID>`.
