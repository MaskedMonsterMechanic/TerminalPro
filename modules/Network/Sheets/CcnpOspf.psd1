@{
    Command  = 'Show-CcnpOspf'
    Alias    = 'ccnpospf'
    Synopsis = 'OSPF multi-area: router types, LSA types, route types, cost, network types, virtual links'
    Group    = 'CCNP'
    Order    = 210
    Index    = 'Show-NetCommands'
    Title    = 'CCNP - OSPF: AREAS, LSAs AND ROUTE TYPES'
    Prompt   = 'Router(config)#'

    Sections = @(
        @{
            Title  = 'WHY AREAS'
            Rows   = @'
 :: Problem :: In one big area every router holds every link of the whole network, and every change makes every router run SPF again.
 :: Solution :: Cut the network into areas. Routers keep the full map of their own area only, and get a short summary of the others.
 :: Rule :: Area 0 is the backbone. Every other area must connect to it (directly or with a virtual link). Traffic between areas goes through area 0.
 :: Limit :: A common advice is about 50 routers per area. It depends on the hardware and how stable the links are.
'@
        }
        @{
            Title  = 'ROUTER TYPES'
            Rows   = @'
 :: Internal router :: All its interfaces are in one area.
 :: Backbone router :: At least one interface is in area 0.
 :: ABR (area border router) :: Interfaces in more than one area. It keeps a database for each one, and makes the summaries between them.
 :: ASBR (autonomous system boundary router) :: Brings in routes from outside OSPF (redistribution, a static route, another protocol).
Note: a router can be several of these at once.
'@
        }
        @{
            Title  = 'LSA TYPES (the messages that carry the map)'
            Rows   = @'
 :: 1 Router :: Every router writes one for itself: its links and their costs. Stays in its own area.
 :: 2 Network :: The DR writes one for each multi-access network: the list of routers on it. Stays in its own area.
 :: 3 Summary :: The ABR writes these: a network from another area, with a cost. Sent into the other areas.
 :: 4 ASBR summary :: The ABR tells the other areas how to reach the ASBR.
 :: 5 External :: The ASBR writes these for routes from outside. Flooded to all areas, except stub areas.
 :: 7 NSSA external :: Same as type 5, but made inside a not-so-stubby area. The ABR changes it into a type 5 at the border.
Note: the types 6 and 8 to 11 are rare (opaque LSAs are used for extensions).
Note: the LSA is refreshed every 30 minutes and thrown away after 60 minutes without refresh.
'@
        }
        @{
            Title  = 'ROUTE TYPES IN THE ROUTING TABLE'
            Rows   = @'
 :: O :: Intra-area: the network is in the same area. (From LSA 1 and 2.)
 :: O IA :: Inter-area: the network is in another area. (From LSA 3.)
 :: O E1 :: External type 1: cost = the external cost + the internal cost to the ASBR.
 :: O E2 :: External type 2 (the default): only the external cost. It does not change on the way. Use it when there is one exit.
 :: O N1 / O N2 :: The same two types, from an NSSA area.
Note: the router prefers O, then O IA, then E1 / N1, then E2 / N2, whatever the metrics are.
Note: an inter-area cost = the cost to the ABR + the cost the ABR advertises.
'@
        }
        @{
            Title  = 'MULTI-AREA SETUP'
            Rows   = @'
router ospf 1 :: The process
Router(config-router)# :: router-id 2.2.2.2 :: Router ID
Router(config-router)# :: network 10.0.0.0 0.0.0.255 area 0 :: Interfaces in this range go into area 0
Router(config-router)# :: network 10.1.0.0 0.0.255.255 area 1 :: These go into area 1. An ABR has both lines.
Router(config-router)# :: area 1 range 10.1.0.0 255.255.252.0 :: On the ABR: one summary for the networks of area 1 (see ccnpospf2)
Router# :: show ip ospf :: Router ID, the areas it is in, and "area border router" if it is an ABR
Router# :: show ip ospf border-routers :: The ABRs and ASBRs this router knows about
'@
        }
        @{
            Title  = 'REDISTRIBUTION INTO OSPF (the ASBR)'
            Rows   = @'
Router(config-router)# :: redistribute static subnets :: Brings in the static routes ("subnets" is needed or classless networks are left out)
Router(config-router)# :: redistribute eigrp 100 subnets metric 50 metric-type 1 :: From EIGRP, with a starting cost of 50, as type E1
Router(config-router)# :: default-information originate :: Tells the area about this router's own default route
Router(config-router)# :: default-information originate always :: ...and even if it has no default route itself
Note: the default starting cost is 20 (1 for BGP routes) and the default type is E2.
Note: more in the redistribution page: ccnpredist
'@
        }
        @{
            Title  = 'NETWORK TYPES AND TIMERS'
            Rows   = @'
 :: Broadcast :: Ethernet. DR and BDR. Hello 10 s, dead 40 s.
 :: Point-to-point :: Serial PPP or HDLC. No DR. Hello 10 s, dead 40 s.
 :: Non-broadcast :: Frame Relay and similar. DR and BDR. You must type the neighbors. Hello 30, dead 120.
 :: Point-to-multipoint :: A hub with many spokes. No DR. Hello 30, dead 120.
 :: Point-to-multipoint non-broadcast :: Like the one above, but you must type the neighbors.
interface g0/0 :: Goes to the interface
Router(config-if)# :: ip ospf network point-to-point :: Chooses the network type. Both ends must agree on whether there is a DR, or the neighbor works but the routes are wrong.
Router(config-if)# :: ip ospf dead-interval minimal hello-multiplier 4 :: Fast hellos: dead time of 1 second, 4 hellos per second
Router(config-router)# :: neighbor 10.1.1.2 :: A static neighbor (non-broadcast networks)
'@
        }
        @{
            Title  = 'VIRTUAL LINK (a last resort)'
            Rows   = @'
Router(config-router)# :: area 1 virtual-link 2.2.2.2 :: On ABR 1: connects through area 1 to the ABR with router ID 2.2.2.2
Router(config-router)# :: area 1 virtual-link 1.1.1.1 :: On ABR 2 (the other end): the same, with the other router's ID
Router# :: show ip ospf virtual-links :: Is it "up"?
Note: use it to connect an area to area 0 through another area, or to repair a split backbone for a while. The better fix is to redesign the areas.
Note: the transit area (here 1) cannot be a stub area.
'@
        }
        @{
            Title  = 'LOOK AT THE DATABASE'
            Prompt = 'Router#'
            Rows   = @'
show ip ospf database :: A list of all the LSAs, per area, by type
show ip ospf database router :: Only the type 1 LSAs (one per router)
show ip ospf database network :: Only type 2
show ip ospf database summary :: Only type 3
show ip ospf database asbr-summary :: Only type 4
show ip ospf database external :: Only type 5
show ip ospf database nssa-external :: Only type 7
show ip ospf database router 1.1.1.1 :: One router's LSA, with its links and costs
show ip route ospf :: O, O IA, O E1, O E2
'@
        }
    )
}
