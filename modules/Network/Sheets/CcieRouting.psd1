@{
    Command  = 'Show-CcieRouting'
    Alias    = 'ccierouting'
    Synopsis = 'Routing concepts: administrative distance, static and multicast routes, PBR, VRF-Lite, route leaking, L3 MTU'
    Group    = 'CCIE'
    Order    = 302
    Index    = 'Show-NetCommands'
    Title    = 'CCIE - ROUTING CONCEPTS'
    Prompt   = 'Router(config)#'

    Sections = @(
        @{
            Title  = 'ADMINISTRATIVE DISTANCE (lowest wins between different sources)'
            Rows   = @'
 :: 0 :: Connected interface
 :: 1 :: Static route
 :: 5 :: EIGRP summary route
 :: 20 :: eBGP
 :: 90 :: EIGRP (internal)
 :: 110 :: OSPF
 :: 115 :: IS-IS
 :: 120 :: RIP
 :: 170 :: EIGRP (external)
 :: 200 :: iBGP
 :: 255 :: Not trusted: never used
Note: the longest prefix match is checked FIRST. Distance only decides between routes with the SAME prefix and length.
Note: change a distance with: distance 80 (under the routing process), or at the end of a static route.
'@
        }
        @{
            Title  = 'STATIC ROUTES'
            Rows   = @'
ip route 10.1.0.0 255.255.0.0 192.0.2.2 :: A static route with a next hop
ip route 10.1.0.0 255.255.0.0 g0/1 192.0.2.2 :: With the interface AND the next hop (the best form on Ethernet)
ip route 0.0.0.0 0.0.0.0 192.0.2.2 250 :: A floating default route: distance 250, so it is used only if the better route is gone
ip route 10.9.9.9 255.255.255.255 Null0 :: Discard route (also used to make a network available for BGP)
ip route 10.1.0.0 255.255.0.0 192.0.2.2 track 1 :: Only while the tracked object is up (for example an IP SLA probe)
ipv6 route 2001:db8:10::/48 2001:db8:ffff::2 :: IPv6 static route
ip mroute 10.0.0.0 255.0.0.0 192.0.2.1 :: A static MULTICAST route: tells RPF where the source is. It does not forward unicast.
Router# :: show ip route static :: Only static routes
Router# :: show ip route 10.1.1.1 :: The route used for ONE address (and how it was learned)
Note: a static route with only an Ethernet interface (no next hop) makes the router ARP for every destination. Avoid it.
'@
        }
        @{
            Title  = 'POLICY-BASED ROUTING (PBR)'
            Rows   = @'
access-list 101 permit ip 10.1.1.0 0.0.0.255 any :: Choose the traffic
route-map PBR permit 10 :: A route map
Router(config-route-map)# :: match ip address 101 :: Traffic that matches the ACL
Router(config-route-map)# :: set ip next-hop 192.0.2.2 :: Send it here. If the next hop is down, it is routed normally.
Router(config-route-map)# :: set ip next-hop verify-availability :: Use together with a track to check that the next hop is alive
Router(config-route-map)# :: set ip default next-hop 192.0.2.2 :: Used ONLY if the routing table has no route (the normal table comes first)
Router(config-route-map)# :: set interface g0/1 :: Send it out of an interface
Router(config-route-map)# :: set ip precedence 5 :: PBR can also mark packets
Router(config-if)# :: ip policy route-map PBR :: Applies it to traffic COMING IN on this interface
ip local policy route-map PBR :: Applies it to traffic made by the router itself
Router# :: show ip policy :: Which interfaces have a policy
Router# :: show route-map PBR :: The map and how many packets matched
Router# :: debug ip policy :: What PBR does with each packet (use with care)
 :: Remember :: Packets that do not match any permit entry are routed normally. A "deny" entry also means "route normally".
'@
        }
        @{
            Title  = 'VRF-LITE (separate routing tables on one router)'
            Rows   = @'
vrf definition RED :: Creates the VRF (the new style, supports IPv4 and IPv6)
Router(config-vrf)# :: address-family ipv4 :: Turns on IPv4 in this VRF
Router(config-vrf)# :: exit-address-family :: Closes the address family
interface g0/1 :: An interface...
Router(config-if)# :: vrf forwarding RED :: ...goes into the VRF. This REMOVES the IP address, so set it again after.
Router(config-if)# :: ip address 10.1.1.1 255.255.255.0 :: The address, now inside the VRF
ip route vrf RED 0.0.0.0 0.0.0.0 10.1.1.2 :: A static route in the VRF
Router# :: show vrf :: VRFs and their interfaces
Router# :: show ip route vrf RED :: The routing table of one VRF
Router# :: ping vrf RED 10.1.1.2 :: Ping from inside the VRF (also: traceroute vrf RED ...)
Router# :: show ip interface brief vrf RED :: The interfaces of one VRF
 :: Old style :: "ip vrf RED" and "ip vrf forwarding RED" still work on older IOS, but only for IPv4.
 :: Route distinguisher (rd) and route targets :: Needed for MPLS VPN (see ccnpvpn). VRF-Lite alone works without them.
'@
        }
        @{
            Title  = 'ROUTING PROTOCOLS INSIDE A VRF'
            Rows   = @'
router ospf 2 vrf RED :: OSPF: one process per VRF (the process number only matters locally)
router eigrp NAME :: EIGRP (named mode)...
Router(config-router)# :: address-family ipv4 unicast vrf RED autonomous-system 100 :: ...with one address family per VRF
router bgp 65001 :: BGP...
Router(config-router)# :: address-family ipv4 vrf RED :: ...with the VRF as an address family
Router(config-router-af)# :: neighbor 10.1.1.2 remote-as 65002 :: The neighbor is reached through the VRF
Router# :: show ip ospf 2 neighbor :: Check the OSPF process of the VRF
Router# :: show ip bgp vpnv4 vrf RED summary :: BGP neighbors in the VRF (also: show bgp vpnv4 unicast vrf RED summary)
'@
        }
        @{
            Title  = 'ROUTE LEAKING BETWEEN VRFs'
            Rows   = @'
 :: Static with the global table :: ip route vrf RED 0.0.0.0 0.0.0.0 192.0.2.1 global (the next hop is in the GLOBAL table). The way back needs a route in the global table too (a static route out of the VRF interface).
 :: Static between two VRFs :: ip route vrf RED 10.2.0.0 255.255.0.0 g0/2 10.2.0.1 (the exit interface belongs to the other VRF)
 :: Route targets :: Export in one VRF and import in another (route-target export 100:1 and route-target import 100:2). Use a route map ("import map") to leak only some routes.
 :: VASI :: VRF-Aware Software Infrastructure: two virtual interfaces (vasileft and vasiright) linked back to back, to connect two VRFs on the same router (and run services like NAT or a firewall between them).
Note: the syntax for route-target leaking depends on the release and platform. Check the documentation of your version before you rely on the lines above.
'@
        }
        @{
            Title  = 'MTU AT LAYER 3'
            Rows   = @'
Router(config-if)# :: ip mtu 1400 :: Largest IPv4 packet on this interface (bigger ones are fragmented, or dropped when DF is set)
Router(config-if)# :: ipv6 mtu 1400 :: The same for IPv6 (routers never fragment IPv6)
Router(config-if)# :: ip tcp adjust-mss 1360 :: Rewrites the MSS in TCP SYN packets, so tunnels do not need fragmenting
Router# :: show ip interface g0/1 :: MTU line
Router# :: ping 10.1.1.2 size 1500 df-bit :: Tests the whole path with "do not fragment"
Router# :: show ip route 10.1.1.2 :: Check the path first when the MTU test fails
 :: Layer 2 MTU vs Layer 3 MTU :: The L2 MTU (system mtu, or "mtu" on a router interface) is the frame size on the wire. "ip mtu" is the IP packet size. IP MTU must fit inside the frame.
 :: OSPF :: Neighbors get stuck in EXSTART/EXCHANGE when the two ends have a different interface MTU. Fix the MTU (or use ip ospf mtu-ignore as a last resort).
'@
        }
    )
}
