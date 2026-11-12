@{
    Command  = 'Show-AdminBuildDomain'
    Alias    = 'adbuild'
    Synopsis = 'Build recipe: a new domain (first domain controller, then a second one)'
    Group    = 'CHEAT-SHEETS'
    Order    = 45
    Index    = 'Show-AdminCommands'
    Title    = 'ADMINTOOLS MODULE - BUILD A DOMAIN'
    Prompt   = 'PS>'

    Sections = @(
        @{
            Title  = 'READ THIS FIRST'
            Rows   = @'
 :: Lab or new server only :: These commands BUILD things and restart servers. Never use them on a working domain controller.
 :: Run ON the server :: As administrator (Windows Server, Desktop or Core). The names below are examples: DC01, DC02, contoso.local, 192.0.2.x.
 :: To look, not build :: Use adsrv (look at servers) and adad (users, groups, policy).
'@
        }
        @{
            Title  = 'PREPARE THE SERVER (ON EACH ONE)'
            Rows   = @'
Get-NetAdapter | Select-Object Name, Status :: Finds the name of the network card (below it is Ethernet)
New-NetIPAddress -InterfaceAlias Ethernet -IPAddress 192.0.2.10 -PrefixLength 24 -DefaultGateway 192.0.2.1 :: A domain controller needs a fixed address
Set-DnsClientServerAddress -InterfaceAlias Ethernet -ServerAddresses 127.0.0.1 :: The first DC uses itself for DNS. The next DC uses the first one (see below).
Rename-Computer -NewName DC01 -Restart :: Sets the name BEFORE it becomes a domain controller. Renaming a DC later is much harder.
sconfig :: The menu on Server Core that does all of this too
'@
        }
        @{
            Title  = 'FIRST DOMAIN CONTROLLER (A NEW FOREST)'
            Rows   = @'
Install-WindowsFeature AD-Domain-Services -IncludeManagementTools :: Installs the role (nothing is a domain controller yet)
$dsrm = Read-Host 'Recovery password' -AsSecureString :: Asks for the recovery (DSRM) password. It is never written in the script.
Test-ADDSForestInstallation -DomainName contoso.local -SafeModeAdministratorPassword $dsrm :: A dry run. Checks everything, changes nothing. Fix what it reports first.
Install-ADDSForest -DomainName contoso.local -InstallDns -SafeModeAdministratorPassword $dsrm -DomainMode WinThreshold -ForestMode WinThreshold -NoRebootOnCompletion -Force :: Builds the forest and the domain, with DNS
Restart-Computer -Force :: Needed to finish. Log on afterwards as CONTOSO\Administrator.
Get-ADRootDSE | Format-Table DNS*, *Functionality :: Check: the domain name and the levels
Note: WinThreshold is the Windows Server 2016 level. Windows Server 2025 also knows Win2025.
Note: The short (NetBIOS) name becomes CONTOSO. Add -DomainNetbiosName to choose another.
Note: Put the same settings in a variable to keep the command short and to reuse it: $f = @{ DomainName = 'contoso.local'; InstallDns = $true }  and then  Install-ADDSForest @f
'@
        }
        @{
            Title  = 'SECOND DOMAIN CONTROLLER (SAME DOMAIN)'
            Rows   = @'
Set-DnsClientServerAddress -InterfaceAlias Ethernet -ServerAddresses 192.0.2.10 :: FIRST point DNS at DC01. Without it the new server cannot find the domain.
Resolve-DnsName dc01.contoso.local :: Check: this must answer before you go on
Install-WindowsFeature AD-Domain-Services, DNS -IncludeManagementTools :: Installs the role and DNS
$cred = Get-Credential CONTOSO\Administrator :: A domain admin, asked for in a window
$dsrm = Read-Host 'Recovery password' -AsSecureString :: The recovery password of THIS server
Test-ADDSDomainControllerInstallation -DomainName contoso.local -Credential $cred -SafeModeAdministratorPassword $dsrm :: The dry run for a second DC
Install-ADDSDomainController -DomainName contoso.local -Credential $cred -SafeModeAdministratorPassword $dsrm -InstallDns -NoRebootOnCompletion -Force :: Makes this server a domain controller in the existing domain
Restart-Computer -Force :: Needed to finish
Set-DnsClientServerAddress -InterfaceAlias Ethernet -ServerAddresses 192.0.2.10, 127.0.0.1 :: After the restart: the partner first, itself second
Note: Add -SiteName "Default-First-Site-Name" to choose the site, and -ReplicationSourceDC dc01.contoso.local to choose where it copies from.
'@
        }
        @{
            Title  = 'CHECK THAT IT WORKED'
            Rows   = @'
Get-ADDomainController -Filter * | Select-Object Name, IPv4Address, Site :: Both servers should be in the list
repadmin /replsummary :: Replication between them: no failures
Resolve-DnsName dc01.contoso.local -Server dc02 :: DC02 also knows the records of DC01
'@
        }
        @{
            Title  = 'MORE THAN ONE SERVER (LOOPS)'
            Rows   = @'
'DC02', 'DC03' | ForEach-Object { Install-WindowsFeature AD-Domain-Services, DNS -IncludeManagementTools -ComputerName $_ } :: Install the role on several servers from your PC, one after the other
Invoke-Command -ComputerName DC02 -ScriptBlock { Install-ADDSDomainController -DomainName contoso.local -Credential $using:cred -SafeModeAdministratorPassword $using:dsrm -InstallDns -NoRebootOnCompletion -Force } :: Makes DC02 a domain controller from your PC. $using: carries your variables over.
foreach ($s in 'DC02', 'DC03') { Restart-Computer -ComputerName $s -Force -Wait -For PowerShell } :: Restarts them one at a time and waits for each
Note: Promote ONE server at a time. Wait until repadmin /replsummary is clean before the next one.
Note: A loop is for the same job on many servers. Never loop a restart over all your domain controllers at once.
Note: Never write a real password in a script or a loop. Use Read-Host -AsSecureString or Get-Credential.
'@
        }
    )
}
