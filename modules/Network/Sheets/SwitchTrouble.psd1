@{
    Command  = 'Show-SwitchTrouble'
    Alias    = 'netswt'
    Synopsis = 'Troubleshooting a switch: ports, VLANs, trunks, STP, MAC table'
    Group    = 'TROUBLESHOOTING'
    Order    = 71
    Index    = 'Show-NetCommands'
    Title    = 'NETWORK MODULE - TROUBLESHOOTING A SWITCH'
    Prompt   = 'Switch#'

    Sections = @(
        @{
            Title  = 'THE PORT'
            Rows   = @'
show interfaces status :: One line per port: connected, notconnect, disabled, err-disabled
show interfaces f0/1 :: The detail for a port: up/up, speed, duplex, and error counters
show interfaces f0/1 counters errors :: Only the error counters
show ip interface brief :: Layer 3 view: only interfaces with an address and VLAN interfaces
show running-config interface f0/1 :: What is configured on the port
Note: "up/up" is fine. "up/down" on the VLAN interface means no active port in the VLAN. "down/down" means no cable or the other end is off. "administratively down" means someone typed shutdown.
Note: CRC errors, runts, giants and late collisions point to cable problems or a duplex mismatch. Fix the cable, or set the same speed and duplex on both ends.
'@
        }
        @{
            Title  = 'ERR-DISABLED PORTS'
            Rows   = @'
show interfaces status err-disabled :: Which ports were shut down by the switch, and why
show errdisable recovery :: Is automatic recovery on, and for which causes
Switch(config-if)# :: shutdown :: First turn the port off...
Switch(config-if)# :: no shutdown :: ...and on again (after you removed the cause)
Switch(config)# :: errdisable recovery cause psecure-violation :: Lets the switch turn the port on again by itself
Switch(config)# :: errdisable recovery interval 300 :: ...after this many seconds
'@
        }
        @{
            Title  = 'VLANS AND TRUNKS'
            Rows   = @'
show vlan brief :: Which ports are in which VLAN, and does the VLAN exist?
show interfaces trunk :: Trunk status, native VLAN, allowed and active VLANs
show interfaces f0/1 switchport :: Mode, access VLAN, trunking VLANs for one port
show dtp interface g0/1 :: What the Dynamic Trunking Protocol does on the port
Note: a host in a VLAN that does not exist loses connectivity, even if the port is up.
Note: a native VLAN mismatch makes the switch log a message and can cause spanning-tree trouble.
Note: a VLAN missing from "allowed vlan" on a trunk is not forwarded over it.
'@
        }
        @{
            Title  = 'MAC ADDRESSES AND TOPOLOGY'
            Rows   = @'
show mac address-table :: Which MAC address is learned on which port
show mac address-table address 0050.56aa.bb11 :: Where is one device?
show mac address-table interface f0/1 :: What is learned on this port
show cdp neighbors :: Which Cisco devices are connected
show cdp neighbors detail :: The same with address and IOS version
show lldp neighbors detail :: The same with the standard protocol (needs: lldp run)
'@
        }
        @{
            Title  = 'SPANNING TREE AND LOOPS'
            Rows   = @'
show spanning-tree :: Root bridge, port roles and states for each VLAN
show spanning-tree summary :: Mode and number of ports per state
show spanning-tree inconsistentports :: Ports blocked for a reason (root guard, loop guard, BPDU guard)
show etherchannel summary :: Bundles: SU is in use, SD is down, P is bundled
Note: a broadcast storm shows as 100% CPU and all port LEDs flashing in sync. Unplug cables one at a time to find the loop.
'@
        }
        @{
            Title  = 'SECURITY AND LOGS'
            Rows   = @'
show port-security :: Overview of port security: max addresses, violations, action
show port-security interface f0/18 :: One port
show logging :: The log messages: link up/down, security violations, loop messages
show running-config | section interface :: Only the interface parts of the configuration
show version :: IOS version, uptime and the reason for the last restart
show processes cpu sorted :: What uses the CPU
'@
        }
        @{
            Title  = 'A SHORT ORDER OF WORK'
            Rows   = @'
Note: 1. Port: up/up? Speed and duplex? Errors?
Note: 2. VLAN: does the VLAN exist, and is the port in it?
Note: 3. Trunk: is it up, and does it allow the VLAN, with a matching native VLAN?
Note: 4. MAC table: is the device's address learned on the expected port?
Note: 5. Spanning tree: is the port forwarding or blocking?
Note: 6. Security: is port security or an ACL blocking it?
Note: 7. Layer 3: SVI up, "ip routing" on, a default gateway set for the management address?
'@
        }
    )
}
