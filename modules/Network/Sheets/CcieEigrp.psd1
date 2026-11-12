@{
    Command  = 'Show-CcieEigrp'
    Alias    = 'ccieeigrp'
    Synopsis = 'EIGRP in depth: neighbors, stub, summarising, unequal cost, filtering, authentication, DMVPN tuning, troubleshooting'
    Group    = 'CCIE'
    Order    = 304
    Index    = 'Show-NetCommands'
    Title    = 'CCIE - EIGRP IN DEPTH'
    Prompt   = 'Router(config-router)#'

    Sections = @(
        @{
            Title  = 'THE BASICS TO KNOW BY HEART'
            Rows   = @'
 :: Transport :: IP protocol 88. Multicast 224.0.0.10 (IPv6: ff02::a). Reliable (RTP) for updates, queries, replies. Hellos are not acknowledged.
 :: Neighbors :: Need the same AS number, the same K values, a source address in the same subnet, and matching authentication. Hello and hold timers do NOT have to match.
 :: Feasible successor :: A neighbor whose reported distance is LOWER than the feasible distance of the best route. It can take over with no query (this is the feasibility condition).
 :: Active and SIA :: With no feasible successor the route goes ACTIVE: queries go out. No answer within the active timer (3 minutes) is "stuck in active" and the neighbor is reset.
 :: Metric :: Classic: bandwidth and delay. Tool: ccnpmetric -Link GigabitEthernet,Serial
Note: groundwork pages: ccnpeigrp, ccnpeigrp2 (DUAL), ccnpeigrp3 (named mode).
'@
        }
        @{
            Title  = 'NEIGHBORS, TIMERS, AND SPLIT HORIZON'
            Rows   = @'
Router(config-if)# :: ip hello-interval eigrp 100 5 :: Hello seconds (defaults: 5 on fast links, 60 on slow multipoint links)
Router(config-if)# :: ip hold-time eigrp 100 15 :: Hold seconds (default 3 x hello: 15 or 180)
neighbor 10.1.1.2 g0/0 :: A unicast neighbor (for links without multicast). Both ends need it, and multicast hellos stop on that interface.
passive-interface g0/1 :: Advertises the network but forms no neighbor here
passive-interface default :: Passive on all, then use "no passive-interface" on the links that need neighbors
Router(config-if)# :: no ip split-horizon eigrp 100 :: Hub of a hub-and-spoke (DMVPN or Frame Relay): the hub must send spoke routes back out of the same interface
Router(config-if)# :: no ip next-hop-self eigrp 100 :: DMVPN phase 2: the hub keeps the spoke as the next hop, so spokes talk directly
timers active-time 3 :: Minutes a route may stay active before it is "stuck" (default 3)
eigrp router-id 1.1.1.1 :: Fixed router ID (also needed to tell external routes apart)
Router# :: show ip eigrp interfaces detail :: Timers, split horizon, and authentication per interface
'@
        }
        @{
            Title  = 'STUB ROUTERS (limit the queries)'
            Rows   = @'
eigrp stub connected summary :: The default: this router advertises only connected and summary routes, and is not asked queries
eigrp stub connected static redistributed :: Other choices: connected, static, summary, redistributed, receive-only
eigrp stub receive-only :: Advertises nothing at all
eigrp stub leak-map LEAK :: Also allows the routes picked by a route map
Router# :: show ip eigrp neighbors detail :: On the HUB: shows "Stub Peer Advertising ... Routes"
 :: Why :: A spoke should never be asked about routes that it cannot reach better. Stub spokes keep queries (and SIA problems) away from the hub.
'@
        }
        @{
            Title  = 'SUMMARISING'
            Rows   = @'
Router(config-if)# :: ip summary-address eigrp 100 10.1.0.0 255.255.0.0 :: Classic mode: summary on an interface. It adds a Null0 route with distance 5.
Router(config-if)# :: ip summary-address eigrp 100 10.1.0.0 255.255.0.0 90 :: ...with an own distance (a floating summary, for example 250)
Router(config-router-af-interface)# :: summary-address 10.1.0.0 255.255.0.0 :: Named mode: set it in the "af-interface" of the interface
no auto-summary :: Classic mode on older IOS: stops summary at classful borders (the default in newer IOS)
Router# :: show ip route 10.1.0.0 255.255.0.0 :: A summary route shows as "D" with Null0 and distance 5
 :: Leak-map :: A summary can let some specific routes through with "summary-address ... leak-map NAME" (named mode).
'@
        }
        @{
            Title  = 'LOAD BALANCING AND METRIC TUNING'
            Rows   = @'
maximum-paths 6 :: Equal-cost paths used at the same time (default 4)
variance 2 :: Also use paths with a metric up to 2 x the best, but ONLY if they are feasible successors
traffic-share balanced :: Share in proportion to the metric (the default with variance)
traffic-share min across-interfaces :: Use only the lowest metric
offset-list 0 out 1000 g0/0 :: Adds 1000 to the metric of the routes sent out of g0/0 (0 = all routes, or an ACL number)
default-metric 100000 20 255 1 1500 :: Metric for redistributed routes: bandwidth (kb/s), delay (tens of microseconds), reliability, load, MTU
Router(config-if)# :: delay 100 :: Delay in tens of microseconds: the best way to prefer a path (bandwidth also changes QoS and other things)
 :: Note on variance :: Example: best 100, another feasible successor 180: with "variance 2" both are used. At 250 it is not.
'@
        }
        @{
            Title  = 'FILTERING AND CHANGING THE DISTANCE'
            Rows   = @'
distribute-list prefix FROM-BRANCH in g0/0 :: Filters routes received on an interface (a prefix list)
distribute-list route-map RM out :: Filters or changes what is sent (also per interface)
distance eigrp 90 170 :: Distance for internal (90) and external (170) routes
distance 120 10.1.1.2 0.0.0.0 99 :: A different distance for routes from one neighbor (with an ACL)
redistribute ospf 1 metric 100000 20 255 1 1500 :: Redistribute with a metric (EIGRP always needs one)
Router(config)# :: ip prefix-list FROM-BRANCH permit 10.9.0.0/16 :: The prefix list for the first line
Note: EIGRP is distance vector like: you CAN filter inside the domain (unlike OSPF inside an area).
'@
        }
        @{
            Title  = 'AUTHENTICATION'
            Rows   = @'
Router(config)# :: key chain EIGRP-KEYS :: A key chain...
Router(config-keychain)# :: key 1 :: ...with a key...
Router(config-keychain-key)# :: key-string <secret> :: ...and its secret
Router(config-if)# :: ip authentication mode eigrp 100 md5 :: Classic mode: MD5 on this interface
Router(config-if)# :: ip authentication key-chain eigrp 100 EIGRP-KEYS :: ...with the key chain
Router(config-router-af-interface)# :: authentication mode hmac-sha-256 <secret> :: Named mode: HMAC-SHA-256 (the secret is typed here, not from a key chain)
Router(config-router-af-interface)# :: authentication key-chain EIGRP-KEYS :: Named mode: or MD5 with a key chain
Note: the exact named-mode lines differ between IOS XE versions. Check with ?.
'@
        }
        @{
            Title  = 'CHECK AND TROUBLESHOOT'
            Rows   = @'
Router# :: show ip eigrp neighbors :: Neighbors with hold time, uptime, SRTT and RTO, and queue count
Router# :: show ip eigrp topology :: Successors and feasible successors (P = passive, A = active)
Router# :: show ip eigrp topology all-links :: Also the routes that are NOT feasible successors
Router# :: show ip eigrp topology 10.1.1.0/24 :: One route: FD, RD, and each path
Router# :: show ip eigrp traffic :: Packet counts (hello, update, query, reply, ack)
Router# :: show ip protocols :: AS, K values, router ID, distance, and the networks
Router# :: debug eigrp packets :: Packets in and out (use with care)
 :: No neighbor :: AS number, K values, different subnet, passive interface, authentication, ACL blocking 224.0.0.10 or protocol 88, or a secondary address used as the source.
 :: Neighbor keeps flapping :: Check "retransmission limit" messages: a bad link or MTU. Unicast neighbors often fail from one side only.
 :: Stuck in active :: A neighbor did not answer a query. Look for slow links, overloaded routers, and add stubs and summaries to stop the queries early.
'@
        }
    )
}
