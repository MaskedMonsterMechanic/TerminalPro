@{
    Command  = 'Show-CcnpEigrpDual'
    Alias    = 'ccnpeigrp2'
    Synopsis = 'EIGRP topology, DUAL, metric tuning, load balancing, stub, summaries, filtering'
    Group    = 'CCNP'
    Order    = 202
    Index    = 'Show-NetCommands'
    Title    = 'CCNP - EIGRP: TOPOLOGY TABLE, DUAL AND TUNING'
    Prompt   = 'Router(config)#'

    Sections = @(
        @{
            Title  = 'THE WORDS OF DUAL'
            Rows   = @'
 :: Feasible distance (FD) :: The best metric THIS router has to a network.
 :: Reported distance (RD) :: The metric the NEIGHBOR says it has to that network (also called advertised distance).
 :: Successor :: The neighbor on the best path: the lowest FD. Its route goes into the routing table.
 :: Feasible successor (FS) :: A backup neighbor whose RD is LOWER than the FD of the successor. That condition proves its path does not loop through this router.
 :: Passive (P) :: The route is stable. This is the good state.
 :: Active (A) :: The router lost its successor and has no feasible successor, so it asks its neighbors with Query packets.
 :: Stuck in active (SIA) :: The neighbors do not answer in time (the active timer is 3 minutes). The neighbor is then reset.
Note: with a feasible successor the switch to the backup is immediate, with no queries.
'@
        }
        @{
            Title  = 'READ THE TOPOLOGY TABLE'
            Rows   = @'
P 10.1.2.0/30, 1 successors, FD is 2297856 :: P = passive. One successor. The FD (best metric) is 2297856.
via 10.1.102.2 (2297856/128256), Serial0/0/0 :: A path through that neighbor: (FD of this path / RD of the neighbor).
via 10.1.103.3 (2809856/2297856), Serial0/0/1 :: RD 2297856 is NOT lower than the FD 2297856, so this is not a feasible successor.
Note: the numbers in this example are made up for a lab with T1 serial links, but they are worked out with: ccnpmetric -Bandwidth 8000000,1544 -Delay 5000,20000
Router# :: show ip eigrp topology :: Only successors and feasible successors
Router# :: show ip eigrp topology all-links :: Every path that was learned, also those that are not feasible
Router# :: show ip eigrp topology 10.1.2.0/30 :: Details of one network
'@
        }
        @{
            Title  = 'TUNE THE METRIC'
            Rows   = @'
interface s0/0/0 :: Goes to the interface
Router(config-if)# :: bandwidth 64 :: Tells EIGRP (and OSPF) the speed in kbps. It does NOT change the real speed. Set both ends the same.
Router(config-if)# :: delay 2000 :: Sets the delay in TENS of microseconds (2000 = 20,000 us). Often the better thing to change: only the delay is added up along the path.
Router(config-router)# :: offset-list 0 in 10000 s0/0/0 :: Adds 10000 to the metric of all routes learned on that interface
Router(config-router)# :: offset-list 10 out 5000 :: Adds 5000 to routes in ACL 10 that are sent out
Note: calculate with: ccnpmetric -Bandwidth 64 -Delay 20000
'@
        }
        @{
            Title  = 'LOAD BALANCING'
            Rows   = @'
 :: Equal cost :: Paths with the same metric are used together. Up to 4 by default.
Router(config-router)# :: maximum-paths 8 :: Changes the number of equal paths that are used
 :: Unequal cost :: Only EIGRP can do it.
Router(config-router)# :: variance 2 :: Also use feasible paths whose metric is at most 2 times the best metric
Router(config-router)# :: traffic-share balanced :: Share the traffic in proportion to the metrics (the default)
Note: a path is only used with variance when it is a feasible successor. The variance does not make a bad path feasible.
Note: with CEF the traffic is shared per destination (per flow), not per packet.
Router# :: show ip route 10.1.2.0 :: Look at "Traffic share count" for each path
'@
        }
        @{
            Title  = 'STUB ROUTERS (less querying, fewer problems)'
            Rows   = @'
Router(config-router)# :: eigrp stub :: Same as "eigrp stub connected summary": the router tells its neighbors it is a stub
Router(config-router)# :: eigrp stub connected static summary :: Also advertises static routes
Router(config-router)# :: eigrp stub receive-only :: Advertises nothing, only listens
Router(config-router)# :: eigrp stub redistributed :: Also advertises redistributed routes
Note: the other routers do not send queries to a stub router. Use it on branch routers with one way in.
Note: options: connected, static, summary, redistributed, receive-only, leak-map.
Router# :: show ip eigrp neighbors detail :: On the hub: look for "Stub Peer Advertising ( CONNECTED SUMMARY ) Routes"
'@
        }
        @{
            Title  = 'SUMMARIES AND DEFAULT ROUTES'
            Rows   = @'
interface g0/0 :: Goes to the interface the summary leaves from
Router(config-if)# :: ip summary-address eigrp 100 10.1.0.0 255.255.252.0 :: Sends one summary instead of the individual networks
Router(config-if)# :: ip summary-address eigrp 100 0.0.0.0 0.0.0.0 :: Sends a default route out of this interface (the more specific routes are still sent unless you filter them)
Router(config)# :: ip route 0.0.0.0 0.0.0.0 203.0.113.1 :: A static default on the edge router...
Router(config-router)# :: redistribute static :: ...and tell EIGRP about it (it shows up as D*EX)
Note: the summary route has a distance of 5 on the router that makes it, and a Null0 route is added to stop loops.
Note: a summary also cuts the QUERY range: a router outside the summary does not query for the parts inside it.
Note: work out the summary with: netsum 10.1.0.0/24,10.1.1.0/24,10.1.2.0/24,10.1.3.0/24
'@
        }
        @{
            Title  = 'FILTERING ROUTES'
            Rows   = @'
access-list 10 permit 10.1.2.0 0.0.0.255 :: A standard ACL that matches the networks
Router(config-router)# :: distribute-list 10 in g0/0 :: Only accepts those routes on this interface
ip prefix-list ALLOWED seq 5 permit 10.1.0.0/16 le 24 :: A prefix list: the network, and prefix lengths up to /24
Router(config-router)# :: distribute-list prefix ALLOWED out s0/0/0 :: Only advertises those routes on this interface
Router(config-router)# :: distribute-list route-map RM in :: Uses a route map (can also change the metric)
Note: prefix lists look at the network AND the prefix length, ACLs only at the network. That is why prefix lists are the better tool.
'@
        }
        @{
            Title  = 'CHECK'
            Prompt = 'Router#'
            Rows   = @'
show ip eigrp topology all-links :: All paths, with FD and RD
show ip route 10.1.2.0 :: The metric, the paths in use, the traffic share
show ip protocols :: Variance, maximum paths, K values, and the summaries
show ip eigrp topology active :: Routes that are stuck in active
Note: stuck in active? A neighbor does not answer queries: a slow or lossy link, or too many routers in the query range. Stub routers and summaries make the range smaller.
'@
        }
    )
}
