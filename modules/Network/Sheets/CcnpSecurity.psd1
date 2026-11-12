@{
    Command  = 'Show-CcnpSecurity'
    Alias    = 'ccnpsec'
    Synopsis = 'Router security: management plane, SSH, AAA, SNMPv3, NTP, uRPF, time-based and infrastructure ACLs'
    Group    = 'CCNP'
    Order    = 240
    Index    = 'Show-NetCommands'
    Title    = 'CCNP - ROUTER AND ROUTING SECURITY'
    Prompt   = 'Router(config)#'

    Sections = @(
        @{
            Title  = 'THE THREE PLANES (what you protect)'
            Rows   = @'
 :: Management plane :: How you reach and control the router: SSH, console, SNMP, NTP, logging, AAA.
 :: Control plane :: Traffic the router itself must process: routing protocols, ARP, ICMP. Protect it with authentication and rate limits (CoPP).
 :: Data plane :: The traffic that passes through. Protect it with ACLs, uRPF, and firewalls.
'@
        }
        @{
            Title  = 'MANAGEMENT PLANE: ACCESS AND PASSWORDS'
            Rows   = @'
hostname R1 :: A host name and a domain name are needed to make the SSH keys
ip domain-name lab.example :: The domain name
crypto key generate rsa modulus 2048 :: The key pair for SSH (2048 bits or more)
ip ssh version 2 :: SSH version 2 only
ip ssh time-out 60 :: Seconds the login may take
ip ssh authentication-retries 3 :: Wrong passwords allowed per connection
enable algorithm-type scrypt secret <password> :: The privileged password, stored as a strong hash (never use "enable password")
username admin privilege 15 algorithm-type scrypt secret <password> :: A local user with a strong hash
service password-encryption :: Hides the other passwords from a quick look. It is only type 7, which anyone can reverse: it is NOT real protection.
security passwords min-length 10 :: A minimum password length
login block-for 120 attempts 3 within 60 :: Blocks logins for 2 minutes after 3 failures within 60 seconds
Router(config-line)# :: transport input ssh :: On "line vty 0 15": SSH only, no telnet
Router(config-line)# :: login local :: Log in with the local users
Router(config-line)# :: exec-timeout 5 0 :: Logs out an idle session after 5 minutes
Router(config-line)# :: access-class 21 in :: Only addresses in ACL 21 may connect
no ip http server :: Turn off the web server if it is not needed (also: no ip http secure-server)
banner login # Authorized use only # :: A legal warning shown before the login
'@
        }
        @{
            Title  = 'AAA (one place for logins, permissions and records)'
            Rows   = @'
aaa new-model :: Turns AAA on. Do this only after you have a working local user, or you can lock yourself out.
tacacs server TAC1 :: A TACACS+ server (use "radius server" for RADIUS)
Router(config-server-tacacs)# :: address ipv4 192.0.2.50 :: Its address
Router(config-server-tacacs)# :: key <shared-secret> :: The shared secret
aaa authentication login default group tacacs+ local :: Who are you? Ask the server first, and use the local users if the server does not answer
aaa authorization exec default group tacacs+ local :: What may you do? (the privilege level at login)
aaa authorization commands 15 default group tacacs+ local :: Ask for every level-15 command
aaa accounting commands 15 default start-stop group tacacs+ :: Write down what was done and by whom
Router# :: show aaa servers :: Are the servers alive?
Note: TACACS+ encrypts the whole message and separates the three A's, which is why it is the usual choice for device login. RADIUS (1812/1813) is the usual choice for network access (802.1X, VPN).
'@
        }
        @{
            Title  = 'SNMP, NTP AND LOGGING'
            Rows   = @'
snmp-server group MONITOR v3 priv :: A SNMPv3 group that needs authentication AND encryption
snmp-server user nms MONITOR v3 auth sha <auth-pass> priv aes 128 <priv-pass> :: A user in the group
no snmp-server community public :: Remove the well-known community strings (SNMP v1 and v2c send them in clear text)
ntp authenticate :: Only trust time from servers that authenticate
ntp authentication-key 1 md5 <key> :: A key
ntp trusted-key 1 :: Trust this key
ntp server 192.0.2.123 key 1 :: Take the time from this server, and prove it with the key
service timestamps log datetime msec :: Time on every log line (the time must be right to be useful)
logging host 192.0.2.50 :: Send the logs to a central server
logging trap informational :: What level of messages to send
Router# :: show ntp status :: Is the clock synchronized?
'@
        }
        @{
            Title  = 'ACCESS LISTS FOR SECURITY'
            Rows   = @'
time-range WORKHOURS :: Starts a time range
Router(config-time-range)# :: periodic weekdays 8:00 to 17:00 :: Monday to Friday, 8 to 17 (the clock must be right)
access-list 110 permit tcp 192.168.10.0 0.0.0.255 any eq 80 time-range WORKHOURS :: A line that only works during the range
 :: Infrastructure ACL :: An ACL on the edge that only lets in what the network needs (routing protocol packets from known neighbors, SSH from the admin network) towards the router addresses, and drops the rest.
 :: Anti-spoofing :: Drop packets from outside that claim to come from inside (your own ranges, private ranges, loopback 127.0.0.0/8).
Router# :: show time-range :: Shows whether each range is active now
Note: more on ACLs in ccnaacl.
'@
        }
        @{
            Title  = 'uRPF (drop packets with a forged source address)'
            Rows   = @'
interface g0/1 :: The interface facing the outside
Router(config-if)# :: ip verify unicast source reachable-via rx :: STRICT: the source must be reachable through THIS interface. Use it where the routing is symmetric (one way in and out).
Router(config-if)# :: ip verify unicast source reachable-via any :: LOOSE: the source only needs to be in the routing table somewhere. Safe with several providers.
Router(config-if)# :: ip verify unicast source reachable-via rx allow-default :: Strict, and a default route counts as a match
Router# :: show ip interface g0/1 :: Look for the uRPF line and the drop counters
Note: strict mode can drop good packets when the return path is different from the way in. Use loose mode on multihomed connections.
'@
        }
        @{
            Title  = 'DO NOT RUN WHAT YOU DO NOT USE'
            Rows   = @'
no cdp run :: Or "no cdp enable" on the interfaces towards the outside
no lldp run :: Same idea
no ip source-route :: IP source routing lets the sender choose the path
no ip proxy-arp :: On interfaces where it is not needed
no ip redirects :: Stops ICMP redirects
no ip unreachables :: Stops ICMP unreachable answers (on the outside interfaces)
no ip directed-broadcast :: Off by default in current IOS: just check
no service pad :: Old and not needed
no ip bootp server :: Old and not needed
shutdown :: Every unused interface
Note: this is not the full list. Use the CIS benchmark or Cisco's hardening guide for the whole picture.
'@
        }
        @{
            Title  = 'AUTHENTICATING ROUTING PROTOCOLS (where to find it)'
            Rows   = @'
 :: Key chains :: "key chain NAME" / "key 1" / "key-string <secret>" (also accept-lifetime and send-lifetime). Used by EIGRP, RIPv2 and newer OSPF.
 :: EIGRP :: ip authentication mode eigrp 100 md5, and ip authentication key-chain eigrp 100 NAME. See ccnpeigrp.
 :: OSPF :: ip ospf authentication message-digest, and ip ospf message-digest-key 1 md5 <secret>. See ccnpospf2.
 :: BGP :: neighbor X password <secret> (MD5 on the TCP session). See ccnpbgp.
 :: RIPv2 :: ip rip authentication mode md5, and ip rip authentication key-chain NAME.
 :: OSPFv3 / IPv6 :: ospfv3 authentication in newer IOS, or IPsec on older IOS.
Note: plain text authentication only stops mistakes, not attackers. Use MD5 at least, or SHA where it is offered.
'@
        }
    )
}
