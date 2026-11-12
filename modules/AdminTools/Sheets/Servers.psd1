@{
    Command  = 'Show-AdminServers'
    Alias    = 'adsrv'
    Synopsis = 'Servers from your own PC: look, install, restart, time, domain controllers, DNS, DHCP, group policy'
    Group    = 'CHEAT-SHEETS'
    Order    = 44
    Index    = 'Show-AdminCommands'
    Title    = 'ADMINTOOLS MODULE - SERVERS FROM A CLIENT'
    Prompt   = 'PS>'

    Sections = @(
        @{
            Title  = 'FIRST: WHAT YOU NEED'
            Rows   = @'
Test-WSMan <server> :: Does the server answer remoting? If not, see adremote.
Get-Module -ListAvailable ActiveDirectory, DnsServer, DhcpServer, GroupPolicy :: Which management modules your PC has (they come with the RSAT tools, see adad)
Note: Remoting must be on at the server (see adremote). The commands that start with Get-Dns, Get-Dhcp, Get-AD and Get-GP need the RSAT tools on YOUR PC (see adad).
Note: Replace <server>, <dc> and <dhcp> with a name such as DC01 or FILE01. In a domain, the full name looks like dc01.contoso.local.
'@
        }
        @{
            Title  = 'LOOK AT A SERVER (changes nothing)'
            Rows   = @'
Test-NetConnection <server> -Port 445 :: Can I reach file sharing on it? (389 is LDAP, 3389 is remote desktop, 5985 is remoting)
Resolve-DnsName <server>.contoso.local -Server <dc> :: Asks one particular DNS server for the address
Get-CimInstance Win32_OperatingSystem -ComputerName <server> | Select-Object CSName, Version, LastBootUpTime :: Name, Windows version and when it last started
systeminfo /s <server> :: The long overview: OS, hotfixes, boot time, network cards
Get-NetIPAddress -CimSession <server> -AddressFamily IPv4 | Select-Object InterfaceAlias, IPAddress, PrefixLength :: The IP addresses on the server
Get-WindowsFeature -ComputerName <server> | Where-Object Installed :: Every role and feature that is installed (Windows Server only)
Get-WindowsFeature -ComputerName <server> -Name DHCP, DNS | Select-Object Name, InstallState :: Are these roles there? (-Name takes several)
Get-WindowsFeature -ComputerName <server> -Name *RSAT* | Where-Object Installed :: Which management tools are installed on it
'@
        }
        @{
            Title  = 'INSTALL A ROLE, RESTART'
            Rows   = @'
Install-WindowsFeature -Name <feature> -ComputerName <server> -IncludeManagementTools :: Installs a role on the server (look first with Get-WindowsFeature)
$r = Install-WindowsFeature -Name <feature> -ComputerName <server> :: Keep the result: it says whether a restart is needed
$r.RestartNeeded :: Yes, No or Maybe
Restart-Computer -ComputerName <server> -Force -Wait -For PowerShell :: Restarts it and waits until PowerShell remoting answers again
Get-WindowsFeature -Name RSAT* | Install-WindowsFeature :: Run ON a server: installs all its management tools
Note: Install the roles one server at a time, and look at the result before the next one.
'@
        }
        @{
            Title  = 'TIME (NTP)'
            Rows   = @'
w32tm /query /computer:<server> /status :: Which time source it uses, when it last synced, the offset
w32tm /query /computer:<server> /peers :: The time servers it talks to
w32tm /monitor :: Compares the time on the domain controllers
w32tm /resync :: Syncs this computer now
w32tm /config /manualpeerlist:"0.pool.ntp.org 1.pool.ntp.org" /syncfromflags:manual /reliable:yes /update :: Run ON the domain controller that holds the PDC emulator role: it gets its time from the internet
Note: Only that one domain controller should take its time from outside. Everything else in the domain follows the domain.
Note: Flags after a server in a peer list: 0x1 special interval, 0x2 use as fallback only, 0x4 symmetric active, 0x8 client. They add up: 0xa is 0x8 + 0x2.
'@
        }
        @{
            Title  = 'DOMAIN CONTROLLERS'
            Rows   = @'
Get-ADDomainController -Filter * | Select-Object HostName, IPv4Address, IsGlobalCatalog, OperatingSystem :: Every domain controller in the domain
Get-ADDomain | Select-Object Name, DomainMode, PDCEmulator :: Domain name, functional level and who holds the PDC emulator role
Get-ADForest | Format-List *Master*, GlobalCatalogs :: Forest-wide roles and the global catalog servers
Get-ADRootDSE -Server <dc> | Format-Table DNS*, *Functionality :: The DNS name and functional levels as that domain controller sees them
repadmin /replsummary :: Replication health in one overview (look for failures and large deltas)
repadmin /showrepl <dc> :: Replication partners of one domain controller, and when each last worked
dcdiag /s:<dc> :: A set of health tests on one domain controller
'@
        }
        @{
            Title  = 'DNS AND DHCP'
            Rows   = @'
Get-DnsServerZone -ComputerName <dc> :: The zones on a DNS server
Get-DnsServerResourceRecord -ComputerName <dc> -ZoneName contoso.local -RRType A :: The A records in a zone (PTR for a reverse zone, MX for mail)
Get-DhcpServerInDC :: The DHCP servers that are authorised in Active Directory
Get-DhcpServerv4Scope -ComputerName <dhcp> :: The scopes on a DHCP server
Get-DhcpServerv4Failover -ComputerName <dhcp> :: The failover relationship, if any (mode, partner, state)
Get-DhcpServerv4Lease -ComputerName <dhcp> -ScopeId 192.0.2.0 :: Who has a lease in that scope right now
'@
        }
        @{
            Title  = 'GROUP POLICY'
            Rows   = @'
Get-GPO -All | Select-Object DisplayName, GpoStatus, ModificationTime :: Every group policy, its state and when it last changed
Get-GPInheritance -Target "OU=Servers,DC=contoso,DC=local" :: Which policies reach that OU, and in what order
Get-GPOReport -Name "<policy>" -ReportType Html -Path .\policy.html :: A readable report of one policy
Invoke-GPUpdate -Computer <server> -Force :: Tells the server to fetch its policies now
gpresult /r /s <server> :: Which policies a server really got
'@
        }
        @{
            Title  = 'FILE SERVERS'
            Rows   = @'
Get-SmbShare -CimSession <server> :: The shares on a server
Get-SmbShareAccess -CimSession <server> -Name <share> :: Who has which share permission
Get-Volume -CimSession <server> :: Drives with size and free space
Get-Disk -CimSession <server> :: The physical disks and their state
'@
        }
    )
}
