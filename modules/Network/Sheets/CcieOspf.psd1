@{
    Command  = 'Show-CcieOspf'
    Alias    = 'ccieospf'
    Synopsis = 'OSPF in depth: LSA types, area types, network types, filtering, timers, LFA, OSPFv3 address families, troubleshooting'
    Group    = 'CCIE'
    Order    = 303
    Index    = 'Show-NetCommands'
    Title    = 'CCIE - OSPF IN DEPTH'
    Prompt   = 'Router(config-router)#'

    Sections = @(
        @{
            Title  = 'LSA TYPES'
            Rows   = @'
 :: Type 1, Router :: Made by every router. Lists its links in ONE area. Stays in the area.
 :: Type 2, Network :: Made by the DR on a broadcast or non-broadcast segment. Lists the routers on it. Stays in the area.
 :: Type 3, Summary :: Made by an ABR. Carries a prefix from one area into another (inter-area route, O IA).
 :: Type 4, ASBR summary :: Made by an ABR. Tells how to reach an ASBR that is in another area.
 :: Type 5, External :: Made by an ASBR. A route from outside OSPF. Flooded in the whole domain, except stub areas.
 :: Type 7, NSSA external :: Made by an ASBR inside an NSSA. The ABR turns it into type 5 when it leaves the area.
 :: Type 9, 10, 11 :: Opaque LSAs: link-local, area-wide, AS-wide. Used for extensions (for example traffic engineering, graceful restart).
 :: Route order :: Intra-area (O), inter-area (O IA), external type 1 (E1) or NSSA type 1 (N1), then external type 2 (E2) or N2. Distance is 110 for all.
 :: E1 vs E2 :: E2 (the default) keeps the external cost as it is. E1 adds the internal cost to the ASBR.
'@
        }
        @{
            Title  = 'AREA TYPES'
            Rows   = @'
area 1 stub :: Stub: no type 4 or 5. The ABR sends a default route in instead. All routers of the area must agree.
area 1 stub no-summary :: Totally stubby (on the ABR only): also no type 3. Only the default route comes in.
area 1 nssa :: NSSA: no type 5 from outside, but an ASBR inside the area is allowed (type 7)
area 1 nssa no-summary :: Totally NSSA (on the ABR): also no type 3
area 1 nssa default-information-originate :: The ABR sends a default route into the NSSA
area 1 nssa no-redistribution :: The ABR does not turn "redistribute" routes into the NSSA
area 1 default-cost 20 :: Cost of the default route the ABR sends into a stub area
 :: Rules :: Area 0 can never be a stub. A virtual link cannot cross a stub area. The "stub" flag is in the hello: neighbors must match, or they do not form.
'@
        }
        @{
            Title  = 'NETWORK TYPES AND TIMERS'
            Rows   = @'
Router(config-if)# :: ip ospf network point-to-point :: No DR election, no type 2 LSA (hello 10, dead 40). The usual choice on two-router links.
Router(config-if)# :: ip ospf network broadcast :: DR and BDR election (hello 10, dead 40)
Router(config-if)# :: ip ospf network non-broadcast :: NBMA: neighbors are typed by hand, with DR election (hello 30, dead 120)
Router(config-if)# :: ip ospf network point-to-multipoint :: No DR. Adds a /32 host route per neighbor (hello 30, dead 120)
Router(config-if)# :: ip ospf network point-to-multipoint non-broadcast :: Like the above, but neighbors typed by hand
Router(config-if)# :: ip ospf priority 0 :: This router never becomes DR or BDR. The highest priority wins, then the highest router ID.
Router(config-if)# :: ip ospf hello-interval 1 :: Seconds between hellos
Router(config-if)# :: ip ospf dead-interval 4 :: Seconds without hello before the neighbor is down
Router(config-if)# :: ip ospf dead-interval minimal hello-multiplier 4 :: Dead interval 1 second, so 4 hellos per second (sub-second)
Router(config-if)# :: ip ospf cost 50 :: Sets the cost of the interface by hand
neighbor 10.1.1.2 :: On non-broadcast networks: the neighbor address
 :: DR election :: Not pre-emptive. A router with a better priority that arrives later does NOT take over. Clear the process to force a new election.
'@
        }
        @{
            Title  = 'COST, SPF AND ROUTER ID'
            Rows   = @'
auto-cost reference-bandwidth 100000 :: Reference in Mb/s (100000 = 100 Gb/s). Set the SAME value on all routers.
router-id 1.1.1.1 :: A fixed router ID (a change needs: clear ip ospf process)
timers throttle spf 50 200 5000 :: SPF run timing in ms: first wait, wait between runs, longest wait
max-metric router-lsa :: Tells others not to use this router for transit (for maintenance)
bfd all-interfaces :: Uses BFD for fast failure detection on all OSPF interfaces
passive-interface default :: Passive on all interfaces...
no passive-interface g0/1 :: ...except this one
 :: Cost :: reference bandwidth / interface bandwidth, never below 1. Tool: ccnacost -Link GigabitEthernet,Serial
'@
        }
        @{
            Title  = 'FILTERING AND SUMMARISING'
            Rows   = @'
area 1 range 10.1.0.0 255.255.0.0 :: ABR: sends ONE type 3 summary for the area (this is the way to summarise inter-area routes)
area 1 range 10.1.0.0 255.255.0.0 not-advertise :: ABR: hides this prefix (and its parts) from the other areas
summary-address 172.16.0.0 255.255.0.0 :: ASBR: summarises EXTERNAL routes (type 5)
area 1 filter-list prefix NO-TEN in :: ABR: filters the type 3 routes going INTO area 1 (also: out)
distribute-list prefix NO-TEN in :: Filters what goes into the ROUTING TABLE of this router only. The LSAs are still flooded: others still see them.
distribute-list route-map RM in :: The same with a route map
Router(config)# :: ip prefix-list NO-TEN deny 10.9.0.0/16 :: The prefix list for the above
Router(config)# :: ip prefix-list NO-TEN permit 0.0.0.0/0 le 32 :: ...and let the rest through
redistribute static subnets metric 20 metric-type 1 :: Redistribution: "subnets" is needed or classful networks only are taken
 :: Remember :: OSPF is link-state: every router in an area must have the same database, so you filter at area borders (ABR) or at the border of the domain (ASBR), not inside.
'@
        }
        @{
            Title  = 'VIRTUAL LINKS AND LFA'
            Rows   = @'
area 1 virtual-link 2.2.2.2 :: A virtual link to the ABR with this router ID, through transit area 1 (set it on BOTH ends). It connects an area to area 0.
fast-reroute per-prefix enable prefix-priority low :: Loop-free alternate (LFA): pre-computes a backup next hop, so traffic switches in milliseconds
fast-reroute per-prefix remote-lfa tunnel mpls-ldp :: Remote LFA: reaches the backup through an LDP tunnel (needs MPLS LDP)
Router# :: show ip ospf fast-reroute :: Shows the LFA state
 :: Idea :: A neighbor is a loop-free alternate if its own best path to the destination does not go back through you.
Note: a virtual link is a last resort for a temporary fix. A real link to area 0 is the right design.
'@
        }
        @{
            Title  = 'AUTHENTICATION'
            Rows   = @'
Router(config-if)# :: ip ospf authentication message-digest :: MD5 on this interface
Router(config-if)# :: ip ospf message-digest-key 1 md5 <secret> :: The key ID and the secret (the same at both ends)
area 0 authentication message-digest :: Turns it on for a whole area (then keys are still set per interface)
Router(config-if)# :: ip ospf authentication null :: No authentication on this interface (overrides the area setting)
Router(config-if)# :: ip ospf authentication key-chain KEYS :: SHA authentication from a key chain (key ... cryptographic-algorithm hmac-sha-256)
Router(config-if)# :: ospfv3 authentication ipsec spi 256 sha1 <40 hex digits> :: OSPFv3 uses IPsec for authentication (older style)
Note: the SHA key chain form (RFC 5709) needs a recent IOS XE. Check "ip ospf authentication ?" on your device.
'@
        }
        @{
            Title  = 'OSPFv3 AND ADDRESS FAMILIES'
            Rows   = @'
Router(config)# :: ipv6 unicast-routing :: Turn on IPv6 routing first (global)
Router(config)# :: router ospfv3 1 :: The OSPFv3 process (the new, address-family style)
Router(config-router)# :: router-id 1.1.1.1 :: OSPFv3 still needs an IPv4-style router ID
Router(config-router)# :: address-family ipv6 unicast :: IPv6 settings (and: address-family ipv4 unicast for IPv4 in OSPFv3)
Router(config-if)# :: ospfv3 1 ipv6 area 0 :: Enables IPv6 on this interface in area 0
Router(config-if)# :: ospfv3 1 ipv4 area 0 :: Enables IPv4 over OSPFv3 on this interface (address families)
Router(config-if)# :: ospfv3 network point-to-point :: Network type in OSPFv3
 :: Differences from OSPFv2 :: Runs per link, not per subnet. Uses link-local addresses. Authentication through IPsec or an authentication trailer. New LSAs: type 8 (link) and type 9 (intra-area prefix).
 :: Multicast :: ff02::5 (all OSPF routers) and ff02::6 (DR/BDR)
Note: the "ospfv3 ... ipv4 area" lines depend on the release. Check with the ? help.
'@
        }
        @{
            Title  = 'CHECK AND TROUBLESHOOT'
            Rows   = @'
Router# :: show ip ospf neighbor :: State of each neighbor (FULL, 2WAY, EXSTART, INIT ...)
Router# :: show ip ospf interface brief :: Area, cost, state and neighbor count per interface
Router# :: show ip ospf interface g0/0 :: Network type, timers, DR and BDR, and authentication
Router# :: show ip ospf database :: The LSDB by type
Router# :: show ip ospf database router 1.1.1.1 :: One router LSA in full
Router# :: show ip ospf border-routers :: ABRs and ASBRs that this router knows
Router# :: show ip ospf rib :: The routes OSPF itself holds
Router# :: debug ip ospf adj :: Shows why a neighbor does not form
 :: Stuck in INIT :: Hello comes in, but the neighbor does not see ours (ACL, one-way link, or authentication)
 :: Stuck in 2WAY :: Normal between two non-DR routers on a broadcast segment
 :: Stuck in EXSTART or EXCHANGE :: MTU mismatch, or unicast problems (a firewall, or NAT)
 :: No neighbor at all :: Different area ID, subnet or mask, hello or dead timers, authentication, stub flag, duplicate router ID, a passive interface, or protocol 89 blocked
'@
        }
    )
}
