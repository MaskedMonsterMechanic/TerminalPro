@{
    Command  = 'Show-CcieSdn'
    Alias    = 'cciesdn'
    Synopsis = 'Software-defined infrastructure: SD-Access and SD-WAN, the roles, the words and a few show commands'
    Group    = 'CCIE'
    Order    = 309
    Index    = 'Show-NetCommands'
    Title    = 'CCIE - SD-ACCESS AND SD-WAN: THE WORDS'

    Sections = @(
        @{
            Title  = 'READ THIS FIRST'
            Rows   = @'
 :: What this page is :: A list of the words and the roles, so the topics are easy to recognise. These two systems are learned in a lab or in Cisco's own documentation: there is little to type here.
 :: Names change :: Cisco renames the products. Cisco DNA Center is now called Catalyst Center. The SD-WAN parts have newer names too (see below). The old names are still common.
'@
        }
        @{
            Title  = 'SD-ACCESS: THE PARTS'
            Rows   = @'
 :: Catalyst Center (DNA Center) :: The controller: design, policy, automation and assurance for the campus.
 :: ISE (Identity Services Engine) :: Authentication and policy: it gives each user or device a group tag (SGT).
 :: Fabric :: The campus network built as an underlay plus an overlay.
 :: Underlay :: Plain routed IP between the switches. IS-IS is used when Catalyst Center builds it (LAN automation). It can also be built by hand.
 :: Overlay :: The virtual network on top: LISP for the control plane, VXLAN for the data plane.
 :: Edge node :: Connects hosts. Does the encapsulation (like an ITR/ETR).
 :: Border node :: Connects the fabric to the outside (internet, data centre, WAN). Can be an internal, external, or anywhere border.
 :: Control plane node :: The LISP map server and resolver: it knows which edge a host is behind.
 :: Intermediate node :: A normal Layer 3 switch between nodes in the underlay. Knows nothing about the overlay.
 :: Extended node :: A small switch connected to an edge node, to extend the ports.
 :: Fusion router :: A router (or firewall) that connects the fabric to shared services in the outside, and leaks the routes between VRFs.
 :: Fabric in a box :: One switch that is control plane, border and edge at once (a small site).
'@
        }
        @{
            Title  = 'SD-ACCESS: THE PROTOCOLS'
            Rows   = @'
 :: LISP :: Splits identity from location. EID is the host address. RLOC is the address of the edge (location). The map server keeps the mapping, and the edge asks the map resolver.
 :: VXLAN :: A tunnel over UDP (port 4789). A Layer 2 frame inside, with a 24-bit VNI (over 16 million segments). SD-Access also puts the SGT in the header (VXLAN-GPO).
 :: TrustSec :: Policy by SGT (Security Group Tag): who may talk to whom, in a matrix. It follows the user, not the IP address.
 :: VN (virtual network) :: Macro-segmentation: a separate VRF for a group (for example staff and guests). No traffic between them without a firewall.
 :: SGT :: Micro-segmentation: inside one VN, a policy between tag groups.
 :: Anycast gateway :: The same gateway address on every edge for a subnet, so hosts move without a change.
 :: Native multicast :: The underlay can replicate multicast (PIM), or the edge can use head-end replication.
'@
        }
        @{
            Title  = 'SD-WAN: THE PARTS'
            Rows   = @'
 :: SD-WAN Manager (vManage) :: The GUI and the API: configuration, monitoring, software.
 :: SD-WAN Controller (vSmart) :: The brain of the routing: it runs OMP with all the edges and applies the central policy.
 :: SD-WAN Validator (vBond) :: The first contact: it checks new devices, and tells them where the controllers are. Sits at a public address.
 :: WAN Edge (vEdge, cEdge) :: The router at each site. IOS XE SD-WAN routers are called cEdge.
 :: Overlay :: Management Protocol (OMP) between edges and controllers, and IPsec tunnels between edges.
 :: Zero-touch :: A new router finds the validator by itself (plug and play), and gets its configuration.
'@
        }
        @{
            Title  = 'SD-WAN: THE WORDS'
            Rows   = @'
 :: OMP :: Overlay Management Protocol. Carries OMP routes (prefixes), TLOC routes, and service routes. Runs inside a DTLS or TLS connection to the controllers.
 :: TLOC :: Transport Locator: the "address" of a tunnel end: system IP + color + encapsulation (ipsec or gre).
 :: Color :: A name for a type of transport (mpls, biz-internet, lte ...). Policy can choose by color.
 :: VPN 0 :: The transport side (the WAN). Control connections and tunnels start here.
 :: VPN 512 :: Out-of-band management.
 :: Other VPNs :: Service-side VPNs: the sites' own networks (a VPN here is like a VRF).
 :: BFD :: Runs inside the tunnels, and measures loss, latency and jitter.
 :: Control policy :: Changes the routes and TLOCs the controller sends (for example hub-and-spoke or a custom topology).
 :: Data policy :: Acts on the packets: pick a path, mark, or send to a firewall.
 :: App-aware routing :: A policy with an SLA class (loss, latency and jitter limits). Traffic uses a tunnel that meets it, and moves when the path gets worse.
 :: Template :: Device or feature template: one definition pushed to many routers.
'@
        }
        @{
            Title  = 'A FEW SHOW COMMANDS'
            Rows   = @'
Router# :: show sdwan control connections :: Connections to the controllers (state should be "up")
Router# :: show sdwan omp routes :: The routes learned by OMP
Router# :: show sdwan omp tlocs :: The tunnel endpoints
Router# :: show sdwan bfd sessions :: The tunnels to other sites, with loss, latency and jitter
Router# :: show sdwan running-config :: The configuration pushed from the manager
Switch# :: show lisp session :: SD-Access: LISP sessions (the exact command depends on the release)
Switch# :: show cts role-based permissions :: SD-Access: the SGT policy matrix
Note: on older SD-WAN software the "sdwan" word is missing: show control connections, show omp routes. Check with ?.
'@
        }
    )
}
