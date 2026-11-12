@{
    Command  = 'Show-RouterBasic'
    Alias    = 'netrob'
    Synopsis = 'Router setup: interfaces, loopback, serial, IPv6, default route'
    Group    = 'ROUTER'
    Order    = 60
    Index    = 'Show-NetCommands'
    Title    = 'NETWORK MODULE - ROUTER CONFIGURATION'
    Prompt   = 'Router(config)#'

    Sections = @(
        @{
            Title  = 'ETHERNET INTERFACE'
            Rows   = @'
interface g0/0 :: Goes to interface configuration mode
Router(config-if)# :: description LAN 1 - Office :: Writes a label that shows up in show commands
Router(config-if)# :: ip address 192.168.10.1 255.255.255.0 :: The IPv4 address and mask
Router(config-if)# :: no shutdown :: Turns the interface on (router interfaces are off by default)
Router(config-if)# :: ip address dhcp :: Takes the address from a DHCP server instead
Router# :: show ip interface brief :: The quick check: Status and Protocol should both say "up"
Router# :: show interfaces g0/0 :: The detail: errors, rates, duplex
'@
        }
        @{
            Title  = 'IPV6'
            Rows   = @'
Router(config)# :: ipv6 unicast-routing :: Lets the router route IPv6 (also makes it send router advertisements)
Router(config-if)# :: ipv6 address 2001:db8:acad:1::1/64 :: A global unicast address
Router(config-if)# :: ipv6 address fe80::1 link-local :: A link-local address that is easy to remember (the same on every interface is fine)
Router(config-if)# :: ipv6 address 2001:db8:acad:1::/64 eui-64 :: Builds the interface ID from the MAC address
Router(config-if)# :: ipv6 address autoconfig default :: Takes the address from router advertisements (SLAAC)
Router# :: show ipv6 interface brief :: The quick check for IPv6
Router# :: show ipv6 route :: The IPv6 routing table
Router# :: show ipv6 neighbors :: The IPv6 neighbor table (the "ARP table" of IPv6)
Note: try netcalc6 and neteui in this module to work the addresses out.
'@
        }
        @{
            Title  = 'SERIAL INTERFACE'
            Rows   = @'
Router(config)# :: interface s0/0/0 :: Goes to the serial interface
Router(config-if)# :: ip address 209.165.200.225 255.255.255.252 :: A /30 is the normal size for a point-to-point link
Router(config-if)# :: clock rate 128000 :: Sets the speed on the DCE end only (look for the DCE end with: show controllers s0/0/0)
Router(config-if)# :: encapsulation ppp :: Uses PPP instead of the default HDLC (both ends must match)
Router(config-if)# :: no shutdown :: Turns it on
Router# :: show controllers s0/0/0 :: Shows which end is DCE and DTE
'@
        }
        @{
            Title  = 'LOOPBACK'
            Rows   = @'
Router(config)# :: interface loopback 0 :: Creates a software interface that is always up
Router(config-if)# :: ip address 10.0.0.1 255.255.255.255 :: A host address: the router ID for OSPF and BGP and a stable address to manage the router on
Note: loopbacks never go down while the router runs, so they do not change the router ID when a cable is pulled.
'@
        }
        @{
            Title  = 'SUBINTERFACES (ROUTER ON A STICK)'
            Rows   = @'
Router(config)# :: interface g0/0 :: The physical interface connected to the trunk
Router(config-if)# :: no shutdown :: Turns the physical interface on (it has no IP address itself)
Router(config)# :: interface g0/0.10 :: Creates a subinterface for VLAN 10 (the number after the dot is only a label)
Router(config-subif)# :: encapsulation dot1q 10 :: Says which VLAN this subinterface carries
Router(config-subif)# :: ip address 192.168.10.1 255.255.255.0 :: The gateway address for that VLAN
Router(config-subif)# :: encapsulation dot1q 99 native :: For the native VLAN on a subinterface
Router# :: show ip interface brief :: Checks that each subinterface is up
Note: see Show-NetInterVlan (netiv) for the whole picture.
'@
        }
        @{
            Title  = 'DEFAULT ROUTE AND BASIC ROUTING'
            Rows   = @'
Router(config)# :: ip route 0.0.0.0 0.0.0.0 203.0.113.1 :: Sends everything unknown to the next hop (for example the ISP)
Router(config)# :: ip route 0.0.0.0 0.0.0.0 g0/1 :: The same through an interface (fine on point-to-point links, avoid on Ethernet)
Router(config)# :: ipv6 route ::/0 2001:db8:ffff::1 :: The IPv6 default route
Router# :: show ip route :: Look for the "S*" line (a static default route)
Router# :: show ip protocols :: Which routing protocols run and what they advertise
Note: more in Show-NetStatic (netsta).
'@
        }
        @{
            Title  = 'USEFUL EXTRAS'
            Rows   = @'
Router(config)# :: ip name-server 8.8.8.8 :: Where the router asks for names (only with "ip domain-lookup" turned on)
Router(config)# :: ip host R2 192.0.2.2 :: A tiny hosts file: now "ping R2" works
Router(config)# :: ntp server 192.0.2.123 :: Takes the time from an NTP server
Router(config)# :: logging host 192.0.2.50 :: Sends the log messages to a syslog server
Router(config)# :: service timestamps log datetime msec :: Puts a time on every log line
Router(config)# :: cdp run :: CDP on (it is on by default); use "no cdp run" or no cdp enable on an interface towards untrusted links
Router(config)# :: lldp run :: LLDP on (the standard version of CDP)
Router# :: ping 192.0.2.1 source loopback 0 :: Pings from a chosen address
Router# :: traceroute 192.0.2.1 :: Shows the hops
'@
        }
    )
}
