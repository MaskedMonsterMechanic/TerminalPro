@{
    Command  = 'Show-CcnpBgp'
    Alias    = 'ccnpbgp'
    Synopsis = 'BGP: eBGP and iBGP setup, path selection, attributes, filtering, checking'
    Group    = 'CCNP'
    Order    = 220
    Index    = 'Show-NetCommands'
    Title    = 'CCNP - BGP (BORDER GATEWAY PROTOCOL)'
    Prompt   = 'Router(config)#'

    Sections = @(
        @{
            Title  = 'FACTS'
            Rows   = @'
 :: What :: The routing protocol between autonomous systems (AS). It carries the whole internet routing table.
 :: Type :: Path vector: every route comes with the list of AS numbers it passed. That list also prevents loops: a router refuses a route that already has its own AS in it.
 :: Transport :: TCP port 179. The neighbors are typed by hand (no discovery).
 :: eBGP / iBGP :: Between different AS numbers / inside the same AS number. Distance 20 / 200.
 :: AS numbers :: 16-bit (1 - 65535) or 32-bit. Private: 64512 - 65534 (and 4200000000 - 4294967294).
 :: Timers :: Keepalive 60 s, hold time 180 s.
 :: Messages :: Open, Keepalive, Update, Notification.
 :: States :: Idle, Connect, Active, OpenSent, OpenConfirm, Established. Only "Established" is good (the show command then shows the number of prefixes).
 :: iBGP rule :: A route learned from an iBGP neighbor is NOT passed on to another iBGP neighbor. So iBGP needs a full mesh, or route reflectors.
'@
        }
        @{
            Title  = 'CONNECTING TO THE INTERNET (the four designs)'
            Rows   = @'
 :: Single-homed :: One link to one ISP. A default route is enough. No BGP needed.
 :: Dual-homed :: Two links to the SAME ISP. Protects against a link failure, not an ISP failure. A default route on each (one floating) often does it, or BGP with that ISP.
 :: Single-multihomed :: One link to each of TWO ISPs. Protects against an ISP failure. BGP is the right tool, so you can pick the way out and the way in.
 :: Dual-multihomed :: Two links to each of two ISPs. The most protection, and the most to manage.
 :: Updates you can ask for :: Only a default route (the simplest), a default route plus some chosen routes (partial), or the full internet table (hundreds of thousands of routes: needs enough memory).
 :: Your address space :: Provider-assigned addresses belong to the ISP: changing ISP means renumbering. Provider-independent addresses (and your own AS number) stay with you, and are needed for real multihoming with BGP.
Note: NAT hides the inside addresses, so a connection with one provider-assigned address works without BGP. See netnt.
'@
        }
        @{
            Title  = 'EBGP SETUP'
            Rows   = @'
router bgp 65001 :: Starts BGP in AS 65001 (your own AS)
Router(config-router)# :: bgp router-id 1.1.1.1 :: Router ID
Router(config-router)# :: neighbor 203.0.113.2 remote-as 65002 :: The neighbor and ITS AS number. A different number means eBGP.
Router(config-router)# :: network 192.0.2.0 mask 255.255.255.0 :: Advertises this network. It must be in the routing table with exactly this prefix and mask (a Null0 static route is often used).
Router(config-router)# :: neighbor 203.0.113.2 description ISP-A :: A label
Router(config-router)# :: neighbor 203.0.113.2 password <secret> :: MD5 authentication on the TCP session (both ends)
Router(config-router)# :: bgp log-neighbor-changes :: Logs neighbors going up and down
Router(config-router)# :: no bgp default ipv4-unicast :: Good habit: neighbors are not activated for IPv4 by themselves, you do it in the address family
Router(config-router)# :: address-family ipv4 :: IPv4 settings
Router(config-router-af)# :: neighbor 203.0.113.2 activate :: Turns the neighbor on for IPv4
'@
        }
        @{
            Title  = 'IBGP SETUP (inside one AS)'
            Rows   = @'
Router(config-router)# :: neighbor 10.0.0.2 remote-as 65001 :: The same AS number as your own: iBGP
Router(config-router)# :: neighbor 10.0.0.2 update-source loopback 0 :: Use the loopback as the source of the session: it stays up as long as there is any path
Router(config-router)# :: neighbor 10.0.0.2 next-hop-self :: On the border router: tells the iBGP peers "send it to ME", because they cannot reach the eBGP neighbor's address
Router(config-router)# :: neighbor 10.0.0.2 route-reflector-client :: On a route reflector: this neighbor is a client, and gets iBGP routes reflected to it
Note: eBGP neighbors are normally one hop away (TTL 1). If you use loopbacks or the neighbor is further away, add: neighbor X ebgp-multihop 2
Note: the IGP (OSPF, EIGRP) must give every iBGP router a route to the next hop and to the other loopbacks.
'@
        }
        @{
            Title  = 'CHOOSING THE BEST PATH (in this order)'
            Rows   = @'
 :: 1 Weight :: Highest. Cisco only, and only on this router.
 :: 2 Local preference :: Highest. Default 100. Shared with the whole AS. The usual way to choose the exit.
 :: 3 Originated here :: Routes made by this router (network, aggregate) beat learned ones.
 :: 4 AS path :: Shortest.
 :: 5 Origin :: IGP (i) is better than EGP (e), and that is better than incomplete (?).
 :: 6 MED :: Lowest. Compared only between routes from the same neighbor AS, by default. The way to suggest an entry to a neighbor.
 :: 7 eBGP over iBGP :: An eBGP route wins.
 :: 8 IGP metric :: The lowest cost to the next hop.
 :: 9 Tie-breakers :: The oldest eBGP route, then the lowest router ID, then the lowest neighbor address.
Note: to remember the start: "We Love Oranges AS Oranges Mean Pure Refreshment" = Weight, Local pref, Originate, AS path, Origin, MED, Paths (eBGP over iBGP), Router ID.
'@
        }
        @{
            Title  = 'THE ATTRIBUTES'
            Rows   = @'
 :: Well-known mandatory :: ORIGIN, AS_PATH, NEXT_HOP. Must be in every update.
 :: Well-known discretionary :: LOCAL_PREF, ATOMIC_AGGREGATE.
 :: Optional transitive :: AGGREGATOR, COMMUNITY. Passed on even if the router does not understand them.
 :: Optional non-transitive :: MED, ORIGINATOR_ID, CLUSTER_LIST. Not passed to other AS.
Note: the communities are labels on routes (like 65001:100). The neighbor can act on the label.
'@
        }
        @{
            Title  = 'STEER THE TRAFFIC (with a route map)'
            Rows   = @'
route-map PREFER-A permit 10 :: A route map
Router(config-route-map)# :: set local-preference 200 :: Makes the routes through this neighbor more attractive for the whole AS
route-map PAD-OUT permit 10 :: Another one
Router(config-route-map)# :: set as-path prepend 65001 65001 :: Makes your routes look longer to the outside: they choose another path
route-map SET-MED permit 10 :: And another
Router(config-route-map)# :: set metric 50 :: Sets the MED (lower is better)
Router(config-router)# :: neighbor 203.0.113.2 route-map PREFER-A in :: Applies the map to what comes in from this neighbor
Router(config-router)# :: neighbor 203.0.113.6 route-map PAD-OUT out :: Applies the map to what goes out to this neighbor
Router(config-router)# :: neighbor 203.0.113.2 weight 200 :: Weight: all routes from this neighbor, this router only
Note: local preference decides how YOU leave. AS-path prepending and MED suggest how OTHERS enter.
'@
        }
        @{
            Title  = 'FILTER AND PROTECT'
            Rows   = @'
Router(config-router)# :: neighbor 203.0.113.2 prefix-list FROM-ISP in :: Only accepts the networks the prefix list allows
Router(config-router)# :: neighbor 203.0.113.2 prefix-list TO-ISP out :: Only advertises your own networks (so you do not become a transit AS by mistake)
Router(config-router)# :: neighbor 203.0.113.2 maximum-prefix 1000 80 :: Warns at 80% and shuts the session down above 1000 routes
Router(config-router)# :: neighbor 203.0.113.2 default-originate :: Sends a default route to this neighbor
Router(config-router)# :: aggregate-address 192.0.0.0 255.255.252.0 summary-only :: One summary route, and the details are held back
Note: for the real internet add: filters for private and reserved addresses, a limit on AS path length, and TTL security (ttl-security hops 1).
Note: after changing a policy: clear ip bgp 203.0.113.2 soft in (or out). It does not reset the session.
'@
        }
        @{
            Title  = 'IPv6'
            Rows   = @'
Router(config-router)# :: neighbor 2001:db8:ffff::2 remote-as 65002 :: The neighbor can be an IPv6 address (sessions can carry both families)
Router(config-router)# :: address-family ipv6 unicast :: IPv6 settings
Router(config-router-af)# :: neighbor 2001:db8:ffff::2 activate :: Turns the neighbor on for IPv6
Router(config-router-af)# :: network 2001:db8:100::/48 :: Advertises an IPv6 network
Router# :: show bgp ipv6 unicast summary :: The IPv6 neighbors
'@
        }
        @{
            Title  = 'CHECK BGP'
            Prompt = 'Router#'
            Rows   = @'
show ip bgp summary :: Neighbors: AS, uptime, and the number of prefixes received (or the state if not Established)
show ip bgp :: The BGP table: > is the best path, i is learned by iBGP
show ip bgp 192.0.2.0 :: One network: all paths and why one was chosen
show ip bgp neighbors :: Everything about the sessions, with the reason for the last reset
show ip bgp neighbors 203.0.113.2 advertised-routes :: What you send to this neighbor
show ip bgp neighbors 203.0.113.2 routes :: What you accepted from this neighbor
show ip route bgp :: Routes in the routing table (B)
clear ip bgp 203.0.113.2 soft :: Re-sends and re-reads the routes without a reset
Note: stuck in Idle or Active? Check: a route to the neighbor, port 179 not blocked, the right AS number, the same password, update-source, and ebgp-multihop for non-adjacent neighbors.
'@
        }
    )
}
