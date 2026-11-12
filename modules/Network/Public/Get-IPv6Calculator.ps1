function Get-IPv6Calculator {
<#
.SYNOPSIS
    IPv6 calculator: short and full form, network, first and last address, type and number of /64 subnets.

.DESCRIPTION
    Give it an address with a prefix (2001:db8:acad:1234::1/64). Without a prefix, /64 is used.

.PARAMETER Address
    The IPv6 address, optionally with /prefix. Several addresses can be piped in.

.PARAMETER Prefix
    The prefix length (0 to 128). Used when the address has no /prefix.

.EXAMPLE
    Get-IPv6Calculator 2001:db8:acad:1234::1/48

.EXAMPLE
    netcalc6 fe80::1
#>
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string[]]$Address,

        [Parameter(Position = 1)]
        [ValidateRange(0, 128)]
        [int]$Prefix = 64
    )

    process {
        if (-not $Address) { $Address = @(Read-Host 'IPv6 address with prefix (for example 2001:db8:acad::1/64)') }

        foreach ($item in $Address) {
            try {
                $text = $item.Trim()
                $length = $Prefix
                if ($text -match '^(.+?)\s*/\s*(\d{1,3})$') {
                    $text = $Matches[1]
                    $length = [int]$Matches[2]
                    if ($length -gt 128) { throw "The prefix length must be between 0 and 128 (got $length)." }
                }

                $bytes = ConvertTo-NetIPv6Bytes $text
                $mask  = Get-NetIPv6MaskBytes $length

                $network = New-Object byte[] 16
                $last    = New-Object byte[] 16
                for ($i = 0; $i -lt 16; $i++) {
                    $network[$i] = $bytes[$i] -band $mask[$i]
                    $last[$i]    = $network[$i] -bor ((-bnot $mask[$i]) -band 0xFF)
                }

                # the solicited-node multicast address: ff02::1:ff + the last 24 bits
                $solicited = [byte[]](0xff, 0x02, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0xff, $bytes[13], $bytes[14], $bytes[15])

                $subnets64 = if ($length -le 64) { Format-Power2 (64 - $length) } else { 'less than one /64' }

                [pscustomobject]@{
                    PSTypeName    = 'TerminalPro.IPv6Calc'
                    Address       = ConvertFrom-NetIPv6Bytes $bytes
                    Expanded      = ConvertFrom-NetIPv6BytesLong $bytes
                    Prefix        = $length
                    Network       = ConvertFrom-NetIPv6Bytes $network
                    Cidr          = '{0}/{1}' -f (ConvertFrom-NetIPv6Bytes $network), $length
                    FirstAddress  = ConvertFrom-NetIPv6Bytes $network
                    LastAddress   = ConvertFrom-NetIPv6Bytes $last
                    Type          = Get-NetIPv6Type $bytes
                    Subnets64     = $subnets64
                    Addresses     = Format-Power2 (128 - $length)
                    InterfaceId   = ('{0:x4}:{1:x4}:{2:x4}:{3:x4}' -f ([int]$bytes[8] * 256 + $bytes[9]), ([int]$bytes[10] * 256 + $bytes[11]), ([int]$bytes[12] * 256 + $bytes[13]), ([int]$bytes[14] * 256 + $bytes[15]))
                    SolicitedNode = ConvertFrom-NetIPv6Bytes $solicited
                }
            }
            catch {
                Write-Error -Message $_.Exception.Message -TargetObject $item
            }
        }
    }
}
