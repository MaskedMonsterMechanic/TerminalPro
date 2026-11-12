@{
    Command  = 'Show-NetStatic'
    Alias    = 'netsta'
    Synopsis = 'Static routes: default, summary, floating, IPv6, checking the table'
    Group    = 'ROUTER'
    Order    = 64
    Index    = 'Show-NetCommands'
    Title    = 'NETWORK MODULE - STATIC ROUTING'
    Prompt   = 'Router(config)#'

    Sections = @(
        @{
            Title  = 'THE THREE KINDS OF STATIC ROUTE'
            Rows   = @'
ip route 192.168.2.0 255.255.255.0 10.0.0.2 :: Next-hop route: "to reach 192.168.2.0/24, send to 10.0.0.2". The router looks up 10.0.0.2 too (recursive).
ip route 192.168.2.0 255.255.255.0 s0/0/0 :: Exit-interface route: fine on point-to-point links like serial. The router treats the network as directly connected.
ip route 192.168.2.0 255.255.255.0 g0/1 10.0.0.2 :: Fully specified: interface AND next hop. The right choice on Ethernet.
Note: an exit-interface route on Ethernet makes the router send an ARP for every destination, which wastes memory. Use the next hop.
'@
        }
        @{
            Title  = 'DEFAULT ROUTE (gateway of last resort)'
            Rows   = @'
ip route 0.0.0.0 0.0.0.0 203.0.113.1 :: Everything that no other route matches goes here
ip route 0.0.0.0 0.0.0.0 g0/1 :: The same through an exit interface
ipv6 route ::/0 2001:db8:ffff::1 :: The IPv6 default route
Router# :: show ip route :: The line says "Gateway of last resort is ..." and the route starts with S*
'@
        }
        @{
            Title  = 'IPV6 STATIC ROUTES'
            Rows   = @'
ipv6 unicast-routing :: Required first, or the router does not route IPv6
ipv6 route 2001:db8:acad:2::/64 2001:db8:acad:ff::2 :: Next hop route
ipv6 route 2001:db8:acad:2::/64 g0/1 fe80::2 :: Fully specified (REQUIRED when the next hop is a link-local address)
ipv6 route 2001:db8:acad:2::/64 s0/0/0 :: Exit-interface route
Router# :: show ipv6 route static :: Only the static IPv6 routes
'@
        }
        @{
            Title  = 'SUMMARY ROUTE (one route for several networks)'
            Rows   = @'
ip route 192.168.0.0 255.255.252.0 10.0.0.2 :: One route for 192.168.0.0 - 192.168.3.0 (four /24 networks)
ip route 10.0.0.0 255.0.0.0 null0 :: A route to nowhere: drops anything for the range that has no more specific route
Note: work out the summary with: netsum 192.168.0.0/24,192.168.1.0/24,192.168.2.0/24,192.168.3.0/24
'@
        }
        @{
            Title  = 'FLOATING STATIC ROUTE (a backup that only wakes up when needed)'
            Rows   = @'
ip route 0.0.0.0 0.0.0.0 203.0.113.1 :: The main default route (administrative distance 1)
ip route 0.0.0.0 0.0.0.0 198.51.100.1 5 :: The backup: the 5 at the end is a higher administrative distance, so it is not used until the main route disappears
Note: the backup number must be higher than the main route's distance. If the main one is learned from OSPF (110), give the backup 111 or more.
Note: a static route with an exit interface goes away when that interface goes down. A static route with ONLY a next hop does not, if the next hop can still be reached some other way.
Router# :: show ip route :: Only the best route is shown. Take down the main link to see the backup appear.
'@
        }
        @{
            Title  = 'ADMINISTRATIVE DISTANCE (lower wins when two sources know the same network)'
            Rows   = @'
 :: 0 :: Connected interface
 :: 1 :: Static route
 :: 5 :: EIGRP summary route
 :: 20 :: External BGP (eBGP)
 :: 90 :: EIGRP (internal)
 :: 110 :: OSPF
 :: 115 :: IS-IS
 :: 120 :: RIP
 :: 170 :: EIGRP (external)
 :: 200 :: Internal BGP (iBGP)
 :: 255 :: Unknown: never used
Note: the router first picks the longest matching prefix. The administrative distance only decides between routes with the SAME prefix length.
'@
        }
        @{
            Title  = 'READ THE ROUTING TABLE'
            Rows   = @'
Router# :: show ip route :: The whole table
Router# :: show ip route static :: Only static routes
Router# :: show ip route 192.168.2.0 :: Detail of one route: how it was learned, the distance, the next hop
Router# :: show ip route summary :: How many routes of each kind
Router# :: show running-config | include ip route :: The static routes as typed
Router# :: ping 192.168.2.1 source g0/0 :: Tests from the LAN side address (the other router needs a route BACK to it)
Router# :: traceroute 192.168.2.1 :: Shows each hop, and where it stops
Note: C = connected, L = the router's own address, S = static, S* = static default, O = OSPF, D = EIGRP, R = RIP, B = BGP, * = candidate default.
Note: [1/0] in a line is [administrative distance / metric].
'@
        }
        @{
            Title  = 'WHEN IT DOES NOT WORK'
            Rows   = @'
Note: 1. The packet needs a route THERE and a route BACK. A ping that fails with no reply is often the missing return route.
Note: 2. The next hop must be reachable: ping it from the router first.
Note: 3. A static route does not appear in the table if its exit interface is down, or the next hop has no route.
Note: 4. Typo in the mask? A /24 typed as 255.255.0.0 sends a lot more than you meant.
Note: 5. The longest match wins: a more specific route to the wrong place beats your correct, broader one.
Router# :: show ip interface brief :: Is the interface up and up?
Router# :: debug ip packet :: Last resort and dangerous on a busy router: use an ACL to limit it first
'@
        }
    )
}
