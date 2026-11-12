@{
    Command  = 'Show-PCTrouble'
    Alias    = 'netpct'
    Synopsis = 'Troubleshooting from a Windows PC (PowerShell and classic tools)'
    Group    = 'TROUBLESHOOTING'
    Order    = 70
    Index    = 'Show-NetCommands'
    Title    = 'NETWORK MODULE - TROUBLESHOOTING FROM THE PC'
    Prompt   = 'PS>'

    Sections = @(
        @{
            Title  = 'START HERE: WORK FROM THE INSIDE OUT'
            Rows   = @'
Test-Connection 127.0.0.1 :: 1. The network stack of this PC
Get-NetIPConfiguration :: 2. Do I have an address, a gateway and DNS servers?
Test-Connection <gateway> :: 3. Can I reach my default gateway?
Test-Connection 1.1.1.1 :: 4. Can I reach the internet by address?
Resolve-DnsName example.com :: 5. Does name lookup work?
Test-NetConnection example.com -Port 443 :: 6. Does the actual service answer?
Note: the first step that fails tells you where to look. If 4 works and 5 does not, it is DNS.
'@
        }
        @{
            Title  = 'MY ADDRESS AND SETTINGS'
            Rows   = @'
Get-NetIPConfiguration :: Address, gateway, DNS for each connected adapter
Get-NetIPAddress -AddressFamily IPv4 :: All IPv4 addresses on this PC
Get-NetAdapter :: The adapters and their link state and speed
Get-NetRoute -AddressFamily IPv4 :: The routing table of the PC
Get-DnsClientServerAddress :: Which DNS servers each adapter uses
ipconfig /all :: The old tool: MAC address, DHCP server, lease times
ipconfig /release ; ipconfig /renew :: Gives the DHCP address back and asks for a new one
ipconfig /flushdns :: Empties the DNS cache of the PC
Get-NetNeighbor :: The ARP / neighbor table (IP to MAC)
arp -a :: The same in the old tool
'@
        }
        @{
            Title  = 'REACH SOMETHING'
            Rows   = @'
Test-Connection 192.168.1.1 -Count 4 :: Ping (in PowerShell 7 it also takes -Repeat, -TimeoutSeconds)
Test-NetConnection 192.168.1.1 :: Ping with a short summary
Test-NetConnection 192.168.1.1 -TraceRoute :: Ping and the hops on the way
Test-NetConnection example.com -Port 443 :: Does a TCP port answer? (TcpTestSucceeded: True or False)
nettp 192.168.1.1 22,80,443 :: The same with the Network module, for many ports at once
ping -t 192.168.1.1 :: Pings until you stop it with Ctrl+C
ping -f -l 1472 192.168.1.1 :: Finds the largest packet that fits without fragmenting (1472 + 28 = 1500)
tracert -d example.com :: The hops, without looking up names (faster)
pathping example.com :: Trace and loss per hop (takes a few minutes)
'@
        }
        @{
            Title  = 'NAMES (DNS)'
            Rows   = @'
Resolve-DnsName example.com :: Asks the PC's DNS server
Resolve-DnsName example.com -Server 1.1.1.1 :: Asks a specific server (compare with your own)
Resolve-DnsName example.com -Type MX :: Mail servers for a domain
Resolve-DnsName 8.8.8.8 :: The reverse lookup (address to name)
nslookup example.com :: The old tool
Clear-DnsClientCache :: Empties the DNS cache of the PC
'@
        }
        @{
            Title  = 'CONNECTIONS AND PORTS'
            Rows   = @'
Get-NetTCPConnection -State Established :: Open TCP connections on this PC
Get-NetTCPConnection -LocalPort 443 :: Who uses a port
Get-NetTCPConnection -State Listen :: What listens for connections
netstat -ano :: The old tool, with the process ID (PID)
Get-Process -Id <pid> :: Which program has that PID
'@
        }
        @{
            Title  = 'WI-FI AND FIREWALL'
            Rows   = @'
netsh wlan show interfaces :: The Wi-Fi connection: signal, channel, speed, SSID
netsh wlan show profiles :: The saved Wi-Fi networks
netsh wlan show wlanreport :: Makes a Wi-Fi report (HTML) for the last days
Get-NetFirewallProfile :: Is the firewall on, for which network types?
Get-NetFirewallRule -Enabled True -Direction Inbound :: The active inbound rules
Get-NetConnectionProfile :: Is the network Public, Private or Domain?
'@
        }
        @{
            Title  = 'RESET THE NETWORK STACK (only when you are sure; this changes the PC)'
            Rows   = @'
netsh winsock reset :: Resets the socket layer (needs a restart)
netsh int ip reset :: Resets the TCP/IP settings (needs a restart)
Restart-NetAdapter -Name "Ethernet" :: Turns one adapter off and on
Note: run these as administrator. Start there: ipconfig /release, ipconfig /renew, ipconfig /flushdns.
'@
        }
    )
}
