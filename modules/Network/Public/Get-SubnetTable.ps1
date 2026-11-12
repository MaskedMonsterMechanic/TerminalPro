function Get-SubnetTable {
<#
.SYNOPSIS
    The subnet cheat table, worked out by the computer so it is never wrong.

.DESCRIPTION
    IPv4: for every prefix length the mask, wildcard, number of addresses, usable hosts, and how many
    subnets of that size fit in a class A, B or C network.
    IPv6: for the usual prefix lengths, how many subnets of each common size fit inside.

.PARAMETER IPv6
    Show the IPv6 table instead.

.EXAMPLE
    Get-SubnetTable

.EXAMPLE
    Get-SubnetTable | Where-Object UsableHosts -ge 100 | Select-Object -Last 1
#>
    [CmdletBinding()]
    param(
        [switch]$IPv6
    )

    if ($IPv6) {
        foreach ($p in 32, 36, 40, 44, 48, 52, 56, 60, 64) {
            $row = [ordered]@{ PSTypeName = 'TerminalPro.SubnetTable6'; Prefix = "/$p"; Addresses = (Format-Power2 (128 - $p)) }
            foreach ($child in 48, 52, 56, 60, 64) {
                $row["Sub$child"] = if ($child -ge $p) { Format-Power2 ($child - $p) } else { $null }
            }
            [pscustomobject]$row
        }
        return
    }

    foreach ($p in 8..32) {
        $mask  = Get-NetMaskInt $p
        $total = [int64]1 -shl (32 - $p)
        if     ($p -le 30) { $usable = $total - 2 }
        elseif ($p -eq 31) { $usable = 2 }
        else               { $usable = 1 }

        [pscustomobject]@{
            PSTypeName     = 'TerminalPro.SubnetTable'
            Prefix         = "/$p"
            Mask           = ConvertFrom-NetInt $mask
            Wildcard       = ConvertFrom-NetInt ((-bnot $mask) -band 4294967295)
            Addresses      = $total
            UsableHosts    = $usable
            ClassASubnets  = [int64]1 -shl ($p - 8)
            ClassBSubnets  = if ($p -ge 16) { [int64]1 -shl ($p - 16) } else { $null }
            ClassCSubnets  = if ($p -ge 24) { [int64]1 -shl ($p - 24) } else { $null }
        }
    }
}
