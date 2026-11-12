@{
    Command  = 'Show-NetInterVlan'
    Alias    = 'netiv'
    Synopsis = 'Inter-VLAN routing: router on a stick, SVIs, routed ports, checklist'
    Group    = 'SWITCH'
    Order    = 52
    Index    = 'Show-NetCommands'
    Title    = 'NETWORK MODULE - INTER-VLAN ROUTING'
    Prompt   = 'Switch(config)#'

    Sections = @(
        @{
            Title  = 'THE THREE WAYS'
            Rows   = @'
 :: Legacy :: One router interface per VLAN. Uses lots of ports and cables, rarely seen now.
 :: Router on a stick :: One trunk to a router, with one subinterface per VLAN. Cheap, but the single link is the limit.
 :: Layer 3 switch (SVI) :: The switch does the routing with a virtual interface per VLAN. The usual choice in a real network.
'@
        }
        @{
            Title  = 'ROUTER ON A STICK - the switch side'
            Rows   = @'
vlan 10 :: Creates VLAN 10
Switch(config-vlan)# :: name Sales :: Names it
vlan 20 :: Creates VLAN 20
Switch(config-vlan)# :: name Support :: Names it
interface f0/6 :: The port to the router
Switch(config-if)# :: switchport mode trunk :: Trunk to the router
Switch(config-if)# :: switchport trunk allowed vlan 10,20,99 :: Only the VLANs the router needs
interface f0/11 :: A host port in VLAN 10
Switch(config-if)# :: switchport mode access :: An access port
Switch(config-if)# :: switchport access vlan 10 :: In VLAN 10
'@
        }
        @{
            Title  = 'ROUTER ON A STICK - the router side'
            Prompt = 'R1(config)#'
            Rows   = @'
interface g0/0 :: The physical interface, up but without an address
R1(config-if)# :: no shutdown :: Turns it on
interface g0/0.10 :: Subinterface for VLAN 10
R1(config-subif)# :: encapsulation dot1q 10 :: This subinterface carries VLAN 10
R1(config-subif)# :: ip address 192.168.10.1 255.255.255.0 :: The hosts' default gateway in VLAN 10
interface g0/0.20 :: Subinterface for VLAN 20
R1(config-subif)# :: encapsulation dot1q 20 :: This subinterface carries VLAN 20
R1(config-subif)# :: ip address 192.168.20.1 255.255.255.0 :: The hosts' default gateway in VLAN 20
interface g0/0.99 :: Subinterface for the native / management VLAN
R1(config-subif)# :: encapsulation dot1q 99 native :: The untagged VLAN (must match the switch's native VLAN)
R1(config-subif)# :: ip address 192.168.99.1 255.255.255.0 :: Its address
Note: if the physical interface is not turned on with "no shutdown", none of its subinterfaces work.
R1# :: show ip route :: Each subinterface's network shows up as C (connected)
R1# :: show interfaces g0/0.10 :: Look at the encapsulation line
'@
        }
        @{
            Title  = 'LAYER 3 SWITCH WITH SVIs'
            Rows   = @'
ip routing :: Turns routing on (without this the VLAN interfaces do not forward between each other)
vlan 10 :: Creates the VLANs first
interface vlan 10 :: The switched virtual interface (SVI) for VLAN 10
Switch(config-if)# :: ip address 192.168.10.1 255.255.255.0 :: The hosts' default gateway
Switch(config-if)# :: no shutdown :: Turns it on
interface vlan 20 :: The SVI for VLAN 20
Switch(config-if)# :: ip address 192.168.20.1 255.255.255.0 :: The hosts' default gateway
Switch(config-if)# :: no shutdown :: Turns it on
Switch# :: show ip route :: Both networks should be C (connected)
Switch# :: show ip interface brief :: The SVI is up/up only if at least one port in the VLAN is up
Note: the VLAN must exist, and at least one access port (or a trunk carrying it) must be up, or its SVI stays down.
'@
        }
        @{
            Title  = 'ROUTED PORT AND UPLINK (layer 3 switch)'
            Rows   = @'
interface g1/0/1 :: The uplink to a router
Switch(config-if)# :: no switchport :: Makes it a routed port (an ordinary router interface)
Switch(config-if)# :: ip address 10.0.0.2 255.255.255.252 :: Its address
Switch(config)# :: ip route 0.0.0.0 0.0.0.0 10.0.0.1 :: Default route towards the router
'@
        }
        @{
            Title  = 'HOST SETTINGS (what the PC needs)'
            Rows   = @'
PS> :: Get-NetIPConfiguration :: Address, gateway and DNS
PS> :: ipconfig /all :: The same in the old tool
PS> :: Test-NetConnection 192.168.20.10 -TraceRoute :: Pings and shows the hops (the first hop must be the gateway)
Note: the host's default gateway must be the router's subinterface or the SVI address of ITS OWN VLAN.
'@
        }
        @{
            Title  = 'CHECKLIST (go from the bottom up)'
            Rows   = @'
Note: 1. Is the host's port in the right VLAN? (show vlan brief)
Note: 2. Does the VLAN exist on every switch on the path? (show vlan brief)
Note: 3. Is the trunk up, and does it allow the VLAN? (show interfaces trunk)
Note: 4. Do the native VLANs match on both ends? (show interfaces trunk, and the CDP/log message about a native VLAN mismatch)
Note: 5. Router: does the subinterface have the right "encapsulation dot1q <vlan>" and an address in the VLAN's network?
Note: 6. Layer 3 switch: is "ip routing" on, is the SVI up/up?
Note: 7. Host: does it have an address in the right network and the right default gateway?
Switch# :: show interfaces trunk :: Trunk status and allowed VLANs
Switch# :: show vlan brief :: Which ports belong to which VLAN
Switch# :: show ip interface brief :: Interface states and addresses
'@
        }
    )
}
