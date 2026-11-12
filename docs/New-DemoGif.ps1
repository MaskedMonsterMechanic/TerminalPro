<#
.SYNOPSIS
    Makes a short animated GIF for the README: a PaulShell demo with FAKE data.

.DESCRIPTION
    Reuses the same idea as New-Screenshots.ps1: real commands, made-up PC and
    addresses, drawn as a dark terminal. Nothing private can get into the GIF.
    Scenes: the prompt, the start page, netcalc, and a port check.

.PARAMETER OutPath
    Where the GIF goes. Default: docs\images\demo.gif

.EXAMPLE
    .\docs\New-DemoGif.ps1
#>
[CmdletBinding()]
param([string]$OutPath)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$root = Split-Path $here -Parent
if (-not $OutPath) { $OutPath = Join-Path $here 'images\demo.gif' }
$env:PSModulePath = "$(Join-Path $root 'modules');$env:PSModulePath"
$env:TERMINALPRO_WIDTH = '88'
Remove-Item Env:\NO_COLOR -ErrorAction SilentlyContinue
try { $Host.UI.RawUI.ForegroundColor = 'Gray' } catch { }
foreach ($m in 'TerminalPro.Core', 'AdminTools', 'Network', 'Unix', 'Markdown', 'WinTools') {
    Import-Module $m -Force
}

# ---------------------------------------------------------------- fake data
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
}
function global:Get-DemoDisks {
    foreach ($d in @(@('C', '', 612.4, 930.6), @('D', 'Projects', 140.2, 223.6))) {
        [pscustomobject]@{ PSTypeName = 'TerminalPro.DiskStorage'; ComputerName = 'DEMO-PC'; Drive = $d[0]; Label = $d[1]; FileSystem = 'NTFS'
            Health = 'Healthy'; FreeGB = $d[2]; FreePercent = [math]::Round(100 * $d[2] / $d[3]); SizeGB = $d[3] }
    }
}
$global:TerminalProStartInfo = 'Get-DemoPCInfo', 'Get-DemoAdapters', 'Get-DemoDisks'
function global:Get-Location { [pscustomobject]@{ Path = 'C:\Users\demo\Documents' } }

# ---------------------------------------------------------------- catch coloured output
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
            foreach ($t in ($text -split "`r?`n")) {
                [void]$lines.Add((New-Object System.Collections.ArrayList (, @(@{ Text = $t; Color = '' }))))
            }
        }
    }
    if ($current.Count) { [void]$lines.Add($current) }
    , $lines
}
function Get-LineText($line) { ($line | ForEach-Object { $_.Text }) -join '' }

$palette = @{
    '' = '#CCCCCC'; 'Black' = '#0C0C0C'; 'DarkBlue' = '#0037DA'; 'DarkGreen' = '#13A10E'; 'DarkCyan' = '#3A96DD'
    'DarkRed' = '#C50F1F'; 'DarkMagenta' = '#881798'; 'DarkYellow' = '#C19C00'; 'Gray' = '#CCCCCC'; 'DarkGray' = '#767676'
    'Blue' = '#3B78FF'; 'Green' = '#16C60C'; 'Cyan' = '#61D6D6'; 'Red' = '#E74856'; 'Magenta' = '#B4009E'
    'Yellow' = '#F9F1A5'; 'White' = '#F2F2F2'
}
function ToColor([string]$name) {
    $hex = if ($palette.ContainsKey($name)) { $palette[$name] } else { $palette[''] }
    [System.Drawing.ColorTranslator]::FromHtml($hex)
}

# Fixed canvas so every GIF frame is the same size
$canvasW = 920
$canvasH = 520
$font = New-Object System.Drawing.Font('Consolas', 14, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$fmt = [System.Drawing.StringFormat]::GenericTypographic
$probe = New-Object System.Drawing.Bitmap 10, 10
$pg = [System.Drawing.Graphics]::FromImage($probe)
$cellW = [Math]::Ceiling($pg.MeasureString('MMMMMMMMMM', $font, 1000, $fmt).Width / 10 * 100) / 100
$cellH = [Math]::Ceiling($font.GetHeight($pg) + 2)
$pg.Dispose(); $probe.Dispose()
$pad = 16
$maxCols = [int](($canvasW - 2 * $pad) / $cellW)
$maxRows = [int](($canvasH - 2 * $pad) / $cellH)

function New-Frame([System.Collections.IEnumerable]$lines) {
    $bmp = New-Object System.Drawing.Bitmap $canvasW, $canvasH
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.Clear((ToColor 'Black'))
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
    $y = $pad
    $row = 0
    foreach ($line in $lines) {
        if ($row -ge $maxRows) { break }
        $col = 0
        foreach ($piece in $line) {
            $brush = New-Object System.Drawing.SolidBrush (ToColor $piece.Color)
            foreach ($ch in $piece.Text.ToCharArray()) {
                if ($col -ge $maxCols) { break }
                if ($ch -ne ' ') {
                    $g.DrawString([string]$ch, $font, $brush, [single]($pad + $col * $cellW), [single]$y, $fmt)
                }
                $col++
            }
            $brush.Dispose()
            if ($col -ge $maxCols) { break }
        }
        $y += $cellH
        $row++
    }
    $g.Dispose()
    $bmp
}

function New-PromptLines([string]$Typed) {
    $lines = New-Object System.Collections.ArrayList
    [void]$lines.Add((New-Object System.Collections.ArrayList (, @(
        @{ Text = ' PaulShell > '; Color = 'Red' }
        @{ Text = $Typed; Color = 'White' }
    ))))
    , $lines
}

function Add-HeldFrame([System.Collections.ArrayList]$bag, $bmp, [int]$Copies) {
    for ($i = 0; $i -lt $Copies; $i++) {
        [void]$bag.Add($bmp.Clone())
    }
}

# ---------------------------------------------------------------- scenes
Write-Host 'Making demo GIF frames...'
$frames = New-Object System.Collections.ArrayList

# 1. empty prompt
$b = New-Frame (New-PromptLines '')
Add-HeldFrame $frames $b 8
$b.Dispose()

# 2. typing home
foreach ($t in @('h', 'ho', 'hom', 'home')) {
    $b = New-Frame (New-PromptLines $t)
    Add-HeldFrame $frames $b 2
    $b.Dispose()
}

# 3. start page (cropped to canvas)
$start = Get-Lines { Show-StartPage -NoClear }
foreach ($l in $start) {
    foreach ($p in $l) {
        $p.Text = $p.Text -replace 'PowerShell Version: 5\.1[\d\.]*', 'PowerShell Version: 7.7.0'
    }
}
$b = New-Frame $start
Add-HeldFrame $frames $b 22
$b.Dispose()

# 4. typing netcalc
$cmd = 'netcalc 192.0.2.10/24'
for ($i = 1; $i -le $cmd.Length; $i += 2) {
    $b = New-Frame (New-PromptLines $cmd.Substring(0, [Math]::Min($i, $cmd.Length)))
    Add-HeldFrame $frames $b 1
    $b.Dispose()
}
$b = New-Frame (New-PromptLines $cmd)
Add-HeldFrame $frames $b 3
$b.Dispose()

# 5. netcalc output under the prompt
$calc = Get-Lines {
    Write-Host ' PaulShell > netcalc 192.0.2.10/24' -ForegroundColor Red
    Write-Host ''
    Get-NetCalculator 192.0.2.10/24 | Format-List | Out-String -Stream
}
$b = New-Frame $calc
Add-HeldFrame $frames $b 22
$b.Dispose()

# 6. typing a port check
$cmd2 = 'Test-TcpPort 192.0.2.10 80,443,3389'
for ($i = 1; $i -le $cmd2.Length; $i += 3) {
    $b = New-Frame (New-PromptLines $cmd2.Substring(0, [Math]::Min($i, $cmd2.Length)))
    Add-HeldFrame $frames $b 1
    $b.Dispose()
}

# 7. fake port results (no real network call; invented rows)
$portOut = Get-Lines {
    Write-Host ' PaulShell > Test-TcpPort 192.0.2.10 80,443,3389' -ForegroundColor Red
    Write-Host ''
    @(
        [pscustomobject]@{ ComputerName = '192.0.2.10'; Port = 80;   Open = $true;  Result = 'Open';    Milliseconds = 12 }
        [pscustomobject]@{ ComputerName = '192.0.2.10'; Port = 443;  Open = $true;  Result = 'Open';    Milliseconds = 15 }
        [pscustomobject]@{ ComputerName = '192.0.2.10'; Port = 3389; Open = $false; Result = 'Timeout'; Milliseconds = 1000 }
    ) | Format-Table -AutoSize | Out-String -Stream
}
$b = New-Frame $portOut
Add-HeldFrame $frames $b 22
$b.Dispose()

# 8. end on the prompt again
$b = New-Frame (New-PromptLines '')
Add-HeldFrame $frames $b 10
$b.Dispose()

Write-Host ("  {0} frames" -f $frames.Count)

# ---------------------------------------------------------------- write animated GIF (repeat frames = hold time; browser ~10 fps)
$dir = Split-Path $OutPath -Parent
if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }

$encoder = New-Object System.Windows.Media.Imaging.GifBitmapEncoder
foreach ($bmp in $frames) {
    $ms = New-Object System.IO.MemoryStream
    $bmp.Save($ms, [System.Drawing.Imaging.ImageFormat]::Png)
    [void]$ms.Seek(0, 'Begin')
    $bi = New-Object System.Windows.Media.Imaging.BitmapImage
    $bi.BeginInit()
    $bi.StreamSource = $ms
    $bi.CacheOption = [System.Windows.Media.Imaging.BitmapCacheOption]::OnLoad
    $bi.EndInit()
    $bi.Freeze()
    $encoder.Frames.Add([System.Windows.Media.Imaging.BitmapFrame]::Create($bi))
    $bmp.Dispose()
    $ms.Dispose()
}
$fs = [System.IO.File]::Open($OutPath, [System.IO.FileMode]::Create)
$encoder.Save($fs)
$fs.Dispose()
$font.Dispose()

# clean up session fakes
Remove-Item Function:\Get-Location, Function:\Get-DemoPCInfo, Function:\Get-DemoAdapters, Function:\Get-DemoDisks -ErrorAction SilentlyContinue
Remove-Variable TerminalProStartInfo, TerminalProPromptName -Scope Global -ErrorAction SilentlyContinue
Remove-Item Env:\TERMINALPRO_WIDTH -ErrorAction SilentlyContinue

$item = Get-Item -LiteralPath $OutPath
Write-Host ("Wrote {0} ({1:N0} KB)" -f $item.FullName, ($item.Length / 1KB))
