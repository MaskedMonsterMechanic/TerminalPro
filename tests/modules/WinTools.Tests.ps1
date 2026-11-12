# Extra tests for WinTools. Dot-sourced by Test-Modules.ps1 (so Check and $name are available).
#
# SAFETY: Set-IpDnsRename changes the real machine. These tests never let it do that:
#  - they only use -WhatIf, or inputs that are rejected before anything is changed
#  - the three cmdlets that make the changes are replaced by fakes that only count calls

Write-Host '  -- WinTools: Set-IpDnsRename (safe checks only)'

# Importing the module must not change the machine or the current folder.
Remove-Module WinTools -Force
$policyBefore = (Get-ExecutionPolicy -List | ForEach-Object { "$($_.Scope)=$($_.ExecutionPolicy)" }) -join ';'
$folderBefore = (Get-Location).Path
Import-Module (Join-Path $modules 'WinTools\WinTools.psd1') -Force
$policyAfter = (Get-ExecutionPolicy -List | ForEach-Object { "$($_.Scope)=$($_.ExecutionPolicy)" }) -join ';'
Check 'importing leaves the execution policy alone' ($policyBefore -ceq $policyAfter)
Check 'importing leaves the current folder alone'    ($folderBefore -ceq (Get-Location).Path)

# Fakes: they count calls and change nothing.
$global:TPCalls = New-Object System.Collections.ArrayList
Set-Item function:global:New-NetIPAddress          -Value { $global:TPCalls.Add('New-NetIPAddress') | Out-Null }
Set-Item function:global:Set-DnsClientServerAddress -Value { $global:TPCalls.Add('Set-DnsClientServerAddress') | Out-Null }
Set-Item function:global:Rename-Computer           -Value { $global:TPCalls.Add('Rename-Computer') | Out-Null }

function Throws([scriptblock]$Block) { try { & $Block *>$null; $false } catch { $true } }

try {
    $all = @{ InterfaceAlias = 'Ethernet'; IPv4Address = '192.0.2.10'; PrefixLength = 24; Gateway = '192.0.2.1'
              DnsServer = '192.0.2.53', '192.0.2.54'; ComputerName = 'SRV01'; IPv6Address = '2001:db8::10'; IPv6Gateway = '2001:db8::1' }

    $global:TPCalls.Clear()
    $threw = Throws { Set-IpDnsRename @all -WhatIf }
    Check '-WhatIf with every setting runs without error' (-not $threw)
    Check '-WhatIf changes nothing (no cmdlet was called)'  ($global:TPCalls.Count -eq 0)

    Check 'a bad IPv4 address is rejected'      (Throws { Set-IpDnsRename -InterfaceAlias Ethernet -IPv4Address '300.1.1.1' -PrefixLength 24 -WhatIf })
    Check 'a short IPv4 address is rejected'    (Throws { Set-IpDnsRename -InterfaceAlias Ethernet -IPv4Address '10.1' -PrefixLength 24 -WhatIf })
    Check 'a missing prefix length is rejected' (Throws { Set-IpDnsRename -InterfaceAlias Ethernet -IPv4Address '192.0.2.10' -WhatIf })
    Check 'a prefix length of 33 is rejected'   (Throws { Set-IpDnsRename -InterfaceAlias Ethernet -IPv4Address '192.0.2.10' -PrefixLength 33 -WhatIf })
    Check 'a bad gateway is rejected'           (Throws { Set-IpDnsRename -InterfaceAlias Ethernet -IPv4Address '192.0.2.10' -PrefixLength 24 -Gateway 'nope' -WhatIf })
    Check 'an IPv4 address given as IPv6 is rejected' (Throws { Set-IpDnsRename -InterfaceAlias Ethernet -IPv6Address '192.0.2.10' -WhatIf })
    Check 'an address without an interface is rejected' (Throws { Set-IpDnsRename -IPv4Address '192.0.2.10' -PrefixLength 24 -WhatIf })
    Check 'a bad DNS server is rejected'        (Throws { Set-IpDnsRename -InterfaceAlias Ethernet -DnsServer 'dns.example' -WhatIf })
    Check 'a computer name with a space is rejected' (Throws { Set-IpDnsRename -ComputerName 'my pc' -WhatIf })
    Check 'a computer name over 15 characters is rejected' (Throws { Set-IpDnsRename -ComputerName 'ABCDEFGHIJKLMNOP' -WhatIf })
    Check 'nothing was changed by any rejected call' ($global:TPCalls.Count -eq 0)

    $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $isAdmin) {
        Check 'a real run without administrator rights is refused' (Throws { Set-IpDnsRename @all -Confirm:$false })
        Check 'and it changed nothing' ($global:TPCalls.Count -eq 0)
    }
    else {
        Write-Host '  (skipped: the real-run check, because this prompt is elevated)' -ForegroundColor DarkGray
    }
}
finally {
    foreach ($n in 'New-NetIPAddress', 'Set-DnsClientServerAddress', 'Rename-Computer') { Remove-Item "function:global:$n" -ErrorAction SilentlyContinue }
    Remove-Variable TPCalls -Scope Global -ErrorAction SilentlyContinue
}

# ---------------------------------------------------------------------------------------------
Write-Host '  -- WinTools: app catalogue and Install-WinApp (a fake winget; nothing is installed)'

Import-Module (Join-Path $modules 'WinTools\WinTools.psd1') -Force

# The catalogue that ships with the module.
$apps = @(Get-WinApp)
Check 'catalogue: has a good number of programs' ($apps.Count -ge 30)
Check 'catalogue: every entry names publisher, licence, a web address and a description' (@($apps | Where-Object { -not $_.Publisher -or -not $_.License -or $_.Homepage -notmatch '^https?://' -or -not $_.Description }).Count -eq 0)
Check 'catalogue: categories are from the known list' (@($apps | Where-Object { $_.Category -notin 'Developer', 'Terminal', 'Network', 'System', 'Security', 'Media' }).Count -eq 0)
Check 'catalogue: keys and ids are unique' ((@($apps.Key | Select-Object -Unique).Count -eq $apps.Count) -and (@($apps.Id | ForEach-Object { $_.ToLower() } | Select-Object -Unique).Count -eq $apps.Count))
Check 'catalogue: the file holds no folder paths or user names' (-not ([IO.File]::ReadAllText((Join-Path $modules 'WinTools\Data\apps.psd1')) -match 'C:\\Users|\\AppData\\'))
Check 'Get-WinApp: -Category filters' ((@(Get-WinApp -Category Network).Count -ge 3) -and (@(Get-WinApp -Category Network | Where-Object Category -ne 'Network').Count -eq 0))
Check 'Get-WinApp: part of a name finds the program' ((@(Get-WinApp tree).Key) -contains 'treesize')
Check 'Get-WinApp: an unknown name gives nothing' (@(Get-WinApp 'zzz-no-such-program' -WarningAction SilentlyContinue).Count -eq 0)

# A small catalogue of our own for the install tests.
$tmpCat = Join-Path $env:TEMP ('tp-apps-test-{0}.psd1' -f [guid]::NewGuid().ToString('N'))
$badCat = Join-Path $env:TEMP ('tp-apps-bad-{0}.psd1' -f [guid]::NewGuid().ToString('N'))
$catLines = @(
    '@{'
    '    Apps = @('
    "        @{ Key = 'one'; Name = 'Test One'; Category = 'Developer'; Id = 'Test.One'; Publisher = 'Test Maker'; License = 'MIT'; Homepage = 'https://example.com/one'; Description = 'First test program'; Note = 'A note.' }"
    "        @{ Key = 'two'; Name = 'Test Two'; Category = 'Network'; Id = 'Test.Two'; Publisher = 'Test Maker'; License = 'GPL-3.0'; Homepage = 'https://example.com/two'; Description = 'Second test program'; Note = '' }"
    '    )'
    '}'
)
[IO.File]::WriteAllText($tmpCat, ($catLines -join "`r`n"), (New-Object Text.UTF8Encoding $false))

function Throws([scriptblock]$Block) { try { & $Block *>$null; $false } catch { $true } }
$entry = "Name = 'A'; Category = 'Developer'; License = 'L'; Homepage = 'https://e.com'; Description = 'D'"
$badCatalogues = @(
    "@{ Apps = @( @{ Key = 'a'; Id = 'X.A'; Publisher = 'P'; $entry }, @{ Key = 'a'; Id = 'X.B'; Publisher = 'P'; $entry } ) }"   # a key used twice
    "@{ Apps = @( @{ Key = 'a'; Id = 'X.A'; $entry } ) }"                                                                          # no publisher
    "@{ Apps = @( @{ Key = 'a'; Id = 'X.A; calc'; Publisher = 'P'; $entry } ) }"                                                     # a bad id
)
$badRefused = 0
foreach ($bad in $badCatalogues) {
    [IO.File]::WriteAllText($badCat, $bad, (New-Object Text.UTF8Encoding $false))
    if (Throws { Get-WinApp -Path $badCat }) { $badRefused++ }
}
Check 'a catalogue with a duplicate key, a missing publisher or a bad id is refused' ($badRefused -eq 3)

# Fake winget: records what it was asked, answers "show" with a publisher, returns a chosen exit code for "install".
$global:TPWinget = New-Object System.Collections.ArrayList
$global:TPPublisher = 'Test Maker'
$global:TPExit = 0
Set-Item function:global:winget -Value {
    $global:TPWinget.Add(($args -join ' ')) | Out-Null
    if ($args[0] -eq 'show') {
        $global:LASTEXITCODE = 0
        'Found Test [' + $args[2] + ']'
        if ($global:TPPublisher) { 'Publisher: ' + $global:TPPublisher }
        'Installer SHA256: 0123abcd'
    }
    else {
        $global:LASTEXITCODE = $global:TPExit
        'fake installer output'
    }
}
function Installs { @($global:TPWinget | Where-Object { $_ -like 'install *' }) }

try {
    $global:TPWinget.Clear()
    $r = @(Install-WinApp one, two -Path $tmpCat -WhatIf 6>$null)
    Check 'Install-WinApp -WhatIf: looks the programs up but installs nothing' (((Installs).Count -eq 0) -and (@($global:TPWinget | Where-Object { $_ -like 'show *' }).Count -eq 2) -and ($r.Count -eq 0))

    $global:TPWinget.Clear(); $global:TPExit = 0
    $r = @(Install-WinApp one -Path $tmpCat -Confirm:$false 6>$null)
    $line = (Installs | Select-Object -First 1)
    Check 'Install-WinApp: installs a program from the catalogue' (($r.Count -eq 1) -and ($r[0].Status -eq 'Installed') -and ($r[0].Id -eq 'Test.One'))
    Check 'Install-WinApp: asks winget for the exact id, from the winget source, silent' (($line -match '--id Test\.One') -and ($line -match ' -e ') -and ($line -match '--source winget') -and ($line -match '--silent') -and ($line -match '--accept-package-agreements'))

    $global:TPWinget.Clear(); $global:TPPublisher = 'Somebody Else'
    $r = @(Install-WinApp one -Path $tmpCat -Confirm:$false -ErrorAction SilentlyContinue -ErrorVariable ev 6>$null)
    Check 'Install-WinApp: a changed publisher is refused, and nothing is installed' (((Installs).Count -eq 0) -and ($r.Count -eq 0) -and ("$ev" -match 'Somebody Else'))

    $global:TPWinget.Clear(); $global:TPPublisher = ''
    $r = @(Install-WinApp one -Path $tmpCat -Confirm:$false -ErrorAction SilentlyContinue 6>$null)
    Check 'Install-WinApp: when the publisher cannot be read, nothing is installed' (((Installs).Count -eq 0) -and ($r.Count -eq 0))

    $global:TPWinget.Clear(); $global:TPPublisher = 'Somebody Else'
    $r = @(Install-WinApp one -Path $tmpCat -Confirm:$false -SkipPublisherCheck 6>$null)
    Check 'Install-WinApp: -SkipPublisherCheck installs anyway' (((Installs).Count -eq 1) -and ($r[0].Status -eq 'Installed'))
    $global:TPPublisher = 'Test Maker'

    $global:TPWinget.Clear()
    $r = @(Install-WinApp 'not-in-the-list' -Path $tmpCat -Confirm:$false -ErrorAction SilentlyContinue 6>$null)
    Check 'Install-WinApp: a key that is not in the catalogue is refused, and winget is never called' (($global:TPWinget.Count -eq 0) -and ($r.Count -eq 0))

    $global:TPWinget.Clear()
    $r = @(Install-WinApp 'one; calc' -Path $tmpCat -Confirm:$false -ErrorAction SilentlyContinue 6>$null)
    Check 'Install-WinApp: a key with extra commands in it is refused' (($global:TPWinget.Count -eq 0) -and ($r.Count -eq 0))

    $global:TPExit = -1978335189
    $r = @(Install-WinApp one -Path $tmpCat -Confirm:$false 6>$null)
    Check 'Install-WinApp: "no newer version" is reported as AlreadyUpToDate' ($r[0].Status -eq 'AlreadyUpToDate')

    $global:TPExit = 1
    $r = @(Install-WinApp one -Path $tmpCat -Confirm:$false -WarningAction SilentlyContinue 6>$null)
    Check 'Install-WinApp: a failing install is reported as Failed with its exit code' (($r[0].Status -eq 'Failed') -and ($r[0].ExitCode -eq 1))
    $global:TPExit = 0

    $global:TPWinget.Clear()
    $r = @(Get-WinApp -Path $tmpCat | Install-WinApp -Path $tmpCat -Confirm:$false 6>$null)
    Check 'Install-WinApp: programs can be sent in from Get-WinApp' (($r.Count -eq 2) -and ((Installs).Count -eq 2))

    $global:TPWinget.Clear()
    $r = @(Install-WinApp ONE -Path $tmpCat -Confirm:$false 6>$null)
    Check 'Install-WinApp: keys are not case sensitive' ($r.Count -eq 1)
}
finally {
    Remove-Item function:global:winget -ErrorAction SilentlyContinue
    Remove-Item $tmpCat, $badCat -ErrorAction SilentlyContinue
    Remove-Variable TPWinget, TPPublisher, TPExit -Scope Global -ErrorAction SilentlyContinue
}
