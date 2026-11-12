@{
    Command  = 'Show-CcnpEigrp'
    Alias    = 'ccnpeigrp'
    Synopsis = 'EIGRP basics: facts, setup, neighbors, timers, K values, checking'
    Group    = 'CCNP'
    Order    = 201
    Index    = 'Show-NetCommands'
    Title    = 'CCNP - EIGRP: SETUP AND NEIGHBORS (classic mode, IPv4)'
    Prompt   = 'Router(config)#'

    Sections = @(
        @{
            Title  = 'FACTS'
            Rows   = @'
 :: What :: Enhanced Interior Gateway Routing Protocol. Cisco made it, and the base of it is open (RFC 7868).
 :: How it works :: Neighbors say hello, then send their routes in full once. After that only changes are sent, and only to the routers that need them.
 :: Algorithm :: DUAL (Diffusing Update Algorithm): finds loop-free paths and keeps backup paths ready.
 :: Transport :: IP protocol 88, multicast 224.0.0.10 (IPv6: ff02::a). Its own reliable delivery (RTP): updates are acknowledged.
 :: Packets :: Hello, Update, Query, Reply, Acknowledgment.
 :: Distance :: 90 inside the AS, 170 for external routes (redistributed), 5 for a summary route the router makes itself.
 :: Metric :: Bandwidth and delay by default. Tool: ccnpmetric -Link fe, serial
 :: Tables :: Neighbor table, topology table (all paths), routing table (best paths only).
 :: Default :: Up to 4 equal paths. Auto-summary is OFF in current IOS.
'@
        }
        @{
            Title  = 'BASIC SETUP'
            Rows   = @'
router eigrp 100 :: Starts EIGRP in autonomous system 100. The number must match on all neighbors.
Router(config-router)# :: eigrp router-id 1.1.1.1 :: Sets the router ID by hand (the same rules as OSPF: manual, highest loopback, highest interface)
Router(config-router)# :: network 10.1.0.0 0.0.255.255 :: Turns EIGRP on for interfaces with an address in this range, and advertises that network (wildcard mask)
Router(config-router)# :: network 192.168.1.0 :: Without a wildcard mask it works on the classful network
Router(config-router)# :: passive-interface g0/0 :: No hellos on the LAN, but the network is still advertised
Router(config-router)# :: passive-interface default :: All passive...
Router(config-router)# :: no passive-interface s0/0/0 :: ...except this one
Router(config-router)# :: no auto-summary :: Needed on older IOS, where classful summarizing was on
Router(config-router)# :: maximum-paths 6 :: Share the traffic over up to 6 equal paths
'@
        }
        @{
            Title  = 'WHAT MUST MATCH FOR A NEIGHBOR TO FORM'
            Rows   = @'
 :: Same AS number :: Different numbers never become neighbors.
 :: Same K values :: The metric weights must be identical (see below).
 :: Same subnet :: The sender's address must be in the receiver's primary subnet.
 :: Same authentication :: Key chain and mode (if used).
 :: Not passive :: A passive interface sends and accepts no hellos.
 :: Not required to match :: Hello and hold times (each side tells the other its hold time), and the network statements.
 :: Router ID :: Must be unique.
'@
        }
        @{
            Title  = 'TIMERS'
            Rows   = @'
interface g0/0 :: Goes to the interface
Router(config-if)# :: ip hello-interval eigrp 100 5 :: How often a hello is sent (default 5 s; 60 s on slow multipoint links)
Router(config-if)# :: ip hold-time eigrp 100 15 :: How long this router tells its neighbors to wait before they decide it is gone (default 3 x hello = 15 s)
Note: make the hold time at least 3 times the hello time. Fast timers speed up failure detection but add load.
Note: for fast failure detection on point-to-point links, BFD is the better tool.
'@
        }
        @{
            Title  = 'K VALUES (the weights of the metric)'
            Rows   = @'
Router(config-router)# :: metric weights 0 1 0 1 0 0 :: The default: TOS (always 0), K1 (bandwidth) 1, K2 (load) 0, K3 (delay) 1, K4 0, K5 0
Router(config-router)# :: metric weights 0 1 1 1 0 0 :: Example: also use load (K2 = 1). Every router in the AS must be changed.
Note: leave them alone in real networks. Load and reliability change all the time and cause route flaps.
Note: neighbors with different K values show a "K-value mismatch" log message and do not come up.
'@
        }
        @{
            Title  = 'SPECIAL NEIGHBOR SETUPS'
            Rows   = @'
Router(config-router)# :: neighbor 10.1.1.2 g0/0 :: A static neighbor: hellos go as unicast to that address (for networks without multicast, like some WAN services)
Router(config)# :: key chain EIGRP-KEYS :: Creates a key chain for authentication
Router(config-keychain)# :: key 1 :: A key
Router(config-keychain-key)# :: key-string <secret> :: The password
Router(config-if)# :: ip authentication mode eigrp 100 md5 :: Authenticates the EIGRP messages on this interface
Router(config-if)# :: ip authentication key-chain eigrp 100 EIGRP-KEYS :: With the keys from the chain
Router(config-if)# :: ip bandwidth-percent eigrp 100 50 :: EIGRP may use at most 50% of the link's (configured) bandwidth
'@
        }
        @{
            Title  = 'CHECK EIGRP'
            Prompt = 'Router#'
            Rows   = @'
show ip eigrp neighbors :: The neighbors: address, interface, hold time, uptime, SRTT/RTO, queue count
show ip eigrp neighbors detail :: With the timers, K values and the software version
show ip eigrp interfaces :: Which interfaces run EIGRP, with the number of neighbors
show ip eigrp topology :: The topology table (see the DUAL page: ccnpeigrp2)
show ip eigrp traffic :: Counts of hellos, updates, queries, replies and acks
show ip protocols :: The AS, the K values, the networks, passive interfaces, distances, variance
show ip route eigrp :: Only the EIGRP routes (D for internal, D EX for external)
debug eigrp packets hello :: Shows hellos (undebug all when done)
debug ip eigrp :: Shows route changes
'@
        }
        @{
            Title  = 'A NEIGHBOR DOES NOT COME UP: CHECK THESE'
            Rows   = @'
 :: 1 :: Interfaces up/up, in the same subnet.
 :: 2 :: The same AS number in "router eigrp".
 :: 3 :: A network statement covers the interface (see: show ip eigrp interfaces).
 :: 4 :: The interface is not passive.
 :: 5 :: The same K values.
 :: 6 :: The same authentication, with valid key lifetimes.
 :: 7 :: No ACL blocks IP protocol 88 or 224.0.0.10.
 :: 8 :: Unique router IDs.
 :: Flapping :: Look for "retry limit exceeded": a link that loses packets, or an MTU problem.
'@
        }
    )
}
