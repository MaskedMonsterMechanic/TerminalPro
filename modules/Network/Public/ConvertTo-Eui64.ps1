function ConvertTo-Eui64 {
<#
.SYNOPSIS
    Turns a MAC address into the IPv6 interface ID it would get with EUI-64, and the link-local address.

.DESCRIPTION
    The MAC address is split in the middle, FF FE is put in the gap, and the 7th bit of the first byte
    is flipped. With -Prefix you also get the full address for a /64 network.

.PARAMETER MacAddress
    A MAC address in any common form: 00-1A-2B-3C-4D-5E, 00:1A:2B:3C:4D:5E, 001A.2B3C.4D5E or 001A2B3C4D5E.

.PARAMETER Prefix
    Optional /64 network (2001:db8:1:1::/64) to build the full address in.

.EXAMPLE
    ConvertTo-Eui64 00-1A-2B-3C-4D-5E

.EXAMPLE
    ConvertTo-Eui64 001A.2B3C.4D5E -Prefix 2001:db8:acad:1::/64
#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [string[]]$MacAddress,

        [Parameter(Position = 1)]
        [string]$Prefix
    )

    process {
        foreach ($item in $MacAddress) {
            try {
                $clean = $item -replace '[-:.\s]', ''
                if ($clean -notmatch '^[0-9a-fA-F]{12}$') { throw "'$item' is not a MAC address (12 hexadecimal digits, for example 00-1A-2B-3C-4D-5E)." }

                $mac = [byte[]](0..5 | ForEach-Object { [Convert]::ToByte($clean.Substring(2 * $_, 2), 16) })
                $flipped     = $mac[0] -bxor 0x02          # flip the "universal/local" bit
                $interfaceId = [byte[]]($flipped, $mac[1], $mac[2], 0xFF, 0xFE, $mac[3], $mac[4], $mac[5])

                $linkLocal = [byte[]](0xFE, 0x80, 0, 0, 0, 0, 0, 0) + $interfaceId

                $address = $null
                if ($Prefix) {
                    $p = $Prefix
                    if ($p -match '^(.+?)\s*/\s*(\d{1,3})$') {
                        if ([int]$Matches[2] -gt 64) { throw "EUI-64 needs a prefix of /64 or shorter (got /$($Matches[2]))." }
                        $p = $Matches[1]
                    }
                    $prefixBytes = ConvertTo-NetIPv6Bytes $p
                    $address = ConvertFrom-NetIPv6Bytes ([byte[]]($prefixBytes[0..7]) + $interfaceId)
                }

                [pscustomobject]@{
                    PSTypeName  = 'TerminalPro.Eui64'
                    MacAddress  = ($mac | ForEach-Object { '{0:X2}' -f $_ }) -join '-'
                    InterfaceId = ('{0:x4}:{1:x4}:{2:x4}:{3:x4}' -f ([int]$interfaceId[0] * 256 + $interfaceId[1]), ([int]$interfaceId[2] * 256 + $interfaceId[3]), ([int]$interfaceId[4] * 256 + $interfaceId[5]), ([int]$interfaceId[6] * 256 + $interfaceId[7]))
                    LinkLocal   = ConvertFrom-NetIPv6Bytes $linkLocal
                    Address     = $address
                }
            }
            catch {
                Write-Error -Message $_.Exception.Message -TargetObject $item
            }
        }
    }
}
