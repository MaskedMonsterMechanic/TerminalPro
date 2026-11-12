function Show-CheatSheetIndex {
<#
.SYNOPSIS
    Shows the list of all cheat-sheets in a module, built from the sheet files themselves.

.DESCRIPTION
    Every sheet file names its Command, Alias, Synopsis and Group. The index reads them,
    so it can never go out of date. The index has its own sheet file (Kind = 'Index') with
    the Title and an optional Info text.

.PARAMETER Path
    The index sheet file. The other sheets are read from the same folder.

.EXAMPLE
    Show-UnixCommands
#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [string]$Path,

        [switch]$NoClear
    )

    $index = Read-CheatSheetData -Path $Path
    $folder = Split-Path -LiteralPath $Path

    $entries = foreach ($file in Get-ChildItem -LiteralPath $folder -Filter '*.psd1') {
        $d = Read-CheatSheetData -Path $file.FullName
        if ($d.Command) {
            [pscustomobject]@{
                Group    = if ($d.Group) { [string]$d.Group } else { 'COMMANDS' }
                Order    = if ($d.Order) { [int]$d.Order } else { 100 }
                Command  = [string]$d.Command
                Alias    = [string]$d.Alias
                Synopsis = [string]$d.Synopsis
            }
        }
    }
    $entries = @($entries)

    if (-not $NoClear) { try { Clear-Host } catch { } }
    Write-SheetHeader -Title $index.Title

    $prompt = (Get-TPPromptName) + ' >'
    $widths = @($prompt.Length, [Math]::Min(40, [int](($entries | ForEach-Object { $_.Command.Length } | Measure-Object -Maximum).Maximum)), [int](($entries | ForEach-Object { $_.Alias.Length } | Measure-Object -Maximum).Maximum), 0)
    $colors = @($script:Colors.Prompt, $script:Colors.Input, $script:Colors.Output, $script:Colors.Input)

    # The column heads (PROMPT, INPUT, ALIAS) must fit their columns.
    $widths[0] = [Math]::Max($widths[0], 6)
    $widths[2] = [Math]::Max($widths[2], 5)

    # In a small window the command column gets narrower (down to 16) so the description keeps some room.
    # Text wider than its column wraps inside the column.
    $window   = Get-TPWidth
    $longest  = [int](($entries | ForEach-Object { $_.Synopsis.Length } | Measure-Object -Maximum).Maximum)
    $minOut   = [Math]::Min($longest, [Math]::Max(20, [int]($window / 3)))
    while (($window - (1 + $widths[0] + 1 + $widths[1] + 1 + $widths[2] + 1)) -lt $minOut -and $widths[1] -gt 16) { $widths[1]-- }
    $ruleW  = [Math]::Min($window - 1, $widths[0] + $widths[1] + $widths[2] + 40)

    Write-SheetWrapped -Cells @('PROMPT', 'INPUT', 'ALIAS', 'OUTPUT') -Widths $widths -Colors $colors

    # Groups go by their lowest Order number (then by name). Not left to the order Group-Object happens to return.
    $groups = $entries | Group-Object Group | Sort-Object @{ Expression = { ($_.Group | Measure-Object Order -Minimum).Minimum } }, Name
    foreach ($g in $groups) {
        Write-SheetSectionTitle -Title $g.Name -Width $ruleW
        $gap = $false   # an entry that wrapped gets an empty line after it
        foreach ($e in $g.Group | Sort-Object Order, Command) {
            if ($gap) { Write-Host '' }
            Write-SheetWrapped -Cells @($prompt, $e.Command, $e.Alias, $e.Synopsis) -Widths $widths -Colors $colors
            $gap = ($script:LastWrappedLines -gt 1)
        }
    }

    if ($index.Info) {
        # The box is 9 characters wider than its text. In a small window the text wraps inside it.
        $maxInner = [Math]::Max(10, $window - 9)
        $lines = @(@($index.Info) | ForEach-Object { Split-TPText -Text ([string]$_) -Width $maxInner })
        $inner = [int](($lines | ForEach-Object { $_.Length } | Measure-Object -Maximum).Maximum)
        $border = '*' * ($inner + 6)
        Write-Host ''
        Write-TPText ('   ' + $border) $script:Colors.Rule
        Write-TPText ('   *  ' + 'INFORMATION'.PadRight($inner) + '  *') $script:Colors.Topic
        foreach ($l in $lines) { Write-TPText ('   *  ' + $l.PadRight($inner) + '  *') $script:Colors.Rule }
        Write-TPText ('   ' + $border) $script:Colors.Rule
    }
    Write-SheetHomeLine
    Write-Host ''
}
