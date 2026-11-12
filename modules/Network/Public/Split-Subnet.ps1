function Split-Subnet {
<#
.SYNOPSIS
    Cuts a network into equal subnets: by how many you want, how many hosts each needs, or the new prefix.

.DESCRIPTION
    Use exactly one of -Count, -Hosts or -NewPrefix.
    -Count rounds up to a power of two (5 subnets gives 8, because subnets come in powers of two).
    For different sizes in one network use Get-VlsmPlan.

.PARAMETER Network
    The network to cut up, as address/prefix.

.PARAMETER Count
    How many subnets you want (at least).

.PARAMETER Hosts
    How many usable hosts each subnet needs (at least).

.PARAMETER NewPrefix
    The prefix length every subnet should get.

.EXAMPLE
    Split-Subnet 192.168.0.0/24 -Count 4

.EXAMPLE
    Split-Subnet 10.0.0.0/16 -Hosts 500
#>
    [CmdletBinding(DefaultParameterSetName = 'Count')]
    param(
        [Parameter(Mandatory, Position = 0)]
        [string]$Network,

        [Parameter(Mandatory, ParameterSetName = 'Count', Position = 1)]
        [ValidateRange(1, 65536)]
        [int]$Count,

        [Parameter(Mandatory, ParameterSetName = 'Hosts')]
        [ValidateRange(1, 16777214)]
        [int]$Hosts,

        [Parameter(Mandatory, ParameterSetName = 'Prefix')]
        [ValidateRange(1, 32)]
        [int]$NewPrefix
    )

    $net  = Split-NetworkText $Network
    $mask = Get-NetMaskInt $net.Prefix
    $base = $net.Address -band $mask

    switch ($PSCmdlet.ParameterSetName) {
        'Count' {
            $bits = 0
            while (([int64]1 -shl $bits) -lt $Count) { $bits++ }
            if ($Count -ne ([int64]1 -shl $bits)) { Write-Warning "Subnets come in powers of two, so $Count becomes $([int64]1 -shl $bits)." }
            $newPrefix = $net.Prefix + $bits
        }
        'Hosts' {
            $newPrefix = 32 - (Get-NetHostBits $Hosts)
        }
        'Prefix' {
            $newPrefix = $NewPrefix
        }
    }

    if ($newPrefix -gt 32) { throw "A /$($net.Prefix) network is too small to give that many subnets." }
    if ($newPrefix -lt $net.Prefix) { throw "Each subnet needs a /$newPrefix, which is bigger than the network you gave (/$($net.Prefix))." }
    if ($newPrefix -eq $net.Prefix) { Write-Warning "That is the whole network: one subnet of /$newPrefix." }
    if (($newPrefix - $net.Prefix) -gt 16) { throw 'That would make more than 65,536 subnets. Use fewer or a longer network prefix.' }

    $size   = [int64]1 -shl (32 - $newPrefix)
    $number = [int64]1 -shl ($newPrefix - $net.Prefix)

    for ($i = 0; $i -lt $number; $i++) {
        $calc = New-NetCalcObject -Address ($base + $i * $size) -Prefix $newPrefix
        [pscustomobject]@{
            PSTypeName  = 'TerminalPro.Subnet'
            Subnet      = $i + 1
            Network     = $calc.Cidr
            Mask        = $calc.Mask
            FirstHost   = $calc.FirstHost
            LastHost    = $calc.LastHost
            Broadcast   = $calc.Broadcast
            UsableHosts = $calc.UsableHosts
        }
    }
}
