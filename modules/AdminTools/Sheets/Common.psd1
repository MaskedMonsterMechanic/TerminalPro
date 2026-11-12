@{
    Command  = 'Show-AdminCommon'
    Alias    = 'admincom'
    Synopsis = 'Most used PowerShell commands for administration'
    Group    = 'CHEAT-SHEETS'
    Order    = 40
    Index    = 'Show-AdminCommands'
    Title    = 'ADMINTOOLS MODULE - MOST USED COMMANDS'
    Prompt   = 'PS>'

    Sections = @(
        @{
            Title  = 'HELP AND DISCOVERY'
            Rows   = @'
Get-Help <command> -Examples :: Shows the examples of a command (alias: help, hlp)
Get-Help about_CommonParameters :: Parameters that every command supports
Update-Help :: Downloads the newest help files (run as administrator)
Get-Command *service* :: Finds commands by name
Get-Command -Module <module> :: Lists the commands of one module (alias: gcm)
<command> | Get-Member :: Shows what an object can do and hold (alias: gm)
Get-Module -ListAvailable :: Lists the installed modules (alias: gmo)
Import-Module <module> :: Loads a module (alias: ipmo)
Get-ExecutionPolicy -List :: Shows the script policy for every scope
Get-Alias -Definition Get-ChildItem :: Shows the aliases of a command
'@
        }
        @{
            Title  = 'THE PIPELINE'
            Rows   = @'
Get-Service | Where-Object Status -eq 'Running' :: Keeps only the objects that match
Get-Process | Sort-Object CPU -Descending | Select-Object -First 5 :: The five busiest processes
Get-Process | Group-Object Name | Sort-Object Count -Descending :: Counts the objects per name
Get-ChildItem | Measure-Object Length -Sum :: Adds up a property
<command> | ForEach-Object { $_.Name } :: Does something for every object
<command> | Select-Object -ExpandProperty Name :: Gives the plain values instead of objects
<command> | Format-List * :: Shows every property of an object
<command> | Out-GridView :: A window you can sort and filter (PowerShell 5.1)
<command> | Export-Csv .\out.csv -NoTypeInformation :: Saves the objects as a CSV file
<command> | ConvertTo-Json -Depth 3 :: Turns objects into JSON
Get-Content .\file.json -Raw | ConvertFrom-Json :: Reads JSON back into objects
'@
        }
        @{
            Title  = 'FILES AND PERMISSIONS'
            Rows   = @'
Get-ChildItem C:\Windows\System32 -Filter *.dll :: Lists files, with a filter (alias: gci, ls, dir)
Get-ChildItem -Recurse -File | Sort-Object Length -Descending | Select-Object -First 10 :: The ten biggest files below here
Test-Path <path> :: Tells if a path exists (alias: tp)
Get-Acl <folder> | Format-List :: Shows who may do what on a folder
icacls <folder> :: The same, with the classic tool
icacls <folder> /grant "DOMAIN\user:(OI)(CI)M" :: Gives modify rights that the subfolders inherit
Get-FileHash <file> -Algorithm SHA256 :: Calculates a checksum, to check a download
Get-Item <file> -Stream * :: Shows hidden data streams (also the "downloaded from internet" mark)
Unblock-File <file> :: Removes the "downloaded from internet" mark
Compress-Archive -Path <folder> -DestinationPath <file>.zip :: Makes a zip file
Expand-Archive <file>.zip -DestinationPath <folder> :: Unpacks a zip file
'@
        }
        @{
            Title  = 'COMPUTERS AND SERVICES'
            Rows   = @'
Get-Service -Name <name> :: Shows a service (alias: gsv)
Restart-Service <name> :: Restarts a service (as administrator)
Get-Process -Name <name> :: Shows a process (alias: gps)
Stop-Process -Name <name> -WhatIf :: Shows what would be stopped, without doing it
Get-CimInstance Win32_OperatingSystem :: Operating system details (replaces Get-WmiObject)
Get-CimInstance Win32_ComputerSystem | Format-List * :: Computer details
Get-HotFix | Sort-Object InstalledOn -Descending | Select-Object -First 5 :: The newest installed updates
Get-ScheduledTask | Where-Object State -ne 'Disabled' :: Lists the scheduled tasks that are active
query user /server:<server> :: Who is logged on (needs rights)
Restart-Computer -ComputerName <server> -Force :: Restarts a computer
'@
        }
        @{
            Title  = 'SECURITY AND POLICY'
            Rows   = @'
Get-NetFirewallProfile | Select-Object Name, Enabled :: Shows if the firewall is on
Get-NetFirewallRule -Enabled True -Direction Inbound | Select-Object -First 10 :: Some active inbound rules
Get-MpComputerStatus :: Windows Defender status and signature age
Update-MpSignature :: Updates the Defender signatures
Get-BitLockerVolume :: BitLocker status of the drives (as administrator)
Get-LocalGroupMember -Group Administrators :: Who is local administrator
Get-LocalUser | Select-Object Name, Enabled, LastLogon :: The local users
whoami /all :: Your user, groups and privileges
'@
        }
        @{
            Title  = 'EVENT LOGS'
            Rows   = @'
Get-WinEvent -ListLog * | Where-Object RecordCount | Sort-Object RecordCount -Descending | Select-Object -First 10 :: The logs with the most events
Get-WinEvent -FilterHashtable @{ LogName='System'; Level=1,2; StartTime=(Get-Date).AddDays(-1) } :: Critical and error events from the last day (fast)
Get-WinEvent -FilterHashtable @{ LogName='Security'; Id=4625 } -MaxEvents 20 :: Failed logons (as administrator)
Get-WinEvent -FilterHashtable @{ LogName='System'; Id=41 } :: Unexpected restarts (Kernel-Power)
Get-WinEvent -LogName 'Microsoft-Windows-WindowsUpdateClient/Operational' -MaxEvents 20 :: Windows Update history
wevtutil qe System /c:5 /rd:true /f:text :: The classic tool, last five System events
'@
        }
        @{
            Title  = 'INFO COLLECTING (OTHER COMPUTERS)'
            Rows   = @'
Get-CimInstance -ComputerName <server> Win32_ComputerSystem | Format-List * :: Computer details of a server
Get-ADComputer <server> -Properties * | Format-List * :: What Active Directory knows about it
Invoke-Command -ComputerName <server> -ScriptBlock { $PSVersionTable.PSVersion } :: The PowerShell version on a server
Test-NetConnection <server> -Port 5985 :: Checks that PowerShell remoting can be reached
'@
        }
    )
}
