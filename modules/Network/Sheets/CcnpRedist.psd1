@{
    Command  = 'Show-CcnpRedistribution'
    Alias    = 'ccnpredist'
    Synopsis = 'Redistribution, route maps, prefix lists, distance, policy-based routing, IP SLA'
    Group    = 'CCNP'
    Order    = 230
    Index    = 'Show-NetCommands'
    Title    = 'CCNP - REDISTRIBUTION AND ROUTE SELECTION'
    Prompt   = 'Router(config)#'

    Sections = @(
        @{
            Title  = 'HOW A ROUTER CHOOSES BETWEEN ROUTES'
            Rows   = @'
 :: 1 :: The longest matching prefix wins (a /26 beats a /24).
 :: 2 :: Between the same prefix from different sources: the lowest administrative distance wins.
 :: 3 :: Between the same prefix from the same source: the lowest metric wins.
 :: 4 :: A tie on the metric: the traffic is shared.
Note: metrics from different protocols are never compared. That is why the distance exists.
'@
        }
        @{
            Title  = 'REDISTRIBUTION: THE IDEA AND THE METRIC'
            Rows   = @'
 :: Idea :: A router that runs two routing protocols takes the routes of one and gives them to the other.
 :: The problem :: The protocols have different metrics, so you must give the imported routes a starting metric (the "seed" metric).
Router(config-router)# :: redistribute ospf 1 metric 10000 100 255 1 1500 :: Into EIGRP: bandwidth (kbps), delay (tens of us), reliability, load, MTU
Router(config-router)# :: redistribute eigrp 100 subnets metric 50 metric-type 1 :: Into OSPF: "subnets" is needed for classless routes. Type 1 adds the internal cost.
Router(config-router)# :: redistribute ospf 1 metric 3 :: Into RIP: a hop count (1 - 15)
Router(config-router)# :: redistribute static :: Takes the static routes
Router(config-router)# :: redistribute connected :: Takes the connected networks (also those where the protocol does not run)
Router(config-router)# :: default-metric 10000 100 255 1 1500 :: A default seed for everything that is redistributed (EIGRP style)
Note: into OSPF the seed is 20 by default (1 for BGP). Into EIGRP, RIP and IS-IS you MUST set it, or the routes are not imported.
Note: EIGRP external routes get distance 170 (worse than internal 90). OSPF external routes keep 110, the same as internal OSPF.
'@
        }
        @{
            Title  = 'ROUTE MAPS (if, then)'
            Rows   = @'
route-map RM permit 10 :: Starts a route map. "permit" = the routes that match are used. The number is the order.
Router(config-route-map)# :: match ip address prefix-list ALLOWED :: IF the route matches this prefix list (also: match ip address 10, match tag 20, match metric 100)
Router(config-route-map)# :: set metric 50 :: THEN change the metric (also: set metric-type type-1, set tag 20, set local-preference 200)
route-map RM deny 20 :: The routes that match here are dropped
route-map RM permit 30 :: A line with no match lets everything else through
Router(config-router)# :: redistribute eigrp 100 subnets route-map RM :: Uses the map while redistributing
Router# :: show route-map RM :: The map and how many routes matched each line
Note: every route map ends with a hidden "deny all". The routes that match nothing are dropped.
'@
        }
        @{
            Title  = 'PREFIX LISTS (match the network AND the length)'
            Rows   = @'
ip prefix-list ALLOWED seq 5 permit 10.0.0.0/8 :: Exactly 10.0.0.0/8 and nothing else
ip prefix-list ALLOWED seq 10 permit 10.0.0.0/8 le 24 :: 10.0.0.0/8 and anything inside it up to /24
ip prefix-list ALLOWED seq 15 permit 10.0.0.0/8 ge 16 le 24 :: Inside 10.0.0.0/8, with a length from /16 to /24
ip prefix-list ALLOWED seq 20 permit 0.0.0.0/0 :: Only the default route
ip prefix-list ALLOWED seq 25 permit 0.0.0.0/0 le 32 :: Any route
Router# :: show ip prefix-list :: The lists and their hit counts
Note: lines are read in order of the sequence number, and the first match wins. A hidden "deny all" ends the list.
'@
        }
        @{
            Title  = 'AVOID LOOPS WHEN REDISTRIBUTING AT MORE THAN ONE PLACE'
            Rows   = @'
 :: The danger :: Routes redistributed from A into B can be redistributed back into A by a second router, with a worse (or better) distance. This makes loops and a wrong path.
 :: Fix 1: tags :: When routes go from A into B, mark them with a tag. Where B goes back into A, deny the routes with that tag.
route-map A-TO-B permit 10 :: At the first border router
Router(config-route-map)# :: set tag 100 :: Marks the routes that come from A
route-map B-TO-A deny 10 :: At the same router, the other direction
Router(config-route-map)# :: match tag 100 :: Never send the routes that came from A back to A
route-map B-TO-A permit 20 :: ...and let the rest through
 :: Fix 2: distance :: Give the redistributed routes a worse distance than the original ones, so the original always wins.
Router(config-router)# :: distance 200 10.0.0.1 0.0.0.0 :: Gives the routes learned from that neighbor a distance of 200
Router(config-router)# :: distance eigrp 90 150 :: EIGRP: internal 90, external 150
Router(config-router)# :: distance ospf external 150 :: OSPF external routes get 150
 :: Fix 3: limit :: Redistribute only the networks you really need (a prefix list in the route map).
'@
        }
        @{
            Title  = 'POLICY-BASED ROUTING (choose the path by who sends, not where to)'
            Rows   = @'
access-list 101 permit ip 192.168.10.0 0.0.0.255 any :: Which traffic to catch
route-map PBR permit 10 :: A route map
Router(config-route-map)# :: match ip address 101 :: IF the packet matches the ACL
Router(config-route-map)# :: set ip next-hop 203.0.113.1 :: THEN send it to this next hop (also: set interface, set ip next-hop verify-availability)
interface g0/0 :: The interface where the packets ARRIVE
Router(config-if)# :: ip policy route-map PBR :: Turns it on for traffic coming in on this interface
Router(config)# :: ip local policy route-map PBR :: For traffic made by the router itself
Router# :: show ip policy :: Which interface uses which map
Router# :: show route-map PBR :: How many packets matched
Note: a packet that does not match any line is routed as normal. Use it with care: it is a hidden rule that is easy to forget.
'@
        }
        @{
            Title  = 'IP SLA: A STATIC ROUTE THAT KNOWS WHEN THE LINK IS DEAD'
            Rows   = @'
ip sla 1 :: Creates a probe
Router(config-ip-sla)# :: icmp-echo 203.0.113.1 source-interface g0/1 :: Pings the ISP's router
Router(config-ip-sla-echo)# :: frequency 5 :: Every 5 seconds
ip sla schedule 1 life forever start-time now :: Starts it and keeps it running
track 1 ip sla 1 reachability :: A track object that is "up" while the probe works
ip route 0.0.0.0 0.0.0.0 203.0.113.1 track 1 :: The default route is only used while the track object is up
ip route 0.0.0.0 0.0.0.0 198.51.100.1 10 :: A floating backup route that takes over when the first one is removed
Router# :: show ip sla statistics :: Does the probe work?
Router# :: show track :: The track object's state
'@
        }
        @{
            Title  = 'CHECK'
            Prompt = 'Router#'
            Rows   = @'
show ip protocols :: What is redistributed into what, with the metric and the filters
show ip route 10.5.0.0 :: How a route was learned, and the tag
show route-map :: Route maps and hit counts
show ip prefix-list :: Prefix lists and hit counts
show ip eigrp topology 10.5.0.0/16 :: How EIGRP sees an external route
show ip ospf database external :: The external routes in OSPF
Note: a route is missing after redistribution? Check the seed metric (EIGRP, RIP), the "subnets" keyword (OSPF), and a route map that ends in the hidden deny.
'@
        }
    )
}
