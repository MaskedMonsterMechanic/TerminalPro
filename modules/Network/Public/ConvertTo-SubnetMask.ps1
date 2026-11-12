function ConvertTo-SubnetMask {
<#
.SYNOPSIS
    Turns a prefix length into a subnet mask (24 becomes 255.255.255.0), or a wildcard mask with -Wildcard.

.DESCRIPTION
    The prefix length is the number of leading one-bits in the subnet mask, from 0 to 32. The wildcard mask is the same mask turned upside down, as used in access lists and OSPF network statements.

.PARAMETER Prefix
    The prefix length, 0 to 32.

.PARAMETER Wildcard
    Give the wildcard mask (as used in access lists) instead.

.EXAMPLE
    ConvertTo-SubnetMask 20

.EXAMPLE
    24, 26 | ConvertTo-SubnetMask -Wildcard
#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [ValidateRange(0, 32)]
        [int[]]$Prefix,

        [switch]$Wildcard
    )

    process {
        foreach ($p in $Prefix) {
            $mask = Get-NetMaskInt $p
            if ($Wildcard) { ConvertFrom-NetInt ((-bnot $mask) -band 4294967295) } else { ConvertFrom-NetInt $mask }
        }
    }
}
