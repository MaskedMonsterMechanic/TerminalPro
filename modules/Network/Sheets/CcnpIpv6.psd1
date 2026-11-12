@{
    Command  = 'Show-CcnpIpv6'
    Alias    = 'ccnpipv6'
    Synopsis = 'IPv6 addressing: types, prefixes, global addresses, multicast, neighbor discovery, migration'
    Group    = 'CCNP'
    Order    = 250
    Index    = 'Show-NetCommands'
    Title    = 'CCNP - IPv6 ADDRESSING AND NEIGHBOR DISCOVERY'

    Sections = @(
        @{
            Title  = 'WRITING AN ADDRESS'
            Rows   = @'
Full :: 2001:0db8:0000:0000:0000:ff00:0042:8329 (eight groups of four hex digits)
Rule 1 :: Leave out leading zeros in each group: 2001:db8:0:0:0:ff00:42:8329
 :: Rule 2 :: Replace ONE run of all-zero groups with a double colon (only once, or it is unclear how many were removed): 2001:db8::ff00:42:8329
Prefix :: The same as IPv4 /n: 2001:db8:acad::/48 is the first 48 bits.
Note: the tools do this for you: netcalc6 2001:db8:0:0:0:ff00:42:8329/64
'@
        }
        @{
            Title  = 'ADDRESS TYPES AND RANGES'
            Rows   = @'
::/128 :: The unspecified address (a host that has no address yet)
::1/128 :: Loopback (like 127.0.0.1)
::/0 :: The default route
2000::/3 :: Global unicast: the public addresses (what is handed out now starts with 2 or 3)
fc00::/7 :: Unique local (ULA): private addresses, in practice fd00::/8 with a random 40-bit part
fe80::/10 :: Link-local: only valid on one link. Every IPv6 interface has one. Used by neighbor discovery and as next hop in routes.
ff00::/8 :: Multicast (IPv6 has NO broadcast)
2001:db8::/32 :: Reserved for documentation and examples
Note: there is also anycast: the same address on several devices, and the packet goes to the nearest. It looks like a normal unicast address.
'@
        }
        @{
            Title  = 'MULTICAST ADDRESSES TO KNOW'
            Rows   = @'
ff02::1 :: All nodes on the link (the nearest to a broadcast)
ff02::2 :: All routers on the link
ff02::5 :: All OSPFv3 routers
ff02::6 :: OSPFv3 designated routers
ff02::9 :: All RIPng routers
ff02::a :: All EIGRP routers
ff02::1:ffXX:XXXX :: Solicited-node address: ff02::1:ff + the last 24 bits of the unicast address. Used to look up a neighbor's MAC address.
ff02 :: The "02" means link-local scope. "ff05" would be site scope, and "ff0e" global.
Note: the solicited-node address is worked out for you by: netcalc6 2001:db8::1:2828:9c5a
'@
        }
        @{
            Title  = 'THE STRUCTURE OF A GLOBAL ADDRESS'
            Rows   = @'
 :: Global routing prefix :: Given to you by the provider (often /48 for a site, or /56 for a small site).
 :: Subnet ID :: Your own part: with a /48, 16 bits give 65,536 subnets.
 :: Interface ID :: The last 64 bits. Almost every subnet is a /64.
Example :: 2001:db8:acad::/48 gives subnets 2001:db8:acad:0::/64, 2001:db8:acad:1::/64 ... 2001:db8:acad:ffff::/64
Note: the full table: netsubt -IPv6
Note: do not use anything longer than /64 for a normal LAN: SLAAC needs a /64.
'@
        }
        @{
            Title  = 'HOW A HOST GETS AN ADDRESS'
            Rows   = @'
 :: Static :: You type it.
 :: SLAAC :: The router advertisement gives the prefix, and the host builds the interface ID itself (EUI-64 from the MAC address, or random for privacy).
 :: EUI-64 :: Split the MAC in half, put FFFE in the middle, and flip the 7th bit of the first byte. Tool: neteui 00:1A:2B:3C:4D:5E
 :: Stateless DHCPv6 :: SLAAC for the address, DHCPv6 for DNS and other settings (the O flag).
 :: Stateful DHCPv6 :: DHCPv6 gives the address (the M flag).
Note: the configuration is on the DHCP page: netdhcp
'@
        }
        @{
            Title  = 'NEIGHBOR DISCOVERY (NDP): ICMPv6 DOES THE JOB OF ARP AND MORE'
            Rows   = @'
 :: Router Solicitation (RS, ICMPv6 type 133) :: A host asks "any routers here?" (to ff02::2)
 :: Router Advertisement (RA, type 134) :: A router says "I am a router, here is the prefix, the flags and the lifetime" (to ff02::1)
 :: Neighbor Solicitation (NS, type 135) :: "Who has this address? Tell me your MAC." (to the solicited-node address). Also used to check if an address is in use.
 :: Neighbor Advertisement (NA, type 136) :: The answer with the MAC address.
 :: Redirect (type 137) :: A router tells a host about a better first hop.
 :: DAD :: Duplicate Address Detection: before using an address, the host sends an NS for its OWN address. An answer means the address is taken.
Note: do not block ICMPv6 completely. A firewall or ACL that does, breaks IPv6.
'@
        }
        @{
            Title  = 'IPv6 HEADER VS IPv4 HEADER'
            Rows   = @'
 :: Size :: Fixed 40 bytes. IPv4: 20 bytes and up, with options.
 :: Removed :: Header checksum, fragmentation fields (routers do not fragment), header length, options.
 :: Added :: Flow label, and next header (it points to extension headers, or TCP/UDP).
 :: Renamed :: TTL is now hop limit. Protocol is now next header. Type of service is now traffic class.
 :: Fragmentation :: Only the sender fragments. Path MTU discovery is a must. The minimum MTU is 1280 bytes.
'@
        }
        @{
            Title  = 'ROUTER COMMANDS'
            Prompt = 'Router(config)#'
            Rows   = @'
ipv6 unicast-routing :: Turn on IPv6 routing (also makes the router send RAs)
interface g0/0 :: Goes to the interface
Router(config-if)# :: ipv6 address 2001:db8:acad:1::1/64 :: A global address
Router(config-if)# :: ipv6 address fe80::1 link-local :: A link-local address you can read
Router(config-if)# :: ipv6 address 2001:db8:acad:1::/64 eui-64 :: The prefix, and the interface ID from the MAC address
Router(config-if)# :: ipv6 enable :: A link-local address only, no global address
Router(config-if)# :: ipv6 nd ra suppress all :: Stops router advertisements on this interface (older IOS: ipv6 nd suppress-ra)
Router# :: show ipv6 interface brief :: Addresses and state
Router# :: show ipv6 neighbors :: The neighbor table
Router# :: show ipv6 interface g0/0 :: Joined multicast groups, ND settings, and the flags
Router# :: ping 2001:db8:acad:1::2 :: Ping
Router# :: ping fe80::2 :: A link-local address needs the interface: you are asked for it
'@
        }
        @{
            Title  = 'MOVING FROM IPv4 TO IPv6'
            Rows   = @'
 :: Dual stack :: Run IPv4 and IPv6 side by side. The simplest and the best, when you can.
 :: Tunnels :: IPv6 inside IPv4 (manual tunnels, GRE, ISATAP) to cross a network that is IPv4 only.
 :: Translation :: NAT64 with DNS64 lets IPv6-only hosts reach IPv4 servers.
 :: Old :: 6to4 and Teredo are deprecated. Do not use them for new designs.
'@
        }
    )
}
