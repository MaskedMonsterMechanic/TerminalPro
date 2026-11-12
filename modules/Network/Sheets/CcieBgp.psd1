@{
    Command  = 'Show-CcieBgp'
    Alias    = 'cciebgp'
    Synopsis = 'BGP policy: communities, conditional advertisement, ORF, AS path tricks, regex, route reflectors, aggregation, multipath'
    Group    = 'CCIE'
    Order    = 305
    Index    = 'Show-NetCommands'
    Title    = 'CCIE - BGP POLICY AND SCALING'
    Prompt   = 'Router(config-router)#'

    Sections = @(
        @{
            Title  = 'START HERE'
            Rows   = @'
 :: Groundwork :: ccnpbgp has the basic setup, the best path order and the attributes. This page adds policy and scaling.
 :: Session states :: Idle, Connect, Active, OpenSent, OpenConfirm, Established. "Active" means it is TRYING to connect, not that it works.
 :: Timers :: Keepalive 60 and hold 180 seconds by default. The lower hold time of the two is used.
'@
        }
        @{
            Title  = 'ATTRIBUTE MANIPULATION'
            Rows   = @'
neighbor 10.1.1.2 weight 200 :: Weight: this router only, highest wins
Router(config)# :: route-map IN-A permit 10 :: Route map...
Router(config-route-map)# :: set local-preference 200 :: ...local preference: the whole AS, highest wins, default 100
Router(config-route-map)# :: set as-path prepend 65001 65001 :: ...AS path prepend (make a path longer)
Router(config-route-map)# :: set metric 50 :: ...MED (lower wins, compared only between paths from the same neighbor AS)
Router(config-route-map)# :: set origin igp :: ...origin code
Router(config-route-map)# :: set ip next-hop 10.1.1.9 :: ...next hop
bgp always-compare-med :: Compare MED between paths from different neighbor AS too
bgp deterministic-med :: Orders paths by neighbor AS, so the result does not depend on arrival order
bgp bestpath med missing-as-worst :: A missing MED counts as the worst (the default is 0, the best)
bgp bestpath as-path ignore :: Leave out the AS path length from the choice
bgp default local-preference 150 :: Default local preference for routes this router sends to iBGP
'@
        }
        @{
            Title  = 'COMMUNITIES'
            Rows   = @'
Router(config)# :: ip bgp-community new-format :: Show communities as AA:NN (not one big number)
neighbor 10.1.1.2 send-community both :: Send standard and extended communities (they are NOT sent by default)
Router(config-route-map)# :: set community 65001:100 additive :: Adds a label (without "additive" the old labels are replaced)
Router(config-route-map)# :: set comm-list OLD delete :: Removes the labels listed in a community list
Router(config)# :: ip community-list standard CL-A permit 65001:100 :: A community list...
Router(config-route-map)# :: match community CL-A :: ...to match routes with the label
Router(config-route-map)# :: set extcommunity rt 65001:10 :: Extended: route target (used in MPLS VPN)
Router(config-route-map)# :: set extcommunity soo 65001:1 :: Extended: site of origin (stops loops with multiple sites)
Router# :: show ip bgp community 65001:100 :: Routes with this label
 :: no-export :: Do not send to eBGP neighbors (also not outside a confederation)
 :: no-advertise :: Do not send to ANY neighbor
 :: local-AS :: Do not send outside the local AS (or confederation sub-AS)
 :: internet :: The default: all routes belong to it
'@
        }
        @{
            Title  = 'CONDITIONAL ADVERTISEMENT AND ORF'
            Rows   = @'
neighbor 10.1.1.2 advertise-map ADV non-exist-map TRIGGER :: Sends the routes in ADV ONLY when the routes in TRIGGER are NOT in the table (backup path idea)
neighbor 10.1.1.2 advertise-map ADV exist-map TRIGGER :: Sends the routes in ADV only when the routes in TRIGGER ARE in the table
neighbor 10.1.1.2 default-originate route-map IF-OK :: A default route, sent only if the route map matches something in the table
neighbor 10.1.1.2 capability orf prefix-list both :: Outbound route filtering: this router tells the neighbor what it wants, so the neighbor sends less
neighbor 10.1.1.2 prefix-list WANTED in :: The list that is sent to the neighbor with ORF
Router# :: show ip bgp neighbors 10.1.1.2 advertised-routes :: What you really send
Note: the advertise-map and the trigger map each use a route map with "match ip address prefix-list". Check: show ip bgp neighbors 10.1.1.2 (look for the condition lines) and show route-map.
'@
        }
        @{
            Title  = 'AS PATH TRICKS'
            Rows   = @'
neighbor 10.1.1.2 local-as 65100 :: Pretend to be in AS 65100 for THIS neighbor (adds 65100 to the path). Used when merging networks.
neighbor 10.1.1.2 local-as 65100 no-prepend :: ...without adding it to routes learned from this neighbor
neighbor 10.1.1.2 local-as 65100 no-prepend replace-as :: ...and only the local-as is added to what is sent out
neighbor 10.1.1.2 allowas-in 1 :: Accepts routes with your own AS in the path (up to 1 time). Used in some VPN designs.
neighbor 10.1.1.2 remove-private-as :: Removes private AS numbers (64512-65534) when sending to this eBGP neighbor, only if all are private
neighbor 10.1.1.2 remove-private-as all :: Removes all private AS numbers
neighbor 10.1.1.2 remove-private-as all replace-as :: Replaces them with your own AS number (keeps the length)
Router(config)# :: ip as-path access-list 10 permit ^65002_ :: A list that matches an AS path with a regular expression
neighbor 10.1.1.2 filter-list 10 in :: Uses it to filter what comes in (or out)
Router# :: show ip bgp regexp ^65002_ :: Routes whose AS path matches
'@
        }
        @{
            Title  = 'AS PATH REGULAR EXPRESSIONS'
            Rows   = @'
 :: ^$ :: Empty path: routes from THIS AS
 :: ^65002_ :: Learned from a neighbor in AS 65002 (it is the FIRST in the path)
 :: _65002$ :: Originated in AS 65002 (it is the LAST in the path)
 :: _65002_ :: AS 65002 is anywhere in the path
 :: ^65002$ :: A path with ONLY AS 65002
 :: .* :: Any path (including the empty one)
 :: _ :: Matches the start, the end, or a space (the border between two AS numbers)
 :: [0-9]+ :: Any AS number
 :: (65002|65003) :: One of the two
 :: ^65002(_65002)*$ :: AS 65002 and its own prepends only
'@
        }
        @{
            Title  = 'ROUTE REFLECTORS AND CONFEDERATIONS'
            Rows   = @'
neighbor 10.0.0.2 route-reflector-client :: On the reflector: this neighbor is a client
bgp cluster-id 10.0.0.100 :: Cluster ID (default: the router ID). Redundant reflectors in one cluster share it.
bgp confederation identifier 65000 :: Confederation: the outside sees ONE AS (65000)
bgp confederation peers 65002 65003 :: The other sub-AS numbers inside the confederation
 :: Reflection rules :: Route from a CLIENT goes to all clients and non-clients. From a NON-CLIENT it goes to clients only. From an eBGP neighbor it goes to all.
 :: Loop prevention :: ORIGINATOR_ID (the router that made the route) and CLUSTER_LIST (the clusters it passed).
 :: Not changed :: A reflector does not change the next hop, local preference or MED of reflected routes.
 :: Full mesh needed? :: The reflectors and the other non-clients still need a full mesh. The clients only peer with their reflector.
Router# :: show ip bgp 10.1.1.0 :: Look for "Originator" and "Cluster list" lines in the output
'@
        }
        @{
            Title  = 'AGGREGATION'
            Rows   = @'
aggregate-address 10.1.0.0 255.255.0.0 :: Makes the summary when at least one specific route exists. Specific routes are still sent.
aggregate-address 10.1.0.0 255.255.0.0 summary-only :: ...and the specific routes are held back
aggregate-address 10.1.0.0 255.255.0.0 as-set :: ...with an AS_SET: the AS numbers of the parts, so loops stay detected (the path loses its detail)
aggregate-address 10.1.0.0 255.255.0.0 summary-only suppress-map KEEP :: Hold back all but the routes this map picks (leak a few)
neighbor 10.1.1.2 unsuppress-map LEAK :: Leaks suppressed routes to ONE neighbor
aggregate-address 10.1.0.0 255.255.0.0 attribute-map SET-ATTR :: Changes the attributes of the summary
 :: AS_SET :: Look: show ip bgp 10.1.0.0 shows "{65002,65003}" in the path.
'@
        }
        @{
            Title  = 'REFRESH, MULTIPATH AND TIMERS'
            Rows   = @'
neighbor 10.1.1.2 soft-reconfiguration inbound :: Keeps a copy of everything received (uses memory). Needed only if the neighbor has no route refresh.
Router# :: clear ip bgp 10.1.1.2 soft in :: Route refresh: asks the neighbor to send all again, and applies the new policy. No reset.
Router# :: clear ip bgp 10.1.1.2 soft out :: Sends all again with the new outbound policy
Router# :: show ip bgp neighbors 10.1.1.2 received-routes :: Only works with soft-reconfiguration inbound
maximum-paths 4 :: Up to 4 eBGP paths in the routing table. Weight, local preference, AS path length, origin, MED and IGP metric must tie, and the neighbor AS must be the same.
maximum-paths ibgp 4 :: The same for iBGP
bgp bestpath as-path multipath-relax :: Allows paths with a different AS path (but the same length)
neighbor 10.1.1.2 timers 10 30 :: Keepalive and hold time for this neighbor
neighbor 10.1.1.2 fall-over bfd :: Takes the session down when BFD does
neighbor 10.1.1.2 ttl-security hops 1 :: Accepts only packets with TTL 254 or more (the neighbor is at most 1 hop away)
bgp graceful-restart :: Keeps forwarding while a neighbor restarts its BGP
'@
        }
        @{
            Title  = 'MULTIHOMING IDEAS'
            Rows   = @'
 :: Send traffic out :: Set local preference on the routes from the preferred ISP (or weight on one router).
 :: Receive traffic in :: AS path prepending (a hint), a smaller prefix on the preferred link (a strong hint), MED (for one neighbor AS), or the ISP's own communities.
 :: Do not become transit :: Send ONLY your own prefixes to the ISPs: an outbound prefix list or filter-list "^$".
 :: Load balancing :: Split your address space over the two links, or use maximum-paths with the same AS path length.
 :: ISP communities :: Most ISPs publish a list of communities that set their local preference or prepending. Look in the ISP's documentation.
'@
        }
    )
}
