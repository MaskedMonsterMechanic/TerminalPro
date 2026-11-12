@{
    Command  = 'Show-CcieQos'
    Alias    = 'ccieqos'
    Synopsis = 'QoS: DiffServ, DSCP/CoS table, trust, MQC classes and policies, NBAR, marking, policing, shaping, queuing, tunnels'
    Group    = 'CCIE'
    Order    = 308
    Index    = 'Show-NetCommands'
    Title    = 'CCIE - QUALITY OF SERVICE'
    Prompt   = 'Router(config)#'

    Sections = @(
        @{
            Title  = 'THE IDEA (DiffServ)'
            Rows   = @'
 :: Differentiated Services :: No reservation per flow. Packets are MARKED at the edge, and each router treats a class the same way (per-hop behavior).
 :: Four tools :: Classify and mark. Police or shape. Queue (and schedule). Drop early (to avoid tail drop).
 :: Where :: Mark at the edge of the network (trust boundary). Core routers only read the mark.
 :: Order :: Classification first, then marking, then policing, then queuing and shaping on the way out.
'@
        }
        @{
            Title  = 'MARKS: DSCP, PRECEDENCE, COS'
            Rows   = @'
 :: DSCP :: 6 bits in the IP header (the top 6 bits of the old ToS byte). Value 0 to 63. ToS byte = DSCP x 4 (EF 46 = 184).
 :: IP precedence :: The first 3 bits of the same byte (0 to 7). It is the old way. Class selector CS1 to CS7 is DSCP 8, 16, 24 ... 56 and is compatible.
 :: CoS (802.1p) :: 3 bits in the 802.1Q tag (0 to 7). Layer 2 only: it is lost when the frame is routed.
 :: AF formula :: AFxy: DSCP = 8 x x + 2 x y. (x = class 1-4, y = drop 1-3). AF31 = 26, AF32 = 28, AF33 = 30.
 :: Names :: CS0 = 0 (default), CS1 = 8, CS2 = 16, CS3 = 24, CS4 = 32, CS5 = 40, CS6 = 48, CS7 = 56, EF = 46
 :: AF values :: AF11 10, AF12 12, AF13 14. AF21 18, AF22 20, AF23 22. AF31 26, AF32 28, AF33 30. AF41 34, AF42 36, AF43 38.
 :: Typical use :: EF voice. AF41 interactive video. CS3 or AF31 call signaling. CS6 routing protocols. CS1 scavenger (less than best effort). 0 best effort.
 :: Typical CoS :: 5 voice, 4 video, 3 signaling, 0 default (the common pairing)
'@
        }
        @{
            Title  = 'TRUST BOUNDARY (on a switch)'
            Rows   = @'
Switch(config)# :: mls qos :: Older Catalyst: turns QoS on (with it off, all marks are cleared)
Switch(config-if)# :: mls qos trust dscp :: Older Catalyst: trust the DSCP of incoming packets (or: trust cos)
Switch(config-if)# :: mls qos trust device cisco-phone :: Trust only if a Cisco phone is found (by CDP)
Switch(config-if)# :: switchport priority extend cos 0 :: What the phone does with frames from the PC behind it
Switch# :: show mls qos interface g1/0/1 :: Trust state of a port
 :: Newer switches :: Catalyst 9000 with IOS XE uses MQC policies (class-map, policy-map, service-policy) for trust and marking. Check your model and release.
 :: Rule :: Trust what you control (phones, uplinks). For untrusted hosts, re-mark everything at the port.
'@
        }
        @{
            Title  = 'MQC: CLASSIFY'
            Rows   = @'
class-map match-any VOICE :: A class (match-any: one match is enough; match-all: all must match)
Router(config-cmap)# :: match dscp ef :: Match on DSCP
Router(config-cmap)# :: match ip dscp af31 cs3 :: Several values at once
Router(config-cmap)# :: match access-group name RTP-ACL :: Match an ACL
Router(config-cmap)# :: match protocol http :: Match with NBAR (the router looks inside the packets to know the application)
Router(config-cmap)# :: match not protocol bittorrent :: "not" inverts a match
Router(config-cmap)# :: match class-map OTHER-CLASS :: Nest another class
Router(config-if)# :: ip nbar protocol-discovery :: Collects statistics of which applications use the interface
Router# :: show ip nbar protocol-discovery :: The application list with byte counts
Router# :: show class-map :: All classes
Note: NBAR protocol packs differ between releases. Use "match protocol ?" to see what your device knows.
'@
        }
        @{
            Title  = 'MQC: ACT (the policy)'
            Rows   = @'
policy-map WAN-OUT :: A policy...
Router(config-pmap)# :: class VOICE :: ...with a class...
Router(config-pmap-c)# :: priority percent 10 :: ...strict priority queue (LLQ), with a built-in policer at 10%
Router(config-pmap-c)# :: priority 1000 :: ...or in kb/s
Router(config-pmap)# :: class VIDEO :: Another class
Router(config-pmap-c)# :: bandwidth percent 30 :: Guaranteed 30% when the link is full (CBWFQ)
Router(config-pmap-c)# :: bandwidth remaining percent 20 :: Or: share of what is left after priority
Router(config-pmap-c)# :: random-detect dscp-based :: Early drop by DSCP (WRED) to avoid tail drop
Router(config-pmap-c)# :: queue-limit 64 packets :: Queue depth
Router(config-pmap-c)# :: set dscp af31 :: Mark (also: set cos, set precedence)
Router(config-pmap)# :: class class-default :: Everything else
Router(config-pmap-c)# :: fair-queue :: Flow-based fair queuing for the rest
Router(config-if)# :: service-policy output WAN-OUT :: Applies it to an interface (output for queuing and shaping)
Router(config-if)# :: service-policy input MARK-IN :: Input is for marking and policing
Router# :: show policy-map interface g0/1 :: Packets, drops, and rates per class: the most useful QoS command
'@
        }
        @{
            Title  = 'POLICING AND SHAPING'
            Rows   = @'
Router(config-pmap-c)# :: police cir 1000000 :: Policing: limits to 1 Mb/s
Router(config-pmap-c-police)# :: conform-action transmit :: ...in profile: send
Router(config-pmap-c-police)# :: exceed-action drop :: ...above: drop (or: set-dscp-transmit af32 to re-mark)
Router(config-pmap-c)# :: shape average 10000000 :: Shaping: smooths to 10 Mb/s by queuing the extra (output only)
Router(config-pmap-c)# :: shape average percent 50 :: Or as a percent of the link
 :: Police vs shape :: Policing drops (or re-marks) the excess: no delay, jagged traffic, works in and out. Shaping buffers the excess: adds delay, smooth traffic, output only.
 :: Token bucket :: Bc (committed burst) is the bucket size. CIR is the fill rate. Tc = Bc / CIR is the time interval. A packet passes when enough tokens are there.
 :: Hierarchical :: Parent policy shapes to the rate of the circuit, and the child policy (service-policy in the class-default) queues inside it.
'@
        }
        @{
            Title  = 'HIERARCHICAL POLICY AND TUNNELS'
            Rows   = @'
policy-map PARENT :: The parent...
Router(config-pmap)# :: class class-default :: ...has only class-default...
Router(config-pmap-c)# :: shape average 50000000 :: ...shapes to the circuit rate...
Router(config-pmap-c)# :: service-policy WAN-OUT :: ...and the child policy queues inside it
Router(config-if)# :: service-policy output PARENT :: Applies the parent
Router(config-if)# :: qos pre-classify :: On a tunnel: classify on the inner packet (the original headers) before they are encrypted or encapsulated
 :: Tunnels :: The outer header gets a copy of the DSCP by default (GRE), so the WAN sees the mark. Without pre-classify, you can only match what is visible on the outer header.
 :: Overhead :: Shape to a bit less than the link rate, and allow for tunnel and IPsec overhead in the budget.
'@
        }
        @{
            Title  = 'CHECK AND TROUBLESHOOT'
            Rows   = @'
Router# :: show policy-map interface g0/1 output :: Per class: matched, dropped, queued, and rates
Router# :: show policy-map :: The policy as typed
Router# :: show interfaces g0/1 :: Queuing strategy and drops
Router# :: show queueing interface g0/1 :: The queue state (on platforms that support it)
 :: No matches :: The class-map type (match-any or match-all) is wrong, the ACL is wrong, or the packets are marked after the policy.
 :: Drops in the priority class :: The built-in policer is working: the voice traffic is above its rate.
 :: Marks vanish :: Look for a device that re-marks to 0 or does not trust the mark (a provider edge, a switch with QoS off).
'@
        }
    )
}
