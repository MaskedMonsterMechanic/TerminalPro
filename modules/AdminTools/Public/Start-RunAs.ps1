function Start-RunAs {
<#
.SYNOPSIS
    Runs a program as another user. You type the password in the window, never in a script.

.DESCRIPTION
    A friendly front for runas.exe. Without parameters it asks for the program, the user and the domain.
    With -NetOnly the other user's rights are used on the NETWORK only, and the program itself runs as you
    (handy for tools that must reach a domain from a computer that is not in it).

.PARAMETER Program
    The program, with its own arguments if it needs them.

.PARAMETER User
    The user: name, DOMAIN\name or name@domain.

.PARAMETER Domain
    The domain, when the user is given as a plain name.

.EXAMPLE
    Start-RunAs -Program mmc.exe -User admin01 -Domain CONTOSO -NetOnly

.EXAMPLE
    Start-RunAs -Program notepad.exe -User admin01 -WhatIf
#>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [string]$Program,
        [string]$User,
        [string]$Domain,
        [switch]$NetOnly
    )

    if (-not $Program) { $Program = Read-Host 'Which program would you like to run' }
    if (-not $User)    { $User    = Read-Host 'Which user would you like to run as (name, DOMAIN\name or name@domain)' }
    if (-not $Domain -and $User -notmatch '[\\@]') { $Domain = Read-Host 'Which domain (leave empty for this computer)' }

    $argumentText = Get-RunAsArgument -Program $Program -User $User -Domain $Domain -NetOnly:$NetOnly
    $runas = Join-Path $env:SystemRoot 'System32\runas.exe'

    if ($PSCmdlet.ShouldProcess($Program, "runas $argumentText")) {
        Start-Process -FilePath $runas -ArgumentList $argumentText -NoNewWindow -Wait
    }
}
