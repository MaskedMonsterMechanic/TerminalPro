function Set-IpDnsRename {
<#
.SYNOPSIS
    Sets the IP address, the DNS servers and the computer name of THIS machine in one go.

.DESCRIPTION
    Run it with no parameters and it asks the questions one at a time. Press Enter to skip a step.
    Or give the values as parameters.

    This changes the network settings of the machine and renames it, so it asks you to confirm.
    Use -WhatIf to only see what it would do. A real run needs an elevated (administrator) prompt.
    If the interface already has an address, remove it first (Remove-NetIPAddress).
    A new computer name takes effect after a restart.

.PARAMETER InterfaceAlias
    The network interface, for example Ethernet. Get-NetAdapter lists them.

.PARAMETER IPv4Address
    The IPv4 address, for example 192.0.2.10. Needs -PrefixLength.

.PARAMETER PrefixLength
    The IPv4 prefix length, for example 24 (255.255.255.0).

.PARAMETER Gateway
    The IPv4 default gateway.

.PARAMETER IPv6Address
    An IPv6 address. Optional.

.PARAMETER IPv6PrefixLength
    The IPv6 prefix length. Default 64.

.PARAMETER IPv6Gateway
    The IPv6 default gateway. Optional.

.PARAMETER DnsServer
    One or more DNS server addresses (primary first).

.PARAMETER ComputerName
    The new name of the machine (up to 15 letters, digits and hyphens).

.EXAMPLE
    Set-IpDnsRename -InterfaceAlias Ethernet -IPv4Address 192.0.2.10 -PrefixLength 24 -Gateway 192.0.2.1 -DnsServer 192.0.2.53 -ComputerName SRV01 -WhatIf

.EXAMPLE
    Set-IpDnsRename
#>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param(
        [string]$InterfaceAlias,
        [string]$IPv4Address,
        [ValidateRange(1, 32)][int]$PrefixLength,
        [string]$Gateway,
        [string]$IPv6Address,
        [ValidateRange(1, 128)][int]$IPv6PrefixLength = 64,
        [string]$IPv6Gateway,
        [string[]]$DnsServer,
        [string]$ComputerName
    )

    function Assert-Address([string]$Value, [string]$Version, [string]$Label) {
        $ip = $null
        $ok = [System.Net.IPAddress]::TryParse($Value, [ref]$ip)
        if ($ok -and $Version -eq 4) { $ok = ($Value -match '^\d{1,3}(\.\d{1,3}){3}$') -and $ip.AddressFamily -eq 'InterNetwork' }
        if ($ok -and $Version -eq 6) { $ok = ($ip.AddressFamily -eq 'InterNetworkV6') }
        if (-not $ok) { throw "$Label '$Value' is not a valid IPv$Version address." }
    }

    $settingNames = $PSBoundParameters.Keys | Where-Object { $_ -notin 'WhatIf', 'Confirm', 'Verbose', 'Debug' }
    $havePrefix = $PSBoundParameters.ContainsKey('PrefixLength')

    # A real run changes the machine, so check for administrator rights before asking anything.
    if (-not $WhatIfPreference) {
        $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
        if (-not $isAdmin) { throw 'Run this from an elevated (administrator) prompt, or add -WhatIf to only see the plan.' }
    }

    # No parameters: ask, one question at a time. An empty answer skips that step.
    if (@($settingNames).Count -eq 0) {
        if (Get-Command Get-NetAdapter -ErrorAction SilentlyContinue) {
            Get-NetAdapter | Format-Table Name, InterfaceDescription, Status -AutoSize | Out-Host
        }
        $InterfaceAlias = Read-Host 'Interface (name from the list above)'
        $IPv4Address    = Read-Host 'IPv4 address (empty = skip)'
        if ($IPv4Address) {
            $PrefixLength = [int](Read-Host 'IPv4 prefix length (for example 24)')
            $havePrefix = $true
            $Gateway = Read-Host 'IPv4 gateway (empty = none)'
        }
        $IPv6Address = Read-Host 'IPv6 address (empty = skip)'
        if ($IPv6Address) {
            $answer = Read-Host 'IPv6 prefix length (empty = 64)'
            if ($answer) { $IPv6PrefixLength = [int]$answer }
            $IPv6Gateway = Read-Host 'IPv6 gateway (empty = none)'
        }
        $primary   = Read-Host 'Primary DNS server (empty = skip)'
        $secondary = if ($primary) { Read-Host 'Secondary DNS server (empty = none)' }
        $DnsServer = @($primary, $secondary) | Where-Object { $_ }
        $ComputerName = Read-Host 'New computer name (empty = skip)'
    }

    # Check everything before changing anything.
    if (($IPv4Address -or $IPv6Address -or $DnsServer) -and -not $InterfaceAlias) { throw 'Give the interface (-InterfaceAlias) for the address and DNS settings.' }
    if ($IPv4Address) {
        Assert-Address $IPv4Address 4 'IPv4 address'
        if (-not $havePrefix) { throw 'Give the IPv4 prefix length (-PrefixLength), for example 24.' }
        if ($Gateway) { Assert-Address $Gateway 4 'IPv4 gateway' }
    }
    if ($IPv6Address) {
        Assert-Address $IPv6Address 6 'IPv6 address'
        if ($IPv6Gateway) { Assert-Address $IPv6Gateway 6 'IPv6 gateway' }
    }
    foreach ($d in @($DnsServer)) { if ($d) { $isV6 = $d.Contains(':'); Assert-Address $d $(if ($isV6) { 6 } else { 4 }) 'DNS server' } }
    if ($ComputerName -and $ComputerName -notmatch '^[A-Za-z0-9-]{1,15}$') {
        throw "Computer name '$ComputerName' is not valid. Use up to 15 letters, digits and hyphens."
    }
    if (-not ($IPv4Address -or $IPv6Address -or $DnsServer -or $ComputerName)) {
        Write-Host 'Nothing to do.'
        return
    }

    # The changes. Each one asks first.
    if ($IPv4Address) {
        $what = "Set IPv4 address $IPv4Address/$PrefixLength" + $(if ($Gateway) { " with gateway $Gateway" } else { '' })
        if ($PSCmdlet.ShouldProcess($InterfaceAlias, $what)) {
            $p = @{ InterfaceAlias = $InterfaceAlias; IPAddress = $IPv4Address; PrefixLength = $PrefixLength; AddressFamily = 'IPv4' }
            if ($Gateway) { $p.DefaultGateway = $Gateway }
            New-NetIPAddress @p | Out-Null
        }
    }
    if ($IPv6Address) {
        $what = "Set IPv6 address $IPv6Address/$IPv6PrefixLength" + $(if ($IPv6Gateway) { " with gateway $IPv6Gateway" } else { '' })
        if ($PSCmdlet.ShouldProcess($InterfaceAlias, $what)) {
            $p = @{ InterfaceAlias = $InterfaceAlias; IPAddress = $IPv6Address; PrefixLength = $IPv6PrefixLength; AddressFamily = 'IPv6' }
            if ($IPv6Gateway) { $p.DefaultGateway = $IPv6Gateway }
            New-NetIPAddress @p | Out-Null
        }
    }
    if ($DnsServer) {
        if ($PSCmdlet.ShouldProcess($InterfaceAlias, "Set DNS servers to $(@($DnsServer) -join ', ')")) {
            Set-DnsClientServerAddress -InterfaceAlias $InterfaceAlias -ServerAddresses @($DnsServer)
        }
    }
    if ($ComputerName) {
        if ($PSCmdlet.ShouldProcess($env:COMPUTERNAME, "Rename the computer to $ComputerName (needs a restart)")) {
            Rename-Computer -NewName $ComputerName
            Write-Host "The computer is renamed to $ComputerName. Restart it for the new name to take effect."
        }
    }
}
