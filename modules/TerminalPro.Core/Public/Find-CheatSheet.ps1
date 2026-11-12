function Find-CheatSheet {
<#
.SYNOPSIS
    Searches every Terminal Pro cheat-sheet for a word.

.DESCRIPTION
    Looks in the Sheets folder of each module found on the module path (the Terminal Pro
    modules folder is on it). Returns objects, so you can pipe them on.

.PARAMETER Text
    The text to look for (in the prompt, the input or the output of a row).

.PARAMETER Module
    Only search these modules.

.EXAMPLE
    Find-CheatSheet vlan

.EXAMPLE
    Find-CheatSheet chmod -Module Unix | Format-Table Command, Input, Output -AutoSize
#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [string]$Text,

        [string[]]$Module
    )

    $pattern = "*$Text*"
    $seen = @{}

    foreach ($root in ($env:PSModulePath -split ';' | Where-Object { $_ -and (Test-Path -LiteralPath $_) })) {
        foreach ($dir in Get-ChildItem -LiteralPath $root -Directory -ErrorAction SilentlyContinue) {
            $sheets = Join-Path $dir.FullName 'Sheets'
            if (-not (Test-Path -LiteralPath $sheets)) { continue }
            if ($Module -and $dir.Name -notin $Module) { continue }
            if ($seen.ContainsKey($dir.Name)) { continue }
            $seen[$dir.Name] = $true

            foreach ($file in Get-ChildItem -LiteralPath $sheets -Filter '*.psd1') {
                $sheet = Read-CheatSheetData -Path $file.FullName
                if (-not $sheet.Command -or -not $sheet.Sections) { continue }   # skips index and command-only entries
                foreach ($s in Get-CheatSheetSection -Sheet $sheet) {
                    foreach ($r in $s.Rows | Where-Object Kind -eq 'Row') {
                        if ($r.Prompt -like $pattern -or $r.Input -like $pattern -or $r.Output -like $pattern) {
                            [pscustomobject]@{
                                Module  = $dir.Name
                                Command = [string]$sheet.Command
                                Section = $s.Title
                                Prompt  = $r.Prompt
                                Input   = $r.Input
                                Output  = $r.Output
                            }
                        }
                    }
                }
            }
        }
    }
}
