<#
.SYNOPSIS
    Removes Terminal Pro and puts your original Windows Terminal settings back.

.DESCRIPTION
    Reads install.json (written by install.ps1) so it only ever deletes what the
    installer created. If you changed the Terminal settings after installing,
    nothing is overwritten unless you add -Force.

    Use -WhatIf to see every step without doing anything.

.PARAMETER InstallPath
    The Terminal Pro folder. Default: %LOCALAPPDATA%\TerminalPro

.PARAMETER Force
    Restore the original settings even if the settings file changed since install.

.EXAMPLE
    & "$env:LOCALAPPDATA\TerminalPro\uninstall.ps1" -WhatIf
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [string]$InstallPath = (Join-Path $env:LOCALAPPDATA 'TerminalPro'),
    [switch]$Force,
    [switch]$FromTemp
)

$ErrorActionPreference = 'Stop'
$InstallPath = [IO.Path]::GetFullPath($InstallPath).TrimEnd('\')

# This script lives inside the folder it deletes. Run a copy from TEMP instead.
if (-not $FromTemp -and $PSCommandPath -and $PSCommandPath.StartsWith($InstallPath + '\', [StringComparison]::OrdinalIgnoreCase)) {
    $tmp = Join-Path ([IO.Path]::GetTempPath()) "TerminalPro-uninstall-$PID.ps1"
    # -WhatIf:$false on purpose: this only copies the script itself into TEMP, even in a dry run.
    Copy-Item $PSCommandPath $tmp -Force -WhatIf:$false
    try { & $tmp -InstallPath $InstallPath -FromTemp -Force:$Force -WhatIf:$WhatIfPreference }
    finally { Remove-Item $tmp -Force -ErrorAction SilentlyContinue -WhatIf:$false }
    return
}

function Invoke-Step {
    param([string]$Text, [scriptblock]$Action)
    if ($WhatIfPreference) {
        Write-Host "[would] $Text" -ForegroundColor Yellow
        return
    }
    Write-Host "[ .. ] $Text" -ForegroundColor Cyan
    & $Action
}

# ------------------------------------------------------------------ preflight (read-only)
Write-Host 'Terminal Pro uninstall' -ForegroundColor Cyan
$manifestPath = Join-Path $InstallPath 'install.json'
if (-not (Test-Path $manifestPath)) {
    throw "No Terminal Pro install found at '$InstallPath' (install.json is missing). Nothing was changed."
}
$m = Get-Content $manifestPath -Raw | ConvertFrom-Json
if ($m.installPath -ne $InstallPath) {
    throw "install.json says this install belongs to '$($m.installPath)', not '$InstallPath'. Nothing was changed."
}

$settingsPath = $m.settingsPath
$settingsNow  = if (Test-Path $settingsPath) { (Get-FileHash $settingsPath -Algorithm SHA256).Hash } else { $null }
$settingsChanged = $settingsNow -and ($settingsNow -ne $m.settingsHash)
if ($settingsChanged -and -not $Force) {
    throw "The Terminal settings file changed since Terminal Pro wrote it:`n  $settingsPath`nNothing was changed. Back it up if you want to keep your edits, then run again with -Force."
}

Write-Host "  Install folder   : $InstallPath"
Write-Host "  Terminal settings: $settingsPath"
Write-Host ''

# ------------------------------------------------------------------ 1. settings
if ($m.settingsExistedBefore) {
    Invoke-Step 'Put your original Terminal settings back' {
        if (-not $m.backupPath -or -not (Test-Path $m.backupPath)) {
            throw "The settings backup is missing ($($m.backupPath)). Nothing was changed."
        }
        Copy-Item $m.backupPath $settingsPath -Force
    }
}
else {
    Invoke-Step 'Remove the settings file Terminal Pro created (Terminal makes a fresh default)' {
        if (Test-Path $settingsPath) { Remove-Item $settingsPath -Force }
    }
}

# ------------------------------------------------------------------ 2. the folder
Invoke-Step 'Delete the Terminal Pro folder' {
    try {
        Remove-Item $InstallPath -Recurse -Force
    }
    catch {
        throw "Could not delete '$InstallPath'. Close any Terminal tab that uses PowerShell from Terminal Pro and run this again. ($($_.Exception.Message))"
    }
}

Write-Host ''
if ($WhatIfPreference) { Write-Host 'Dry run finished. Nothing was changed.' -ForegroundColor Yellow }
else { Write-Host 'Terminal Pro is removed. Your Terminal settings are back as they were.' -ForegroundColor Green }
