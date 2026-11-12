@{
    Command  = 'Show-CcieSwitchSecurity'
    Alias    = 'ccieswsec'
    Synopsis = 'Switch security, IPv6 first-hop security, CoPP, router ACL/uRPF pointers, management, logging'
    Group    = 'CCIE'
    Order    = 307
    Index    = 'Show-NetCommands'
    Title    = 'CCIE - SWITCH AND INFRASTRUCTURE SECURITY'
    Prompt   = 'Switch(config)#'

    Sections = @(
        @{
            Title  = 'DHCP SNOOPING'
            Rows   = @'
ip dhcp snooping :: Turns it on (global)
ip dhcp snooping vlan 10,20 :: ...for these VLANs
Switch(config-if)# :: ip dhcp snooping trust :: On ports toward the DHCP server or the uplink. Untrusted ports may NOT send server replies (offer, ack).
Switch(config-if)# :: ip dhcp snooping limit rate 15 :: Packets per second allowed on an untrusted port (errdisable if exceeded)
no ip dhcp snooping information option :: Stops option 82 insertion. Needed when the DHCP relay is a router behind this switch and the switch is not the relay.
ip dhcp snooping information option allow-untrusted :: Accepts DHCP packets that have option 82 from untrusted ports
Switch# :: show ip dhcp snooping :: Settings, VLANs and trusted ports
Switch# :: show ip dhcp snooping binding :: The table: MAC, IP, VLAN, port, lease. DAI and IP Source Guard use it.
 :: Option 82 :: The relay agent information. The switch adds the port and switch ID, so the server can tell where a request came from.
'@
        }
        @{
            Title  = 'DYNAMIC ARP INSPECTION AND IP SOURCE GUARD'
            Rows   = @'
ip arp inspection vlan 10 :: DAI on a VLAN. ARP packets are checked against the snooping table.
Switch(config-if)# :: ip arp inspection trust :: Trusted port (uplinks, routers). ARP is not checked.
Switch(config-if)# :: ip arp inspection limit rate 15 :: ARP packets per second on an untrusted port (default 15)
ip arp inspection validate src-mac dst-mac ip :: Also check MAC and IP fields inside the ARP packet
arp access-list STATIC-HOSTS :: A static ARP list for hosts without DHCP...
Switch(config-arp-nacl)# :: permit ip host 10.1.1.5 mac host aaaa.bbbb.cccc :: ...one allowed pair
ip arp inspection filter STATIC-HOSTS vlan 10 :: ...used for VLAN 10
Switch(config-if)# :: ip verify source :: IP Source Guard: only the IP address from the snooping table may be used on this port
Switch(config-if)# :: ip verify source port-security :: ...and also checks the MAC address (needs port security)
Switch# :: show ip arp inspection :: Statistics and the VLANs
Switch# :: show ip verify source :: IP Source Guard entries
 :: Needs :: DHCP snooping must be on, or the binding table is empty and legitimate hosts are blocked.
'@
        }
        @{
            Title  = 'PORT SECURITY AND STORM CONTROL'
            Prompt = 'Switch(config-if)#'
            Rows   = @'
switchport port-security :: Port security on (the port must be an access or trunk port, not dynamic)
switchport port-security maximum 2 :: Largest number of MAC addresses
switchport port-security mac-address sticky :: Learned addresses are kept in the running config
switchport port-security mac-address aaaa.bbbb.cccc :: A fixed allowed address
switchport port-security violation shutdown :: Violation: the port goes errdisable (the default)
switchport port-security violation restrict :: Violation: drops the frames, counts, and logs
switchport port-security violation protect :: Violation: drops the frames, no log
switchport port-security aging time 10 :: Minutes before a learned address is removed
storm-control broadcast level 20 :: Limits broadcast to 20% of the link speed
storm-control multicast level 30 :: The same for multicast (also: unicast)
storm-control action shutdown :: What to do above the level: shutdown, or trap
Switch# :: show port-security interface g1/0/1 :: State, count, and last violation
Switch# :: show storm-control :: Levels and status
'@
        }
        @{
            Title  = 'VACL AND PACL'
            Rows   = @'
ip access-list extended BLOCK-TELNET :: An ACL for a VLAN map...
Switch(config-ext-nacl)# :: permit tcp any any eq 23 :: ...it matches what the map should act on
vlan access-map VMAP 10 :: A VLAN access map...
Switch(config-access-map)# :: match ip address BLOCK-TELNET :: ...matches the ACL...
Switch(config-access-map)# :: action drop :: ...and drops it (action forward lets it through)
vlan access-map VMAP 20 :: A last entry with no match...
Switch(config-access-map)# :: action forward :: ...to let everything else pass (the end of a map is an implicit drop)
vlan filter VMAP vlan-list 10 :: Applies the map to VLAN 10 (all traffic inside it, even between hosts)
Switch(config-if)# :: ip access-group ACL-NAME in :: PACL: an ACL on a Layer 2 (switched) port, INBOUND only
Switch# :: show vlan access-map :: The maps and their entries
 :: Compare :: A router ACL (RACL) filters traffic that is ROUTED between VLANs. A VACL filters inside a VLAN too. A PACL filters at the port.
'@
        }
        @{
            Title  = 'IPv6 FIRST-HOP SECURITY'
            Rows   = @'
ipv6 nd raguard policy HOSTS :: RA Guard: a policy...
Switch(config-nd-raguard)# :: device-role host :: ...for ports with hosts: router advertisements are dropped (use "device-role router" on router ports)
Switch(config-if)# :: ipv6 nd raguard attach-policy HOSTS :: ...applied to a port
ipv6 dhcp guard policy CLIENTS :: DHCPv6 Guard: a policy...
Switch(config-dhcp-guard)# :: device-role client :: ...for client ports: server replies are dropped
Switch(config-if)# :: ipv6 dhcp guard attach-policy CLIENTS :: ...applied to a port
ipv6 snooping policy SNOOP :: IPv6 snooping: builds the binding table (address, MAC, port) from ND and DHCPv6
Switch(config-if)# :: ipv6 snooping attach-policy SNOOP :: ...applied to a port
ipv6 nd inspection policy ND-INSPECT :: ND inspection: checks neighbor discovery against the binding table
ipv6 source-guard policy SG :: IPv6 source guard: drops packets from addresses not in the binding table
Switch# :: show ipv6 neighbors binding :: The binding table (the command depends on the release)
Note: from IOS XE 16.x, the older "ipv6 snooping" lines are replaced by "device-tracking" policies. Check ? on your version.
 :: Why :: A fake router advertisement can move all hosts to an attacker (man in the middle). RA Guard stops that on the switch.
'@
        }
        @{
            Title  = 'CONTROL PLANE POLICING (CoPP)'
            Prompt = 'Router(config)#'
            Rows   = @'
access-list 120 permit tcp 10.0.0.0 0.0.0.255 any eq 22 :: Traffic that should reach the CPU: here SSH from the management network
class-map match-all COPP-SSH :: A class...
Router(config-cmap)# :: match access-group 120 :: ...for that traffic
policy-map COPP :: A policy...
Router(config-pmap)# :: class COPP-SSH :: ...with the class...
Router(config-pmap-c)# :: police 64000 conform-action transmit exceed-action drop :: ...limited to 64 kb/s
Router(config-pmap)# :: class class-default :: Everything else...
Router(config-pmap-c)# :: police 128000 conform-action transmit exceed-action drop :: ...a small limit
control-plane :: The control plane...
Router(config-cp)# :: service-policy input COPP :: ...with the policy applied to what goes to the CPU
Router# :: show policy-map control-plane :: What passed and what was dropped
Note: test in a lab first. A policy that is too strict drops routing protocol hellos and you lose the router.
 :: Related :: CoPP protects the router itself. For passwords, SSH, AAA, SNMPv3, NTP and uRPF, see ccnpsec.
'@
        }
        @{
            Title  = 'MANAGEMENT: CONSOLE, VTY, SSH, SCP'
            Prompt = 'Router(config)#'
            Rows   = @'
line console 0 :: The console line...
Router(config-line)# :: logging synchronous :: ...stops log messages cutting into what you type
Router(config-line)# :: exec-timeout 10 0 :: ...logs out after 10 minutes idle
line vty 0 15 :: The remote lines...
Router(config-line)# :: transport input ssh :: ...SSH only
Router(config-line)# :: access-class 21 in :: ...only from the addresses in ACL 21
ip ssh version 2 :: SSH version 2
ip scp server enable :: Allows secure copy (scp) to and from the device
Router# :: copy running-config scp://admin@10.1.1.5/r1.cfg :: Copy the config with scp
Router# :: show ssh :: Active SSH sessions
Router# :: show users :: Who is logged in
'@
        }
        @{
            Title  = 'LOGGING AND CHANGE TRACKING'
            Prompt = 'Router(config)#'
            Rows   = @'
service timestamps log datetime msec localtime show-timezone :: Time on every log line, with milliseconds
service timestamps debug datetime msec :: The same for debug output
logging buffered 64000 informational :: A log in memory (size, and the level to keep)
logging host 10.1.1.5 :: Sends logs to a syslog server (UDP 514)
logging trap informational :: The level sent to the server
logging source-interface loopback 0 :: The same source address every time
archive :: Config archive...
Router(config-archive)# :: log config :: ...record every command typed in config mode...
Router(config-archive-log-cfg)# :: logging enable :: ...turn it on...
Router(config-archive-log-cfg)# :: notify syslog contenttype plaintext :: ...and send it as a syslog message
Router# :: show archive log config all :: Who changed what
Router# :: debug condition interface g0/0 :: Conditional debug: only debug output for this interface
Router# :: debug condition ip 10.1.1.5 :: ...or only for this address
Router# :: show debug condition :: The conditions now set
Router# :: undebug all :: Turn all debugging off (do this first when the router feels slow)
 :: Levels :: 0 emergencies, 1 alerts, 2 critical, 3 errors, 4 warnings, 5 notifications, 6 informational, 7 debugging
 :: SNMP :: SNMPv2c uses a community string in clear text. SNMPv3 has users, authentication and encryption. See ccnpsec.
'@
        }
        @{
            Title  = 'ROUTER FILTERS: ACLs AND uRPF'
            Prompt = 'Router(config)#'
            Rows   = @'
ip access-list extended OUTSIDE-IN :: A named IPv4 ACL...
Router(config-ext-nacl)# :: deny ip 10.0.0.0 0.255.255.255 any :: ...with a rule (here: private source addresses from outside)
Router(config-if)# :: ip access-group OUTSIDE-IN in :: ...on an interface
ipv6 access-list V6-IN :: A named IPv6 ACL...
Router(config-ipv6-acl)# :: permit icmp any any nd-na :: ...if you end it with your own "deny ipv6 any any", also permit nd-na and nd-ns before it, or neighbor discovery (and IPv6) breaks
Router(config-if)# :: ipv6 traffic-filter V6-IN in :: ...on an interface (IPv6 uses traffic-filter, not access-group)
Router(config-if)# :: ip verify unicast source reachable-via rx :: uRPF strict mode: the source must be reachable out of the SAME interface
Router(config-if)# :: ip verify unicast source reachable-via any :: uRPF loose mode: the source must be anywhere in the table (for multihomed edges)
Router# :: show ip interface g0/0 :: Shows the ACLs and uRPF drop counters
 :: ACL rules :: Top down, the first match wins. There is an implicit "deny all" at the end. Extended ACLs go near the SOURCE, standard near the DESTINATION.
 :: IPv6 :: The implicit rules at the end of an IPv6 ACL also allow neighbor discovery (permit nd-na, permit nd-ns) before the final deny.
'@
        }
    )
}
