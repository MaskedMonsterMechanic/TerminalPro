@{
    Command  = 'Show-CcieMulticast'
    Alias    = 'cciemcast'
    Synopsis = 'Multicast: addresses, IGMP and snooping, RPF, PIM sparse mode, static RP/BSR/Auto-RP, SSM, MSDP anycast RP'
    Group    = 'CCIE'
    Order    = 306
    Index    = 'Show-NetCommands'
    Title    = 'CCIE - MULTICAST'
    Prompt   = 'Router(config)#'

    Sections = @(
        @{
            Title  = 'ADDRESSES'
            Rows   = @'
 :: 224.0.0.0/4 :: All IPv4 multicast (224.0.0.0 to 239.255.255.255)
 :: 224.0.0.0/24 :: Link-local: never forwarded by routers. 224.0.0.1 all hosts, .2 all routers, .5 and .6 OSPF, .9 RIPv2, .10 EIGRP, .13 PIM, .18 VRRP, .22 IGMPv3, .102 HSRPv2
 :: 232.0.0.0/8 :: Source Specific Multicast (SSM)
 :: 239.0.0.0/8 :: Administratively scoped: private, for use inside your own network
 :: 224.0.1.39 and 224.0.1.40 :: Auto-RP: announce and discovery
 :: Multicast MAC address :: 01:00:5e + the LOWEST 23 bits of the IP address. 5 bits are lost, so 32 groups share one MAC (239.1.1.1 and 224.129.1.1 collide).
 :: IPv6 :: ff00::/8. ff02::1 all nodes, ff02::2 all routers, ff02::d all PIM routers. MAC: 33:33 + the last 32 bits.
'@
        }
        @{
            Title  = 'IGMP (hosts tell the router what they want)'
            Rows   = @'
Router(config-if)# :: ip igmp version 3 :: Version 3 (needed for SSM). Default is version 2.
Router(config-if)# :: ip igmp join-group 239.1.1.1 :: The router itself joins the group (the router answers pings to it)
Router(config-if)# :: ip igmp static-group 239.1.1.1 :: Forwards the group out of this interface, with no host needed
Router(config-if)# :: ip igmp query-interval 30 :: Seconds between general queries (default 60)
Router(config-if)# :: ip igmp access-group 10 :: IGMP filter: only the groups in this ACL may be joined
Router(config-if)# :: ip igmp limit 50 :: Largest number of groups on this interface
Router# :: show ip igmp groups :: Groups, who reported, and when it expires
Router# :: show ip igmp interface g0/0 :: Version, querier, timers
 :: IGMPv2 :: Query to 224.0.0.1. Report to the group. Leave to 224.0.0.2. The querier is the router with the LOWEST IP address.
 :: IGMPv3 :: Reports go to 224.0.0.22 and can name the sources (include or exclude). It makes SSM possible.
 :: MLD :: The same job for IPv6. MLDv1 is like IGMPv2, MLDv2 is like IGMPv3.
'@
        }
        @{
            Title  = 'LAYER 2: SNOOPING AND QUERIER'
            Rows   = @'
Switch(config)# :: ip igmp snooping :: On by default. The switch forwards a group only to the ports with listeners.
Switch(config)# :: ip igmp snooping querier :: A querier on the switch, when no multicast router is in the VLAN
Switch(config)# :: ip igmp snooping vlan 10 immediate-leave :: Removes a port at once on leave (only when ONE host per port)
Switch(config)# :: ip igmp profile 1 :: IGMP filter on a switch: a profile of permitted groups...
Switch(config-igmp-profile)# :: permit :: ...with a range (range 239.1.1.1 239.1.1.10)
Switch(config-if)# :: ip igmp filter 1 :: ...applied to a port
Switch(config)# :: ipv6 mld snooping :: The same for IPv6
Switch# :: show ip igmp snooping groups :: Groups and ports
Switch# :: show ip igmp snooping querier :: Which device is the querier
 :: PIM snooping :: Lets a switch see PIM hellos and joins, so it can keep multicast away from routers that do not want it.
'@
        }
        @{
            Title  = 'RPF (reverse path forwarding check)'
            Rows   = @'
 :: Rule :: A multicast packet is accepted ONLY if it comes in on the interface that the unicast table would use to reach the SOURCE. Otherwise it is dropped.
 :: Why :: It stops loops: the tree has no spanning tree to use.
Router# :: show ip rpf 10.1.1.10 :: Which interface and neighbor RPF uses for a source
ip mroute 10.1.1.0 255.255.255.0 192.0.2.2 :: Change the RPF path for a source: a static multicast route
 :: Common problem :: RPF failure: the path to the source goes out of another interface than the multicast arrives on (look at it with "show ip mroute count": RPF failed counter).
'@
        }
        @{
            Title  = 'PIM SPARSE MODE AND THE RP'
            Rows   = @'
ip multicast-routing :: Turns multicast routing on (global)
Router(config-if)# :: ip pim sparse-mode :: PIM on this interface. Needed on EVERY routed interface in the path.
ip pim rp-address 10.0.0.1 :: Static RP (all routers need it)
ip pim rp-address 10.0.0.1 20 :: Static RP only for the groups in ACL 20
ip pim spt-threshold infinity :: Never switch to the shortest path tree: stay on the shared tree via the RP
Router# :: show ip pim neighbor :: PIM neighbors
Router# :: show ip pim rp mapping :: Which RP is used for which groups (and how it was learned)
Router# :: show ip pim interface :: PIM mode, neighbors and DR per interface
Router# :: show ip mroute :: The multicast table: (*,G) shared tree and (S,G) source trees
Router# :: show ip mroute count :: Packet counts, and RPF failures
 :: (*,G) :: Any source, to the group. The path is built toward the RP (the shared tree).
 :: (S,G) :: One source, to the group. The shortest path tree.
 :: Flags :: S sparse, C connected host, L local (the router itself), P pruned, T SPT bit set, J joined the shortest path tree
 :: Steps :: Receiver joins (*,G) toward the RP. Source registers with the RP. Packets flow down the shared tree. The last router joins the source and switches to the shortest path.
'@
        }
        @{
            Title  = 'DISCOVERING THE RP: BSR AND AUTO-RP'
            Rows   = @'
ip pim bsr-candidate loopback 0 0 100 :: BSR: this router is a candidate bootstrap router (hash length 0, priority 100)
ip pim rp-candidate loopback 0 group-list 20 :: BSR: this router offers to be an RP for the groups in ACL 20
ip pim send-rp-announce loopback 0 scope 16 group-list 20 :: Auto-RP: announces the RP to 224.0.1.39 (Cisco)
ip pim send-rp-discovery loopback 0 scope 16 :: Auto-RP: the mapping agent. It tells everyone the result on 224.0.1.40.
ip pim autorp listener :: With sparse mode only: lets the Auto-RP groups pass (they use dense mode)
ip pim rp-announce-filter rp-list 1 group-list 2 :: On the mapping agent: accepts announcements only from the RPs in ACL 1, for the groups in ACL 2
ip multicast boundary 10 :: On an interface: blocks the groups denied by ACL 10 from crossing (a scope border)
 :: Compare :: Static: simple, but you must change every router. BSR: open standard. Auto-RP: Cisco only. Both find the RP by themselves.
'@
        }
        @{
            Title  = 'SSM AND ANYCAST RP'
            Rows   = @'
ip pim ssm default :: Turns SSM on for 232.0.0.0/8. No RP is used, and the receivers name the SOURCE (needs IGMPv3).
interface Loopback 1 :: Anycast RP: give BOTH RPs the same address on a loopback, and advertise it in the IGP
ip pim rp-address 10.0.0.100 :: ...and use that address as the RP on all routers
ip msdp peer 10.255.0.2 connect-source loopback 0 :: MSDP between the two RPs: they share source information (use their UNIQUE addresses)
ip msdp originator-id loopback 0 :: The source address of MSDP messages
ip multicast multipath :: Share multicast load over equal-cost paths (picked by source address)
Router# :: show ip msdp peer :: State of the MSDP session
Router# :: show ip msdp sa-cache :: The sources that other RPs told about
 :: IPv6 :: ipv6 multicast-routing, ipv6 pim rp-address 2001:db8::1, and "ipv6 pim anycast-rp 2001:db8::100 2001:db8::1" on the RPs (anycast RP without MSDP).
'@
        }
        @{
            Title  = 'TEST AND FIND PROBLEMS'
            Rows   = @'
Router(config-if)# :: ip igmp join-group 239.1.1.1 :: A test receiver (an interface on the router)
Router# :: ping 239.1.1.1 repeat 5 :: A test sender: the replies show who joined
Router# :: mtrace 10.1.1.10 10.9.9.9 239.1.1.1 :: Traces the reverse path from a receiver to a source
 :: Check in order :: 1) Is PIM on every interface? 2) Do you have PIM neighbors? 3) Do all routers agree on the RP? 4) Does RPF work for the source and for the RP? 5) Did the host join (show ip igmp groups)?
 :: TTL :: Many multicast apps use TTL 1: they never leave the first router.
'@
        }
    )
}
