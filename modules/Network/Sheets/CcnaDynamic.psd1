@{
    Command  = 'Show-CcnaDynamic'
    Alias    = 'ccnadyn'
    Synopsis = 'Dynamic routing: protocol families, passive interfaces, RIP and RIPng'
    Group    = 'CCNA'
    Order    = 103
    Index    = 'Show-NetCommands'
    Title    = 'CCNA - DYNAMIC ROUTING AND RIP'
    Prompt   = 'Router(config)#'

    Sections = @(
        @{
            Title  = 'THE PROTOCOL FAMILIES'
            Rows   = @'
 :: RIPv2 / RIPng :: Distance vector, inside one organization (IGP). Counts hops. IPv4 / IPv6.
 :: EIGRP / EIGRP for IPv6 :: Advanced distance vector (Cisco, IGP). Bandwidth and delay.
 :: OSPFv2 / OSPFv3 :: Link state (IGP). Cost based on bandwidth. IPv4 / IPv6.
 :: IS-IS :: Link state (IGP). Used by providers.
 :: BGP-4 / MP-BGP :: Path vector, between organizations (EGP). The routing of the internet.
Note: distance vector means "I tell my neighbors what I know". Link state means "everyone gets the whole map and works out the path".
'@
        }
        @{
            Title  = 'WHY AND WHY NOT'
            Rows   = @'
 :: For :: Fits many routers, copes with growth, finds a new path by itself when a link fails.
 :: Against :: More to set up, needs extra settings to be secure, and uses CPU, memory and bandwidth.
 :: Components :: Data structures (tables), messages (hello, updates), and an algorithm to choose the best path.
'@
        }
        @{
            Title  = 'RIP - FACTS'
            Rows   = @'
 :: Metric :: Hop count. Up to 15 hops. 16 means unreachable.
 :: Updates :: Every 30 seconds. RIPv1 broadcasts them. RIPv2 uses multicast 224.0.0.9.
 :: Distance :: 120
 :: RIPv1 :: Classful: no masks in updates.
 :: RIPv2 :: Classless: has masks, supports authentication.
 :: Auto-summary :: Both versions summarize at classful borders unless you turn it off.
 :: Use :: Rarely in production today, but a good way to learn the ideas.
'@
        }
        @{
            Title  = 'RIPv2 CONFIGURATION'
            Rows   = @'
router rip :: Goes into the RIP configuration
Router(config-router)# :: version 2 :: Sends and receives version 2 only
Router(config-router)# :: network 192.168.1.0 :: Turns RIP on for interfaces in this classful network (just the network, no mask)
Router(config-router)# :: no auto-summary :: Stops the summary at classful borders (almost always what you want)
Router(config-router)# :: passive-interface g0/0 :: Do not send updates out of this LAN interface, but still advertise its network
Router(config-router)# :: passive-interface default :: All interfaces passive...
Router(config-router)# :: no passive-interface s0/0/0 :: ...except this one
Router(config-router)# :: default-information originate :: Tells the other routers about this router's default route
no router rip :: Turns RIP off and removes its configuration
Note: passive-interface works the same way in EIGRP and OSPF.
'@
        }
        @{
            Title  = 'SPREAD A DEFAULT ROUTE'
            Rows   = @'
ip route 0.0.0.0 0.0.0.0 s0/0/1 209.165.200.226 :: On the edge router: the default route towards the ISP
router rip :: Goes into RIP
Router(config-router)# :: default-information originate :: The edge router now tells all the others, so only one static default is needed
Router# :: show ip route :: On another router: look for "R*" (a RIP default route)
'@
        }
        @{
            Title  = 'RIPng (IPv6)'
            Rows   = @'
ipv6 unicast-routing :: Required first
ipv6 router rip LAB :: Creates the process (the name is local)
interface g0/0 :: Goes to an interface
Router(config-if)# :: ipv6 rip LAB enable :: Turns RIPng on for this interface
Router(config-if)# :: ipv6 rip LAB default-information originate :: Sends a default route out of this interface
Note: RIPng uses multicast ff02::9 and UDP port 521.
'@
        }
        @{
            Title  = 'CHECK RIP'
            Prompt = 'Router#'
            Rows   = @'
show ip protocols :: Version, networks, neighbors (Routing Information Sources), timers, and passive interfaces
show ip route rip :: Only RIP routes
show ip rip database :: The RIP database
debug ip rip :: Shows the updates sent and received (undebug all when done)
show ipv6 rip :: RIPng status
Note: routes missing? Check the network statement, a passive interface that should not be, a version mismatch, and auto-summary hiding discontiguous networks.
'@
        }
    )
}
