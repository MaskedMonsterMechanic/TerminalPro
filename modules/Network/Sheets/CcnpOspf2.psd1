@{
    Command  = 'Show-CcnpOspfAdvanced'
    Alias    = 'ccnpospf2'
    Synopsis = 'OSPF: stub, totally stubby and NSSA areas, summaries, filtering, authentication, OSPFv3'
    Group    = 'CCNP'
    Order    = 211
    Index    = 'Show-NetCommands'
    Title    = 'CCNP - OSPF: STUB AREAS, SUMMARIES, FILTERING, SECURITY, OSPFv3'
    Prompt   = 'Router(config)#'

    Sections = @(
        @{
            Title  = 'THE AREA TYPES AT A GLANCE'
            Rows   = @'
 :: Normal :: Gets everything: type 1, 2, 3, 4 and 5 LSAs.
 :: Stub :: No type 4 and 5 (external routes). The ABR sends in a default route instead.
 :: Totally stubby :: No type 3 either. The area gets ONE default route and its own routes. (Cisco only.)
 :: NSSA :: A stub area that may have its own ASBR. External routes made in the area are type 7, and the ABR changes them to type 5.
 :: Totally NSSA :: An NSSA without type 3. Also gets a default route from the ABR.
Note: the idea: a branch with one way out does not need to know all the routes. A smaller database and a quicker SPF.
'@
        }
        @{
            Title  = 'STUB AND TOTALLY STUBBY'
            Rows   = @'
Router(config-router)# :: area 2 stub :: On EVERY router in area 2 (the "stub" flag in the hellos must match, or the routers do not become neighbors)
Router(config-router)# :: area 2 stub no-summary :: On the ABR only: also stops type 3. The other routers in the area just use "area 2 stub".
Router(config-router)# :: area 2 default-cost 10 :: On the ABR: the cost of the default route it sends into the stub area
Router# :: show ip ospf :: Look for "Area 2 ... It is a stub area" (and "no summary LSA in this area")
Router# :: show ip route ospf :: In the stub area: an "O*IA 0.0.0.0/0" default route
Note: a stub area cannot have an ASBR (redistribution) and cannot be the transit area of a virtual link.
'@
        }
        @{
            Title  = 'NSSA'
            Rows   = @'
Router(config-router)# :: area 3 nssa :: On every router in area 3
Router(config-router)# :: area 3 nssa default-information-originate :: On the ABR: also sends a default route into the NSSA (it is not sent by default)
Router(config-router)# :: area 3 nssa no-summary :: On the ABR: totally NSSA, which also stops type 3 and sends a default route
Router(config-router)# :: redistribute static subnets :: On the ASBR inside the NSSA: the routes become type 7 (O N2)
Note: on the other side of the ABR those routes show up as normal external routes (O E2).
'@
        }
        @{
            Title  = 'SUMMARIZING'
            Rows   = @'
Router(config-router)# :: area 1 range 10.1.0.0 255.255.252.0 :: On the ABR: a type 3 summary for area 1's networks, going out to the other areas
Router(config-router)# :: area 1 range 10.1.2.0 255.255.255.0 not-advertise :: On the ABR: hides one network from the others
Router(config-router)# :: area 1 range 10.1.0.0 255.255.252.0 cost 100 :: Sets the cost by hand (otherwise: the lowest cost of the networks inside)
Router(config-router)# :: summary-address 172.16.0.0 255.255.0.0 :: On the ASBR: one summary for the external routes
Note: a summary makes a route to Null0 on the router that makes it. This stops loops.
Note: work out the summary with: netsum 10.1.0.0/24,10.1.1.0/24,10.1.2.0/24,10.1.3.0/24
'@
        }
        @{
            Title  = 'FILTERING'
            Rows   = @'
ip prefix-list HIDE seq 5 deny 10.1.3.0/24 :: A prefix list
ip prefix-list HIDE seq 10 permit 0.0.0.0/0 le 32 :: ...that allows the rest
Router(config-router)# :: area 1 filter-list prefix HIDE out :: On the ABR: stops type 3 LSAs for those networks from leaving area 1 (also: in)
Router(config-router)# :: distribute-list prefix HIDE in :: On any router: stops the routes from going into the ROUTING TABLE of this router. They stay in the database, so other routers are not affected.
Note: OSPF cannot filter inside an area, because all the routers in an area must have the same database.
'@
        }
        @{
            Title  = 'AUTHENTICATION'
            Rows   = @'
interface g0/0 :: Goes to the interface
Router(config-if)# :: ip ospf authentication message-digest :: Uses MD5 on this link
Router(config-if)# :: ip ospf message-digest-key 1 md5 <secret> :: The key number and the password (the same on both ends)
Router(config-router)# :: area 0 authentication message-digest :: Turns MD5 on for all interfaces in area 0 (the keys are still set on the interfaces)
Router(config-if)# :: ip ospf authentication key-chain OSPF-KEYS :: Newer IOS: use a key chain, also for SHA (hmac-sha-256)
Router(config-if)# :: ip ospf authentication-key <secret> :: Simple password in clear text: avoid
Note: a neighbor that does not come up after turning on authentication: check the key number, the password and the type on both sides.
'@
        }
        @{
            Title  = 'SPEED OF CHANGE'
            Rows   = @'
Router(config-router)# :: timers throttle spf 50 200 5000 :: How long to wait before running SPF: start 50 ms, then 200 ms, at most 5000 ms
Router(config-router)# :: timers throttle lsa all 0 200 5000 :: The same idea for sending LSAs
Router(config-if)# :: ip ospf hello-interval 1 :: Shorter hello time. Set the dead time at the same time (a multiple of the hello).
Note: for fast failure detection on links, BFD is the better choice (bfd all-interfaces under OSPF).
'@
        }
        @{
            Title  = 'OSPFv3 (IPv6, and IPv4 too)'
            Rows   = @'
 :: Differences :: Runs per link, not per subnet. Uses link-local addresses for neighbors. Multicast ff02::5 and ff02::6. The router ID is still a 32-bit number.
 :: LSAs :: Type 1 and 2 no longer hold addresses. New: type 8 (link-local info) and type 9 (intra-area prefixes).
 :: Security :: Uses IPsec (AH / ESP) in the original version. Newer IOS has "ospfv3 authentication".
ipv6 unicast-routing :: Required first (in global configuration)
router ospfv3 1 :: The newer, address-family style process
Router(config-router)# :: router-id 1.1.1.1 :: Router ID
Router(config-router)# :: address-family ipv6 unicast :: IPv6 settings go in here (passive-interface, summaries, and so on)
interface g0/0 :: Goes to the interface
Router(config-if)# :: ospfv3 1 ipv6 area 0 :: Turns OSPFv3 on for IPv6 on this interface
Router(config-if)# :: ospfv3 1 ipv4 area 0 :: ...and also for IPv4 (one process can do both address families)
Router# :: show ospfv3 neighbor :: Neighbors
Router# :: show ospfv3 interface brief :: Interfaces
Router# :: show ipv6 route ospf :: Routes
Note: the older form still exists: "ipv6 router ospf 1" and "ipv6 ospf 1 area 0" on the interface (see ccnaospf).
'@
        }
        @{
            Title  = 'A NEIGHBOR OR A ROUTE IS MISSING: CHECK THESE'
            Rows   = @'
 :: Stub flag :: Stub, NSSA and normal areas do not become neighbors with each other.
 :: Authentication :: Type and key must match.
 :: MTU :: A different IP MTU keeps routers in EXSTART/EXCHANGE.
 :: Area number :: Both ends of a link must be in the same area.
 :: Area 0 :: Is the area connected to the backbone? Without it its routes are not seen elsewhere.
 :: Filters :: A filter-list, distribute-list or not-advertise could be hiding the route.
 :: Type 5 routes in a stub area :: They are not there by design. Look for the default route.
'@
        }
    )
}
