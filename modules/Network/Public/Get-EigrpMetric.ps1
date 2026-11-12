function Get-EigrpMetric {
<#
.SYNOPSIS
    Works out the classic EIGRP metric of a path, and shows the steps.

.DESCRIPTION
    metric = 256 x ( K1 x BW + K2 x BW / (256 - load) + K3 x delay )  x  ( K5 / (reliability + K4) )
    where BW    = 10,000,000 / the LOWEST bandwidth on the path (kbps), whole number
          delay = the SUM of the delays on the path, in tens of microseconds
    The last bracket is left out when K5 is 0 (the default).
    With the default K values (K1 = 1, K3 = 1, the rest 0) this is: 256 x (BW + delay).

    Give either the numbers of each link (-Bandwidth and -Delay), or the link types (-Link).

.PARAMETER Bandwidth
    Bandwidth of each link on the path, in kbps. The lowest one is used.

.PARAMETER Delay
    Delay of each link on the path, in microseconds. They are added up.

.PARAMETER Link
    Link types instead of numbers: Ethernet, FastEthernet, GigabitEthernet, TenGigabitEthernet,
    Serial (or T1), E1. Short forms (fe, gig) work too.

.PARAMETER Load
    Load of the worst link, 1 to 255 (only matters if K2 is not 0). Default 1.

.PARAMETER Reliability
    Reliability of the worst link, 1 to 255 (only matters if K5 is not 0). Default 255.

.PARAMETER K1
    Weight of bandwidth. Default 1.
.PARAMETER K2
    Weight of load. Default 0.
.PARAMETER K3
    Weight of delay. Default 1.
.PARAMETER K4
    Weight of reliability (part 1). Default 0.
.PARAMETER K5
    Weight of reliability (part 2). Default 0.

.EXAMPLE
    Get-EigrpMetric -Link FastEthernet
    # 28160: the metric of one FastEthernet link

.EXAMPLE
    Get-EigrpMetric -Bandwidth 1544 -Delay 20000
    # 2169856: one T1 link

.EXAMPLE
    Get-EigrpMetric -Link gig, serial, fe
    # The path goes over three links: the lowest bandwidth is the serial link, the delays are added
#>
    [CmdletBinding(DefaultParameterSetName = 'Values')]
    param(
        [Parameter(Mandatory, ParameterSetName = 'Values', Position = 0)]
        [ValidateRange(1, [int]::MaxValue)]
        [int[]]$Bandwidth,

        [Parameter(Mandatory, ParameterSetName = 'Values', Position = 1)]
        [ValidateRange(0, [int]::MaxValue)]
        [int[]]$Delay,

        [Parameter(Mandatory, ParameterSetName = 'Link', Position = 0)]
        [string[]]$Link,

        [ValidateRange(1, 255)][int]$Load = 1,
        [ValidateRange(1, 255)][int]$Reliability = 255,
        [ValidateRange(0, 255)][int]$K1 = 1,
        [ValidateRange(0, 255)][int]$K2 = 0,
        [ValidateRange(0, 255)][int]$K3 = 1,
        [ValidateRange(0, 255)][int]$K4 = 0,
        [ValidateRange(0, 255)][int]$K5 = 0
    )

    if ($PSCmdlet.ParameterSetName -eq 'Link') {
        $bw = @(); $dl = @()
        foreach ($name in $Link) {
            try { $key = Resolve-NetLinkType $name }
            catch { $PSCmdlet.ThrowTerminatingError([System.Management.Automation.ErrorRecord]::new($_.Exception, 'BadLink', 'InvalidArgument', $name)) }
            $bw += $script:LinkDefaults[$key].Bandwidth
            $dl += $script:LinkDefaults[$key].Delay
        }
    }
    else { $bw = $Bandwidth; $dl = $Delay }

    $minBw      = ($bw | Measure-Object -Minimum).Minimum
    $totalDelay = [int64]($dl | Measure-Object -Sum).Sum

    $bwTerm    = [int64][math]::Floor(10000000 / $minBw)     # whole number, like the router
    $delayTerm = [int64][math]::Floor($totalDelay / 10)      # tens of microseconds

    $inner = ($K1 * $bwTerm) + [math]::Floor(($K2 * $bwTerm) / (256 - $Load)) + ($K3 * $delayTerm)
    $metric = 256 * $inner
    if ($K5 -ne 0) { $metric = [math]::Floor($metric * $K5 / ($Reliability + $K4)) }

    $formula = if ($K1 -eq 1 -and $K2 -eq 0 -and $K3 -eq 1 -and $K4 -eq 0 -and $K5 -eq 0) {
        "256 x ($bwTerm + $delayTerm)"
    }
    else {
        $f = "256 x ($($K1) x $bwTerm + $($K2) x $bwTerm / (256 - $Load) + $($K3) x $delayTerm)"
        if ($K5 -ne 0) { $f += " x $($K5) / ($Reliability + $($K4))" }
        $f
    }

    [pscustomobject]@{
        PSTypeName       = 'TerminalPro.EigrpMetric'
        Metric           = [int64]$metric
        MinBandwidthKbps = [int64]$minBw
        TotalDelayUsec   = $totalDelay
        BandwidthTerm    = $bwTerm
        DelayTerm        = $delayTerm
        Links            = $bw.Count
        K                = "K1=$K1 K2=$K2 K3=$K3 K4=$K4 K5=$K5"
        Formula          = $formula
    }
}
