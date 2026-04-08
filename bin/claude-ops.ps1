# claude-ops.ps1 — PowerShell wrapper for Windows
# Delegates to the bash script via Git Bash

$KitRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$BashScript = Join-Path $KitRoot "bin" "claude-ops"

# Find Git Bash
$GitBash = $null
$PossiblePaths = @(
    "C:\Program Files\Git\bin\bash.exe",
    "C:\Program Files (x86)\Git\bin\bash.exe",
    (Get-Command bash -ErrorAction SilentlyContinue).Source
)

foreach ($p in $PossiblePaths) {
    if ($p -and (Test-Path $p)) {
        $GitBash = $p
        break
    }
}

if (-not $GitBash) {
    Write-Error "Git Bash not found. Install Git for Windows: https://git-scm.com/download/win"
    exit 1
}

# Convert Windows path to Unix-style for bash
$UnixScript = $BashScript -replace '\\', '/' -replace '^([A-Z]):', '/$1'

& $GitBash -c "$UnixScript $($args -join ' ')"
