@{
    Command  = 'Show-CcnaAcl'
    Alias    = 'ccnaacl'
    Synopsis = 'Access lists: standard, extended, named, IPv6, VTY, verifying'
    Group    = 'CCNA'
    Order    = 102
    Index    = 'Show-NetCommands'
    Title    = 'CCNA - ACCESS CONTROL LISTS (ACLs)'
    Prompt   = 'Router(config)#'

    Sections = @(
        @{
            Title  = 'THE RULES'
            Rows   = @'
 :: Order :: The router reads the list from the top and stops at the first match.
 :: Implicit deny :: Every list ends with a hidden "deny all". A list with only deny lines blocks everything.
 :: New lines :: A line you add goes to the END of the list. To insert one, use a named list (or sequence numbers) and give the line a number.
 :: One list :: Per interface, per direction (in or out), per protocol (IPv4 or IPv6).
 :: Inbound :: Checked when the packet arrives, before routing. Outbound: checked after routing, before the packet leaves.
 :: Own traffic :: A list on an interface does not filter packets the router makes itself (its own pings, routing updates).
 :: Standard ACL :: Looks at the source address only. Place it close to the DESTINATION.
 :: Extended ACL :: Looks at source, destination, protocol and ports. Place it close to the SOURCE.
'@
        }
        @{
            Title  = 'NUMBERS'
            Rows   = @'
 :: 1 - 99 and 1300 - 1999 :: Standard IPv4 ACLs
 :: 100 - 199 and 2000 - 2699 :: Extended IPv4 ACLs
 :: Names :: Standard or extended, with any name. This is the better choice: lines can be edited and inserted.
'@
        }
        @{
            Title  = 'WILDCARD MASKS (the mask turned upside down: 0 = must match, 1 = ignore)'
            Rows   = @'
 :: 0.0.0.255 :: The whole /24: 192.168.10.0 0.0.0.255
 :: 0.0.0.15 :: A /28: 192.168.10.16 0.0.0.15
 :: 0.0.1.255 :: A /23: 192.168.10.0 0.0.1.255
 :: 0.0.0.0 :: Exactly one address. The short form is: host 192.168.10.10
 :: 255.255.255.255 :: Any address. The short form is: any
Note: 255 minus each octet of the subnet mask gives the wildcard. The tool does it for you: netmask 27 -Wildcard
'@
        }
        @{
            Title  = 'STANDARD ACL (numbered)'
            Rows   = @'
access-list 10 permit host 192.168.10.10 :: Allows that one host
access-list 10 permit 192.168.20.0 0.0.0.255 :: Allows the whole network
access-list 10 deny any log :: The same as the hidden last line, but visible and with a log message
access-list 10 remark Office networks :: A comment
interface g0/1 :: Goes to the interface
Router(config-if)# :: ip access-group 10 out :: Puts the list on the interface, in the outbound direction
Router(config)# :: no access-list 10 :: Deletes the WHOLE list
Note: first take it off the interface with "no ip access-group 10 out", then delete it.
'@
        }
        @{
            Title  = 'NAMED ACL (with sequence numbers)'
            Rows   = @'
ip access-list standard NO-PC11 :: Creates a named standard list and goes into it
Router(config-std-nacl)# :: deny host 192.168.11.10 :: Blocks one host
Router(config-std-nacl)# :: permit any :: Lets everyone else through (without this the implicit deny would block them)
interface g0/0 :: Goes to the interface
Router(config-if)# :: ip access-group NO-PC11 out :: Puts the list on it
ip access-list standard NO-PC11 :: Goes back into the list
Router(config-std-nacl)# :: 5 deny host 192.168.11.20 :: Inserts a line at the TOP (number 5, before 10 and 20)
Router(config-std-nacl)# :: no 10 :: Deletes line number 10 only
ip access-list resequence NO-PC11 10 10 :: Renumbers the lines: first line 10, then 20, 30 and so on
'@
        }
        @{
            Title  = 'EXTENDED ACL'
            Rows   = @'
ip access-list extended WEB-ONLY :: Creates the list
Router(config-ext-nacl)# :: permit tcp 192.168.10.0 0.0.0.255 any eq 80 :: Allows web (HTTP) from the network
Router(config-ext-nacl)# :: permit tcp 192.168.10.0 0.0.0.255 any eq 443 :: Allows HTTPS
Router(config-ext-nacl)# :: permit udp 192.168.10.0 0.0.0.255 host 192.0.2.53 eq 53 :: Allows DNS to one server
Router(config-ext-nacl)# :: permit icmp any any echo-reply :: Allows ping answers back in
Router(config-ext-nacl)# :: deny ip any any log :: Blocks and logs the rest
interface g0/0 :: The interface close to the source
Router(config-if)# :: ip access-group WEB-ONLY in :: Checks traffic coming from the LAN
Note: the pattern is: permit or deny, protocol (ip, tcp, udp, icmp), source, [source port], destination, [destination port].
Note: port tests: eq 80, neq 80, lt 1024, gt 1023, range 20 21. Ports can be names too (www, domain, 22 for ssh).
Note: "established" lets TCP replies in (the packet has the ACK or RST flag), a simple way to allow answers to your own connections.
'@
        }
        @{
            Title  = 'ACL ON THE VIRTUAL TERMINAL LINES (who may log in)'
            Rows   = @'
access-list 21 permit 192.168.10.0 0.0.0.255 :: Only the admin network may connect
line vty 0 15 :: Goes to the remote lines
Router(config-line)# :: access-class 21 in :: Applies the list to incoming logins (here it is access-class, not access-group)
Router(config-line)# :: transport input ssh :: And only SSH
Router(config-line)# :: login local :: And log in with a local user
'@
        }
        @{
            Title  = 'IPv6 ACLs'
            Rows   = @'
ipv6 access-list BLOCK-GUEST :: Creates an IPv6 list (they are always named and always extended)
Router(config-ipv6-acl)# :: deny ipv6 2001:db8:acad:30::/64 2001:db8:acad:10::/64 :: Blocks one network from reaching another
Router(config-ipv6-acl)# :: permit ipv6 any any :: Allows the rest
interface g0/0 :: Goes to the interface
Router(config-if)# :: ipv6 traffic-filter BLOCK-GUEST in :: Puts the list on it (not access-group)
Note: the hidden last lines of an IPv6 list are: permit icmp any any nd-na, permit icmp any any nd-ns, deny ipv6 any any. The first two keep neighbor discovery (IPv6's ARP) working.
'@
        }
        @{
            Title  = 'CHECK THE ACL'
            Prompt = 'Router#'
            Rows   = @'
show access-lists :: All the lists, with a counter of matches for each line
show ip access-lists WEB-ONLY :: One list
show ip interface g0/0 :: Look for "Inbound access list is ..." and "Outgoing access list is ..."
show running-config | section access-list :: The lists as typed
clear access-list counters :: Sets the match counters to zero (do it before a test)
show ipv6 access-list :: The IPv6 lists
Note: a counter that stays at zero means the traffic never reached that line: wrong direction, wrong interface, or an earlier line matched.
'@
        }
    )
}
