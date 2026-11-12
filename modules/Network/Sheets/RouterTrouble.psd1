@{
    Command  = 'Show-RouterTrouble'
    Alias    = 'netrot'
    Synopsis = 'Troubleshooting a router: interfaces, routes, protocols, ACLs, NAT'
    Group    = 'TROUBLESHOOTING'
    Order    = 72
    Index    = 'Show-NetCommands'
    Title    = 'NETWORK MODULE - TROUBLESHOOTING A ROUTER'
    Prompt   = 'Router#'

    Sections = @(
        @{
            Title  = 'INTERFACES'
            Rows   = @'
show ip interface brief :: Every interface: address, Status and Protocol (both "up" is good)
show interfaces g0/0 :: The detail: errors, drops, rate, duplex, MTU
show ipv6 interface brief :: The same for IPv6
show controllers s0/0/0 :: On serial: DCE or DTE, clock rate, cable type
show interfaces description :: The descriptions of all interfaces
Note: "administratively down" is a shutdown. "down/down" is the cable or the other end. "up/down" is a layer 2 mismatch (encapsulation, clock rate, keepalives).
'@
        }
        @{
            Title  = 'ROUTING TABLE'
            Rows   = @'
show ip route :: The IPv4 routing table
show ip route 10.1.1.0 :: How one route was learned and where it goes
show ip route static :: Only the static routes
show ip route ospf :: Only the OSPF routes (same for eigrp, rip, bgp)
show ipv6 route :: The IPv6 table
show ip protocols :: Which protocols run, the networks they cover, the neighbors and the distances
show ip cef 10.1.1.1 :: What the forwarding table does with one address
'@
        }
        @{
            Title  = 'NEIGHBORS AND PROTOCOLS'
            Rows   = @'
show ip ospf neighbor :: OSPF neighbors: should be FULL (or 2WAY between two DROTHERs)
show ip ospf interface brief :: Which interfaces run OSPF, with area and cost
show ip eigrp neighbors :: EIGRP neighbors
show ip eigrp topology :: The EIGRP topology table
show ip bgp summary :: BGP neighbors and the number of prefixes received
show cdp neighbors detail :: Who is connected, with their address
Note: neighbors stuck? Check that both sides agree on the subnet, timers, area or AS number, authentication and MTU.
'@
        }
        @{
            Title  = 'ACLS AND NAT'
            Rows   = @'
show access-lists :: The ACL entries and how often each one matched
show ip interface g0/0 :: Look at "Inbound access list" and "Outgoing access list"
show ip nat translations :: The NAT table
show ip nat statistics :: Hits, misses and the inside / outside interfaces
show running-config | section access-list :: All ACL lines as typed
Note: an ACL has an implicit "deny all" at the end. And order matters: the first match wins.
'@
        }
        @{
            Title  = 'REACHING AND TRACING'
            Rows   = @'
ping 10.1.1.1 :: Basic reachability (uses the address of the outgoing interface as source)
ping 10.1.1.1 source loopback 0 :: From another address: tests the return path
ping 10.1.1.1 repeat 100 size 1500 :: A longer test with big packets
traceroute 10.1.1.1 :: The hops, and the one where it stops
show arp :: IP to MAC addresses learned on the router
show ipv6 neighbors :: The IPv6 version of ARP
'@
        }
        @{
            Title  = 'CONFIGURATION AND DEVICE'
            Rows   = @'
show running-config :: The active configuration
show startup-config :: The saved configuration
show running-config | include ip route :: Only the lines that contain this text
show running-config | section ospf :: The whole section that starts with this text
show version :: IOS version, uptime, configuration register, memory
show processes cpu sorted :: What uses the CPU
show logging :: The log buffer
terminal monitor :: Shows log and debug messages in a telnet or SSH session
undebug all :: Turns all debugging off (do this when you have finished)
'@
        }
        @{
            Title  = 'A SHORT ORDER OF WORK'
            Rows   = @'
Note: 1. Interfaces up/up, with the right address and mask?
Note: 2. Is there a route to the destination, AND a route back on the other router?
Note: 3. Do routing protocol neighbors form? If not, check timers, area or AS, authentication, subnet and MTU.
Note: 4. Does an ACL or NAT change or block the traffic?
Note: 5. Test from the router with a "source" address, to test the return path.
Note: 6. Debug only if you must, with a limited filter, and "undebug all" when done.
'@
        }
    )
}
