function ConvertTo-PrefixLength {
<#
.SYNOPSIS
    Turns a subnet mask (255.255.255.0) or a wildcard mask (0.0.0.255) into a prefix length (24).

.DESCRIPTION
    Accepts either kind of mask and tells which it is by the bits: a subnet mask is ones then zeros, a wildcard mask is zeros then ones. A mask that is neither (for example 255.0.255.0) is refused.

.PARAMETER Mask
    A subnet mask or a wildcard mask.

.EXAMPLE
    ConvertTo-PrefixLength 255.255.240.0

.EXAMPLE
    ConvertTo-PrefixLength 0.0.3.255
#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [string[]]$Mask
    )

    process {
        foreach ($m in $Mask) {
            try {
                if ($m -notmatch '^\s*\d{1,3}(\.\d{1,3}){3}\s*$') { throw "'$m' is not a mask (it should look like 255.255.255.0)." }
                Resolve-NetMask $m
            }
            catch { Write-Error -Message $_.Exception.Message -TargetObject $m }
        }
    }
}
