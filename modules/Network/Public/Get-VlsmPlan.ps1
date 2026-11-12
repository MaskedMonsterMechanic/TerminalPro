function Get-VlsmPlan {
<#
.SYNOPSIS
    Variable Length Subnet Masking: gives each group of hosts the smallest subnet that fits, biggest first.

.DESCRIPTION
    You say how many hosts every subnet needs. The biggest is placed first at the start of the network,
    the next after it, and so on, so nothing overlaps and the gaps are as small as they can be.
    If it does not fit, you are told how many addresses are missing. Hosts means usable host addresses;
    every subnet is at least a /30 (a link between two routers needs 2).

.PARAMETER Network
    The network to divide, as address/prefix.

.PARAMETER Hosts
    The number of hosts each subnet needs, for example 100, 50, 20, 2, 2.

.PARAMETER Name
    Optional names, in the same order as -Hosts.

.EXAMPLE
    Get-VlsmPlan 192.168.10.0/24 -Hosts 100, 50, 20, 10 -Name Sales, Office, Lab, Servers

.EXAMPLE
    Get-VlsmPlan 10.0.0.0/24 -Hosts 60, 2, 2 | Format-Table
#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [string]$Network,

        [Parameter(Mandatory, Position = 1)]
        [ValidateRange(1, 16777214)]
        [int[]]$Hosts,

        [Parameter(Position = 2)]
        [string[]]$Name
    )

    $net  = Split-NetworkText $Network
    $mask = Get-NetMaskInt $net.Prefix
    $base = $net.Address -band $mask
    $end  = $base + ([int64]1 -shl (32 - $net.Prefix)) - 1

    if ($Name -and $Name.Count -ne $Hosts.Count) { throw "Give one name for each number of hosts ($($Hosts.Count) numbers, $($Name.Count) names)." }

    # Keep the order the user gave for equal sizes (Sort-Object is not stable on its own).
    $requests = for ($i = 0; $i -lt $Hosts.Count; $i++) {
        [pscustomobject]@{
            Index = $i
            Name  = if ($Name) { $Name[$i] } else { 'Subnet {0}' -f ($i + 1) }
            Hosts = $Hosts[$i]
            Bits  = Get-NetHostBits $Hosts[$i]
        }
    }
    $requests = $requests | Sort-Object @{ Expression = 'Bits'; Descending = $true }, Index

    $cursor = $base
    foreach ($r in $requests) {
        $size = [int64]1 -shl $r.Bits

        # start on a boundary that fits the size (it already is when the biggest go first)
        if ($cursor % $size -ne 0) { $cursor += $size - ($cursor % $size) }

        if (($cursor + $size - 1) -gt $end) {
            $needed = ($requests | ForEach-Object { [int64]1 -shl $_.Bits } | Measure-Object -Sum).Sum
            $have   = $end - $base + 1
            throw "It does not fit. '$($r.Name)' needs $size addresses but the network is full. In total the subnets need $needed addresses and a /$($net.Prefix) only has $have. Try a bigger network."
        }

        $calc = New-NetCalcObject -Address $cursor -Prefix (32 - $r.Bits)
        [pscustomobject]@{
            PSTypeName  = 'TerminalPro.VlsmPlan'
            Name        = $r.Name
            HostsNeeded = $r.Hosts
            Network     = $calc.Cidr
            Mask        = $calc.Mask
            FirstHost   = $calc.FirstHost
            LastHost    = $calc.LastHost
            Broadcast   = $calc.Broadcast
            UsableHosts = $calc.UsableHosts
            Spare       = $calc.UsableHosts - $r.Hosts
        }
        $cursor += $size
    }
}
