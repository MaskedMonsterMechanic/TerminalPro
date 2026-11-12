@{
    Command  = 'Show-NetPortNumbers'
    Alias    = 'netpn'
    Synopsis = 'The common port numbers (use -Filter to search, e.g. netpn -Filter ssh)'
    Group    = 'THEORY'
    Order    = 86
    Index    = 'Show-NetCommands'
    Title    = 'NETWORK MODULE - COMMON PORT NUMBERS'

    Sections = @(
        @{
            Title  = 'WEB AND NAMES'
            Rows   = @'
80/tcp :: HTTP
443/tcp :: HTTPS (HTTP/3 uses 443/udp)
8080/tcp :: HTTP, alternate (proxies, test servers)
8443/tcp :: HTTPS, alternate
53/udp :: DNS queries (also 53/tcp for large answers and zone transfers)
853/tcp :: DNS over TLS
67/udp :: DHCP server
68/udp :: DHCP client
547/udp :: DHCPv6 server and relay
546/udp :: DHCPv6 client
'@
        }
        @{
            Title  = 'REMOTE ACCESS AND FILES'
            Rows   = @'
22/tcp :: SSH (also SFTP and SCP)
23/tcp :: Telnet (unencrypted: avoid)
3389/tcp :: Remote Desktop (RDP)
5900/tcp :: VNC
5985/tcp :: Windows Remote Management (WinRM) over HTTP, PowerShell remoting
5986/tcp :: WinRM over HTTPS
20/tcp :: FTP data
21/tcp :: FTP control
69/udp :: TFTP
445/tcp :: SMB (Windows file sharing)
139/tcp :: NetBIOS session (old file sharing)
137/udp :: NetBIOS name service
138/udp :: NetBIOS datagram service
2049/tcp :: NFS
873/tcp :: rsync
'@
        }
        @{
            Title  = 'MAIL'
            Rows   = @'
25/tcp :: SMTP (server to server)
587/tcp :: SMTP submission (client to server, with STARTTLS)
465/tcp :: SMTP over TLS (SMTPS)
110/tcp :: POP3
995/tcp :: POP3 over TLS
143/tcp :: IMAP
993/tcp :: IMAP over TLS
'@
        }
        @{
            Title  = 'NETWORK MANAGEMENT'
            Rows   = @'
161/udp :: SNMP (queries)
162/udp :: SNMP traps
123/udp :: NTP
514/udp :: Syslog
514/tcp :: RSH (old, unsafe) - not syslog
6514/tcp :: Syslog over TLS
1812/udp :: RADIUS authentication
1813/udp :: RADIUS accounting
49/tcp :: TACACS+
389/tcp :: LDAP (also 389/udp)
636/tcp :: LDAP over TLS (LDAPS)
3268/tcp :: Active Directory global catalog
3269/tcp :: Active Directory global catalog over TLS
88/tcp :: Kerberos (also 88/udp)
464/tcp :: Kerberos password change
135/tcp :: Microsoft RPC endpoint mapper
'@
        }
        @{
            Title  = 'ROUTING AND LAYER 2 PROTOCOLS ON TOP OF IP'
            Rows   = @'
179/tcp :: BGP
520/udp :: RIP
521/udp :: RIPng
89 :: OSPF (an IP protocol number, not a port)
88 :: EIGRP (an IP protocol number, not a port; it is not the same as Kerberos port 88)
1 :: ICMP (IP protocol number)
58 :: ICMPv6 (IP protocol number)
6 :: TCP (IP protocol number)
17 :: UDP (IP protocol number)
47 :: GRE (IP protocol number)
50 :: ESP, used by IPsec (IP protocol number)
51 :: AH, used by IPsec (IP protocol number)
112 :: VRRP (IP protocol number)
500/udp :: IKE (IPsec key exchange)
4500/udp :: IPsec NAT traversal
1701/udp :: L2TP
1723/tcp :: PPTP (old, unsafe)
1194/udp :: OpenVPN (default)
51820/udp :: WireGuard (default)
646/tcp :: LDP (MPLS label distribution)
1985/udp :: HSRP (version 1 sends to 224.0.0.2, version 2 to 224.0.0.102)
3222/udp :: GLBP
'@
        }
        @{
            Title  = 'DATABASES AND SERVICES'
            Rows   = @'
1433/tcp :: Microsoft SQL Server
1521/tcp :: Oracle database
3306/tcp :: MySQL and MariaDB
5432/tcp :: PostgreSQL
27017/tcp :: MongoDB
6379/tcp :: Redis
9200/tcp :: Elasticsearch
5672/tcp :: RabbitMQ (AMQP)
9092/tcp :: Apache Kafka
2375/tcp :: Docker API, unencrypted (never expose it)
2376/tcp :: Docker API over TLS
6443/tcp :: Kubernetes API server
'@
        }
        @{
            Title  = 'VOICE, VIDEO AND OTHER'
            Rows   = @'
5060/udp :: SIP (also 5060/tcp)
5061/tcp :: SIP over TLS
2000/tcp :: Cisco SCCP (Skinny), IP phones
554/tcp :: RTSP (streaming)
16384-32767/udp :: A common range for RTP voice and video
1900/udp :: SSDP / UPnP discovery
5353/udp :: mDNS (Bonjour, local name lookup)
5355/udp :: LLMNR (Windows local name lookup)
9100/tcp :: Raw printing (JetDirect)
631/tcp :: IPP (printing)
'@
        }
        @{
            Title  = 'THE THREE RANGES'
            Rows   = @'
0 - 1023 :: Well-known ports: for standard services (need admin or root rights to listen)
1024 - 49151 :: Registered ports: for programs registered with IANA
49152 - 65535 :: Dynamic or ephemeral ports: the client side picks one of these for each connection
Note: the full list is kept by IANA: the "Service Name and Transport Protocol Port Number Registry".
Note: check one on your PC: Get-NetTCPConnection -LocalPort 443, and from here: nettp <host> 443.
'@
        }
    )
}
