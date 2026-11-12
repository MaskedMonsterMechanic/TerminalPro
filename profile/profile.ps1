# Terminal Pro profile
# Loaded by the Terminal profiles, so nothing is written to Documents\ and no
# system-wide profile is changed. Works in PowerShell 7 and Windows PowerShell 5.1.

# --- Where we live ---------------------------------------------------------------
$global:TerminalProHome    = Split-Path $PSScriptRoot -Parent
$global:TerminalProProfile = $PSCommandPath

# Make modules saved in our folder visible. This only affects the current session.
$ourModules = Join-Path $TerminalProHome 'modules'
if ((Test-Path $ourModules) -and (($env:PSModulePath -split ';') -notcontains $ourModules)) {
    $env:PSModulePath = "$ourModules;$env:PSModulePath"
}

# --- Settings you may want to change -----------------------------------------------
$global:TerminalProPromptName = 'PaulShell'

# What the start page shows under the header (commands that are not installed are skipped).
# Change, add or remove names. Type  home  to see the start page again.
$global:TerminalProStartInfo = 'Get-PCInfo', 'Get-NetIPAdapter', 'Get-DiskStorage'

# --- Console behaviour -------------------------------------------------------------
if (Get-Module PSReadLine) {
    Set-PSReadLineOption -BellStyle None

    # Inline predictions need PSReadLine 2.2 or newer (PowerShell 7).
    if ((Get-Module PSReadLine).Version -ge [version]'2.2.0') {
        try { Set-PSReadLineOption -PredictionSource HistoryAndPlugin -PredictionViewStyle ListView } catch { }
    }
}

# --- Aliases -----------------------------------------------------------------------
# Note: the old alias "gh" for Get-Help is now "hlp", because "gh" is the GitHub CLI.
Set-Alias hlp  Get-Help        -Option AllScope -Scope Global
Set-Alias tp   Test-Path       -Option AllScope -Scope Global
Set-Alias his  Get-History     -Option AllScope -Scope Global
Set-Alias ihis Invoke-History  -Option AllScope -Scope Global

# Reload this profile.
function global:posh { . $global:TerminalProProfile }

# --- Modules (only if they were installed) -----------------------------------------
foreach ($name in 'TerminalPro.Core', 'AdminTools', 'posh-git') {
    Import-Module $name -ErrorAction SilentlyContinue
}

# Smarter predictions (needs PowerShell 7.2 or newer and the module in modules.psd1). Silent if it is not there.
if ($PSVersionTable.PSVersion -ge [version]'7.2') {
    Import-Module CompletionPredictor -ErrorAction SilentlyContinue
}

# --- Prompt ------------------------------------------------------------------------
$global:TerminalProIsAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

function global:Prompt {
    if ($global:TerminalProIsAdmin) { "$($global:TerminalProPromptName)Admin > " }
    else { "$($global:TerminalProPromptName) > " }
}

# --- Start page --------------------------------------------------------------------
# "home" (Show-StartPage) shows this page again from anywhere. Every module page ends with a "home" line.
Set-Location ([Environment]::GetFolderPath('MyDocuments'))
if (Get-Command Show-StartPage -ErrorAction SilentlyContinue) {
    Show-StartPage
}
else {
    # Plain version, used when the TerminalPro.Core module is not installed.
    try { Clear-Host } catch { }   # fails harmlessly when there is no real console
    Write-Host "PowerShell Version: $($PSVersionTable.PSVersion)"
    ''
    Get-Date -Format g
    (Get-Location).Path
}