@{
    Command  = 'Show-SwitchBasic'
    Alias    = 'netswb'
    Synopsis = 'Switch setup: management address, ports, VLANs, trunks, port security'
    Group    = 'SWITCH'
    Order    = 50
    Index    = 'Show-NetCommands'
    Title    = 'NETWORK MODULE - SWITCH CONFIGURATION'
    Prompt   = 'Switch(config)#'

    Sections = @(
        @{
            Title  = 'MANAGEMENT ADDRESS (a switch has no IP address on its ports)'
            Rows   = @'
interface vlan 99 :: Goes to the management interface (better a separate management VLAN like 99 than VLAN 1)
Switch(config-if)# :: ip address 192.168.99.2 255.255.255.0 :: Gives the switch its own address
Switch(config-if)# :: no shutdown :: Turns the interface on
Switch(config)# :: ip default-gateway 192.168.99.1 :: Where the switch sends traffic that is not local (this is a switch command, not a router command)
Switch# :: show interfaces vlan 99 :: Checks that the management interface is up and up
'@
        }
        @{
            Title  = 'ACCESS PORTS'
            Rows   = @'
Switch(config)# :: interface range f0/1 - 24 :: Configures many ports at once
Switch(config-if-range)# :: switchport mode access :: The port belongs to one VLAN and carries untagged frames
Switch(config-if-range)# :: switchport access vlan 10 :: Puts the ports in VLAN 10
Switch(config-if-range)# :: spanning-tree portfast :: Skips the listening and learning wait on ports with an end device
Switch(config-if-range)# :: spanning-tree bpduguard enable :: Shuts the port down if a switch is plugged into it
Switch(config-if)# :: description Office PC 14 :: Writes a label on the port
Switch(config-if)# :: speed 100 :: Fixes the speed (the other end must be fixed too, or leave both on auto)
Switch(config-if)# :: duplex full :: Fixes the duplex
Switch(config-if)# :: shutdown :: Turns an unused port off
'@
        }
        @{
            Title  = 'VLANS'
            Rows   = @'
Switch(config)# :: vlan 10 :: Creates VLAN 10 and enters its configuration
Switch(config-vlan)# :: name Sales :: Names it
Switch(config)# :: no vlan 10 :: Deletes VLAN 10 (move the ports out of it first)
Switch# :: show vlan brief :: Lists the VLANs and their access ports
Switch# :: show interfaces f0/1 switchport :: Shows the mode and VLAN of one port
Note: the VLAN database is the file vlan.dat in flash. It survives "erase startup-config".
Note: VLAN 1 is the default, 1002-1005 are reserved, and 1-1005 are the normal range (up to 4094 extended).
'@
        }
        @{
            Title  = 'TRUNKS (802.1Q)'
            Rows   = @'
Switch(config)# :: interface g0/1 :: Goes to the uplink
Switch(config-if)# :: switchport mode trunk :: Carries many VLANs between switches
Switch(config-if)# :: switchport trunk native vlan 99 :: Sets the VLAN for untagged frames (the same on both ends)
Switch(config-if)# :: switchport trunk allowed vlan 10,20,99 :: Only lets these VLANs cross (leave out the rest)
Switch(config-if)# :: switchport nonegotiate :: Turns off DTP so the port cannot be talked into trunking
Switch# :: show interfaces trunk :: Lists the trunks, the native VLAN and the allowed VLANs
Switch# :: show interfaces g0/1 switchport :: Shows the administrative and operational mode
'@
        }
        @{
            Title  = 'PORT SECURITY'
            Rows   = @'
Switch(config-if)# :: switchport mode access :: Port security only works on access ports (and trunks set up for it)
Switch(config-if)# :: switchport port-security :: Turns it on
Switch(config-if)# :: switchport port-security maximum 2 :: Allows two MAC addresses on the port
Switch(config-if)# :: switchport port-security mac-address sticky :: Learns the addresses and keeps them in the running config
Switch(config-if)# :: switchport port-security violation restrict :: Drops the frames and logs it (protect = silent, shutdown = default, port goes err-disabled)
Switch# :: show port-security interface f0/18 :: Shows the settings and violations of one port
Switch# :: show port-security address :: Shows the secured MAC addresses
Switch# :: show interfaces status err-disabled :: Lists ports that were shut down by a violation
Switch(config-if)# :: shutdown then no shutdown :: Brings an err-disabled port back
'@
        }
        @{
            Title  = 'SPANNING TREE AND LINK AGGREGATION'
            Rows   = @'
Switch(config)# :: spanning-tree mode rapid-pvst :: Uses the fast version of spanning tree (the sensible choice today)
Switch(config)# :: spanning-tree vlan 10 root primary :: Makes this switch the root bridge for VLAN 10
Switch(config)# :: spanning-tree vlan 10 priority 4096 :: Sets the priority by hand (multiples of 4096, lower wins)
Switch# :: show spanning-tree :: Shows the root, the port roles and the port states
Switch# :: show spanning-tree vlan 10 :: Shows it for one VLAN
Switch(config-if-range)# :: channel-group 1 mode active :: Bundles ports with LACP (802.3ad / 802.1AX); the other end uses active or passive
Switch(config)# :: interface port-channel 1 :: Configures the bundle itself (trunk, VLANs and so on go here)
Switch# :: show etherchannel summary :: Shows the bundles: SU = in use, SD = down, P = bundled in the port-channel
'@
        }
        @{
            Title  = 'LAYER 3 SWITCH'
            Rows   = @'
Switch(config)# :: ip routing :: Lets a multilayer switch route between its VLAN interfaces
Switch(config-if)# :: no switchport :: Turns a switch port into a routed port (with an IP address on it)
Switch(config)# :: interface vlan 10 :: Creates the gateway for VLAN 10
Switch(config-if)# :: ip address 192.168.10.1 255.255.255.0 :: The address the hosts use as default gateway
Switch# :: show ip route :: Checks that the connected networks are in the table
'@
        }
        @{
            Title  = 'LOOK AT THE SWITCH'
            Rows   = @'
Switch# :: show mac address-table :: Lists the learned MAC addresses and the ports
Switch# :: show mac address-table dynamic vlan 10 :: Only the learned ones in VLAN 10
Switch# :: clear mac address-table dynamic :: Forgets the learned addresses
Switch# :: show interfaces status :: One line per port: connected, notconnect, err-disabled
Switch# :: show cdp neighbors detail :: Shows who is connected, with their address
Switch# :: show lldp neighbors :: The same with the standard protocol (turn on first: lldp run)
Switch# :: show interfaces f0/1 :: Counters: look at CRC, collisions and runts for cable problems
'@
        }
    )
}
