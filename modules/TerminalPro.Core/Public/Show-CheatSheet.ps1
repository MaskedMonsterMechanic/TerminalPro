function Show-CheatSheet {
<#
.SYNOPSIS
    Shows one cheat-sheet file as a coloured page.

.DESCRIPTION
    A sheet is a PowerShell data file (.psd1) with a Title and Sections. Each section has Rows,
    one per line:
        input :: output                    (uses the section's Prompt)
        prompt :: input :: output
        a line without ' :: ' is a note, shown under the output column.

    The module commands (Show-UnixCommon, Show-NetBasic, ...) call this for you.

.PARAMETER Path
    The sheet file.

.PARAMETER Filter
    Only show rows that contain this text (in the prompt, input or output).

.PARAMETER NoClear
    Do not clear the screen first.

.PARAMETER AsObject
    Return the rows as objects instead of drawing the page (for Where-Object, Export-Csv and so on).

.EXAMPLE
    Show-UnixCommon -Filter grep

.EXAMPLE
    Show-NetPortNumbers -AsObject | Where-Object Input -like '*443*'
#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [string]$Path,

        [string]$Filter,

        [switch]$NoClear,

        [switch]$AsObject
    )

    $sheet    = Read-CheatSheetData -Path $Path
    $sections = @(Get-CheatSheetSection -Sheet $sheet)

    # Apply the filter. A note stays together with the row above it.
    if ($Filter) {
        $pattern = "*$Filter*"
        $kept = foreach ($s in $sections) {
            $rows = New-Object System.Collections.Generic.List[object]
            $keepNotes = $false
            foreach ($r in $s.Rows) {
                if ($r.Kind -eq 'Row') {
                    $keepNotes = ($r.Prompt -like $pattern -or $r.Input -like $pattern -or $r.Output -like $pattern)
                    if ($keepNotes) { $rows.Add($r) }
                }
                elseif ($keepNotes) { $rows.Add($r) }
            }
            if ($rows.Count -gt 0) { [pscustomobject]@{ Title = $s.Title; Rows = $rows.ToArray() } }
        }
        $sections = @($kept)
    }

    if ($AsObject) {
        foreach ($s in $sections) {
            foreach ($r in $s.Rows | Where-Object Kind -eq 'Row') {
                [pscustomobject]@{ Sheet = $sheet.Title; Section = $s.Title; Prompt = $r.Prompt; Input = $r.Input; Output = $r.Output }
            }
        }
        return
    }

    if (-not $NoClear) { try { Clear-Host } catch { } }
    Write-SheetHeader -Title $sheet.Title

    if ($sections.Count -eq 0) {
        Write-TPText " Nothing matches '$Filter'." $script:Colors.Time
        Write-SheetFooter -Command $sheet.Index
        return
    }

    # Column widths come from the content, so nothing can drift out of line.
    $allRows = @($sections.Rows | Where-Object Kind -eq 'Row')
    $promptW = [Math]::Min(34, [int](($allRows | ForEach-Object { $_.Prompt.Length } | Measure-Object -Maximum).Maximum))
    $inputW  = [Math]::Min(60, [int](($allRows | ForEach-Object { $_.Input.Length }  | Measure-Object -Maximum).Maximum))
    $outputW = [int](($allRows | ForEach-Object { $_.Output.Length } | Measure-Object -Maximum).Maximum)
    $hasPrompt = $promptW -gt 0
    # The column heads (PROMPT, INPUT) must fit their columns.
    if ($hasPrompt) { $promptW = [Math]::Max($promptW, 6) }
    $inputW = [Math]::Max($inputW, 5)

    # In a small window, make the input and prompt columns narrower so the output keeps a readable width.
    # Text that is wider than its column wraps inside the column.
    $window = Get-TPWidth
    $minOut = [Math]::Min($outputW, [Math]::Max(20, [int]($window / 3)))
    $before = { 1 + $(if ($hasPrompt) { $promptW + 1 } else { 0 }) + $inputW + 1 }
    while (($window - (& $before)) -lt $minOut) {
        # Input shrinks first, then the prompt (kept whole as long as it can be), then both a little more.
        if     ($inputW -gt 20)                    { $inputW-- }
        elseif ($hasPrompt -and $promptW -gt 22)   { $promptW-- }
        elseif ($inputW -gt 12)                    { $inputW-- }
        elseif ($hasPrompt -and $promptW -gt 10)   { $promptW-- }
        else   { break }
    }
    $ruleW = [Math]::Min($window - 1, $promptW + $inputW + $outputW + 4)

    if ($hasPrompt) { $widths = @($promptW, $inputW, 0); $colors = @($script:Colors.Prompt, $script:Colors.Input, $script:Colors.Output) }
    else            { $widths = @($inputW, 0);           $colors = @($script:Colors.Input, $script:Colors.Output) }

    # Column heads
    if ($hasPrompt) { Write-SheetWrapped -Cells @('PROMPT', 'INPUT', 'OUTPUT') -Widths $widths -Colors $colors }
    else            { Write-SheetWrapped -Cells @('INPUT', 'OUTPUT') -Widths $widths -Colors $colors }

    foreach ($s in $sections) {
        Write-SheetSectionTitle -Title $s.Title -Width $ruleW
        $gap = $false   # an entry (a row and its notes) that wrapped gets an empty line after it
        foreach ($r in $s.Rows) {
            if ($r.Kind -eq 'Row') {
                if ($gap) { Write-Host ''; $gap = $false }
                if ($hasPrompt) { Write-SheetWrapped -Cells @($r.Prompt, $r.Input, $r.Output) -Widths $widths -Colors $colors }
                else            { Write-SheetWrapped -Cells @($r.Input, $r.Output) -Widths $widths -Colors $colors }
                $gap = ($script:LastWrappedLines -gt 1)
            }
            else {
                # A note sits under the output column, and wraps there too.
                $indent = if ($hasPrompt) { $promptW + 1 + $inputW + 1 } else { $inputW + 1 }
                $noteW  = [Math]::Max(10, $window - 1 - $indent)
                $noteLines = @(Split-TPText -Text $r.Output -Width $noteW)
                foreach ($line in $noteLines) {
                    Write-Host (' ' + (' ' * $indent)) -NoNewline
                    Write-TPText $line $script:Colors.Output
                }
                if ($noteLines.Count -gt 1) { $gap = $true }
            }
        }
    }

    Write-SheetFooter -Command $sheet.Index
}
