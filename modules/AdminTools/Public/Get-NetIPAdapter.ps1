function Get-NetIPAdapter {
<#
.SYNOPSIS
    Shows each network adapter with its IP address, gateway and DNS servers.

.DESCRIPTION
    Returns one object per adapter address. Read-only.
    By default only adapters that are Up are shown, without VMware and VirtualBox host adapters.

.PARAMETER All
    Show every adapter, also the ones that are down or virtual.

.PARAMETER IPv6
    Also show the IPv6 addresses.

.EXAMPLE
    Get-NetIPAdapter

.EXAMPLE
    Get-NetIPAdapter -All -IPv6 | Format-List
#>
    [CmdletBinding()]
    param(
        [switch]$All,
        [switch]$IPv6
    )

    $adapters = @(Get-NetAdapter -ErrorAction Stop)
    if (-not $All) {
        $adapters = @($adapters | Where-Object { $_.Status -eq 'Up' -and $_.InterfaceDescription -notmatch 'VMware|VirtualBox' })
    }

    $families  = @('IPv4')
    if ($IPv6) { $families = @('IPv4', 'IPv6') }

    # One call each, instead of one call per adapter.
    $addresses = @(Get-NetIPAddress -ErrorAction SilentlyContinue)

    # Some commands give the address family as a number (2 or 23), some as a name. Always use the name.
    $familyName = { param($f) if ("$f" -eq '2' -or "$f" -eq 'IPv4') { 'IPv4' } elseif ("$f" -eq '23' -or "$f" -eq 'IPv6') { 'IPv6' } else { "$f" } }

    $dns = @{}
    foreach ($d in Get-DnsClientServerAddress -ErrorAction SilentlyContinue) {
        $dns["$($d.InterfaceIndex)/$(& $familyName $d.AddressFamily)"] = @($d.ServerAddresses)
    }

    $gateway = @{}
    foreach ($prefix in '0.0.0.0/0', '::/0') {
        foreach ($r in Get-NetRoute -DestinationPrefix $prefix -ErrorAction SilentlyContinue) {
            $gateway["$($r.InterfaceIndex)/$(& $familyName $r.AddressFamily)"] = [string]$r.NextHop
        }
    }

    foreach ($a in $adapters | Sort-Object Name) {
        foreach ($family in $families) {
            $mine = @($addresses | Where-Object { $_.InterfaceIndex -eq $a.InterfaceIndex -and "$($_.AddressFamily)" -eq $family })

            # An adapter with no address still gets one row when everything is shown.
            if (-not $mine) {
                if (-not ($All -and $family -eq 'IPv4')) { continue }
                $mine = @($null)
            }

            foreach ($ip in $mine) {
                $key = "$($a.InterfaceIndex)/$family"
                [pscustomobject]@{
                    PSTypeName   = 'TerminalPro.NetIPAdapter'
                    Adapter      = $a.Name
                    Family       = $family
                    IPAddress    = if ($ip) { [string]$ip.IPAddress } else { $null }
                    PrefixLength = if ($ip) { [int]$ip.PrefixLength } else { $null }
                    Type         = if ($ip) { [string]$ip.Type } else { $null }
                    Gateway      = $gateway[$key]
                    DnsServers   = @($dns[$key])
                    Description  = $a.InterfaceDescription
                    Status       = [string]$a.Status
                    Speed        = $a.LinkSpeed
                    MediaType    = $a.PhysicalMediaType
                }
            }
        }
    }
}
