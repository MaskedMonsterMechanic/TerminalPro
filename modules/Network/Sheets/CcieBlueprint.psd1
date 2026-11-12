@{
    Command  = 'Show-CcieBlueprint'
    Alias    = 'ccie'
    Synopsis = 'CCIE Enterprise Infrastructure: the exam in short, the five domains, and where each is covered here'
    Group    = 'CCIE'
    Order    = 300
    Index    = 'Show-NetCommands'
    Title    = 'CCIE - ENTERPRISE INFRASTRUCTURE: THE MAP'

    Sections = @(
        @{
            Title  = 'THE EXAM'
            Rows   = @'
 :: Name :: CCIE Enterprise Infrastructure (lab exam). Version 1.1 when this page was written.
 :: Format :: An eight-hour, hands-on lab. You plan, build, fix and tune dual-stack (IPv4 and IPv6) networks.
 :: Automation :: Cisco says you are expected to program and automate during the lab. It is part of the whole exam, not just its own block.
 :: Written exam :: ENCOR (350-401) is the written exam that comes first (also the core exam for CCNP Enterprise).
 :: Where it is official :: The topic list is on the Cisco Learning Network (CCIE Enterprise Infrastructure exam topics). It changes with each version: check it before you plan.
'@
        }
        @{
            Title  = 'THE FIVE DOMAINS (weights from the v1.1 blueprint)'
            Rows   = @'
 :: 1. Network Infrastructure :: 30%. Switching (STP, EtherChannel, VLANs), routing concepts, EIGRP, OSPF, BGP, multicast.
 :: 2. Software-Defined Infrastructure :: 25%. Cisco SD-Access and Cisco SD-WAN.
 :: 3. Transport Technologies and Solutions :: 15%. MPLS Layer 3 VPN and DMVPN (and static GRE tunnels).
 :: 4. Infrastructure Security and Services :: 15%. Device and network security, system management, QoS, IP services.
 :: 5. Automation and Programmability :: 15%. Python, data models (YANG), NETCONF/RESTCONF, EEM, telemetry.
'@
        }
        @{
            Title  = 'WHERE TO LOOK IN THIS MODULE'
            Rows   = @'
 :: ccieswitch :: Switched campus: errdisable, UDLD, VLANs, trunks, EtherChannel, spanning tree.
 :: ccierouting :: Administrative distance, PBR, VRF-Lite and route leaking, MTU.
 :: ccieospf :: OSPF in depth: LSA types, area types, filtering, LFA, OSPFv3 address families.
 :: ccieeigrp :: EIGRP in depth: stub, summarization, unequal cost, authentication, named mode.
 :: cciebgp :: BGP policy: communities, conditional advertisement, AS path tricks, route reflectors.
 :: cciemcast :: Multicast: IGMP, PIM sparse mode, RP methods, SSM, MSDP.
 :: ccieswsec :: Switch and IPv6 first-hop security, CoPP, management and logging.
 :: ccieqos :: QoS: DSCP, MQC, policing, shaping, queuing.
 :: cciesdn :: SD-Access and SD-WAN: the words and the roles.
 :: ccieauto :: NETCONF, RESTCONF, YANG, Python, Jinja2, EEM, telemetry.
 :: ccnpvpn :: MPLS, GRE and DMVPN basics (the CCNP page covers the groundwork).
 :: ccnpsec, ccnpipv6 :: Router security and IPv6 groundwork.
Note: the calculators help in the lab too: netcalc, netvlsm, netsum, ccnpmetric (EIGRP), ccnacost (OSPF).
'@
        }
        @{
            Title  = 'HOW TO USE THESE PAGES'
            Rows   = @'
 :: Quick lookup :: These pages are a memory aid for syntax and facts. They do not replace building the topics in a lab.
 :: Syntax differs :: IOS XE versions and platforms differ. Where I am less sure, the page says so. Always check with ? and the documentation for your version.
 :: Search all pages :: Find-CheatSheet <word> (for example: Find-CheatSheet udld)
'@
        }
    )
}
