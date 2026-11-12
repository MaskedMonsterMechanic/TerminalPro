@{
    Command  = 'Show-CcnpEigrpNamed'
    Alias    = 'ccnpeigrp3'
    Synopsis = 'EIGRP for IPv6, named mode, wide metrics'
    Group    = 'CCNP'
    Order    = 203
    Index    = 'Show-NetCommands'
    Title    = 'CCNP - EIGRP FOR IPv6, NAMED MODE AND WIDE METRICS'
    Prompt   = 'Router(config)#'

    Sections = @(
        @{
            Title  = 'EIGRP FOR IPv6 (classic mode)'
            Rows   = @'
ipv6 unicast-routing :: Required first
ipv6 router eigrp 100 :: Creates the IPv6 process (the AS number must match the neighbors')
Router(config-rtr)# :: eigrp router-id 1.1.1.1 :: Needed if the router has no IPv4 address: the router ID is a 32-bit number
Router(config-rtr)# :: no shutdown :: Older IOS versions start the process shut down
Router(config-rtr)# :: passive-interface g0/0 :: As in IPv4
interface g0/1 :: Goes to the interface
Router(config-if)# :: ipv6 eigrp 100 :: Turns it on for this interface (there is no network command: it is per interface)
Router# :: show ipv6 eigrp neighbors :: Neighbors, shown with their link-local addresses
Router# :: show ipv6 eigrp topology :: The IPv6 topology table
Router# :: show ipv6 route eigrp :: The routes
Note: IPv6 neighbors use LINK-LOCAL addresses as next hops. The interfaces do not need a global address to form a neighbor.
Note: IPv6 EIGRP works the same way as IPv4 EIGRP: DUAL, metric, stub, variance. It runs as a separate process, with its own tables.
'@
        }
        @{
            Title  = 'NAMED MODE (all EIGRP settings in one place)'
            Rows   = @'
router eigrp LAB :: Starts a named process. The name is local.
Router(config-router)# :: address-family ipv4 unicast autonomous-system 100 :: IPv4, with the AS number
Router(config-router-af)# :: eigrp router-id 1.1.1.1 :: Router ID
Router(config-router-af)# :: network 10.1.0.0 0.0.255.255 :: Which interfaces
Router(config-router-af)# :: eigrp stub connected summary :: Stub setting, here in the address family
Router(config-router-af)# :: af-interface default :: Settings for ALL interfaces
Router(config-router-af-interface)# :: passive-interface :: Passive on all...
Router(config-router-af-interface)# :: hello-interval 5 :: Timers are set here
Router(config-router-af-interface)# :: hold-time 15 :: Timers are set here
Router(config-router-af-interface)# :: authentication mode hmac-sha-256 0 <password> :: Stronger authentication than MD5 (a named mode feature). The form can differ by IOS: use ? to check.
Router(config-router-af)# :: af-interface g0/1 :: Settings for ONE interface...
Router(config-router-af-interface)# :: no passive-interface :: ...this one is not passive
Router(config-router-af-interface)# :: summary-address 10.1.0.0 255.255.252.0 :: A summary is also set here
Router(config-router-af)# :: topology base :: The topology settings
Router(config-router-af-topology)# :: variance 2 :: Variance, maximum-paths, redistribute and filters go here
Router(config-router-af-topology)# :: maximum-paths 6 :: Equal paths
'@
        }
        @{
            Title  = 'NAMED MODE FOR IPv6'
            Rows   = @'
router eigrp LAB :: The same named process...
Router(config-router)# :: address-family ipv6 unicast autonomous-system 100 :: ...with an IPv6 address family (no per-interface command is needed)
Router(config-router-af)# :: eigrp router-id 1.1.1.1 :: Router ID
Router(config-router-af)# :: af-interface default :: Settings for all interfaces
Note: in named mode, EIGRP is enabled on all interfaces for IPv6 by default. Use "shutdown" or "passive-interface" under the af-interface to stop it.
Router# :: show eigrp address-family ipv4 neighbors :: In named mode the show commands are: show eigrp address-family ipv4|ipv6 ...
Router# :: show eigrp address-family ipv6 topology :: The IPv6 topology table
Router# :: show eigrp protocols :: What runs
'@
        }
        @{
            Title  = 'CLASSIC OR NAMED?'
            Rows   = @'
 :: Classic :: Settings are spread out: some under the process, some on each interface. IPv4 and IPv6 use different commands.
 :: Named :: One block per address family. IPv4 and IPv6 look the same. Wide metrics, and more secure authentication (SHA-256).
 :: Convert :: "eigrp upgrade-cli LAB" turns a classic configuration into a named one (it is a one-way change: save a copy first).
'@
        }
        @{
            Title  = 'WIDE METRICS'
            Rows   = @'
 :: Problem :: The classic metric is 32 bits and bandwidth is divided into 10,000,000 kbps. At 10 Gbps and above all links look the same.
 :: Solution :: The wide metric (named mode) is 64 bits. It also uses a scale that works for links of 100 Gbps and more, and it can use two more values (K6: jitter and energy).
 :: Compatible :: Wide metric routers and classic routers can be neighbors. The wide metric is scaled down to a 32-bit number for the routing table.
 :: Set it :: The K values are in the named mode topology section: metric weights 0 1 0 1 0 0 0 (there are now 6 K values)
Note: the default K values are the same: bandwidth and delay only.
'@
        }
        @{
            Title  = 'CHECK'
            Prompt = 'Router#'
            Rows   = @'
show eigrp address-family ipv4 neighbors :: Neighbors in named mode
show eigrp address-family ipv4 topology :: The topology table in named mode
show eigrp address-family ipv4 interfaces detail :: Timers and settings per interface
show ip protocols :: Shows the named process and its settings
show running-config | section eigrp :: The whole EIGRP configuration
'@
        }
    )
}
