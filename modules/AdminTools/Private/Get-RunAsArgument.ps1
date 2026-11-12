function Get-RunAsArgument {
<#
.SYNOPSIS
    Builds the argument text for runas.exe (not exported). Changes nothing; used by Start-RunAs and the tests.
#>
    [CmdletBinding()]
    param(
        [string]$Program,
        [string]$User,
        [string]$Domain,
        [switch]$NetOnly
    )

    if ([string]::IsNullOrWhiteSpace($Program)) { throw 'Say which program to run.' }
    if ([string]::IsNullOrWhiteSpace($User))    { throw 'Say which user to run as.' }
    if ("$User$Domain" -match '[\s"/]') { throw 'The user and domain cannot contain spaces, quotes or slashes.' }

    # name  ->  DOMAIN\name  (or name@DOMAIN for -NetOnly);  DOMAIN\name and name@DOMAIN are used as they are
    $account = $User
    if ($Domain -and $User -notmatch '[\\@]') {
        if ($NetOnly) { $account = "$User@$Domain" } else { $account = "$Domain\$User" }
    }

    # runas wants the whole program (with its own arguments) as ONE quoted text, inner quotes escaped.
    $quoted = '"' + ($Program.Trim() -replace '"', '\"') + '"'

    $parts = @()
    if ($NetOnly) { $parts += '/netonly' }
    $parts += "/user:$account"
    $parts += $quoted
    $parts -join ' '
}
