function Get-NetCalculator {
<#
.SYNOPSIS
    IPv4 subnet calculator: network, broadcast, host range, mask, wildcard, class, type and binary.

.DESCRIPTION
    Give it an address with a prefix (192.168.1.10/24), an address and a mask (192.168.1.10 255.255.255.0),
    or an address and a prefix (192.168.1.10 24). A wildcard mask (0.0.0.255) is also understood.
    An address with nothing else gets its classful default (A = /8, B = /16, C = /24).
    The result is an object, so you can pipe it: netcalc 10.0.0.0/8 | Select-Object Network, Broadcast.

    /31 gives 2 usable addresses (RFC 3021, point-to-point links) and /32 gives 1 (a single host).

.PARAMETER Address
    The address, optionally with /prefix or a mask after it. Several addresses can be piped in.

.PARAMETER Mask
    A prefix length (24, /24), a subnet mask (255.255.255.0) or a wildcard mask (0.0.0.255).

.EXAMPLE
    Get-NetCalculator 192.168.1.10/24

.EXAMPLE
    netcalc 172.16.5.130 255.255.255.192

.EXAMPLE
    '10.1.1.1/8', '172.16.0.1/12' | Get-NetCalculator | Format-Table Cidr, Broadcast, UsableHosts
#>
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string[]]$Address,

        [Parameter(Position = 1)]
        [Alias('Prefix', 'Netmask')]
        [string]$Mask
    )

    process {
        if (-not $Address) { $Address = @(Read-Host 'Address with prefix or mask (for example 192.168.1.10/24)') }

        foreach ($item in $Address) {
            try {
                $text = $item.Trim()
                $given = $Mask

                if ($text -match '^(\S+?)\s*/\s*(\S+)$' -or $text -match '^(\S+)\s+(\S+)$') {
                    $text = $Matches[1]
                    if (-not $given) { $given = $Matches[2] }
                }

                $number = ConvertTo-NetInt $text
                if ($given) {
                    $prefix = Resolve-NetMask $given
                }
                else {
                    $first = $number -shr 24
                    if     ($first -lt 128) { $prefix = 8 }
                    elseif ($first -lt 192) { $prefix = 16 }
                    else                    { $prefix = 24 }
                    Write-Verbose "No prefix given, using the classful default /$prefix."
                }

                New-NetCalcObject -Address $number -Prefix $prefix
            }
            catch {
                Write-Error -Message $_.Exception.Message -TargetObject $item
            }
        }
    }
}
