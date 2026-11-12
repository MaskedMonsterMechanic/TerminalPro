@{
    Command  = 'Show-AdminBuildDns'
    Alias    = 'addns'
    Synopsis = 'Build recipe: DNS zones and records from one table and one loop'
    Group    = 'CHEAT-SHEETS'
    Order    = 46
    Index    = 'Show-AdminCommands'
    Title    = 'ADMINTOOLS MODULE - BUILD DNS'
    Prompt   = 'PS>'

    Sections = @(
        @{
            Title  = 'READ THIS FIRST'
            Rows   = @'
 :: Where to run it :: On a DNS server (a domain controller), or on your PC with the RSAT tools (see adad). From your PC add -ComputerName dc01 to each command.
 :: What it changes :: It adds zones and records. Look at what is there first (see adsrv). The undo loop is at the bottom.
 :: The names :: contoso.local, contoso.com, 192.0.2.x and DC01 are examples. Use your own.
'@
        }
        @{
            Title  = 'ZONES (ONE LOOP EACH)'
            Rows   = @'
Add-DnsServerPrimaryZone -Name contoso.local -ReplicationScope Forest -DynamicUpdate Secure :: One forward zone, stored in Active Directory. Secure = only domain members may update it.
'contoso.local', 'contoso.com', 'contoso.intra' | ForEach-Object { Add-DnsServerPrimaryZone -Name $_ -ReplicationScope Forest -DynamicUpdate Secure } :: Several forward zones in one go
Add-DnsServerPrimaryZone -NetworkId 192.0.2.0/24 -ReplicationScope Forest -DynamicUpdate Secure :: A reverse zone. Give the network and Windows makes the name (2.0.192.in-addr.arpa).
'192.0.2.0/24', '198.51.100.0/24' | ForEach-Object { Add-DnsServerPrimaryZone -NetworkId $_ -ReplicationScope Forest -DynamicUpdate Secure } :: Several reverse zones
Note: ReplicationScope Forest copies the zone to every DNS server in the forest. Domain means only this domain.
Note: Make the reverse zones BEFORE the records, or the PTR records have nowhere to go.
'@
        }
        @{
            Title  = 'THE TABLE (ONE PLACE FOR ALL YOUR RECORDS)'
            Rows   = @'
$rec = Import-Csv .\records.csv :: The table as a file: a header line Zone,Name,IP,Ttl and one line per record. Open it in VS Code or Excel.
$rec = 'Zone,Name,IP,Ttl', 'contoso.local,DC01,192.0.2.10,00:30:00', 'contoso.local,FILE01,192.0.2.20,00:45:00', 'contoso.com,www,192.0.2.80,00:30:00' | ConvertFrom-Csv :: The same table typed in the prompt (three records)
$rec | Format-Table :: Look at it before you use it
Note: Ttl is how long others may remember the answer, as hours:minutes:seconds. Short (00:15:00) for things that change, long (01:00:00) for things that never do.
Note: One table means one place to fix a typo, and the same table can be used again for another lab.
'@
        }
        @{
            Title  = 'THE LOOP (A RECORDS WITH PTR)'
            Rows   = @'
foreach ($r in $rec) { Add-DnsServerResourceRecordA -ZoneName $r.Zone -Name $r.Name -IPv4Address $r.IP -TimeToLive $r.Ttl -CreatePtr } :: Adds every record in the table, and its reverse (PTR) record
foreach ($r in $rec) { if (-not (Get-DnsServerResourceRecord -ZoneName $r.Zone -Name $r.Name -ErrorAction SilentlyContinue)) { Add-DnsServerResourceRecordA -ZoneName $r.Zone -Name $r.Name -IPv4Address $r.IP -TimeToLive $r.Ttl -CreatePtr } } :: The safe version: skips what is already there, so you can run it twice
$rec | ForEach-Object { Resolve-DnsName "$($_.Name).$($_.Zone)" -Type A -Server dc01 } :: Check: asks DNS for every name in the table
Note: CreatePtr only works when the reverse zone for that address exists.
Note: A name with a dot in it ends up as a sub-domain. Use a plain name such as FILE01.
'@
        }
        @{
            Title  = 'OTHER RECORD TYPES'
            Rows   = @'
Add-DnsServerResourceRecordCName -ZoneName contoso.local -Name files -HostNameAlias file01.contoso.local :: An extra name for a server (files.contoso.local points to file01)
Add-DnsServerResourceRecordMX -ZoneName contoso.local -Name . -MailExchange mail01.contoso.local -Preference 10 :: A mail server for the domain itself. The lowest preference is tried first.
$p = 10; 'mail01', 'mail02' | ForEach-Object { Add-DnsServerResourceRecordMX -ZoneName contoso.local -Name . -MailExchange "$_.contoso.local" -Preference $p; $p += 10 } :: Several mail servers: the loop counts the preference for you (10, 20, 30 ...)
Add-DnsServerConditionalForwarderZone -Name partner.example -MasterServers 203.0.113.53, 203.0.113.54 -ReplicationScope Forest :: Questions about ONE domain go to those servers
Set-DnsServerForwarder -IPAddress 203.0.113.53, 203.0.113.54 :: Questions this server cannot answer go to these servers (the normal "internet" forwarders)
Note: Every command takes -ComputerName to work on another DNS server.
'@
        }
        @{
            Title  = 'UNDO'
            Rows   = @'
foreach ($r in $rec) { Remove-DnsServerResourceRecord -ZoneName $r.Zone -Name $r.Name -RRType A -Force } :: Removes every record in the table again (the A records only; remove a PTR with -RRType PTR)
Remove-DnsServerZone -Name contoso.intra -Force :: Removes a whole zone with everything in it. Check the name twice.
'@
        }
    )
}
