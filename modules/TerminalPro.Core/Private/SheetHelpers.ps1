# Helpers shared by Show-CheatSheet, Show-CheatSheetIndex and Find-CheatSheet. Not exported.

function Write-TPText {
    param(
        [string]$Text,
        [string]$Color,
        [switch]$NoNewline
    )
    $params = @{ Object = $Text; NoNewline = [bool]$NoNewline }
    if ($Color -and -not $env:NO_COLOR) { $params.ForegroundColor = $Color }
    Write-Host @params
}

function Get-TPPromptName {
    if ($global:TerminalProPromptName) { $global:TerminalProPromptName } else { 'PS' }
}

function Get-TPWidth {
    # Width of the window, or 110 when there is no real console.
    # TERMINALPRO_WIDTH forces a width (used by the tests and the screenshot script).
    if ($env:TERMINALPRO_WIDTH -match '^\d+$') { $w = [int]$env:TERMINALPRO_WIDTH }
    else { try { $w = $Host.UI.RawUI.WindowSize.Width } catch { $w = 0 } }
    if ($w -gt 40) { $w - 1 } else { 110 }
}

function Read-CheatSheetData {
    # Reads one sheet file. Sheets are PowerShell data files (.psd1).
    param([Parameter(Mandatory)][string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) { throw "Sheet not found: $Path" }
    Import-PowerShellDataFile -LiteralPath $Path
}

function ConvertFrom-CheatSheetRows {
    <#
        Turns the Rows text of a section into row objects.
          input :: output                  (uses the section's prompt)
          prompt :: input :: output
          any line without ' :: '          (a note, shown under the output column)
    #>
    param(
        [string]$Rows,
        [string]$DefaultPrompt
    )
    foreach ($line in ($Rows -split "`r?`n")) {
        $text = $line.TrimEnd()
        if ($text.Trim().Length -eq 0) { continue }

        if ($text -match ' :: ') {
            $parts = $text -split ' :: ', 3
            if ($parts.Count -eq 3) {
                [pscustomobject]@{ Kind = 'Row'; Prompt = $parts[0].Trim(); Input = $parts[1].Trim(); Output = $parts[2].Trim() }
            }
            else {
                [pscustomobject]@{ Kind = 'Row'; Prompt = $DefaultPrompt; Input = $parts[0].Trim(); Output = $parts[1].Trim() }
            }
        }
        else {
            [pscustomobject]@{ Kind = 'Note'; Prompt = ''; Input = ''; Output = $text.Trim() }
        }
    }
}

function Get-CheatSheetSection {
    # Returns the sections of a sheet, each with its row objects.
    param([Parameter(Mandatory)][hashtable]$Sheet)
    $sheetPrompt = if ($Sheet.Prompt) { [string]$Sheet.Prompt } else { '' }
    foreach ($s in @($Sheet.Sections)) {
        $prompt = if ($s.Prompt) { [string]$s.Prompt } else { $sheetPrompt }
        [pscustomobject]@{
            Title = [string]$s.Title
            Rows  = @(ConvertFrom-CheatSheetRows -Rows ([string]$s.Rows) -DefaultPrompt $prompt)
        }
    }
}

function Write-SheetHeader {
    param([string]$Title)
    # The box is indented 16 spaces in a wide window. In a small window it moves left, and a long title wraps inside it.
    $window = Get-TPWidth
    $inner  = [Math]::Min($Title.Length, [Math]::Max(10, $window - 8))
    $width  = $inner + 6
    $pad    = ' ' * [Math]::Max(0, [Math]::Min(16, $window - $width - 1))
    Write-TPText ($pad + ('=' * $width)) $script:Colors.Rule
    foreach ($line in @(Split-TPText -Text $Title -Width $inner)) {
        Write-TPText ($pad + '|  ') $script:Colors.Rule -NoNewline
        Write-TPText $line.PadRight($inner) $script:Colors.Topic -NoNewline
        Write-TPText '  |' $script:Colors.Rule
    }
    Write-TPText ($pad + ('=' * $width)) $script:Colors.Rule
    Write-TPText ('               ' + (Get-Date -Format G)) $script:Colors.Time
    Write-Host ''
}

function Write-SheetCells {
    # Writes one line of cells in columns. $Colors holds one colour per cell.
    param(
        [string[]]$Cells,
        [int[]]$Widths,
        [string[]]$Colors
    )
    Write-Host ' ' -NoNewline
    for ($i = 0; $i -lt $Cells.Count; $i++) {
        $isLast = ($i -eq $Cells.Count - 1)
        $text = if ($isLast) { $Cells[$i] } else { $Cells[$i].PadRight($Widths[$i]) + ' ' }
        Write-TPText $text $Colors[$i] -NoNewline:(-not $isLast)
    }
}

function Split-TPText {
    # Breaks text into lines of at most $Width characters, at spaces. A word longer than a line is cut.
    param([string]$Text, [int]$Width)
    if ($Width -lt 1) { $Width = 1 }
    if ($null -eq $Text) { $Text = '' }
    if ($Text.Length -le $Width) { return $Text }

    $lines = New-Object System.Collections.Generic.List[string]
    $current = ''
    foreach ($word in ($Text -split ' ')) {
        if ($word.Length -eq 0) { continue }
        while ($word.Length -gt $Width) {
            if ($current) { $lines.Add($current); $current = '' }
            $lines.Add($word.Substring(0, $Width))
            $word = $word.Substring($Width)
        }
        if (-not $current) { $current = $word }
        elseif (($current.Length + 1 + $word.Length) -le $Width) { $current += ' ' + $word }
        else { $lines.Add($current); $current = $word }
    }
    if ($current) { $lines.Add($current) }
    $lines.ToArray()
}

function Write-SheetWrapped {
    # Like Write-SheetCells, but text that does not fit the window is wrapped inside its own column.
    # The last cell gets what is left of the window; the lines after the first start under that column.
    param(
        [string[]]$Cells,
        [int[]]$Widths,
        [string[]]$Colors
    )
    $last = $Cells.Count - 1
    $used = 1
    for ($i = 0; $i -lt $last; $i++) { $used += $Widths[$i] + 1 }
    $lastWidth = [Math]::Max(10, (Get-TPWidth) - $used)

    $columns = New-Object 'System.Collections.Generic.List[string[]]'
    for ($i = 0; $i -le $last; $i++) {
        $w = if ($i -eq $last) { $lastWidth } else { $Widths[$i] }
        $columns.Add([string[]]@(Split-TPText -Text $Cells[$i] -Width $w))
    }
    $lineCount = ($columns | ForEach-Object { $_.Count } | Measure-Object -Maximum).Maximum
    $script:LastWrappedLines = $lineCount   # the caller can leave a gap after an entry that took more than one line

    for ($n = 0; $n -lt $lineCount; $n++) {
        Write-Host ' ' -NoNewline
        for ($i = 0; $i -le $last; $i++) {
            $text = if ($n -lt $columns[$i].Count) { $columns[$i][$n] } else { '' }
            if ($i -eq $last) { Write-TPText $text $Colors[$i] }
            else              { Write-TPText ($text.PadRight($Widths[$i]) + ' ') $Colors[$i] -NoNewline }
        }
    }
}

function Write-SheetSectionTitle {
    param([string]$Title, [int]$Width)
    Write-Host ''
    # A title that is wider than the window wraps (nothing changes when it fits).
    foreach ($line in @(Split-TPText -Text $Title -Width ([Math]::Max(10, (Get-TPWidth) - 1)))) {
        Write-Host ' ' -NoNewline
        Write-TPText $line $script:Colors.Topic
    }
    Write-TPText (' ' + ('-' * [Math]::Min($Width, [Math]::Max(10, (Get-TPWidth) - 1)))) $script:Colors.Rule
}

function Write-SheetHomeLine {
    # "Back to the start page" hint, shown at the bottom of every page and index.
    Write-Host ''
    Write-Host ' Back to the start page:'
    Write-TPText (' ' + ('-' * 40)) $script:Colors.Rule
    Write-TPText (' ' + (Get-TPPromptName) + ' > ') $script:Colors.Prompt -NoNewline
    Write-TPText 'Show-StartPage' $script:Colors.Input -NoNewline
    Write-TPText '  home' $script:Colors.Output
}

function Write-SheetFooter {
    param([string]$Command)
    if (-not $Command) { Write-SheetHomeLine; Write-Host ''; return }
    $alias = Get-Alias -Definition $Command -ErrorAction SilentlyContinue | Select-Object -First 1
    Write-Host ''
    Write-Host ' To see everything in this module:'
    Write-TPText (' ' + ('-' * 40)) $script:Colors.Rule
    Write-TPText (' ' + (Get-TPPromptName) + ' > ') $script:Colors.Prompt -NoNewline
    Write-TPText $Command $script:Colors.Input -NoNewline:([bool]$alias)
    if ($alias) { Write-TPText ('  ' + $alias.Name) $script:Colors.Output }
    Write-SheetHomeLine
    Write-Host ''
}

function Get-TPModuleEntry {
    # Terminal Pro modules (tag 'TerminalPro') that have an index sheet. They all live in one folder.
    $folder = Split-Path -Path $script:ModuleRoot -Parent
    foreach ($dir in Get-ChildItem -LiteralPath $folder -Directory | Sort-Object Name) {
        $manifest = Join-Path $dir.FullName "$($dir.Name).psd1"
        if (-not (Test-Path -LiteralPath $manifest)) { continue }
        $info = Import-PowerShellDataFile -LiteralPath $manifest
        if ($info.PrivateData.PSData.Tags -notcontains 'TerminalPro') { continue }

        $sheets = Join-Path $dir.FullName 'Sheets'
        if (-not (Test-Path -LiteralPath $sheets)) { continue }
        foreach ($file in Get-ChildItem -LiteralPath $sheets -Filter '*.psd1') {
            $sheet = Import-PowerShellDataFile -LiteralPath $file.FullName
            if ($sheet.Kind -eq 'Index') {
                [pscustomobject]@{
                    Name        = $dir.Name
                    Command     = [string]$sheet.Command
                    Alias       = [string]$sheet.Alias
                    Description = [string]$info.Description
                }
                break
            }
        }
    }
}