function Write-Color {
<#
.SYNOPSIS
    Writes text with several colours on one line, using ^c colour codes.

.DESCRIPTION
    Put a colour code in the text and everything after it is written in that colour,
    until the next code. ^cn goes back to the normal colour.

    ^cn Normal   ^ck Black     ^cw White    ^ce Gray      ^cE DarkGray
    ^cr Red      ^cR DarkRed   ^cg Green    ^cG DarkGreen
    ^cb Blue     ^cB DarkBlue  ^cc Cyan     ^cC DarkCyan
    ^cm Magenta  ^cM DarkMagenta  ^cy Yellow  ^cY DarkYellow

    Codes are case-sensitive: a small letter is the bright colour, a capital is the dark one.
    Set the environment variable NO_COLOR to print the text without colours.

.PARAMETER Text
    The text to write, with optional colour codes.

.PARAMETER NoNewline
    Do not end the line.

.EXAMPLE
    Write-Color "Hey look ^crthis is red ^cgand this is green^cn, and this is normal."
#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [AllowEmptyString()]
        [string]$Text,

        [switch]$NoNewline
    )

    # Case-sensitive on purpose: a PowerShell @{ } table would treat 'e' and 'E' as the same key.
    $map = New-Object System.Collections.Hashtable ([System.StringComparer]::Ordinal)
    foreach ($pair in 'n=', 'k=Black', 'w=White', 'e=Gray', 'E=DarkGray', 'r=Red', 'R=DarkRed',
                      'g=Green', 'G=DarkGreen', 'b=Blue', 'B=DarkBlue', 'c=Cyan', 'C=DarkCyan',
                      'm=Magenta', 'M=DarkMagenta', 'y=Yellow', 'Y=DarkYellow') {
        $code, $colorName = $pair -split '=', 2
        $map[$code] = if ($colorName) { $colorName } else { $null }
    }

    # Splitting with a capture group returns: text, code, text, code, text ...
    $parts = [regex]::Split($Text, '\^c(.)')
    $color = $null

    for ($i = 0; $i -lt $parts.Count; $i++) {
        if ($i % 2 -eq 1) {
            # A code. Unknown codes are written as they are.
            $code = $parts[$i]
            if ($map.ContainsKey($code)) { $color = $map[$code] }
            else {
                Write-Host ('^c' + $code) -NoNewline
            }
            continue
        }

        $piece = $parts[$i]
        if ($piece.Length -eq 0) { continue }

        $params = @{ Object = $piece; NoNewline = $true }
        if ($color -and -not $env:NO_COLOR) { $params.ForegroundColor = $color }
        Write-Host @params
    }

    if (-not $NoNewline) { Write-Host '' }
}
