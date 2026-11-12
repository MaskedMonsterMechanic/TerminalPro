<#
.SYNOPSIS
    One-off helper: converts an old "$CP ... $CN ... $CA ..." cheat-sheet script into a Sheets\*.psd1 data file.

.DESCRIPTION
    The old scripts were Windows-1252 text with a here-string of colour tokens ($CT topic, $CP prompt,
    $CN normal, $CA output). This reads that, and writes the new data format used by TerminalPro.Core.
    Nothing is invented: rows are copied as they are. Lines it cannot understand are kept as notes and listed.

.PARAMETER Path        The old .ps1 sheet.
.PARAMETER OutFile     The .psd1 to write.
.PARAMETER Command     Name of the command that shows this sheet (for example Show-UnixCommon).
.PARAMETER Alias       Short alias for the command.
.PARAMETER Synopsis    One line for the module index.
.PARAMETER Group       Heading in the module index.
.PARAMETER Order       Sort order in the module index.
.PARAMETER Index       Command of the module index (shown in the footer of the sheet).
.PARAMETER PromptMap   Old prompt variable -> prompt text, for example @{ '$UnixPrompt0' = 'user@ubuntu:~$' }.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$Path,
    [Parameter(Mandatory)][string]$OutFile,
    [Parameter(Mandatory)][string]$Command,
    [Parameter(Mandatory)][string]$Alias,
    [Parameter(Mandatory)][string]$Synopsis,
    [string]$Group = 'COMMANDS',
    [int]$Order = 100,
    [string]$Index,
    [hashtable]$PromptMap = @{}
)

$ErrorActionPreference = 'Stop'
$lines = [IO.File]::ReadAllLines($Path, [Text.Encoding]::GetEncoding(1252))

function Quote([string]$s) { "'" + $s.Replace("'", "''") + "'" }
function Strip([string]$s) { ($s -replace '\$(CN|CA|CP|CT|CC|CR)\b', '').Trim() }

$title = $null
$sections = New-Object System.Collections.Generic.List[object]
$current = $null
$unparsed = New-Object System.Collections.Generic.List[string]
$started = $false    # after the first ____ line (the one under the column heads)
$ended = $false

foreach ($raw in $lines) {
    if ($ended) { break }
    $line = $raw.TrimEnd()

    if (-not $title -and $line -match '\|\s*\$CT\s+(.+?)\s*\$CN\s*\|') { $title = $Matches[1].Trim(); continue }

    if ($line -match '^\s*_{20,}\s*$') {
        if (-not $started) { $started = $true; continue }
        $ended = $true; continue
    }
    if (-not $started) { continue }

    if ($line -match '^\s*-{10,}\s*$') { continue }
    if ($line.Trim() -eq '' -or $line.Trim() -eq '$CN') { continue }

    if ($line -match '^\s*\$CT\s+(.+?)\s*\$CN\s*$') {
        $current = [pscustomobject]@{ Title = $Matches[1].Trim(); Items = (New-Object System.Collections.Generic.List[object]) }
        $sections.Add($current)
        continue
    }

    if (-not $current) {
        $current = [pscustomobject]@{ Title = 'COMMANDS'; Items = (New-Object System.Collections.Generic.List[object]) }
        $sections.Add($current)
    }

    if ($line -match '^\s*\$CP\s+(\S+)\s+\$CN\s*(.*?)\s*\$CA\s*(.*?)\s*$') {
        $p = $Matches[1]
        if ($PromptMap.ContainsKey($p)) { $p = $PromptMap[$p] }
        elseif ($p.StartsWith('$')) { $unparsed.Add("unknown prompt variable $p in: $line") }
        $current.Items.Add([pscustomobject]@{ Kind = 'Row'; Prompt = $p; Input = (Strip $Matches[2]); Output = (Strip $Matches[3]) })
        continue
    }

    $text = Strip $line
    if ($text -ne '') {
        $current.Items.Add([pscustomobject]@{ Kind = 'Note'; Prompt = ''; Input = ''; Output = $text })
        if ($line -match '\$C[PAT]') { $unparsed.Add("kept as note: $line") }
    }
}

if (-not $title) { throw "No title found in $Path" }

# The most common prompt becomes the sheet default, and each section's default likewise.
function MostCommon($items) {
    $g = $items | Where-Object { $_.Kind -eq 'Row' -and $_.Prompt } | Group-Object Prompt | Sort-Object Count -Descending | Select-Object -First 1
    if ($g) { $g.Name } else { '' }
}
$allItems = @($sections | ForEach-Object { $_.Items })
$sheetPrompt = MostCommon $allItems

$out = New-Object System.Text.StringBuilder
[void]$out.AppendLine('@{')
[void]$out.AppendLine("    Command  = $(Quote $Command)")
[void]$out.AppendLine("    Alias    = $(Quote $Alias)")
[void]$out.AppendLine("    Synopsis = $(Quote $Synopsis)")
[void]$out.AppendLine("    Group    = $(Quote $Group)")
[void]$out.AppendLine("    Order    = $Order")
if ($Index) { [void]$out.AppendLine("    Index    = $(Quote $Index)") }
[void]$out.AppendLine("    Title    = $(Quote $title)")
if ($sheetPrompt) { [void]$out.AppendLine("    Prompt   = $(Quote $sheetPrompt)") }
[void]$out.AppendLine('')
[void]$out.AppendLine('    Sections = @(')
foreach ($s in $sections) {
    $sp = MostCommon $s.Items
    [void]$out.AppendLine('        @{')
    [void]$out.AppendLine("            Title  = $(Quote $s.Title)")
    if ($sp -and $sp -ne $sheetPrompt) { [void]$out.AppendLine("            Prompt = $(Quote $sp)") }
    [void]$out.AppendLine("            Rows   = @'")
    $default = if ($sp) { $sp } else { $sheetPrompt }
    foreach ($i in $s.Items) {
        if ($i.Kind -eq 'Note') { [void]$out.AppendLine($i.Output) }
        elseif ($i.Prompt -and $i.Prompt -ne $default) { [void]$out.AppendLine("$($i.Prompt) :: $($i.Input) :: $($i.Output)") }
        else { [void]$out.AppendLine("$($i.Input) :: $($i.Output)") }
    }
    [void]$out.AppendLine("'@")
    [void]$out.AppendLine('        }')
}
[void]$out.AppendLine('    )')
[void]$out.AppendLine('}')

$text = $out.ToString()
$nonAscii = [regex]::Matches($text, '[^\x00-\x7F]') | ForEach-Object { $_.Value } | Sort-Object -Unique
New-Item -ItemType Directory -Path (Split-Path $OutFile) -Force | Out-Null
[IO.File]::WriteAllText($OutFile, $text, (New-Object System.Text.UTF8Encoding($true)))

Write-Host ("{0}: {1} sections, {2} rows, {3} notes" -f (Split-Path $OutFile -Leaf), $sections.Count, @($allItems | Where-Object Kind -eq 'Row').Count, @($allItems | Where-Object Kind -eq 'Note').Count)
if ($nonAscii) { Write-Warning "Non-ASCII characters in the result: $($nonAscii -join ' ')" }
foreach ($u in $unparsed) { Write-Warning $u }
