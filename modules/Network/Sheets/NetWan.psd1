@{
    Command  = 'Show-NetWan'
    Alias    = 'netwan'
    Synopsis = 'WAN: link types, PPP, GRE tunnel, terms'
    Group    = 'THEORY'
    Order    = 83
    Index    = 'Show-NetCommands'
    Title    = 'NETWORK MODULE - WAN BASICS'
    Prompt   = 'Router(config)#'

    Sections = @(
        @{
            Title  = 'WAN WORDS'
            Rows   = @'
 :: WAN :: A network between sites that is bought from a provider, because you cannot pull your own cable across a city
 :: CPE :: Customer premises equipment: the router or modem at your site
 :: Demarc :: The demarcation point: where the provider's responsibility stops and yours starts
 :: Local loop :: The link from your site to the provider's nearest office
 :: CO / POP :: The provider's central office or point of presence
 :: DCE / DTE :: On a serial link the DCE end (the provider side) sets the clock; the DTE end (yours) follows it
 :: CSU/DSU :: Device between a router and a leased line (often built into the router card)
 :: PE / CE :: Provider edge and customer edge routers (the terms in MPLS)
'@
        }
        @{
            Title  = 'KINDS OF WAN CONNECTION'
            Rows   = @'
 :: Leased line :: A private point-to-point circuit (T1/E1 and up). Reliable, expensive, no sharing.
 :: Metro Ethernet :: Ethernet service across a city or country: simple, fast, and priced by speed.
 :: MPLS VPN :: The provider connects your sites with private routing. Supports QoS and many sites.
 :: Broadband (DSL, cable, fiber) :: Cheap and fast, shared, no guarantee. Use with a VPN.
 :: Cellular (4G/5G) :: Quick to set up, good as backup or for remote sites.
 :: Satellite :: Reaches places with nothing else, but with high delay.
 :: Internet VPN :: Encrypted tunnels over the internet: IPsec, DMVPN, or SD-WAN.
 :: Frame Relay / ATM :: Old technologies. You may meet them in old books and old networks.
'@
        }
        @{
            Title  = 'POINT-TO-POINT PROTOCOL (PPP) ON A SERIAL LINK'
            Rows   = @'
interface s0/0/0 :: Goes to the serial interface
Router(config-if)# :: encapsulation ppp :: Uses PPP instead of the default HDLC (both ends must match)
Router(config-if)# :: ppp authentication chap :: Asks the other end to prove who it is with CHAP (a password is not sent over the link)
Router(config)# :: username R2 password <shared-secret> :: The name of the OTHER router and a secret that is the same on both
Router(config-if)# :: ppp multilink :: Joins several links into one
Router(config-if)# :: ppp quality 80 :: Takes the link down if the quality falls below 80%
Router# :: show interfaces s0/0/0 :: "Encapsulation PPP" and "LCP Open" mean it works
Router# :: debug ppp authentication :: Shows the CHAP challenge and response (undebug all when done)
Note: each router's username is the HOSTNAME of the other one. A hostname mismatch is the most common mistake.
'@
        }
        @{
            Title  = 'GRE TUNNEL (a point-to-point link over any IP network)'
            Rows   = @'
interface tunnel 0 :: Creates the tunnel interface
Router(config-if)# :: ip address 172.16.0.1 255.255.255.252 :: The tunnel's own address (a private network of its own)
Router(config-if)# :: tunnel source g0/1 :: Where the tunnel starts: the local public interface
Router(config-if)# :: tunnel destination 198.51.100.2 :: Where it ends: the other router's public address
Router(config-if)# :: tunnel mode gre ip :: GRE over IPv4 (the default)
Router# :: show interfaces tunnel 0 :: Is the tunnel up/up?
Router(config)# :: ip route 192.168.2.0 255.255.255.0 172.16.0.2 :: Sends traffic for the remote LAN through the tunnel (or run a routing protocol over it)
Note: GRE does not encrypt. For privacy put IPsec on top of it.
Note: GRE adds 24 bytes to every packet. Set "ip mtu 1400" and "ip tcp adjust-mss 1360" on the tunnel to avoid fragmentation.
'@
        }
        @{
            Title  = 'CHECK THE WAN LINK'
            Rows   = @'
Router# :: show ip interface brief :: Up and up?
Router# :: show interfaces s0/0/0 :: Encapsulation, errors, and keepalives
Router# :: show controllers s0/0/0 :: DCE or DTE, and clock rate
Router# :: ping 172.16.0.2 :: Can I reach the other end of the link?
Router# :: show cdp neighbors :: Who is on the other end?
Note: serial down/down: check the cable and the other end. up/down: encapsulation or authentication mismatch, or no clock rate on the DCE end.
'@
        }
    )
}
