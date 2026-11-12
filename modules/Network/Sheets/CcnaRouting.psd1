@{
    Command  = 'Show-CcnaRouting'
    Alias    = 'ccnaroute'
    Synopsis = 'How a router decides: forwarding, the routing table line by line, best path'
    Group    = 'CCNA'
    Order    = 101
    Index    = 'Show-NetCommands'
    Title    = 'CCNA - HOW A ROUTER DECIDES (ROUTING TABLE AND FORWARDING)'

    Sections = @(
        @{
            Title  = 'WHAT HAPPENS TO A PACKET'
            Rows   = @'
Step 1 :: The frame arrives. The router checks the MAC address and the error check, then throws away the frame header.
Step 2 :: It looks up the destination IP address in the routing table, and takes the route with the LONGEST matching prefix.
Step 3 :: Directly connected network: it asks ARP for the host's MAC address (or uses its cache) and sends it to the host.
Step 4 :: Remote network: it wraps the packet in a new frame for the next hop (or out of the exit interface).
Step 5 :: No match: it uses the default route (the "gateway of last resort"). If there is none, it drops the packet and sends back an ICMP "unreachable".
Note: when two routes match the same length, the lower administrative distance wins. When the distance is equal too, the lower metric wins. When that is equal too, the router shares the traffic.
'@
        }
        @{
            Title  = 'READ ONE LINE OF THE ROUTING TABLE'
            Rows   = @'
Example: D 10.1.1.0/24 [90/2170112] via 209.165.200.226, 00:00:05, Serial0/0/0
1. D :: The source: how the route was learned (D = EIGRP)
2. 10.1.1.0/24 :: The destination network
3. 90 :: The administrative distance: how much the router trusts that source (lower is better)
4. 2170112 :: The metric: how good the route is, inside the same source (lower is better)
5. via 209.165.200.226 :: The next hop: the router the packet goes to
6. 00:00:05 :: The age: when the route was last updated
7. Serial0/0/0 :: The exit interface
'@
        }
        @{
            Title  = 'ROUTE CODES'
            Rows   = @'
L :: Local: the router's own address on an interface (a /32)
C :: Connected network
S :: Static route
S* :: Static route that is the default route
R :: RIP
D :: EIGRP
EX :: EIGRP external
O :: OSPF
IA :: OSPF inter-area
E1 / E2 :: OSPF external type 1 / 2
N1 / N2 :: OSPF NSSA external type 1 / 2
B :: BGP
i :: IS-IS
* :: Candidate default route
'@
        }
        @{
            Title  = 'WORDS FROM THE ROUTING TABLE'
            Rows   = @'
Ultimate route :: A line that has a next hop or an exit interface. It can be used to forward packets.
Level 1 route :: A route whose mask is the same as or shorter than the classful mask of its network: a network route, a supernet (summary) route, or a default route.
Parent route :: A line that only groups subnets of a classful network ("172.16.0.0/16 is variably subnetted"). It is never used to forward.
Child route :: A subnet below a parent route. Child routes are ultimate routes.
Gateway of last resort :: The default route. It is set when a static default exists or a protocol learns one.
'@
        }
        @{
            Title  = 'HOW THE ROUTER LEARNS ROUTES'
            Rows   = @'
Connected and local :: Added as soon as an interface has an address and is up/up
Static :: Added when you type it, as long as the exit interface (or the next hop) works
Dynamic :: Added by a routing protocol (RIP, EIGRP, OSPF, BGP)
Note: the metric is each protocol's own idea of "best". RIP counts hops. OSPF adds up costs based on bandwidth. EIGRP uses bandwidth and delay (and optionally load and reliability).
Note: only EIGRP can share the traffic over unequal paths (the "variance" command).
'@
        }
        @{
            Title  = 'PACKET FORWARDING METHODS ON A CISCO ROUTER'
            Rows   = @'
Process switching :: The CPU looks up every single packet. Slow, and only used for packets that need special treatment.
Fast switching :: The first packet is process switched, and the result is saved in a cache for the next packets of the same flow. Old.
CEF (Cisco Express Forwarding) :: Builds the forwarding table (FIB) and the adjacency table in advance, and rebuilds them when the topology changes. The default today.
Note: the FIB is a copy of the routing table in a form that is quick to look up. The adjacency table holds the next hops' layer 2 headers.
'@
        }
        @{
            Title  = 'COMMANDS'
            Prompt = 'Router#'
            Rows   = @'
show ip route :: The IPv4 routing table
show ip route 10.1.1.0 :: Why and how this route is used
show ip route | begin Gateway :: Jumps to the gateway of last resort and the routes
show ip route connected :: Only one source (also: static, ospf, eigrp, rip, bgp)
show ip cef 10.1.1.1 :: What the forwarding table does for one address
show adjacency detail :: The layer 2 headers CEF has stored
show ip protocols :: Protocols that run, their networks, neighbors, and distances
show ipv6 route :: The IPv6 routing table
'@
        }
    )
}
