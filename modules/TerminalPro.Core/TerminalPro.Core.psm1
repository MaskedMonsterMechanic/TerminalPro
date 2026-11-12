# TerminalPro.Core
# Shared engine for the Terminal Pro cheat-sheet modules (Unix, Network, ...).
# Own implementation. The ^c colour-code syntax follows the one documented by Brian Clark's Write-Color (2017).

$script:ModuleRoot = $PSScriptRoot

# One place for the colours. Change them here (or set NO_COLOR=1 to switch colours off).
# $null means "the terminal's normal text colour".
$script:Colors = @{
    Topic  = 'DarkGreen'
    Prompt = 'Red'
    Input  = $null
    Output = 'Blue'
    Time   = 'DarkGray'
    Rule   = $null
}

foreach ($folder in 'Private', 'Public') {
    Get-ChildItem -Path (Join-Path $PSScriptRoot $folder) -Filter '*.ps1' -ErrorAction SilentlyContinue |
        ForEach-Object { . $_.FullName }
}

Set-Alias -Name home -Value Show-StartPage
