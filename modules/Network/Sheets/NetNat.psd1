@{
    Command  = 'Show-NetNat'
    Alias    = 'netnt'
    Synopsis = 'NAT: static, dynamic pool, PAT (overload), port forwarding'
    Group    = 'ROUTER'
    Order    = 63
    Index    = 'Show-NetCommands'
    Title    = 'NETWORK MODULE - NETWORK ADDRESS TRANSLATION (NAT)'
    Prompt   = 'Router(config)#'

    Sections = @(
        @{
            Title  = 'THE FOUR NAMES (the part that confuses everybody)'
            Rows   = @'
 :: Inside local :: The address of an inside host as the inside network sees it (for example 192.168.10.10)
 :: Inside global :: The address of that same host as the outside world sees it (for example 203.0.113.10)
 :: Outside global :: The address of an outside host as the outside world sees it (for example a web server, 198.51.100.80)
 :: Outside local :: The address of that outside host as the inside network sees it (usually the same as outside global)
Note: "inside" and "outside" is about where the HOST is. "local" and "global" is about who is looking.
Note: the router keeps a table of the translations. A NAT table entry for PAT also holds the port numbers.
'@
        }
        @{
            Title  = 'FIRST, TELL THE ROUTER WHICH SIDE IS WHICH (needed for all kinds)'
            Rows   = @'
interface g0/0 :: The interface towards the private LAN
Router(config-if)# :: ip nat inside :: This interface is the inside
interface g0/1 :: The interface towards the ISP
Router(config-if)# :: ip nat outside :: This interface is the outside
Router(config)# :: ip route 0.0.0.0 0.0.0.0 203.0.113.1 :: Needed: a way out. The ISP needs a route back to your public addresses.
'@
        }
        @{
            Title  = 'STATIC NAT (one inside host, one public address)'
            Rows   = @'
ip nat inside source static 192.168.10.10 203.0.113.10 :: Every packet from .10 leaves as 203.0.113.10, and the other way round
Router# :: show ip nat translations :: Shows the entry: it is there at once, it never times out
Note: use this for a server that outside users must reach.
'@
        }
        @{
            Title  = 'STATIC NAT WITH PORT FORWARDING'
            Rows   = @'
ip nat inside source static tcp 192.168.10.10 443 203.0.113.1 443 :: Traffic to 203.0.113.1:443 goes to the inside host on port 443
ip nat inside source static tcp 192.168.10.11 22 203.0.113.1 2222 :: Port 2222 on the outside goes to port 22 on another host
ip nat inside source static udp 192.168.10.12 51820 interface g0/1 51820 :: Port forwarding on the router's own outside address
Note: this is "port forwarding" like on a home router.
'@
        }
        @{
            Title  = 'DYNAMIC NAT (a pool of public addresses)'
            Rows   = @'
ip access-list standard NAT-LAN :: The list of inside addresses that may be translated
Router(config-std-nacl)# :: permit 192.168.10.0 0.0.0.255 :: The inside network (wildcard mask, not subnet mask)
ip nat pool PUBLIC 203.0.113.10 203.0.113.14 netmask 255.255.255.248 :: The public addresses to use (netmask or prefix-length)
ip nat inside source list NAT-LAN pool PUBLIC :: Connects the list with the pool
Note: one inside host uses one pool address. When the pool is empty the next host has no connection. That is why PAT is used almost everywhere.
Note: entries time out (24 hours by default). Change with: ip nat translation timeout <seconds>
'@
        }
        @{
            Title  = 'PAT / NAT OVERLOAD (many inside hosts, one public address)'
            Rows   = @'
ip access-list standard NAT-LAN :: The inside addresses that may be translated
Router(config-std-nacl)# :: permit 192.168.10.0 0.0.0.255 :: The inside network
ip nat inside source list NAT-LAN interface g0/1 overload :: Uses the outside interface's address: the usual choice
ip nat inside source list NAT-LAN pool PUBLIC overload :: Or use a pool and let the hosts share the addresses
Note: PAT keeps the connections apart with the port numbers, so one address can serve tens of thousands of connections.
Note: the ACL for NAT only says WHICH addresses are translated. It does not block anything.
'@
        }
        @{
            Title  = 'CHECK AND TROUBLESHOOT NAT'
            Rows   = @'
Router# :: show ip nat translations :: The table: inside local, inside global, outside local, outside global
Router# :: show ip nat translations verbose :: With times and flags
Router# :: show ip nat statistics :: Counters, hits and misses, and which interfaces are inside and outside
Router# :: clear ip nat translation * :: Empties the table (do this when you change the rules)
Router# :: debug ip nat :: Shows each translation as it happens (turn off with: undebug all)
Router# :: show access-lists :: Check the ACL for NAT and its match counters
Router# :: show running-config | include ip nat :: All the NAT lines in the configuration
Note: no translations at all? Check inside and outside on the interfaces, the ACL wildcard, and the default route.
Note: translation but no answer? Check that the ISP has a route back, and that the DNS server is reachable.
'@
        }
        @{
            Title  = 'IPV6 AND NAT'
            Rows   = @'
Note: IPv6 has so many addresses that NAT is not needed to save addresses.
Note: special cases like NAT64 (IPv6 hosts talking to IPv4 servers) and NPTv6 (swapping a prefix) exist, but they are not part of everyday setup.
'@
        }
    )
}
