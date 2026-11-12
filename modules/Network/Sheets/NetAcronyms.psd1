@{
    Command  = 'Show-NetAcronyms'
    Alias    = 'netacro'
    Synopsis = 'Network acronyms explained, grouped by area (use -Filter to search)'
    Group    = 'THEORY'
    Order    = 85
    Index    = 'Show-NetCommands'
    Title    = 'NETWORK MODULE - ACRONYMS'

    Sections = @(
        @{
            Title  = 'ADDRESSING AND NAMES'
            Rows   = @'
IP :: Internet Protocol
IPv4 / IPv6 :: Internet Protocol version 4 (32-bit addresses) / version 6 (128-bit addresses)
MAC :: Media Access Control: the hardware address of a network card (48 bits)
CIDR :: Classless Inter-Domain Routing: addresses written with a prefix length, like /24
VLSM :: Variable Length Subnet Masking: subnets of different sizes inside one network
NAT :: Network Address Translation
PAT :: Port Address Translation (many hosts share one address by using different ports)
APIPA :: Automatic Private IP Addressing (169.254.0.0/16, when no DHCP server answers)
DHCP :: Dynamic Host Configuration Protocol
DNS :: Domain Name System
FQDN :: Fully Qualified Domain Name (server01.lab.example)
SLAAC :: Stateless Address Autoconfiguration (IPv6)
EUI-64 :: Extended Unique Identifier, 64 bits: a way to build an IPv6 interface ID from a MAC address
ARP :: Address Resolution Protocol (IPv4 address to MAC address)
NDP :: Neighbor Discovery Protocol (the IPv6 replacement for ARP, and more)
ULA :: Unique Local Address (IPv6 private addresses, fc00::/7)
GUA :: Global Unicast Address (IPv6 public addresses, 2000::/3)
'@
        }
        @{
            Title  = 'LAYER 2 AND SWITCHING'
            Rows   = @'
LAN :: Local Area Network
VLAN :: Virtual LAN
STP :: Spanning Tree Protocol (802.1D)
RSTP :: Rapid Spanning Tree Protocol (802.1w)
PVST+ :: Per-VLAN Spanning Tree Plus (Cisco)
BPDU :: Bridge Protocol Data Unit (the messages spanning tree sends)
DTP :: Dynamic Trunking Protocol (Cisco)
VTP :: VLAN Trunking Protocol (Cisco: spreads the VLAN list between switches)
LACP :: Link Aggregation Control Protocol (802.3ad / 802.1AX)
PAgP :: Port Aggregation Protocol (Cisco's own bundling protocol)
CDP :: Cisco Discovery Protocol
LLDP :: Link Layer Discovery Protocol (802.1AB): the standard version of CDP
SVI :: Switched Virtual Interface (the layer 3 interface of a VLAN)
PoE :: Power over Ethernet
CAM :: Content Addressable Memory (where the switch keeps the MAC table)
'@
        }
        @{
            Title  = 'ROUTING'
            Rows   = @'
RIP :: Routing Information Protocol (distance vector, hop count)
EIGRP :: Enhanced Interior Gateway Routing Protocol (Cisco, advanced distance vector)
OSPF :: Open Shortest Path First (link state)
IS-IS :: Intermediate System to Intermediate System (link state)
BGP :: Border Gateway Protocol (between autonomous systems: the protocol of the internet)
IGP / EGP :: Interior / Exterior Gateway Protocol
AS / ASN :: Autonomous System / its number
AD :: Administrative Distance (how much a router trusts a route source)
DUAL :: Diffusing Update Algorithm (EIGRP's way to find loop-free paths)
LSA / LSDB :: Link State Advertisement / Link State Database (OSPF)
DR / BDR :: Designated Router / Backup Designated Router (OSPF on multi-access networks)
SPF :: Shortest Path First (the algorithm in OSPF and IS-IS)
FIB :: Forwarding Information Base (the table the router actually forwards by)
RIB :: Routing Information Base (the routing table)
CEF :: Cisco Express Forwarding
HSRP / VRRP / GLBP :: First hop redundancy protocols: Hot Standby Router Protocol / Virtual Router Redundancy Protocol / Gateway Load Balancing Protocol
BFD :: Bidirectional Forwarding Detection (finds link failures fast)
'@
        }
        @{
            Title  = 'TRANSPORT AND APPLICATION PROTOCOLS'
            Rows   = @'
TCP :: Transmission Control Protocol (reliable, connection-oriented)
UDP :: User Datagram Protocol (fast, no guarantee)
ICMP :: Internet Control Message Protocol (ping, traceroute, error messages)
HTTP / HTTPS :: Hypertext Transfer Protocol / Secure
TLS :: Transport Layer Security (the successor of SSL)
SSH :: Secure Shell
SMTP / IMAP / POP3 :: Mail: send / read from the server / download
FTP / SFTP / TFTP :: File transfer: plain / over SSH / trivial (no login, over UDP)
SNMP :: Simple Network Management Protocol
NTP :: Network Time Protocol
SYSLOG :: The standard for sending log messages to a central server
LDAP :: Lightweight Directory Access Protocol
RADIUS / TACACS+ :: Login servers for network devices (AAA)
AAA :: Authentication, Authorization, Accounting
QoS :: Quality of Service
DSCP :: Differentiated Services Code Point (the QoS marking in the IP header)
MTU / MSS :: Maximum Transmission Unit / Maximum Segment Size
TTL :: Time to Live (a hop counter in an IP packet)
'@
        }
        @{
            Title  = 'WAN, VPN AND WIRELESS'
            Rows   = @'
WAN :: Wide Area Network
ISP :: Internet Service Provider
MPLS :: Multiprotocol Label Switching
VPN :: Virtual Private Network
IPsec :: Internet Protocol Security
GRE :: Generic Routing Encapsulation
DMVPN :: Dynamic Multipoint VPN (Cisco)
SD-WAN :: Software-Defined WAN
PPP :: Point-to-Point Protocol
PPPoE :: PPP over Ethernet (used by some DSL providers)
HDLC :: High-Level Data Link Control
CHAP / PAP :: Challenge Handshake Authentication Protocol / Password Authentication Protocol (CHAP is the safer)
DSL :: Digital Subscriber Line
CPE :: Customer Premises Equipment
SSID :: Service Set Identifier (the name of a Wi-Fi network)
WPA2 / WPA3 :: Wi-Fi Protected Access, versions 2 and 3
AP / WLC :: Access Point / Wireless LAN Controller
BSS / ESS :: Basic / Extended Service Set (one AP / several APs with the same SSID)
'@
        }
        @{
            Title  = 'SECURITY AND TROUBLESHOOTING'
            Rows   = @'
ACL :: Access Control List
DMZ :: Demilitarized Zone (a network between the inside and the internet for public servers)
IDS / IPS :: Intrusion Detection / Prevention System
NGFW :: Next-Generation Firewall
DoS / DDoS :: (Distributed) Denial of Service
MITM :: Man in the Middle
DAI :: Dynamic ARP Inspection
DHCP snooping :: A switch feature that only trusts DHCP answers from chosen ports
uRPF :: Unicast Reverse Path Forwarding (drops packets with a spoofed source address)
BYOD :: Bring Your Own Device
NMS :: Network Management System
CLI :: Command Line Interface
GUI :: Graphical User Interface
OID / MIB :: Object Identifier / Management Information Base (SNMP)
RTT :: Round-Trip Time (what ping measures)
SLA :: Service Level Agreement
'@
        }
    )
}
