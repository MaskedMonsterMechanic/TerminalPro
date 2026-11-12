<#
.SYNOPSIS
    Makes the pictures for the README (docs\images\*.png) from the real commands, with FAKE data.

.DESCRIPTION
    Runs the start page and a few pages with made-up computer, network and disk data, catches what they
    print (text and colours) and draws it on a dark picture in a monospace font.
    Nothing private can end up in the pictures: the PC, adapters, drives and folder are invented here.
    Run it again after a change to the look, then commit the new pictures.

    The colours are the Windows Terminal default ("Campbell") colours. The pictures show Windows
    PowerShell version 5.1 as 7.7.0, because they stand for a PowerShell 7 window.

.PARAMETER OutFolder
    Where the pictures go. Default: docs\images next to this script.

.EXAMPLE
    .\docs\New-Screenshots.ps1
#>
[CmdletBinding()]
param([string]$OutFolder)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$root = Split-Path $here -Parent
if (-not $OutFolder) { $OutFolder = Join-Path $here 'images' }
$env:PSModulePath = "$(Join-Path $root 'modules');$env:PSModulePath"
# The pictures need colours, and plain text must count as the normal light grey.
Remove-Item Env:\NO_COLOR -ErrorAction SilentlyContinue
try { $Host.UI.RawUI.ForegroundColor = 'Gray' } catch { }
foreach ($m in 'TerminalPro.Core', 'AdminTools', 'Network', 'Unix', 'WinTools') { Import-Module $m -Force }
if (-not (Test-Path $OutFolder)) { New-Item -ItemType Directory -Path $OutFolder | Out-Null }

# ---------------------------------------------------------------- fake data (everything below is invented)
$global:TerminalProPromptName = 'PaulShell'

function global:Get-DemoPCInfo {
    [pscustomobject]@{
        PSTypeName = 'TerminalPro.PCInfo'; Name = 'DEMO-PC'; Owner = 'Demo User'; Domain = 'WORKGROUP'
        Manufacturer = 'Contoso'; Model = 'Workstation 9000'; OS = 'Microsoft Windows 11 Pro'; Version = '25H2'
        Build = '10.0.26200'; Uptime = (New-TimeSpan -Days 3 -Hours 4 -Minutes 12)
        CPU = 'Example(R) Core(TM) 8-Core Processor'; RamGB = 32
    }
}
function global:Get-DemoAdapters {
    [pscustomobject]@{ PSTypeName = 'TerminalPro.NetIPAdapter'; Adapter = 'Ethernet'; Family = 'IPv4'; IPAddress = '192.0.2.10'; PrefixLength = 24
        Type = 'Unicast'; Gateway = '192.0.2.1'; DnsServers = @('192.0.2.53', '192.0.2.54'); Description = 'Example Gigabit Network Connection'
        Status = 'Up'; Speed = '1 Gbps'; MediaType = '802.3' }
    [pscustomobject]@{ PSTypeName = 'TerminalPro.NetIPAdapter'; Adapter = 'Wi-Fi'; Family = 'IPv4'; IPAddress = '198.51.100.20'; PrefixLength = 24
        Type = 'Unicast'; Gateway = '198.51.100.1'; DnsServers = @('198.51.100.1'); Description = 'Example Wi-Fi 6 Adapter'
        Status = 'Up'; Speed = '1.2 Gbps'; MediaType = 'Native 802.11' }
}
function global:Get-DemoDisks {
    foreach ($d in @(
            @('C', '', 612.4, 930.6), @('D', 'Projects', 140.2, 223.6), @('E', 'Media', 14.8, 1863.0), @('F', 'Backup', 280.1, 931.3))) {
        [pscustomobject]@{ PSTypeName = 'TerminalPro.DiskStorage'; ComputerName = 'DEMO-PC'; Drive = $d[0]; Label = $d[1]; FileSystem = 'NTFS'
            Health = 'Healthy'; FreeGB = $d[2]; FreePercent = [math]::Round(100 * $d[2] / $d[3]); SizeGB = $d[3] }
    }
}
$global:TerminalProStartInfo = 'Get-DemoPCInfo', 'Get-DemoAdapters', 'Get-DemoDisks'
# The start page prints the current folder. Show a made-up one.
function global:Get-Location { [pscustomobject]@{ Path = 'C:\Users\demo\Documents' } }

# ---------------------------------------------------------------- catching what a command prints
# Returns lines; a line is a list of @{ Text; Color } pieces.
function Get-Lines([scriptblock]$Block) {
    $lines = New-Object System.Collections.ArrayList
    $current = New-Object System.Collections.ArrayList
    foreach ($r in (& $Block 6>&1)) {
        if ($r -is [System.Management.Automation.InformationRecord] -and $r.MessageData -is [System.Management.Automation.HostInformationMessage]) {
            $m = $r.MessageData
            [void]$current.Add(@{ Text = [string]$m.Message; Color = $(if ($null -ne $m.ForegroundColor) { [string]$m.ForegroundColor } else { '' }) })
            if (-not $m.NoNewLine) { [void]$lines.Add($current); $current = New-Object System.Collections.ArrayList }
        }
        else {
            $text = if ($r -is [string]) { $r } else { ($r | Out-String).TrimEnd("`r", "`n") }
            foreach ($t in ($text -split "`r?`n")) { [void]$lines.Add((New-Object System.Collections.ArrayList (, @(@{ Text = $t; Color = '' })))) }
        }
    }
    if ($current.Count) { [void]$lines.Add($current) }
    , $lines
}

function Get-LineText($line) { ($line | ForEach-Object { $_.Text }) -join '' }

# ---------------------------------------------------------------- drawing
$palette = @{   # Windows Terminal "Campbell"
    ''            = '#CCCCCC'; 'Black' = '#0C0C0C'; 'DarkBlue' = '#0037DA'; 'DarkGreen' = '#13A10E'; 'DarkCyan' = '#3A96DD'
    'DarkRed'     = '#C50F1F'; 'DarkMagenta' = '#881798'; 'DarkYellow' = '#C19C00'; 'Gray' = '#CCCCCC'; 'DarkGray' = '#767676'
    'Blue'        = '#3B78FF'; 'Green' = '#16C60C'; 'Cyan' = '#61D6D6'; 'Red' = '#E74856'; 'Magenta' = '#B4009E'
    'Yellow'      = '#F9F1A5'; 'White' = '#F2F2F2'
}
function ToColor([string]$name) {
    $hex = if ($palette.ContainsKey($name)) { $palette[$name] } else { $palette[''] }
    [System.Drawing.ColorTranslator]::FromHtml($hex)
}

function Save-Picture($lines, [string]$Path) {
    $font = New-Object System.Drawing.Font('Consolas', 15, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
    $fmt  = [System.Drawing.StringFormat]::GenericTypographic
    $probe = New-Object System.Drawing.Bitmap 10, 10
    $pg = [System.Drawing.Graphics]::FromImage($probe)
    $cellW = [Math]::Ceiling($pg.MeasureString('MMMMMMMMMM', $font, 1000, $fmt).Width / 10 * 100) / 100
    $cellH = [Math]::Ceiling($font.GetHeight($pg) + 3)
    $pg.Dispose(); $probe.Dispose()

    $cols = [int]((@($lines | ForEach-Object { (Get-LineText $_).Length }) + 20) | Measure-Object -Maximum).Maximum
    $pad = 18
    $w = [int]($cols * $cellW + 2 * $pad)
    $h = [int]($lines.Count * $cellH + 2 * $pad)
    $bmp = New-Object System.Drawing.Bitmap $w, $h
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.Clear((ToColor 'Black'))
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
    $y = $pad
    foreach ($line in $lines) {
        $col = 0
        foreach ($piece in $line) {
            $brush = New-Object System.Drawing.SolidBrush (ToColor $piece.Color)
            foreach ($ch in $piece.Text.ToCharArray()) {
                if ($ch -ne ' ') { $g.DrawString([string]$ch, $font, $brush, [single]($pad + $col * $cellW), [single]$y, $fmt) }
                $col++
            }
            $brush.Dispose()
        }
        $y += $cellH
    }
    $g.Dispose()
    $bmp.Save($Path, [System.Drawing.Imaging.ImageFormat]::Png)
    $bmp.Dispose(); $font.Dispose()
    Write-Host ("  {0}  ({1} x {2}, {3} lines)" -f (Split-Path $Path -Leaf), $w, $h, $lines.Count)
}

# ---------------------------------------------------------------- the pictures
Write-Host 'Making the pictures in' $OutFolder

# 1. the start page
$lines = Get-Lines { Show-StartPage -NoClear }
foreach ($l in $lines) { foreach ($p in $l) { $p.Text = $p.Text -replace 'PowerShell Version: 5\.1[\d\.]*', 'PowerShell Version: 7.7.0' } }
Save-Picture $lines (Join-Path $OutFolder 'start-page.png')

# 2. the Network command list: the header, then the three Cisco groups
$all = Get-Lines { Show-NetCommands -NoClear }
$start = 0; $end = $all.Count
for ($i = 0; $i -lt $all.Count; $i++) { if ((Get-LineText $all[$i]).Trim() -eq 'CCNA') { $start = $i; break } }
for ($i = $start; $i -lt $all.Count; $i++) { if ((Get-LineText $all[$i]) -match '^\s+\*{10}') { $end = $i; break } }
$picked = New-Object System.Collections.ArrayList
for ($i = 0; $i -lt 6; $i++) { [void]$picked.Add($all[$i]) }        # title box and the column heads
for ($i = $start - 1; $i -lt $end; $i++) { [void]$picked.Add($all[$i]) }
Save-Picture $picked (Join-Path $OutFolder 'network-commands.png')

# 3. one cheat-sheet page: the title, then the basic setup section
$page = Get-Lines { Show-CcnaOspf -NoClear }
$from = 0; $to = $page.Count
for ($i = 0; $i -lt $page.Count; $i++) { if ((Get-LineText $page[$i]).Trim() -like 'BASIC SETUP*') { $from = $i; break } }
for ($i = $from + 1; $i -lt $page.Count; $i++) { if ((Get-LineText $page[$i]).Trim() -eq 'COST (the metric)') { $to = $i - 1; break } }
$cut = New-Object System.Collections.ArrayList
for ($i = 0; $i -lt 6; $i++) { [void]$cut.Add($page[$i]) }          # title box and the column heads
for ($i = $from - 1; $i -lt $to; $i++) { [void]$cut.Add($page[$i]) }
Save-Picture $cut (Join-Path $OutFolder 'cheat-sheet-page.png')

# 4. one tool: it returns real objects
Save-Picture (Get-Lines { Write-Host ' PaulShell > netcalc 192.168.1.10/24' -ForegroundColor Red; Write-Host ''; Get-NetCalculator 192.168.1.10/24 | Format-List | Out-String -Stream }) (Join-Path $OutFolder 'tool-netcalc.png')

# ---------------------------------------------------------------- clean up what this script added to the session
Remove-Item Function:\Get-Location, Function:\Get-DemoPCInfo, Function:\Get-DemoAdapters, Function:\Get-DemoDisks -ErrorAction SilentlyContinue
Remove-Variable TerminalProStartInfo, TerminalProPromptName -Scope Global -ErrorAction SilentlyContinue
