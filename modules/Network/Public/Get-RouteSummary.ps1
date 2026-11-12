function Get-RouteSummary {
<#
.SYNOPSIS
    Finds the one route (summary / supernet) that covers a list of networks, and says if it is exact.

.DESCRIPTION
    Route summarization: the longest prefix that still covers every network you give.
    Exact = $true means the summary covers those networks and nothing else.
    Exact = $false means it also covers addresses that are not in your list (be careful: that traffic
    would be sent your way too).

.PARAMETER Network
    Two or more networks as address/prefix.

.EXAMPLE
    Get-RouteSummary 192.168.0.0/24, 192.168.1.0/24, 192.168.2.0/24, 192.168.3.0/24

.EXAMPLE
    Get-RouteSummary 10.1.0.0/24, 10.1.5.0/24
#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [string[]]$Network
    )

    $ranges = foreach ($n in $Network) {
        $parsed = Split-NetworkText $n
        $mask   = Get-NetMaskInt $parsed.Prefix
        $start  = $parsed.Address -band $mask
        [pscustomobject]@{ Start = $start; End = $start + ([int64]1 -shl (32 - $parsed.Prefix)) - 1 }
    }
    $ranges = @($ranges | Sort-Object Start)

    $lowest  = $ranges[0].Start
    $highest = ($ranges | Measure-Object End -Maximum).Maximum

    # the longest prefix where the first and the last address share the same network
    $prefix = 32
    while ($prefix -gt 0 -and (($lowest -band (Get-NetMaskInt $prefix)) -ne ($highest -band (Get-NetMaskInt $prefix)))) { $prefix-- }
    $summaryNet = $lowest -band (Get-NetMaskInt $prefix)
    $covered    = [int64]1 -shl (32 - $prefix)

    # how many addresses the given networks really hold (overlaps counted once)
    $inList = [int64]0
    $currentStart = $null; $currentEnd = $null
    foreach ($r in $ranges) {
        if ($null -eq $currentStart) { $currentStart = $r.Start; $currentEnd = $r.End; continue }
        if ($r.Start -le ($currentEnd + 1)) { if ($r.End -gt $currentEnd) { $currentEnd = $r.End } }
        else { $inList += $currentEnd - $currentStart + 1; $currentStart = $r.Start; $currentEnd = $r.End }
    }
    $inList += $currentEnd - $currentStart + 1

    [pscustomobject]@{
        PSTypeName     = 'TerminalPro.RouteSummary'
        Summary        = '{0}/{1}' -f (ConvertFrom-NetInt $summaryNet), $prefix
        Mask           = ConvertFrom-NetInt (Get-NetMaskInt $prefix)
        Wildcard       = ConvertFrom-NetInt ((-bnot (Get-NetMaskInt $prefix)) -band 4294967295)
        Exact          = ($covered -eq $inList)
        Networks       = $ranges.Count
        AddressesInList = $inList
        AddressesCovered = $covered
        Extra          = $covered - $inList
    }
}
