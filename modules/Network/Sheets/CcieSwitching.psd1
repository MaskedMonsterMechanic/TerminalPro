@{
    Command  = 'Show-CcieSwitching'
    Alias    = 'ccieswitch'
    Synopsis = 'Switched campus: errdisable, MAC table, MTU, CDP/LLDP, UDLD, VLANs and trunks, EtherChannel, spanning tree'
    Group    = 'CCIE'
    Order    = 301
    Index    = 'Show-NetCommands'
    Title    = 'CCIE - SWITCHED CAMPUS'
    Prompt   = 'Switch(config)#'

    Sections = @(
        @{
            Title  = 'MAC ADDRESS TABLE AND ERRDISABLE'
            Rows   = @'
mac address-table aging-time 600 :: Seconds before an unused entry is removed (default 300)
mac address-table static aaaa.bbbb.cccc vlan 10 interface g1/0/1 :: A fixed entry
errdisable recovery cause bpduguard :: Bring ports back by themselves after this cause (also: psecure-violation, udld, link-flap, loopback ...)
errdisable recovery interval 300 :: Seconds before the port is tried again (default 300)
Switch# :: show mac address-table dynamic vlan 10 :: Learned addresses in one VLAN
Switch# :: show mac address-table address aaaa.bbbb.cccc :: Where one address was learned
Switch# :: clear mac address-table dynamic :: Empties the learned entries
Switch# :: show interfaces status err-disabled :: Which ports are shut down by errdisable, and why
Switch# :: show errdisable recovery :: Which causes recover, and the timer
Switch# :: show errdisable detection :: Which causes are watched at all
 :: Bring a port back by hand :: shutdown, then no shutdown, on the interface (fix the cause first, or it goes down again)
'@
        }
        @{
            Title  = 'MTU AT LAYER 2'
            Rows   = @'
system mtu 9198 :: Largest frame size on a Catalyst 9000. Older models use "system mtu jumbo" and need a reload.
Switch# :: show system mtu :: The values now in use
 :: Rule :: Every device in the path must allow the same frame size, or the big frames are dropped without notice. Ping with a size and "df-bit" to test: ping 10.1.1.2 size 1500 df-bit
Note: the command name and the limits depend on the model. Check "system mtu ?".
'@
        }
        @{
            Title  = 'CDP AND LLDP'
            Rows   = @'
cdp run :: CDP on for the whole switch (on by default)
lldp run :: LLDP on for the whole switch (off by default)
Switch(config-if)# :: no cdp enable :: Stops CDP on one interface (use "no lldp transmit" and "no lldp receive" for LLDP)
Switch# :: show cdp neighbors detail :: Neighbors with address, platform and version
Switch# :: show lldp neighbors detail :: The same from LLDP (the open standard, 802.1AB)
'@
        }
        @{
            Title  = 'UDLD (one-way links)'
            Prompt = 'Switch(config-if)#'
            Rows   = @'
udld port :: Turns UDLD on for this port (normal mode: marks a one-way port as undetermined and logs it)
udld port aggressive :: Aggressive mode: tries to re-establish, then shuts the port (errdisable) if the link stays one-way
Switch(config)# :: udld enable :: Global: UDLD normal mode on all fiber ports
Switch(config)# :: udld aggressive :: Global: aggressive mode on all fiber ports
Switch# :: show udld g1/0/1 :: State of one port and its neighbor
Switch# :: udld reset :: Re-enables ports shut down by UDLD
 :: Why :: A fiber pair that works in one direction only can make spanning tree loop, because BPDUs stop arriving. UDLD finds this.
'@
        }
        @{
            Title  = 'VLANS AND TRUNKS'
            Prompt = 'Switch(config-if)#'
            Rows   = @'
switchport mode access :: Access port (one VLAN)
switchport access vlan 10 :: The VLAN of the access port
switchport voice vlan 20 :: A second VLAN for the IP phone behind the PC (tagged)
switchport mode trunk :: Trunk (802.1Q) with DTP set to on
switchport trunk encapsulation dot1q :: Needed only on models that also support ISL
switchport trunk native vlan 99 :: The untagged VLAN. It must be the same at both ends, and not VLAN 1.
switchport trunk allowed vlan 10,20,99 :: Manual pruning: only these VLANs cross the trunk
switchport trunk allowed vlan add 30 :: Adds one VLAN (without "add", the whole list is replaced!)
switchport nonegotiate :: Stops DTP frames on the port
Switch(config)# :: vlan 3000 :: Extended range VLAN (1006-4094). The normal range is 1-1005.
Switch(config)# :: vlan dot1q tag native :: Also tags the native VLAN on all trunks
Switch# :: show interfaces trunk :: Trunks, native VLAN, allowed and active VLANs
Switch# :: show interfaces g1/0/1 switchport :: The mode the port runs in (administrative and operational)
Switch# :: show vlan brief :: VLANs and their access ports
'@
        }
        @{
            Title  = 'ETHERCHANNEL'
            Rows   = @'
Switch(config)# :: interface range g1/0/1-2 :: Select the member ports
Switch(config-if-range)# :: channel-group 1 mode active :: Join channel 1 with LACP. This also creates interface port-channel 1.
Switch(config-if-range)# :: channel-group 1 mode on :: Static: no protocol at all
Switch(config)# :: interface port-channel 1 :: The logical interface. Put trunk or access settings here (it copies to the members).
Switch(config-if)# :: no switchport :: On the port-channel: makes it a Layer 3 channel (then give it an IP address)
Switch(config-if)# :: port-channel min-links 2 :: The channel goes down if fewer than 2 links are up
Switch(config)# :: port-channel load-balance src-dst-ip :: What the hash uses to pick a link (src-mac, dst-mac, src-dst-mac, src-dst-ip, src-dst-port ...)
Switch(config)# :: spanning-tree etherchannel guard misconfig :: Shuts down ports that look like a bad (one-sided) channel
Switch# :: show etherchannel summary :: Flags: P = in the channel, I = alone, D = down, s = suspended, SU = Layer 2 and in use, RU = Layer 3 and in use
Switch# :: show etherchannel load-balance :: The hash method
Switch# :: test etherchannel load-balance interface port-channel 1 ip 10.1.1.1 10.2.2.2 :: Which link a flow will use
Switch# :: show lacp neighbor :: LACP partner information
 :: Mode pairs that work :: LACP active+active and active+passive. Never passive+passive. PAgP desirable+desirable and desirable+auto. Never auto+auto. "on" only with "on".
 :: Must match on all members :: Speed, duplex, VLAN or trunk settings, native VLAN, allowed VLANs.
 :: Across two switches :: One channel to two chassis needs a stack, StackWise Virtual or VSS (multichassis EtherChannel). Then there is no spanning tree block between them.
'@
        }
        @{
            Title  = 'SPANNING TREE: MODE AND ROOT'
            Rows   = @'
spanning-tree mode rapid-pvst :: Rapid PVST+ (one tree per VLAN, fast). Other modes: pvst, mst.
spanning-tree vlan 10 root primary :: Sets the priority low enough to become the root (automatic)
spanning-tree vlan 10 root secondary :: A backup root
spanning-tree vlan 10 priority 4096 :: By hand. Only multiples of 4096. Default 32768.
Switch(config-if)# :: spanning-tree vlan 10 cost 10 :: Path cost on one port
Switch(config-if)# :: spanning-tree vlan 10 port-priority 64 :: Port priority, multiples of 16, default 128. Lower wins.
spanning-tree pathcost method long :: The 32-bit cost values (needed for fast links)
spanning-tree vlan 10 hello-time 2 :: Seconds between BPDUs (default 2)
spanning-tree vlan 10 forward-time 15 :: Listening and learning time in classic STP (default 15)
spanning-tree vlan 10 max-age 20 :: How long a BPDU is kept (default 20)
Note: only change the timers on the ROOT, it sends them to all others. Lower values give faster convergence but less room for delay.
'@
        }
        @{
            Title  = 'SPANNING TREE: HOW IT DECIDES'
            Rows   = @'
 :: Root bridge :: The lowest bridge ID wins: priority first, then MAC address. The priority carries the VLAN number (32768 + 10 = 32778 for VLAN 10).
 :: Root port :: On each non-root switch, the one port with the lowest total path cost to the root. Tie: lowest sender bridge ID, then lowest sender port ID.
 :: Designated port :: On each segment, the port that gives the best path to the root. It forwards.
 :: Blocking port :: Every other port: alternate or backup in rapid STP (discarding).
 :: Cost, short method :: 10 Mb/s = 100, 100 Mb/s = 19, 1 Gb/s = 4, 10 Gb/s = 2
 :: Cost, long method :: 10 Mb/s = 2,000,000, 100 Mb/s = 200,000, 1 Gb/s = 20,000, 10 Gb/s = 2,000
 :: Classic port states :: Blocking, listening, learning, forwarding (about 30 to 50 seconds in all)
 :: Rapid port states :: Discarding, learning, forwarding. Edge ports and point-to-point links go to forwarding in seconds (proposal and agreement).
Note: which method is the default depends on the mode and the version. Check with: show spanning-tree summary
'@
        }
        @{
            Title  = 'SPANNING TREE: PROTECTION'
            Prompt = 'Switch(config-if)#'
            Rows   = @'
spanning-tree portfast :: Edge port: goes to forwarding at once. Only for hosts, never for switches.
spanning-tree bpduguard enable :: The port is shut down (errdisable) if a BPDU arrives
spanning-tree bpdufilter enable :: On the interface: sends and receives no BPDUs. DANGEROUS: it can hide a loop.
spanning-tree guard root :: Port may never become a root port. A better BPDU puts it in a "root-inconsistent" state.
spanning-tree guard loop :: If BPDUs stop on a non-designated port, it does not go forwarding (loop-inconsistent)
Switch(config)# :: spanning-tree portfast default :: Global: PortFast on all ACCESS ports
Switch(config)# :: spanning-tree portfast bpduguard default :: Global: BPDU guard on all PortFast ports
Switch(config)# :: spanning-tree loopguard default :: Global: loop guard on all point-to-point ports
Switch# :: show spanning-tree inconsistentports :: Ports blocked by root guard, loop guard or similar
Note: root guard goes toward switches you do not control. BPDU guard goes toward hosts.
'@
        }
        @{
            Title  = 'MULTIPLE SPANNING TREE (MST)'
            Rows   = @'
spanning-tree mode mst :: MST: several VLANs share one tree (an instance). Less CPU and fewer BPDUs than one tree per VLAN.
spanning-tree mst configuration :: Enters the MST region settings
Switch(config-mst)# :: name REGION1 :: Region name. It must match on all switches of the region.
Switch(config-mst)# :: revision 1 :: Revision number. It must match too.
Switch(config-mst)# :: instance 1 vlan 10,20 :: VLANs 10 and 20 use instance 1. It must match too (VLANs not listed stay in instance 0).
spanning-tree mst 1 priority 4096 :: Root for instance 1 (or: spanning-tree mst 1 root primary)
Switch# :: show spanning-tree mst :: Instances, roles and the region
Switch# :: show spanning-tree mst configuration :: Name, revision, and the VLAN-to-instance map
Note: switches with different name, revision or map are in different regions. They meet only through the common IST (instance 0).
Note: to check spanning tree on a VLAN: show spanning-tree vlan 10. In general: show spanning-tree summary.
'@
        }
    )
}
