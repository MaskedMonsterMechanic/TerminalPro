# Extra tests for AdminTools. Dot-sourced by Test-Modules.ps1 (so Check, $name, $modules and $dir are available).
#
# SAFETY: the read-only commands (Get-PCInfo, Get-DiskStorage, Get-NetIPAdapter) run for real on this
# computer. Everything that starts, runs or creates something is only tested with -WhatIf, bad input,
# or with Start-Process / New-CimSession / Register-ScheduledTask replaced by fakes that only count.

Write-Host '  -- AdminTools: the tools'

# ---- no hard-coded paths, no system changes in the module's code
$code = Get-ChildItem $dir.FullName -Recurse -Include *.ps1, *.psm1 | ForEach-Object { [IO.File]::ReadAllText($_.FullName) }
Check 'no hard-coded user or Program Files paths in the code' (-not ($code -match 'C:\\Users|Program Files'))
Check 'the code never changes the execution policy'          (-not ($code -match 'Set-ExecutionPolicy'))

# ---- read-only tools
$pc = Get-PCInfo
Check 'Get-PCInfo returns this computer'            ($pc.Name -ieq $env:COMPUTERNAME)
Check 'Get-PCInfo has OS, uptime and RAM'           ($pc.OS -and ($pc.Uptime -is [timespan]) -and $pc.RamGB -gt 0)
Check 'Get-PCInfo shows the table of the list view' ((Get-PCInfo | Out-String) -match 'Uptime\s*:\s*\d+d \d+h \d+m')
Check 'Get-PCInfo -ComputerName with a bad name is an error, not a crash' ($null -eq (Get-PCInfo -ComputerName 'no-such-computer.invalid' -ErrorAction SilentlyContinue))

$disks = @(Get-DiskStorage)
$c = $disks | Where-Object Drive -eq 'C'
Check 'Get-DiskStorage returns the C drive'         ([bool]$c)
Check 'Get-DiskStorage numbers make sense'          ($c.SizeGB -gt 0 -and $c.FreeGB -le $c.SizeGB -and $c.FreePercent -ge 0 -and $c.FreePercent -le 100)
Check 'Get-DiskStorage prints the old column names' ((Get-DiskStorage | Out-String) -match 'Free \(GB\)\s+Free %\s+Size \(GB\)')
Check 'Get-DiskStorage -All shows at least as many' (@(Get-DiskStorage -All).Count -ge $disks.Count)

$adapters = @(Get-NetIPAdapter -All -IPv6)
Check 'Get-NetIPAdapter -All runs'                  ($adapters.Count -ge 0)
if ($adapters.Count -gt 0) {
    Check 'Get-NetIPAdapter objects have the expected properties' (($adapters[0].PSObject.Properties.Name -join ',') -ceq 'Adapter,Family,IPAddress,PrefixLength,Type,Gateway,DnsServers,Description,Status,Speed,MediaType')
    Check 'Get-NetIPAdapter prints a table with CIDR and Gateway' ((Get-NetIPAdapter -All | Out-String) -match 'Adapter\s+Family\s+IP Address\s+CIDR\s+Gateway')
}

# ---- Show-ModuleList reads the real modules
$list = @(Show-ModuleList)
Check 'Show-ModuleList finds every Terminal Pro module' ((($list.Name | Sort-Object) -join ',') -ceq 'AdminTools,Markdown,Network,Unix,WinTools')
Check 'Show-ModuleList gives each module its index command'    (($list | Where-Object Name -eq 'Unix').Command -ceq 'Show-UnixCommands' -and ($list | Where-Object Name -eq 'AdminTools').Alias -ceq 'admincmd')

# ---- fakes: they count and change nothing
$global:TPCalls = New-Object System.Collections.ArrayList
Set-Item function:global:Start-Process          -Value { $global:TPCalls.Add('Start-Process') | Out-Null }
Set-Item function:global:New-CimSession         -Value { $global:TPCalls.Add('New-CimSession') | Out-Null }
Set-Item function:global:Register-ScheduledTask -Value { $global:TPCalls.Add('Register-ScheduledTask') | Out-Null }
Set-Item function:global:Restart-Service        -Value { [CmdletBinding()] param($Name) $global:TPCalls.Add('Restart-Service ' + $Name) | Out-Null }
Set-Item function:global:Get-CimInstance        -Value { $global:TPCalls.Add('Get-CimInstance') | Out-Null }
Set-Item function:global:Invoke-CimMethod       -Value { $global:TPCalls.Add('Invoke-CimMethod') | Out-Null }

function Throws([scriptblock]$Block) { try { & $Block *>$null; $false } catch { $true } }
$tmp = Join-Path ([IO.Path]::GetTempPath()) ("TPAdminTest_" + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $tmp | Out-Null

try {
    # ---- Test-HostList (pings only this computer; the unknown name is a reserved .invalid name)
    $up = @(Test-HostList 127.0.0.1)
    Check 'Test-HostList: 127.0.0.1 is up'                ($up.Count -eq 1 -and $up[0].Status -eq 'Up' -and $up[0].Address -eq '127.0.0.1' -and $up[0].Replies -eq '1/1')
    Check 'Test-HostList: localhost is up'                ((Test-HostList localhost).Status -eq 'Up')
    Check 'Test-HostList: an unknown name is NoDns'       ((Test-HostList 'no-such-host.invalid').Status -eq 'NoDns')
    Check 'Test-HostList: -Count 3 gives 3/3'             ((Test-HostList 127.0.0.1 -Count 3).Replies -eq '3/3')
    $hostFile = Join-Path $tmp 'hosts.txt'
    "# a comment`r`n`r`n127.0.0.1`r`n  localhost  `r`n" | Set-Content $hostFile
    Check 'Test-HostList: -Path skips comments and blanks' (@(Test-HostList -Path $hostFile).Count -eq 2)
    Check 'Test-HostList: pipeline input works'           (@('127.0.0.1', 'localhost' | Test-HostList).Count -eq 2)
    Check 'Test-HostList: a missing file is an error'     (Throws { Test-HostList -Path (Join-Path $tmp 'nope.txt') })
    Check 'Test-HostList: no input is an error'           (Throws { Test-HostList })
    Check 'Test-HostList: -Count 0 is rejected'           (Throws { Test-HostList 127.0.0.1 -Count 0 })

    # ---- Resolve-HostList
    $r = @(Resolve-HostList localhost)
    Check 'Resolve-HostList: localhost is found'          ($r.Count -eq 1 -and $r[0].Status -eq 'Found' -and $r[0].Direction -eq 'Name to IP' -and $r[0].Result -match '127\.0\.0\.1|::1')
    Check 'Resolve-HostList: an unknown name is NotFound' ((Resolve-HostList 'no-such-host.invalid').Status -eq 'NotFound')
    $mixed = @(Resolve-HostList localhost, 127.0.0.1)
    Check 'Resolve-HostList: names and addresses can be mixed (order kept)' ($mixed.Count -eq 2 -and $mixed[0].Direction -eq 'Name to IP' -and $mixed[1].Direction -eq 'IP to name' -and $mixed[1].Target -eq '127.0.0.1')
    Check 'Resolve-HostList: -Path skips comments and blanks' (@(Resolve-HostList -Path $hostFile).Count -eq 2)
    Check 'Resolve-HostList: a missing file is an error'  (Throws { Resolve-HostList -Path (Join-Path $tmp 'nope.txt') })
    Check 'Resolve-HostList: no input is an error'        (Throws { Resolve-HostList })

    # ---- Restart-RemoteService (only fakes are ever called)
    $global:TPCalls.Clear()
    Restart-RemoteService -Name winmgmt -WhatIf *>$null
    Restart-RemoteService -Name winmgmt, spooler -ComputerName SRV01, SRV02 -WhatIf *>$null
    Check 'Restart-RemoteService -WhatIf touches nothing' ($global:TPCalls.Count -eq 0)
    Check 'Restart-RemoteService rejects a quote in the name' (Throws { Restart-RemoteService -Name "a'b" -WhatIf })
    Check 'Restart-RemoteService rejects a semicolon in the name' (Throws { Restart-RemoteService -Name 'a;b' -WhatIf })
    Check 'nothing was called by the rejected calls'      ($global:TPCalls.Count -eq 0)

    $res = @(Restart-RemoteService -Name winmgmt)
    Check 'Restart-RemoteService (this PC) calls Restart-Service once with the name' ($global:TPCalls.Count -eq 1 -and $global:TPCalls[0] -eq 'Restart-Service winmgmt' -and $res[0].Result -eq 'Restarted' -and $res[0].Computer -ieq $env:COMPUTERNAME)

    $global:TPCalls.Clear()
    $res = @(Restart-RemoteService -Name winmgmt -ComputerName SRV01)
    Check 'Restart-RemoteService (remote) stops cleanly when the connection gives nothing' ($res.Count -eq 1 -and $res[0].Result -eq 'Failed' -and $global:TPCalls -notcontains 'Invoke-CimMethod')
    $global:TPCalls.Clear()

    # ---- Start-AdminShell
    $global:TPCalls.Clear()
    Start-AdminShell -WhatIf *>$null
    Start-AdminShell -WindowsPowerShell -WhatIf *>$null
    Check 'Start-AdminShell -WhatIf starts nothing' ($global:TPCalls.Count -eq 0)
    if (Get-Command wt.exe -ErrorAction SilentlyContinue) {
        Start-AdminShell -InTerminal -WhatIf *>$null
        Check 'Start-AdminShell -InTerminal -WhatIf starts nothing' ($global:TPCalls.Count -eq 0)
    }

    # ---- Start-RunAs: the text sent to runas.exe
    $arg = { param($p, $u, $d, $n) & (Get-Module AdminTools) { param($p, $u, $d, $n) Get-RunAsArgument -Program $p -User $u -Domain $d -NetOnly:$n } $p $u $d $n }
    Check 'runas: domain and user become DOMAIN\user' ((& $arg 'notepad.exe' 'admin01' 'CONTOSO' $false) -ceq '/user:CONTOSO\admin01 "notepad.exe"')
    Check 'runas: -NetOnly uses user@domain and /netonly' ((& $arg 'mmc.exe' 'admin01' 'contoso.com' $true) -ceq '/netonly /user:admin01@contoso.com "mmc.exe"')
    Check 'runas: DOMAIN\user is used as it is'          ((& $arg 'cmd.exe' 'CONTOSO\bob' 'IGNORED' $false) -ceq '/user:CONTOSO\bob "cmd.exe"')
    Check 'runas: a program with a space and arguments is quoted for runas' ((& $arg '"C:\Program Files\App\app.exe" -x' 'bob@contoso.com' '' $false) -ceq '/user:bob@contoso.com "\"C:\Program Files\App\app.exe\" -x"')
    Check 'runas: a missing program is rejected'         (Throws { & $arg '' 'bob' 'D' $false })
    Check 'runas: a user with a space is rejected'       (Throws { & $arg 'a.exe' 'bob smith' 'D' $false })
    Check 'runas: a quote in the user is rejected'       (Throws { & $arg 'a.exe' 'bob"x' 'D' $false })
    $global:TPCalls.Clear()
    Start-RunAs -Program notepad.exe -User admin01 -Domain CONTOSO -WhatIf *>$null
    Check 'Start-RunAs -WhatIf starts nothing'           ($global:TPCalls.Count -eq 0)

    # ---- Register-RemoteTask
    $good = Join-Path $tmp 'good.xml'
    '<?xml version="1.0" encoding="UTF-16"?><Task version="1.2" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task"><Actions><Exec><Command>cmd.exe</Command></Exec></Actions></Task>' | Set-Content $good
    $notTask = Join-Path $tmp 'nottask.xml'; '<Other/>' | Set-Content $notTask
    $broken  = Join-Path $tmp 'broken.xml';  '<Task><oops>' | Set-Content $broken

    $global:TPCalls.Clear()
    Register-RemoteTask -ComputerName SRV01, SRV02 -XmlPath $good -TaskName 'Test Task' -WhatIf *>$null
    Check 'Register-RemoteTask -WhatIf touches no computer' ($global:TPCalls.Count -eq 0)
    Check 'Register-RemoteTask rejects a missing file'      (Throws { Register-RemoteTask -ComputerName SRV01 -XmlPath (Join-Path $tmp 'nope.xml') -TaskName T -WhatIf })
    Check 'Register-RemoteTask rejects broken XML'          (Throws { Register-RemoteTask -ComputerName SRV01 -XmlPath $broken -TaskName T -WhatIf })
    Check 'Register-RemoteTask rejects XML that is not a task' (Throws { Register-RemoteTask -ComputerName SRV01 -XmlPath $notTask -TaskName T -WhatIf })
    Check 'Register-RemoteTask rejects a bad task name'     (Throws { Register-RemoteTask -ComputerName SRV01 -XmlPath $good -TaskName 'a\b' -WhatIf })
    Check 'nothing was started or created by any rejected call' ($global:TPCalls.Count -eq 0)
}
finally {
    foreach ($n in 'Start-Process', 'New-CimSession', 'Register-ScheduledTask', 'Restart-Service', 'Get-CimInstance', 'Invoke-CimMethod') { Remove-Item "function:global:$n" -ErrorAction SilentlyContinue }
    Remove-Variable TPCalls -Scope Global -ErrorAction SilentlyContinue
    Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue
}
