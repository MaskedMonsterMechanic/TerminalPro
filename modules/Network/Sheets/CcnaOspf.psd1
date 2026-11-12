@{
    Command  = 'Show-CcnaOspf'
    Alias    = 'ccnaospf'
    Synopsis = 'OSPF single area: setup, router ID, cost, DR/BDR, neighbors, checking'
    Group    = 'CCNA'
    Order    = 104
    Index    = 'Show-NetCommands'
    Title    = 'CCNA - OSPF (ONE AREA, IPv4 AND IPv6)'
    Prompt   = 'Router(config)#'

    Sections = @(
        @{
            Title  = 'THE IDEA'
            Rows   = @'
 :: Link state :: Every router describes its own links (LSAs) and floods them. All routers in an area build the same map (the LSDB), and each runs the SPF algorithm on it to find its own best paths.
 :: Neighbors :: Routers become neighbors by exchanging Hello packets. Then they swap their databases, and end up "Full".
 :: Messages :: Hello, Database Description (DBD), Link State Request (LSR), Link State Update (LSU), Link State Acknowledgment (LSAck).
 :: Addresses :: 224.0.0.5 is "all OSPF routers". 224.0.0.6 is "the DR and BDR". (IPv6: ff02::5 and ff02::6.)
 :: Distance :: 110. Metric: cost.
 :: Neighbor states :: Down, Init, 2-Way, ExStart, Exchange, Loading, Full.
'@
        }
        @{
            Title  = 'BASIC SETUP (OSPFv2)'
            Rows   = @'
router ospf 10 :: Starts OSPF. The number is only a local process ID: it does not have to match the neighbors'.
Router(config-router)# :: router-id 1.1.1.1 :: Sets the router ID by hand (looks like an address, but is only a name)
Router(config-router)# :: network 192.168.10.0 0.0.0.255 area 0 :: Turns OSPF on for every interface with an address in this range, and puts it in area 0 (wildcard mask!)
Router(config-router)# :: network 10.0.0.1 0.0.0.0 area 0 :: A wildcard of 0.0.0.0 picks exactly one interface
Router(config-router)# :: passive-interface g0/0 :: No hellos on the LAN, but the network is still advertised
Router(config-router)# :: default-information originate :: Tells the others about this router's default route
interface g0/1 :: Goes to an interface
Router(config-if)# :: ip ospf 10 area 0 :: Another way: turn OSPF on for this one interface (instead of a network statement)
Note: the router ID is chosen as: 1. the "router-id" command, 2. the highest loopback address, 3. the highest address of an active interface.
Note: a router ID is not changed while OSPF runs. After changing it use: clear ip ospf process
'@
        }
        @{
            Title  = 'COST (the metric)'
            Rows   = @'
 :: Formula :: cost = reference bandwidth / interface bandwidth. The default reference is 100 Mbps, with a minimum cost of 1.
 :: The problem :: With 100 Mbps as reference, FastEthernet, Gigabit and 10 Gigabit all cost 1. OSPF cannot tell them apart.
auto-cost reference-bandwidth 10000 :: Sets the reference to 10 Gbps (in Mbps). Use the same value on EVERY router.
Router(config-if)# :: ip ospf cost 10 :: Sets the cost of one interface by hand
Router(config-if)# :: bandwidth 1000000 :: Changes the number OSPF uses (in kbps). It does not change the real speed.
Note: the cost of a path is the sum of the costs of the outgoing interfaces on the way.
Note: see the whole table with: show ip ospf interface brief
'@
        }
        @{
            Title  = 'NETWORK TYPES, DR AND BDR'
            Rows   = @'
 :: Broadcast (Ethernet) :: Elects a DR and BDR. Hello 10 s, dead 40 s.
 :: Point-to-point (serial, PPP) :: No election. Hello 10 s, dead 40 s.
 :: Non-broadcast (Frame Relay) :: Elects a DR and BDR. Hello 30 s, dead 120 s.
 :: Why a DR :: On a shared network every router would otherwise become a neighbor of all the others. With a DR, they all talk to the DR and BDR only.
 :: Election :: The highest priority wins, then the highest router ID. Default priority is 1. Priority 0 means "never".
 :: No take-over :: A new router with a higher priority does NOT replace a working DR. The election happens only when the DR is gone.
Router(config-if)# :: ip ospf priority 255 :: Makes this router likely to win
Router(config-if)# :: ip ospf priority 0 :: This router will never be DR or BDR
Router(config-if)# :: ip ospf network point-to-point :: Skips the election on a link with exactly two routers (Ethernet used as a router-to-router link)
Router(config-if)# :: ip ospf hello-interval 5 :: Sends hellos every 5 seconds (the dead interval must match the neighbor's)
Note: in "show ip ospf neighbor": routers that are neither DR nor BDR stay in 2WAY with each other. That is correct.
'@
        }
        @{
            Title  = 'A NEIGHBOR DOES NOT COME UP: CHECK THESE'
            Rows   = @'
 :: 1 :: Both interfaces are up, and in the same subnet with the same mask.
 :: 2 :: Same area number on that link.
 :: 3 :: Same hello and dead timers.
 :: 4 :: Same authentication settings (if used).
 :: 5 :: Same MTU.
 :: 6 :: Different router IDs.
 :: 7 :: The interface is not passive.
 :: 8 :: Network types are compatible (both point-to-point, or both broadcast).
 :: 9 :: No ACL blocks OSPF (IP protocol 89).
 :: Stuck in :: INIT: it hears them but they do not hear it. 2WAY: normal between non-DR routers. EXSTART/EXCHANGE: usually an MTU mismatch.
'@
        }
        @{
            Title  = 'OSPFv3 (IPv6)'
            Rows   = @'
ipv6 unicast-routing :: Required first
ipv6 router ospf 10 :: Starts OSPFv3
Router(config-rtr)# :: router-id 1.1.1.1 :: Needed: OSPFv3 still uses an IPv4-style router ID (set it by hand if the router has no IPv4 address)
interface g0/0 :: Goes to an interface
Router(config-if)# :: ipv6 ospf 10 area 0 :: Turns it on for this interface (there is no network command in OSPFv3)
Router# :: show ipv6 ospf neighbor :: The neighbors
Router# :: show ipv6 ospf interface brief :: The interfaces
Router# :: show ipv6 route ospf :: The routes
'@
        }
        @{
            Title  = 'CHECK OSPF'
            Prompt = 'Router#'
            Rows   = @'
show ip ospf neighbor :: Neighbors: state (FULL, 2WAY), DR/BDR role, and the interface
show ip ospf interface brief :: Interfaces in OSPF: area, cost, state, number of neighbors
show ip ospf interface g0/0 :: The details: network type, timers, DR and BDR
show ip ospf :: Router ID, areas, SPF runs, reference bandwidth
show ip ospf database :: The link state database
show ip route ospf :: Only the OSPF routes (look for the O code and [110/cost])
show ip protocols :: Networks, passive interfaces, neighbors and distance
debug ip ospf adj :: Watches neighbors forming (undebug all when done)
clear ip ospf process :: Restarts OSPF (needed after changing a router ID)
'@
        }
    )
}
