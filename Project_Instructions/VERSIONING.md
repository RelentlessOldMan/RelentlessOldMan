# Versioning — RelentlessOldMan conventions

Point a Claude session at this file when setting up (or converting) a project's version
number. Every project uses the same date-based scheme. It replaces the old semver
`X.Y.Z` patch bumps; when a project still uses those, convert it on its next build.

---

## The scheme

```
YYYY.M.D.N        e.g. 2026.11.13.0
```

- **`YYYY.M.D`** is the date of the build, in local time on the machine doing the build.
- **`N`** is the build number for that day. It starts at **0** on the first build of a day
  and goes up by 1 for **every** build that day: `2026.11.13.0`, `2026.11.13.1`, `2026.11.13.2`, …
  The next day starts over at `.0`.
- **No leading zeros.** January 5 is `2026.1.5.0`, not `2026.01.05.0`. .NET, Python and
  semver all strip leading zeros anyway, so writing them anywhere would make the same
  version look different in different places. Compare versions as numbers, part by part,
  never as strings.
- **A build** is anything the build or release script produces that can be run or handed
  out: a local build, a test build, a release. Each one gets its own number, so any two
  builds you can tell apart have different versions.
- **Never reuse a number and never go backwards.** If the stored version's date is later
  than today (clock wrong, or a build on another machine in a different time zone), keep
  that date and bump `N` instead of starting a lower version.

---

## Where the version lives

One place per project, committed to git. That file is the counter: the build script reads
the last version from it, works out the next one, and writes it back.

| Project type | Single source of truth |
|---|---|
| Python single-file tool | `__version__ = "2026.11.13.0"` in the main `.py` |
| .NET | `<Version>2026.11.13.0</Version>` in `Directory.Build.props` (or the one `.csproj`) |
| Anything else | a `VERSION` file at the repo root holding just the version |

Everything else (exe file properties, plugin manifests, About boxes, `--version`, zip
names, release titles) is stamped from that one value at build time, never typed by hand.

Commit the bumped version with the work it built. If CI also builds, CI uses the committed
version as-is and does **not** bump it; only the build that a person (or Claude) runs bumps.

**Formats that only take three numbers** (npm `package.json`, other strict-semver fields):
write `YYYY.M.D-N`, e.g. `2026.11.13-0`. Semver compares the `-N` part numerically, so
the order still holds.

---

## Working out the next version

The build script does this before it builds:

```powershell
# $current = the version read from the source of truth, e.g. "2026.11.13.2" (or $null if none yet)
function Get-NextVersion([string]$current) {
    $today = Get-Date
    $todayKey = [int]$today.ToString('yyyyMMdd')
    if ($current -match '^(\d+)\.(\d+)\.(\d+)\.(\d+)$') {
        $y, $m, $d, $n = [int]$Matches[1], [int]$Matches[2], [int]$Matches[3], [int]$Matches[4]
        if ($y * 10000 + $m * 100 + $d -ge $todayKey) {      # same day (or a later date): bump N
            return "$y.$m.$d.$($n + 1)"
        }
    }
    return "$($today.Year).$($today.Month).$($today.Day).0"   # first build today (or no/old-style version)
}
```

An old-style `1.4.2` version doesn't match the pattern, so the first build after the
switch simply becomes today's `.0`. Date versions are always higher than the old ones
(2026 > 1), so updates still sort correctly.

---

## Tags and GitHub Releases

A release is just a build that gets published. Tag it with the same version and a `v`
prefix (the same form the existing release scripts use):

```powershell
git tag "v$ver"
git push origin "v$ver"
gh release create "v$ver" <artifacts> --title "<Name> v$ver"
```

Release scripts (`release.ps1`, `make-release.ps1`) call `Get-NextVersion` instead of
bumping a patch number, and drop any "explicit version" argument that could set a
lower or out-of-pattern version.

---

## Checklist

- [ ] One committed source of truth for the version (table above)
- [ ] The build script bumps it with `Get-NextVersion` on every build
- [ ] Every other place the version shows is stamped from it at build time
- [ ] CI builds don't bump
- [ ] Releases tagged `v<version>`, e.g. `v2026.11.13.0`
