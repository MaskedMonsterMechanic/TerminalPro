function Convert-NetNumber {
<#
.SYNOPSIS
    Shows a number or an IPv4 address in decimal, binary and hexadecimal.

.DESCRIPTION
    By default the input is read as a decimal number, or as an IPv4 address when it looks like one.
    Use a 0x or 0b in front, or -From, for hexadecimal and binary. Dots, spaces and underscores in
    binary and hexadecimal input are ignored, so 1100_0000.1010_1000 works.

.PARAMETER Value
    The number or address. Several can be piped in.

.PARAMETER From
    Auto (default), Decimal, Binary or Hex.

.EXAMPLE
    Convert-NetNumber 192

.EXAMPLE
    Convert-NetNumber 192.168.1.10

.EXAMPLE
    Convert-NetNumber 11000000.10101000.00000001.00001010 -From Binary

.EXAMPLE
    netconv 0xFF
#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [string[]]$Value,

        [ValidateSet('Auto', 'Decimal', 'Binary', 'Hex')]
        [string]$From = 'Auto'
    )

    process {
        foreach ($item in $Value) {
            try {
                $text = $item.Trim()
                $kind = $From
                $dotted = $null
                $number = $null

                if ($kind -eq 'Auto') {
                    if     ($text -match '^0[xX]')            { $kind = 'Hex' }
                    elseif ($text -match '^0[bB]')            { $kind = 'Binary' }
                    elseif ($text -match '^\d+(\.\d+){3}$')   { $kind = 'Dotted' }
                    else                                      { $kind = 'Decimal' }
                }

                switch ($kind) {
                    'Dotted' {
                        $number = ConvertTo-NetInt $text
                        $dotted = ConvertFrom-NetInt $number
                    }
                    'Decimal' {
                        $number = [int64]0
                        if (-not [int64]::TryParse($text, [ref]$number) -or $number -lt 0) { throw "'$text' is not a decimal number." }
                    }
                    'Binary' {
                        $digits = ($text -replace '^0[bB]', '') -replace '[\s._]', ''
                        if ($digits -notmatch '^[01]{1,62}$') { throw "'$text' is not a binary number (only 0 and 1, up to 62 digits)." }
                        $number = [Convert]::ToInt64($digits, 2)
                        if ($text -match '^[01]{8}(\.[01]{8}){3}$') { $dotted = ConvertFrom-NetInt $number }
                    }
                    'Hex' {
                        $digits = ($text -replace '^0[xX]', '') -replace '[\s._]', ''
                        if ($digits -notmatch '^[0-9a-fA-F]{1,15}$') { throw "'$text' is not a hexadecimal number (0-9 and A-F, up to 15 digits)." }
                        $number = [Convert]::ToInt64($digits, 16)
                    }
                }

                $binary = [Convert]::ToString($number, 2)
                $binary = $binary.PadLeft([Math]::Ceiling($binary.Length / 8) * 8, '0')
                $binary = (($binary -split '(?<=\G.{8})') | Where-Object { $_ }) -join ' '
                if ($dotted -or ($kind -eq 'Dotted')) { $binary = ConvertTo-NetBinary $number }

                $hex = $number.ToString('X')
                if ($hex.Length % 2) { $hex = '0' + $hex }

                [pscustomobject]@{
                    PSTypeName = 'TerminalPro.NetNumber'
                    Input      = $item
                    Decimal    = $number
                    Binary     = $binary
                    Hex        = $hex
                    Dotted     = $dotted
                }
            }
            catch {
                Write-Error -Message $_.Exception.Message -TargetObject $item
            }
        }
    }
}
