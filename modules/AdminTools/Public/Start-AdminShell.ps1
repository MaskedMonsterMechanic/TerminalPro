function Start-AdminShell {
<#
.SYNOPSIS
    Opens an elevated (administrator) shell in a new window. Windows asks you to confirm.

.DESCRIPTION
    By default it opens the same PowerShell you are using now (so PowerShell 7 gives PowerShell 7).
    Use -InTerminal to open Windows Terminal as administrator instead (your default profile).

.PARAMETER InTerminal
    Open Windows Terminal as administrator.

.PARAMETER WindowsPowerShell
    Open Windows PowerShell 5.1 instead of the shell you are in.

.EXAMPLE
    Start-AdminShell -WhatIf
#>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [switch]$InTerminal,
        [switch]$WindowsPowerShell
    )

    if ($InTerminal) {
        $wt = Get-Command wt.exe -ErrorAction SilentlyContinue
        if (-not $wt) { throw 'Windows Terminal (wt.exe) was not found on this computer.' }
        $file = $wt.Source
    }
    elseif ($WindowsPowerShell) {
        $file = Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe'
    }
    else {
        $file = (Get-Process -Id $PID).Path
    }

    if ($PSCmdlet.ShouldProcess($file, 'Start as administrator')) {
        try { Start-Process -FilePath $file -Verb RunAs }
        catch { Write-Warning "Not started: $($_.Exception.Message)" }   # for example when you press No at the prompt
    }
}
