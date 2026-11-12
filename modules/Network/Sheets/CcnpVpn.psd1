@{
    Command  = 'Show-CcnpVpn'
    Alias    = 'ccnpvpn'
    Synopsis = 'Remote connectivity: MPLS VPN, GRE, DMVPN, IPsec, PPP, MTU and MSS'
    Group    = 'CCNP'
    Order    = 260
    Index    = 'Show-NetCommands'
    Title    = 'CCNP - REMOTE CONNECTIVITY: MPLS, GRE, DMVPN, IPsec'
    Prompt   = 'Router(config)#'

    Sections = @(
        @{
            Title  = 'THREE KINDS OF VPN'
            Rows   = @'
 :: MPLS-based :: The provider keeps each customer's traffic apart with labels. You do not see the labels. Layer 3 (the provider routes for you) or layer 2 (the provider acts like a big switch).
 :: Tunnel-based :: You build the tunnels yourself over the internet: GRE, IPsec, DMVPN. Cheap and flexible. Quality depends on the internet.
 :: Hybrid :: A mix, for example MPLS in the main sites and a tunnel over the internet for small branches or as backup.
'@
        }
        @{
            Title  = 'MPLS VPN WORDS'
            Rows   = @'
 :: Label :: A short tag put in front of the packet. Routers forward by label, not by looking up the address.
 :: LDP :: Label Distribution Protocol: the routers hand out labels to each other.
 :: CE :: Customer edge router (yours). PE: provider edge router. P: provider core router (only knows labels).
 :: VRF :: A separate routing table on the PE for each customer. Many customers can use the same addresses.
 :: RD :: Route distinguisher: a number added to a customer route to make it unique (65001:100).
 :: RT :: Route target: a tag that says which VRFs may import the route.
 :: MP-BGP :: The PE routers carry the customer routes between them with BGP.
 :: Layer 3 :: The CE and PE exchange routes (static, OSPF, EIGRP or BGP). The provider routes your traffic.
 :: Layer 2 :: Ethernet service (VPLS, E-Line): the sites look like they are on one switch or one cable. YOU run the routing between the sites. OSPF then needs the right network type.
'@
        }
        @{
            Title  = 'MPLS AND VRF COMMANDS (provider side, to read configs)'
            Rows   = @'
mpls label protocol ldp :: Use LDP
interface g0/0 :: A core-facing interface
Router(config-if)# :: mpls ip :: Turns MPLS on for the interface
vrf definition CUSTOMER-A :: Creates a VRF
Router(config-vrf)# :: rd 65001:100 :: The route distinguisher
Router(config-vrf)# :: address-family ipv4 :: IPv4 settings of the VRF
Router(config-vrf-af)# :: route-target both 65001:100 :: Export and import routes with this tag
interface g0/1 :: The interface towards the customer
Router(config-if)# :: vrf forwarding CUSTOMER-A :: Puts the interface in the VRF (set it BEFORE the IP address, or the address is removed)
Router# :: show mpls ldp neighbor :: LDP neighbors
Router# :: show mpls forwarding-table :: The label table
Router# :: show ip route vrf CUSTOMER-A :: The routes of one customer
Router# :: show ip vrf :: The VRFs
Note: on a CE router a Layer 3 MPLS VPN just looks like an ordinary router next to you.
'@
        }
        @{
            Title  = 'GRE TUNNEL'
            Rows   = @'
interface tunnel 0 :: Creates the tunnel
Router(config-if)# :: ip address 172.16.0.1 255.255.255.252 :: The tunnel's own address
Router(config-if)# :: tunnel source g0/1 :: The local end (an interface or an address)
Router(config-if)# :: tunnel destination 198.51.100.2 :: The far end
Router(config-if)# :: ip mtu 1400 :: Leave room for the 24 bytes GRE adds
Router(config-if)# :: ip tcp adjust-mss 1360 :: Makes TCP use smaller segments, so they fit
Router# :: show interfaces tunnel 0 :: Up/up?
Note: GRE can carry routing protocols and multicast, which plain IPsec cannot. GRE does not encrypt: combine it with IPsec.
Note: a tunnel that goes up but then flaps, with a routing protocol on it: look for recursive routing (the route to the tunnel destination learned through the tunnel itself).
'@
        }
        @{
            Title  = 'DMVPN (many sites, tunnels made when needed)'
            Rows   = @'
 :: mGRE :: One tunnel interface that can reach many destinations (multipoint GRE), instead of one tunnel per site.
 :: NHRP :: Next Hop Resolution Protocol: works like ARP for the tunnel. Spokes tell the hub their real address, and ask it for other spokes' addresses.
 :: Hub :: The central router with a fixed public address. NHS = next hop server.
 :: Spoke :: A branch router. It registers with the hub, and can build a direct tunnel to another spoke.
 :: Phase 1 :: Spokes talk only to the hub (hub and spoke).
 :: Phase 2 :: Direct spoke-to-spoke tunnels. Needs the original next hop kept in the routes.
 :: Phase 3 :: The hub sends a redirect, spokes make shortcuts. Works with summarized routes: the best choice.
interface tunnel 0 :: The HUB
Router(config-if)# :: ip address 172.16.0.1 255.255.255.0 :: One network for the whole DMVPN
Router(config-if)# :: tunnel source g0/1 :: The public side
Router(config-if)# :: tunnel mode gre multipoint :: Multipoint GRE
Router(config-if)# :: ip nhrp network-id 1 :: Identifies this DMVPN cloud
Router(config-if)# :: ip nhrp authentication KEY :: A short password (8 characters at most)
Router(config-if)# :: ip nhrp map multicast dynamic :: Sends multicast (routing protocol hellos) to every spoke that registers
Router(config-if)# :: ip nhrp redirect :: Phase 3: tells the spokes about a better path
interface tunnel 0 :: A SPOKE
Router(config-if)# :: ip address 172.16.0.2 255.255.255.0 :: Its address in the same network
Router(config-if)# :: tunnel mode gre multipoint :: Multipoint GRE
Router(config-if)# :: ip nhrp network-id 1 :: The same as the hub
Router(config-if)# :: ip nhrp authentication KEY :: The same as the hub
Router(config-if)# :: ip nhrp nhs 172.16.0.1 :: The hub's tunnel address
Router(config-if)# :: ip nhrp map 172.16.0.1 203.0.113.1 :: And its public address
Router(config-if)# :: ip nhrp map multicast 203.0.113.1 :: Sends multicast to the hub
Router(config-if)# :: ip nhrp shortcut :: Phase 3: accepts the shortcut
Router# :: show dmvpn :: The peers and the state (UP, NHRP)
Router# :: show ip nhrp :: The NHRP table
'@
        }
        @{
            Title  = 'IPsec (encryption)'
            Rows   = @'
 :: IKE phase 1 :: The two routers prove who they are and set up a protected channel (ISAKMP security association).
 :: IKE phase 2 :: Inside that channel they agree on the IPsec keys and settings (IPsec security association).
 :: ESP :: Encrypts and authenticates the data. This is what is normally used. IP protocol 50.
 :: AH :: Only authenticates, no encryption. IP protocol 51. Does not work through NAT.
 :: Tunnel mode :: The whole original packet is protected and gets a new IP header (site to site).
 :: Transport mode :: Only the data is protected (used with GRE, or host to host).
 :: NAT-T :: IPsec inside UDP 4500, so it works through NAT. IKE uses UDP 500.
crypto isakmp policy 10 :: Phase 1 settings
Router(config-isakmp)# :: encryption aes 256 :: The cipher
Router(config-isakmp)# :: hash sha256 :: The hash
Router(config-isakmp)# :: authentication pre-share :: A shared secret
Router(config-isakmp)# :: group 14 :: The Diffie-Hellman group (14 or higher)
crypto isakmp key <secret> address 198.51.100.2 :: The secret for this peer
crypto ipsec transform-set TS esp-aes 256 esp-sha256-hmac :: Phase 2 settings
crypto ipsec profile PROF :: A profile for a tunnel interface
Router(ipsec-profile)# :: set transform-set TS :: Uses the transform set
interface tunnel 0 :: The GRE tunnel from above
Router(config-if)# :: tunnel protection ipsec profile PROF :: Encrypts the tunnel (GRE over IPsec: the usual way)
Router# :: show crypto isakmp sa :: Phase 1: should say QM_IDLE
Router# :: show crypto ipsec sa :: Phase 2: look at the encaps and decaps counters
Note: for a plain IPsec site-to-site tunnel without GRE use a crypto map (crypto map CMAP 10 ipsec-isakmp, set peer, set transform-set, match address <ACL>) on the outside interface.
Note: IKEv2 is the newer standard (crypto ikev2 proposal / policy / keyring / profile). The ideas are the same.
'@
        }
        @{
            Title  = 'PPP AUTHENTICATION AND PPPoE'
            Rows   = @'
 :: PAP :: The password is sent in clear text, once. Weak.
 :: CHAP :: A challenge and a hash. The password is never sent. The better one.
username R2 password <shared-secret> :: The OTHER router's host name and the shared secret
interface s0/0/0 :: Goes to the serial interface
Router(config-if)# :: encapsulation ppp :: Turns on PPP
Router(config-if)# :: ppp authentication chap :: Asks for CHAP (use "chap pap" to accept PAP as a fallback)
interface dialer 1 :: PPPoE: the dialer interface (for DSL providers)
Router(config-if)# :: encapsulation ppp :: PPP on it
Router(config-if)# :: ip address negotiated :: The address comes from the provider
Router(config-if)# :: dialer pool 1 :: Ties it to the physical interface
Router(config-if)# :: ppp chap hostname <login> :: The login the provider gave you
Router(config-if)# :: ppp chap password <password> :: And the password
interface g0/1 :: The Ethernet interface towards the DSL modem
Router(config-if)# :: pppoe enable :: Turns PPPoE on
Router(config-if)# :: pppoe-client dial-pool-number 1 :: Uses dialer pool 1
Router(config-if)# :: ip mtu 1492 :: PPPoE takes 8 bytes of the 1500
'@
        }
        @{
            Title  = 'MTU, MSS AND FRAGMENTATION (the cause of many "it connects but is slow" problems)'
            Rows   = @'
 :: MTU :: The largest IP packet an interface sends. Ethernet: 1500. A tunnel or PPPoE makes it smaller.
 :: MSS :: The largest TCP data in one segment. MSS = MTU - 40 (20 IP + 20 TCP). Normally 1460.
 :: PMTUD :: A sender sets the Don't Fragment bit. A router that cannot fit it drops the packet and sends ICMP type 3 code 4 ("fragmentation needed"). If a firewall blocks that ICMP, big packets silently disappear.
 :: Fix :: Lower the MTU on the tunnel (ip mtu 1400) and tell TCP with "ip tcp adjust-mss 1360".
 :: Bandwidth-delay product :: bandwidth x round-trip time = the amount of data "in flight". The TCP window must be at least that big to fill a fast, long link. (100 Mbps with 50 ms RTT is 625,000 bytes.)
 :: ICMP redirect :: A router tells a host "there is a better first hop for that". Switch it off on outside interfaces: no ip redirects.
Router# :: ping 192.0.2.1 size 1500 df-bit :: Tests whether a full-size packet gets through without fragmenting
PS> :: ping -f -l 1472 192.0.2.1 :: The same from Windows (1472 + 28 header bytes = 1500)
'@
        }
    )
}
