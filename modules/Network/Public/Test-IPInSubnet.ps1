function Test-IPInSubnet {
<#
.SYNOPSIS
    True when an IP address belongs to a network. Works for IPv4 and IPv6.

.DESCRIPTION
    Gives one True or False for every address, in the order you gave them.

.PARAMETER Address
    One or more addresses.

.PARAMETER Network
    The network as address/prefix, for example 10.1.0.0/16 or 2001:db8::/32.

.EXAMPLE
    Test-IPInSubnet 10.1.5.9 10.1.0.0/16

.EXAMPLE
    '10.1.5.9', '10.2.0.1' | Test-IPInSubnet -Network 10.1.0.0/16
#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [string[]]$Address,

        [Parameter(Mandatory, Position = 1)]
        [string]$Network
    )

    begin {
        $isV6 = $Network.Contains(':')
        if ($isV6) {
            if ($Network -notmatch '^(.+?)\s*/\s*(\d{1,3})$') { throw "'$Network' is not a network. Write it as address/prefix, for example 2001:db8::/32." }
            $netBytes  = ConvertTo-NetIPv6Bytes $Matches[1]
            $netPrefix = [int]$Matches[2]
            if ($netPrefix -gt 128) { throw "The prefix length must be between 0 and 128 (got $netPrefix)." }
        }
        else {
            $net  = Split-NetworkText $Network
            $mask = Get-NetMaskInt $net.Prefix
        }
    }

    process {
        foreach ($a in $Address) {
            if ($isV6) {
                Test-NetIPv6Prefix -Address (ConvertTo-NetIPv6Bytes $a) -Network $netBytes -Prefix $netPrefix
            }
            else {
                if ($a.Contains(':')) { $false; continue }     # an IPv6 address is never in an IPv4 network
                (((ConvertTo-NetInt $a) -band $mask) -eq ($net.Address -band $mask))
            }
        }
    }
}
