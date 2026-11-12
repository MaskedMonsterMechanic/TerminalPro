@{
    Command  = 'Show-AdminBuildDhcp'
    Alias    = 'addhcp'
    Synopsis = 'Build recipe: DHCP servers, scopes from one table, failover between two servers'
    Group    = 'CHEAT-SHEETS'
    Order    = 47
    Index    = 'Show-AdminCommands'
    Title    = 'ADMINTOOLS MODULE - BUILD DHCP'
    Prompt   = 'PS>'

    Sections = @(
        @{
            Title  = 'READ THIS FIRST'
            Rows   = @'
 :: Where to run it :: On your PC with the RSAT tools (see adad), against the servers by name. Or on the server itself: then leave out -ComputerName.
 :: What it changes :: It installs a role and makes scopes. To look at a finished setup use adsrv (scopes, failover, leases). The undo is at the bottom.
 :: The names :: dc01, dc02, contoso.local, 192.0.2.x and the 10.10.x.x scopes are examples. Use your own.
'@
        }
        @{
            Title  = 'INSTALL AND AUTHORISE (BOTH SERVERS)'
            Rows   = @'
'dc01', 'dc02' | ForEach-Object { Install-WindowsFeature DHCP -IncludeManagementTools -ComputerName $_ } :: Installs the DHCP role on both servers
foreach ($s in 'dc01', 'dc02') { Invoke-Command -ComputerName $s -ScriptBlock { Add-DhcpServerSecurityGroup; Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\ServerManager\Roles\12 -Name ConfigurationState -Value 2; Restart-Service DHCPServer } } :: On each server: makes the DHCP security groups, tells Server Manager the set-up is done, restarts the service
foreach ($s in 'dc01', 'dc02') { Add-DhcpServerInDC -DnsName "$s.contoso.local" } :: Authorises both servers in Active Directory. Needs an Enterprise Admin. An unauthorised DHCP server does not answer.
Get-DhcpServerInDC :: Check: both servers are in the list
Note: The ConfigurationState value only removes the yellow "configuration required" warning in Server Manager. DHCP itself works without it.
'@
        }
        @{
            Title  = 'THE TABLE (ONE LINE PER NETWORK)'
            Rows   = @'
$vlan = Import-Csv .\vlans.csv :: The table as a file: a header line Id,Name and one line per network. Open it in VS Code or Excel.
$vlan = 'Id,Name', '10,Management', '20,HR', '30,Admin', '40,Sales', '50,Purchasing', '60,Finance', '70,Development', '80,IT' | ConvertFrom-Csv :: The same table typed in the prompt (eight networks)
$vlan | Format-Table :: Look at it before you use it
Note: In this example network 30 is 10.10.30.0/24. The loop below makes the addresses from the Id, so there is nothing else to type.
'@
        }
        @{
            Title  = 'THE LOOP (A SCOPE AND ITS GATEWAY FOR EVERY LINE)'
            Rows   = @'
foreach ($v in $vlan) { $n = "10.10.$($v.Id)"; Add-DhcpServerv4Scope -ComputerName dc01.contoso.local -Name "Vlan$($v.Id)" -Description "Vlan $($v.Id) - $($v.Name)" -StartRange "$n.10" -EndRange "$n.100" -SubnetMask 255.255.255.0; Set-DhcpServerv4OptionValue -ComputerName dc01.contoso.local -ScopeId "$n.0" -Router "$n.1" } :: One scope per line in the table: addresses .10 to .100, gateway .1
Get-DhcpServerv4Scope -ComputerName dc01.contoso.local | Select-Object ScopeId, Name, StartRange, EndRange, State :: Check: the scopes on the server
Note: Change .10, .100 and .1 in the loop if your networks look different.
Note: A scope is not handed out before it is Active. Add-DhcpServerv4Scope makes it active by default (add -State InActive to stop that).
'@
        }
        @{
            Title  = 'OPTIONS FOR ALL SCOPES AT ONCE'
            Rows   = @'
Set-DhcpServerv4OptionValue -ComputerName dc01.contoso.local -DnsDomain contoso.local -DnsServer 192.0.2.10, 192.0.2.11 :: Server-wide options: every scope gets this domain name and these DNS servers
Get-DhcpServerv4OptionValue -ComputerName dc01.contoso.local :: Check: the server-wide options
Get-DhcpServerv4OptionValue -ComputerName dc01.contoso.local -ScopeId 10.10.30.0 :: Check: what clients in one scope get (server and scope options together)
Note: Options set on a scope (like the router above) win over the server-wide ones.
Note: Set the same server-wide options on the partner server too, before failover (see below).
'@
        }
        @{
            Title  = 'FAILOVER BETWEEN TWO SERVERS'
            Rows   = @'
$secret = Read-Host 'Shared secret' :: Asked, so it is not written in the script. Both servers use it to trust each other.
Add-DhcpServerv4Failover -ComputerName dc01.contoso.local -PartnerServer dc02.contoso.local -Name 'DC01-DC02' -ScopeId (Get-DhcpServerv4Scope -ComputerName dc01.contoso.local).ScopeId -LoadBalancePercent 60 -SharedSecret $secret -Force :: Load balance, 60 percent on dc01 and 40 on dc02. It takes EVERY scope on dc01 and copies it to dc02.
Add-DhcpServerv4Failover -ComputerName dc01.contoso.local -PartnerServer dc02.contoso.local -Name 'DC01-DC02' -ServerRole Active -ReservePercent 10 -SharedSecret $secret -ScopeId 10.10.30.0 :: Hot standby instead: dc01 answers, dc02 takes over if it fails (10 percent of the addresses are kept for it)
Add-DhcpServerv4FailoverScope -ComputerName dc01.contoso.local -Name 'DC01-DC02' -ScopeId 10.10.80.0 :: Adds a scope later
Invoke-DhcpServerv4FailoverReplication -ComputerName dc01.contoso.local -Name 'DC01-DC02' :: Makes the two servers copy their settings to each other now
Get-DhcpServerv4Failover -ComputerName dc01.contoso.local :: Check: mode, partner, state (Normal is good) and the scopes
Note: Use ONE of the two Add-DhcpServerv4Failover lines, not both. They make the same relationship in two different ways.
Note: The partner must have the DHCP role, be authorised, and be reachable. It does not need any scopes: failover makes them.
Note: Run the failover commands against ONE server, the first one. Do not run them on both.
'@
        }
        @{
            Title  = 'CHECK BOTH SERVERS (LOOPS), AND FINE-TUNING'
            Rows   = @'
'dc01', 'dc02' | ForEach-Object { Get-DhcpServerv4Scope -ComputerName $_ } :: The scopes on both: they should be the same list
'dc01', 'dc02' | ForEach-Object { Get-DhcpServerv4Statistics -ComputerName $_ } :: Numbers for both: addresses in use, free, offers, requests
Add-DhcpServerv4Reservation -ComputerName dc01.contoso.local -ScopeId 10.10.30.0 -IPAddress 10.10.30.50 -ClientId aa-bb-cc-dd-ee-ff -Name printer01 :: One device always gets the same address (the ClientId is its MAC address). With failover it is copied to the partner.
Add-DhcpServerv4ExclusionRange -ComputerName dc01.contoso.local -ScopeId 10.10.30.0 -StartRange 10.10.30.10 -EndRange 10.10.30.20 :: Keeps a part of the range for fixed addresses that DHCP must not hand out
'@
        }
        @{
            Title  = 'UNDO'
            Rows   = @'
Remove-DhcpServerv4Failover -ComputerName dc01.contoso.local -Name 'DC01-DC02' :: Removes the failover relationship (the scopes stay on both servers)
foreach ($v in $vlan) { Remove-DhcpServerv4Scope -ComputerName dc01.contoso.local -ScopeId "10.10.$($v.Id).0" -Force } :: Removes every scope in the table again. Their leases go with them.
Remove-DhcpServerInDC -DnsName dc01.contoso.local :: Takes the server out of Active Directory (it stops answering)
'@
        }
    )
}
