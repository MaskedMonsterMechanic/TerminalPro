@{
    Command  = 'Show-CcnaHsrp'
    Alias    = 'ccnahsrp'
    Synopsis = 'First hop redundancy: HSRP and VRRP setup, priority, preempt, tracking'
    Group    = 'CCNA'
    Order    = 105
    Index    = 'Show-NetCommands'
    Title    = 'CCNA - FIRST HOP REDUNDANCY (HSRP AND VRRP)'
    Prompt   = 'R1(config-if)#'

    Sections = @(
        @{
            Title  = 'THE IDEA'
            Rows   = @'
 :: The problem :: A host has ONE default gateway. If that router dies, the host cannot leave the network, even if another router is right there.
 :: The solution :: Two routers share a virtual IP address and a virtual MAC address. The hosts use the virtual address as their gateway. One router (active) answers for it. If it fails, the other takes over.
 :: HSRP :: Hot Standby Router Protocol (Cisco). Active and standby router.
 :: VRRP :: Virtual Router Redundancy Protocol (open standard). Master and backup.
 :: GLBP :: Gateway Load Balancing Protocol (Cisco). Shares the load between routers.
'@
        }
        @{
            Title  = 'HSRP SETUP'
            Rows   = @'
interface g0/0 :: The LAN interface (it needs its own real address)
R1(config-if)# :: standby version 2 :: Uses version 2 (more groups, IPv6 support). Both routers must match.
R1(config-if)# :: standby 10 ip 192.168.10.1 :: Group 10 and the virtual gateway address the hosts use
R1(config-if)# :: standby 10 priority 110 :: Higher wins (default 100). Set it on the router that should be active.
R1(config-if)# :: standby 10 preempt :: Lets this router take the active role back when it returns (without this it does not)
R1(config-if)# :: standby 10 name LAN10 :: A label
R1(config-if)# :: standby 10 timers 1 3 :: Hello every 1 second, hold 3 seconds (default is 3 and 10): faster fail-over
R1(config-if)# :: standby 10 authentication md5 key-string <secret> :: Only routers with the same key may join
R2(config-if)# :: standby 10 ip 192.168.10.1 :: The other router: same group and virtual address, default priority
Note: the real addresses differ: for example R1 192.168.10.2, R2 192.168.10.3. The virtual one is 192.168.10.1.
Note: the host's default gateway is the VIRTUAL address.
'@
        }
        @{
            Title  = 'TRACK AN UPLINK (give up the active role when the way out is gone)'
            Rows   = @'
track 1 interface g0/1 line-protocol :: Watches the line protocol of the uplink (global configuration)
R1(config-if)# :: standby 10 track 1 decrement 20 :: When the uplink fails, take 20 off the priority, so the other router (110 - 20 = 90, against 100) takes over
R1(config-if)# :: standby 10 preempt :: Needed, so the router can win the role back
R2(config-if)# :: standby 10 preempt :: Needed on the other router too: it must be allowed to take the active role from a router that is still running
'@
        }
        @{
            Title  = 'HSRP FACTS'
            Rows   = @'
 :: Virtual MAC v1 :: 0000.0C07.ACxx (xx = the group number in hex)
 :: Virtual MAC v2 :: 0000.0C9F.Fxxx (xxx = the group number in hex)
 :: Multicast v1 / v2 :: 224.0.0.2 / 224.0.0.102 (UDP port 1985)
 :: Defaults :: Priority 100, hello 3 s, hold time 10 s, preempt OFF
 :: Groups :: v1: 0 - 255. v2: 0 - 4095.
 :: States :: Initial, Learn, Listen, Speak, Standby, Active
 :: Election :: Highest priority, then highest real IP address. The first router up becomes active if the other is not there yet.
 :: Load sharing :: Put different VLANs in different groups and make a different router active in each.
'@
        }
        @{
            Title  = 'VRRP (the same idea, standard version)'
            Rows   = @'
vrrp 10 ip 192.168.10.1 :: Group 10 with the virtual address (on the interface)
R1(config-if)# :: vrrp 10 priority 110 :: Higher wins (default 100)
R1(config-if)# :: vrrp 10 preempt :: Preempt is ON by default in VRRP. This line is only there to be clear.
Note: VRRP uses multicast 224.0.0.18 and IP protocol 112. The master is the one with the highest priority.
Note: the virtual router MAC address is 0000.5E00.01xx (xx = the group number).
'@
        }
        @{
            Title  = 'CHECK'
            Prompt = 'R1#'
            Rows   = @'
show standby brief :: One line per group: interface, priority, state (Active, Standby), the virtual IP
show standby :: Everything: timers, virtual MAC, who is active, tracking
show standby g0/0 :: One interface
show vrrp brief :: The same for VRRP
debug standby events :: Shows role changes (undebug all when done)
Note: both routers say "Active"? They cannot hear each other: check the VLAN, the cable, a filter that blocks 224.0.0.2 or 224.0.0.102, or authentication mismatch.
Note: the active router does not change after a failure? Check preempt, priority and the tracking object.
'@
        }
    )
}
