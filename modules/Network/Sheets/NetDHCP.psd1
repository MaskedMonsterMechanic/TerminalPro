@{
    Command  = 'Show-NetDHCP'
    Alias    = 'netdhcp'
    Synopsis = 'DHCP for IPv4 and IPv6 (server, relay, SLAAC, DHCPv6)'
    Group    = 'ROUTER'
    Order    = 62
    Index    = 'Show-NetCommands'
    Title    = 'NETWORK MODULE - DHCP CONFIGURATION'
    Prompt   = 'Router(config)#'

    Sections = @(
        @{
            Title  = 'DHCP SERVER ON A ROUTER (IPv4)'
            Rows   = @'
ip dhcp excluded-address 192.168.10.1 192.168.10.20 :: Keeps these addresses out of the pool (routers, printers, servers with fixed addresses). Do this first.
ip dhcp pool LAN10 :: Creates a pool and goes into it
Router(dhcp-config)# :: network 192.168.10.0 255.255.255.0 :: The addresses to hand out (also: network 192.168.10.0 /24)
Router(dhcp-config)# :: default-router 192.168.10.1 :: The default gateway the clients get
Router(dhcp-config)# :: dns-server 192.0.2.53 198.51.100.53 :: The DNS servers the clients get
Router(dhcp-config)# :: domain-name lab.example :: The domain name the clients get
Router(dhcp-config)# :: lease 7 :: Lease time: 7 days (days hours minutes: lease 0 8 is 8 hours)
Router(dhcp-config)# :: lease infinite :: Never expires
Router(config)# :: no service dhcp :: Turns the DHCP server and relay service off (it is on by default)
'@
        }
        @{
            Title  = 'DHCP RELAY (the server is on another network)'
            Rows   = @'
interface g0/0 :: The interface the CLIENTS are on
Router(config-if)# :: ip helper-address 192.0.2.10 :: Forwards the clients' DHCP broadcasts as unicast to the server
Note: ip helper-address also forwards TFTP, DNS, NetBIOS and a few other UDP broadcasts. Turn those off with: no ip forward-protocol udp <port>
Note: the server needs a pool for the client's network (it picks the pool from the address of the relay interface).
'@
        }
        @{
            Title  = 'DHCP CLIENT ON A ROUTER OR SWITCH'
            Rows   = @'
interface g0/1 :: The interface that should get an address
Router(config-if)# :: ip address dhcp :: Asks a DHCP server (a common setup for the router facing the ISP)
Router(config-if)# :: no shutdown :: Turns it on
Router# :: show dhcp lease :: Shows what the router got
'@
        }
        @{
            Title  = 'CHECK AND TROUBLESHOOT DHCP (IPv4)'
            Rows   = @'
Router# :: show ip dhcp binding :: Who got which address, until when
Router# :: show ip dhcp pool :: How many addresses are used in each pool
Router# :: show ip dhcp server statistics :: Counters for discover, offer, request, ack
Router# :: show ip dhcp conflict :: Addresses taken out because someone else already used them
Router# :: clear ip dhcp binding * :: Throws out all leases
Router# :: debug ip dhcp server events :: Shows what the server does (turn off with: undebug all)
Router# :: show running-config | section dhcp :: Only the DHCP part of the configuration
PS> :: ipconfig /release ; ipconfig /renew :: On a Windows client: give the address back, ask again
PS> :: Get-DhcpServerv4Lease -ScopeId 192.168.10.0 :: On a Windows DHCP server: the leases in a scope
'@
        }
        @{
            Title  = 'IPV6 ADDRESSING: THE THREE WAYS'
            Rows   = @'
 :: SLAAC only :: Router advertisement with the prefix (A flag). The host builds its own address (EUI-64 or random). No DNS server is given.
 :: SLAAC + stateless DHCPv6 :: As above, plus the O flag. The host gets DNS and domain name from a DHCPv6 server. The server keeps no list of addresses.
 :: Stateful DHCPv6 :: The M flag. The host gets its address from a DHCPv6 server, which keeps a list. The A flag is switched off.
Note: the router sends router advertisements (RA) to ff02::1 (all nodes) every 200 seconds by default, and when a host asks with a router solicitation (RS) sent to ff02::2 (all routers).
'@
        }
        @{
            Title  = 'SLAAC (the router only gives the prefix)'
            Rows   = @'
ipv6 unicast-routing :: Required: without it the router does not send router advertisements
interface g0/0 :: The interface the hosts are on
Router(config-if)# :: ipv6 address 2001:db8:acad:1::1/64 :: The prefix in the address is what the hosts are told
Router(config-if)# :: ipv6 address fe80::1 link-local :: Hosts use this as default gateway: make it easy to read
Router# :: show ipv6 interface g0/0 :: Look for "ND advertised" lines and the "Hosts use stateless autoconfig" line
'@
        }
        @{
            Title  = 'STATELESS DHCPv6 SERVER ON A ROUTER (SLAAC + DNS)'
            Rows   = @'
ipv6 dhcp pool STATELESS :: Creates the pool (no address range in it)
Router(config-dhcpv6)# :: dns-server 2001:db8:acad:1::5 :: The DNS server for the hosts
Router(config-dhcpv6)# :: domain-name lab.example :: The domain name
interface g0/0 :: The interface the hosts are on
Router(config-if)# :: ipv6 dhcp server STATELESS :: Uses the pool on this interface
Router(config-if)# :: ipv6 nd other-config-flag :: Sets the O flag in the router advertisements: "ask DHCPv6 for the other things"
'@
        }
        @{
            Title  = 'STATEFUL DHCPv6 SERVER ON A ROUTER'
            Rows   = @'
ipv6 dhcp pool STATEFUL :: Creates the pool
Router(config-dhcpv6)# :: address prefix 2001:db8:acad:1::/64 lifetime infinite infinite :: The range to hand out (lifetimes: valid, preferred, in seconds)
Router(config-dhcpv6)# :: dns-server 2001:db8:acad:1::5 :: The DNS server
Router(config-dhcpv6)# :: domain-name lab.example :: The domain name
interface g0/0 :: The interface the hosts are on
Router(config-if)# :: ipv6 dhcp server STATEFUL :: Uses the pool on this interface
Router(config-if)# :: ipv6 nd managed-config-flag :: Sets the M flag: "get your address from DHCPv6"
Router(config-if)# :: ipv6 nd prefix default no-autoconfig :: Clears the A flag so hosts do not also build their own address
'@
        }
        @{
            Title  = 'DHCPv6 CLIENT AND RELAY'
            Rows   = @'
interface g0/1 :: The interface that should get its address
Router(config-if)# :: ipv6 enable :: Turns IPv6 on without a global address
Router(config-if)# :: ipv6 address dhcp :: Gets the address from a DHCPv6 server (stateful)
Router(config-if)# :: ipv6 address autoconfig :: Builds the address from router advertisements (SLAAC)
Router(config-if)# :: ipv6 dhcp relay destination 2001:db8:acad:2::5 :: On the client-facing interface of a router: forwards requests to a DHCPv6 server on another network
Router# :: show ipv6 dhcp pool :: The pools and how many clients use them
Router# :: show ipv6 dhcp binding :: Who got which address (stateful only)
Router# :: show ipv6 dhcp interface :: What DHCPv6 does on each interface
Router# :: debug ipv6 dhcp detail :: Shows the DHCPv6 messages (turn off with: undebug all)
'@
        }
    )
}
