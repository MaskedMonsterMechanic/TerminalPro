<#
.SYNOPSIS
    Tests every module in modules\ : manifest, exports against the sheet files, content and rendering.
    Read-only. Nothing is installed.
#>
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$root    = Split-Path $PSScriptRoot -Parent
$modules = Join-Path $root 'modules'
$env:PSModulePath = "$modules;$env:PSModulePath"
$script:failed = 0

function Check([string]$Name, [bool]$Ok) {
    if ($Ok) { Write-Host "  PASS  $Name" -ForegroundColor Green }
    else     { Write-Host "  FAIL  $Name" -ForegroundColor Red; $script:failed++ }
}
function Capture([scriptblock]$Block) { (& $Block *>&1 | Out-String) }

# Joins what Write-Host printed, honouring -NoNewline (each coloured piece is its own record).
function CaptureLine([scriptblock]$Block) {
    $records = & $Block 6>&1
    $text = ''
    foreach ($r in $records) {
        $m = $r.MessageData
        if ($m -is [System.Management.Automation.HostInformationMessage]) { $text += $m.Message; if (-not $m.NoNewLine) { $text += "`n" } }
        else { $text += [string]$m + "`n" }
    }
    $text
}

# ------------------------------------------------------------ README
Write-Host "`nREADME"
$readmeText = [IO.File]::ReadAllText((Join-Path $root 'README.md'))
$imageLinks = @([regex]::Matches($readmeText, '!\[[^\]]*\]\(([^)]+)\)') | ForEach-Object { $_.Groups[1].Value })
$missingImages = @($imageLinks | Where-Object { $_ -notmatch '^https?://' -and -not (Test-Path (Join-Path $root $_)) })
Check 'the README has pictures' ($imageLinks.Count -ge 1)
Check 'every picture in the README exists' ($missingImages.Count -eq 0)
$missingImages | ForEach-Object { Write-Host "        missing: $_" -ForegroundColor Red }
Check 'LICENSE file exists' (Test-Path (Join-Path $root 'LICENSE'))

# ------------------------------------------------------------ Core
Write-Host "`nTerminalPro.Core"
Import-Module (Join-Path $modules 'TerminalPro.Core') -Force
Check 'manifest is valid' ([bool](Test-ModuleManifest (Join-Path $modules 'TerminalPro.Core\TerminalPro.Core.psd1') -ErrorAction SilentlyContinue))
$exported = (Get-Command -Module TerminalPro.Core).Name | Sort-Object
Check 'exports the 5 public commands' (($exported -join ',') -eq 'Find-CheatSheet,Show-CheatSheet,Show-CheatSheetIndex,Show-StartPage,Write-Color')
Check 'the alias home opens the start page' ((Get-Alias home -ErrorAction SilentlyContinue).Definition -eq 'Show-StartPage')
$global:TerminalProStartInfo = 'No-Such-Command-Here'
$startText = Capture { Show-StartPage -NoClear }
Remove-Variable TerminalProStartInfo -Scope Global -ErrorAction SilentlyContinue
Check 'start page: header and PowerShell version' ($startText -match '- START' -and $startText -match 'PowerShell Version: \d')
Check 'start page: lists every Terminal Pro module command' ($startText -match 'Show-AdminCommands' -and $startText -match 'Show-NetCommands' -and $startText -match 'Show-UnixCommands' -and $startText -match 'Show-WinToolsCommands')
Check 'start page: does not list the engine itself' ($startText -notmatch 'TerminalPro.Core')
Check 'start page: tells how to come back' ($startText -match 'home')

# Start page views: fake objects, drawn through the module's private helpers.
$fakeAdapters = @(
    [pscustomobject]@{ Adapter = 'Eth0'; IPAddress = '192.0.2.5'; PrefixLength = 24; Gateway = '192.0.2.1'; DnsServers = @('192.0.2.53', $null); Description = 'Test NIC'; Status = 'Up'; Speed = '1 Gbps'; Type = 'Unicast'; MediaType = '802.3' }
    [pscustomobject]@{ Adapter = 'Eth1'; IPAddress = $null; PrefixLength = $null; Gateway = $null; DnsServers = @($null); Description = 'Idle NIC'; Status = 'Disconnected'; Speed = '0 bps'; Type = $null; MediaType = '802.3' }
)
$adapterText = CaptureLine { & (Get-Module TerminalPro.Core) { param($i) Write-StartAdapters -Items $i } $fakeAdapters }
Check 'start page adapters: one line per adapter' (@($adapterText -split "`r?`n" | Where-Object { $_ -match 'Eth\d' }).Count -eq 2)
Check 'start page adapters: address, gateway and DNS on the line' ($adapterText -match 'Eth0\s+192\.0\.2\.5/24\s+192\.0\.2\.1\s+192\.0\.2\.53\s')
Check 'start page adapters: empty DNS and address show a dash' ($adapterText -match 'Eth1\s+-\s+-\s+-')
Check 'start page adapters: no Type or MediaType column' ($adapterText -notmatch 'Unicast|802\.3|MEDIATYPE')
$fakePC = [pscustomobject]@{ Name = 'fake-pc'; Owner = 'Jane'; Domain = 'WORKGROUP'; Manufacturer = 'Acme'; Model = 'X1'; OS = 'Test OS'; Version = '1H1'; Build = '1.2.3'; Uptime = (New-TimeSpan -Days 2 -Hours 3 -Minutes 4); CPU = 'Test CPU'; RamGB = 16 }
$pcText = CaptureLine { & (Get-Module TerminalPro.Core) { param($i) Write-StartPC -Items $i } $fakePC }
Check 'start page PC: the computer name (upper case) is the header' ($pcText -match '(?m)^ FAKE-PC\s*$')
Check 'start page PC: system, hardware, CPU, memory, uptime and owner lines' ($pcText -match 'SYSTEM\s+Test OS 1H1\s+\(build 1\.2\.3\)' -and $pcText -match 'HARDWARE\s+Acme\s+X1' -and $pcText -match 'CPU\s+Test CPU' -and $pcText -match 'MEMORY\s+16[.,]0 GB' -and $pcText -match 'UPTIME\s+2d 3h 4m' -and $pcText -match 'OWNER\s+Jane\s+\(WORKGROUP\)')
$fakeDisks = @(
    [pscustomobject]@{ ComputerName = 'FAKE-PC'; Drive = 'C'; Label = ''; Health = 'Healthy'; FreeGB = 80; FreePercent = 80; SizeGB = 100 }
    [pscustomobject]@{ ComputerName = 'FAKE-PC'; Drive = 'D'; Label = 'Data'; Health = 'Healthy'; FreeGB = 30; FreePercent = 30; SizeGB = 100 }
    [pscustomobject]@{ ComputerName = 'FAKE-PC'; Drive = 'E'; Label = 'Full'; Health = 'Warning'; FreeGB = 5; FreePercent = 5; SizeGB = 100 }
)
$diskText = CaptureLine { & (Get-Module TerminalPro.Core) { param($i) Write-StartDisks -Items $i } $fakeDisks }
Check 'start page disks: one line per drive, no computer name' (@($diskText -split "`r?`n" | Where-Object { $_ -match '^ [CDE]:' }).Count -eq 3 -and $diskText -notmatch 'FAKE-PC')
Check 'start page disks: shows a warning for an unhealthy drive' ($diskText -match 'E:.*! Warning')
$colorOf = { param($p) & (Get-Module TerminalPro.Core) { param($x) Get-TPFreeColor $x } $p }
Check 'free space colours: over half is green' ((& $colorOf 80) -eq 'Green' -and (& $colorOf 50) -eq 'Green')
Check 'free space colours: 10% up to half is yellow' ((& $colorOf 30) -eq 'Yellow' -and (& $colorOf 10) -eq 'Yellow')
Check 'free space colours: under 10% is red' ((& $colorOf 9) -eq 'Red' -and (& $colorOf 0) -eq 'Red')
Check 'Write-Color prints text without the codes' ((CaptureLine { Write-Color 'a ^crb^cg c^cn d' }).TrimEnd() -ceq 'a b c d')
Check 'Write-Color keeps an unknown code as text'  ((CaptureLine { Write-Color 'x ^czy' }).Trim() -ceq 'x ^czy')
Check 'Write-Color handles text with no codes'      ((CaptureLine { Write-Color 'plain' }).Trim() -ceq 'plain')
Check 'Write-Color -NoNewline does not end the line' ((CaptureLine { Write-Color 'a^crb' -NoNewline }) -ceq 'ab')
Check 'Write-Color codes are case-sensitive (e vs E)' ((CaptureLine { Write-Color '^ceA^cEB' }).Trim() -ceq 'AB')

# ------------------------------------------------------------ sheet modules
foreach ($dir in Get-ChildItem $modules -Directory | Where-Object { Test-Path (Join-Path $_.FullName 'Sheets') }) {
    $name = $dir.Name
    Write-Host "`n$name"
    $manifestPath = Join-Path $dir.FullName "$name.psd1"
    Check 'manifest is valid' ([bool](Test-ModuleManifest $manifestPath -ErrorAction SilentlyContinue))

    $files  = Get-ChildItem (Join-Path $dir.FullName 'Sheets') -Filter '*.psd1'
    $sheets = foreach ($f in $files) { $d = Import-PowerShellDataFile $f.FullName; [pscustomobject]@{ File = $f; Data = $d } }

    Import-Module $manifestPath -Force
    $cmds    = @($sheets | ForEach-Object { $_.Data.Command } | Where-Object { $_ } | Sort-Object)
    $aliases = @($sheets | ForEach-Object { $_.Data.Alias }   | Where-Object { $_ } | Sort-Object)
    $gotCmds    = @((Get-Command -Module $name -CommandType Function).Name | Sort-Object)
    $gotAliases = @((Get-Command -Module $name -CommandType Alias).Name | Sort-Object)
    Check "commands match the sheet files ($($cmds.Count))"  (($cmds -join ',') -eq ($gotCmds -join ','))
    Check "aliases match the sheet files ($($aliases.Count))" (($aliases -join ',') -eq ($gotAliases -join ','))
    Check 'no duplicate commands or aliases' (($cmds | Select-Object -Unique).Count -eq $cmds.Count -and ($aliases | Select-Object -Unique).Count -eq $aliases.Count)

    $indexes = @($sheets | Where-Object { $_.Data.Kind -eq 'Index' })
    Check 'exactly one index sheet' ($indexes.Count -eq 1)

    $bad = @()
    foreach ($s in $sheets) {
        $text = [IO.File]::ReadAllText($s.File.FullName)
        if ($text -match '[^\x00-\x7F]')      { $bad += "$($s.File.Name): non-ASCII character" }
        if ($text -match 'C:\\Users')          { $bad += "$($s.File.Name): hardcoded C:\Users path" }
        if (-not $s.Data.Title -and $s.Data.Kind -ne 'Command') { $bad += "$($s.File.Name): no Title" }
        if ($s.Data.Kind -notin 'Index', 'Command' -and -not $s.Data.Sections) { $bad += "$($s.File.Name): no Sections" }
        if (-not $s.Data.Synopsis)             { $bad += "$($s.File.Name): no Synopsis" }
    }
    Check 'every sheet has Title, Synopsis, Sections, plain ASCII, no C:\Users' ($bad.Count -eq 0)
    $bad | ForEach-Object { Write-Host "        $_" -ForegroundColor Red }

    # Only real cheat-sheets are rendered. 'Index' pages are drawn from the others, and
    # 'Command' entries are real commands that must never be run by a test.
    $pages = @($sheets | Where-Object { $_.Data.Kind -notin 'Command' })

    $emptyRows = @()
    foreach ($s in $sheets | Where-Object { $_.Data.Kind -notin 'Index', 'Command' }) {
        $rows = @(Show-CheatSheet -Path $s.File.FullName -AsObject)
        if ($rows.Count -eq 0) { $emptyRows += "$($s.File.Name): no rows" }
        $rows | Where-Object { -not $_.Input -or -not $_.Output } | ForEach-Object { $emptyRows += "$($s.File.Name): empty input/output near '$($_.Input)$($_.Output)'" }
    }
    Check 'every row has an input and an output' ($emptyRows.Count -eq 0)
    $emptyRows | Select-Object -First 8 | ForEach-Object { Write-Host "        $_" -ForegroundColor Red }

    $renderBad = @()
    foreach ($s in $pages) {
        $cmd = $s.Data.Command
        try {
            $out = Capture { & $cmd -NoClear }
            if ($out -notmatch [regex]::Escape($s.Data.Title)) { $renderBad += "$cmd did not print its title" }
        }
        catch { $renderBad += "$cmd threw: $($_.Exception.Message)" }
    }
    Check 'every command renders and prints its title' ($renderBad.Count -eq 0)
    $renderBad | ForEach-Object { Write-Host "        $_" -ForegroundColor Red }

    # In a small window no line may be wider than the window (long text wraps inside its column).
    $wideBad = @()
    foreach ($width in 80, 50) {
        $env:TERMINALPRO_WIDTH = "$width"
        try {
            foreach ($s in $pages) {
                $longest = ((CaptureLine { & $s.Data.Command -NoClear }) -split "`n" | ForEach-Object { $_.TrimEnd("`r").Length } | Measure-Object -Maximum).Maximum
                if ($longest -gt ($width - 1)) { $wideBad += "$($s.Data.Command) has a line of $longest characters in a $width-wide window" }
            }
        }
        finally { Remove-Item Env:\TERMINALPRO_WIDTH -ErrorAction SilentlyContinue }
    }
    Check 'pages fit a small window (no line wider than the window)' ($wideBad.Count -eq 0)
    $wideBad | Select-Object -First 8 | ForEach-Object { Write-Host "        $_" -ForegroundColor Red }

    # Every index and page ends with a line that leads back to the start page.
    if ($indexes.Count -eq 1) {
        Check 'the index page ends with a "home" line' ((Capture { & $indexes[0].Data.Command -NoClear }) -match 'Show-StartPage')
    }
    # The index shows its groups by their lowest Order number (for Network: CCNA, then CCNP, then CCIE).
    if ($indexes.Count -eq 1) {
        $withOrder = $sheets | Where-Object { $_.Data.Command -and $_.Data.Group }
        $expected  = @($withOrder | Group-Object { $_.Data.Group } | Sort-Object @{ Expression = { ($_.Group | ForEach-Object { [int]$_.Data.Order } | Measure-Object -Minimum).Minimum } }, Name | ForEach-Object { $_.Name })
        $shown     = @((CaptureLine { & $indexes[0].Data.Command -NoClear }) -split "`r?`n" | Where-Object { $_ -match '^ \S' -and $expected -contains $_.Trim() } | ForEach-Object { $_.Trim() })
        $same = ($shown.Count -gt 0) -and (($shown -join '|') -eq (($expected | Where-Object { $shown -contains $_ }) -join '|'))
        Check 'the index shows its groups in Order-number order' $same
    }
    $anyPage = $pages | Where-Object { $_.Data.Kind -notin 'Index' } | Select-Object -First 1
    if ($anyPage) {
        Check 'a cheat-sheet page ends with a "home" line' ((Capture { & $anyPage.Data.Command -NoClear }) -match 'Show-StartPage')
    }

    # A module may have tools only and no cheat-sheet page (yet); then there is nothing to filter.
    $first = $sheets | Where-Object { $_.Data.Kind -notin 'Index', 'Command' } | Select-Object -First 1
    if ($first) {
        $word  = (Show-CheatSheet -Path $first.File.FullName -AsObject | Select-Object -First 1).Input.Split(' ')[0]
        Check "-Filter keeps only matching rows ('$word')" ((Capture { & $first.Data.Command -NoClear -Filter $word }) -match [regex]::Escape($word))
        Check "-Filter with no match says so" ((Capture { & $first.Data.Command -NoClear -Filter 'zzzz-no-such-thing' }) -match 'Nothing matches')
        Check 'Find-CheatSheet finds a row in this module' (@(Find-CheatSheet $word -Module $name).Count -gt 0)
    }

    # Tests that belong to one module only (tests\modules\<Name>.Tests.ps1).
    $custom = Join-Path $PSScriptRoot "modules\$name.Tests.ps1"
    if (Test-Path $custom) { . $custom }

    Remove-Module $name -Force
}

Write-Host ''
if ($script:failed -eq 0) { Write-Host 'All checks passed.' -ForegroundColor Green }
else { Write-Host "$script:failed check(s) failed." -ForegroundColor Red; exit 1 }
