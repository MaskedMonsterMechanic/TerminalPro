function Get-OspfCost {
<#
.SYNOPSIS
    Works out the OSPF cost of each link, and of a whole path.

.DESCRIPTION
    cost of a link = reference bandwidth / link bandwidth, as a whole number (rounded down), at least 1.
    The default reference bandwidth is 100 Mbps. The cost of a path is the sum of the costs of the
    links the packet goes out of.

    Note: with the default reference of 100 Mbps, FastEthernet, Gigabit and 10 Gigabit all cost 1.
    Use -ReferenceBandwidth 10000 (the same as "auto-cost reference-bandwidth 10000") to tell them apart.

.PARAMETER Bandwidth
    Bandwidth of each link on the path, in kbps (the number from "bandwidth" on the interface).

.PARAMETER Link
    Link types instead of numbers: Ethernet, FastEthernet, GigabitEthernet, TenGigabitEthernet,
    Serial (or T1), E1. Short forms (fe, gig) work too.

.PARAMETER ReferenceBandwidth
    The reference bandwidth in Mbps. Default 100. Set it to the same value on every router.

.EXAMPLE
    Get-OspfCost -Link FastEthernet, Serial
    # Costs 1 and 64, total 65

.EXAMPLE
    Get-OspfCost -Link gig, fe -ReferenceBandwidth 10000
    # Costs 10 and 100, total 110

.EXAMPLE
    Get-OspfCost -Bandwidth 128
    # A 128 kbps serial link costs 781
#>
    [CmdletBinding(DefaultParameterSetName = 'Values')]
    param(
        [Parameter(Mandatory, ParameterSetName = 'Values', Position = 0)]
        [ValidateRange(1, [int]::MaxValue)]
        [int[]]$Bandwidth,

        [Parameter(Mandatory, ParameterSetName = 'Link', Position = 0)]
        [string[]]$Link,

        [ValidateRange(1, 4294967)]
        [int]$ReferenceBandwidth = 100
    )

    if ($PSCmdlet.ParameterSetName -eq 'Link') {
        $bw = @()
        foreach ($name in $Link) {
            try { $key = Resolve-NetLinkType $name }
            catch { $PSCmdlet.ThrowTerminatingError([System.Management.Automation.ErrorRecord]::new($_.Exception, 'BadLink', 'InvalidArgument', $name)) }
            $bw += $script:LinkDefaults[$key].Bandwidth
        }
    }
    else { $bw = $Bandwidth }

    $referenceKbps = [int64]$ReferenceBandwidth * 1000
    $costs = foreach ($b in $bw) {
        $c = [int64][math]::Floor($referenceKbps / $b)
        if ($c -lt 1) { 1 } elseif ($c -gt 65535) { 65535 } else { $c }
    }
    $costs = @($costs)

    [pscustomobject]@{
        PSTypeName         = 'TerminalPro.OspfCost'
        TotalCost          = [int64]($costs | Measure-Object -Sum).Sum
        LinkCosts          = $costs -join ' + '
        Links              = $costs.Count
        ReferenceBandwidth = "$ReferenceBandwidth Mbps"
    }
}
