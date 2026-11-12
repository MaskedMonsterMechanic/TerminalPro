@{
    Command  = 'Show-NetOsiModel'
    Alias    = 'netosi'
    Synopsis = 'OSI and TCP/IP models: layers, units of data, devices, protocols'
    Group    = 'THEORY'
    Order    = 80
    Index    = 'Show-NetCommands'
    Title    = 'NETWORK MODULE - THE OSI AND TCP/IP MODELS'

    Sections = @(
        @{
            Title  = 'OSI MODEL (Open Systems Interconnection) - top to bottom'
            Rows   = @'
7 Application :: What the user's program talks: HTTP, HTTPS, DNS, SMTP, SSH, DHCP. Unit of data: data.
6 Presentation :: Format, encoding, compression, encryption (TLS is often placed here). Unit: data.
5 Session :: Starts, keeps and ends the conversation between two programs. Unit: data.
4 Transport :: End to end between programs, with port numbers: TCP (reliable) or UDP (fast). Unit: segment (TCP) or datagram (UDP).
3 Network :: Addresses (IP) and routing between networks: IP, ICMP, routers. Unit: packet.
2 Data Link :: Delivery on one local network with MAC addresses: Ethernet, Wi-Fi, switches, VLANs. Unit: frame.
1 Physical :: Cables, radio, voltage, light, connectors, hubs. Unit: bits.
Note: to remember the order from 7 down: "All People Seem To Need Data Processing". From 1 up: "Please Do Not Throw Sausage Pizza Away".
'@
        }
        @{
            Title  = 'TCP/IP MODEL (what the internet actually uses)'
            Rows   = @'
Application :: OSI layers 5, 6 and 7 together
Transport :: OSI layer 4
Internet :: OSI layer 3
Network access (link) :: OSI layers 1 and 2
Note: some books split "network access" into link and physical, which gives five layers.
'@
        }
        @{
            Title  = 'ENCAPSULATION (what happens when a program sends data)'
            Rows   = @'
Step 1 :: The application makes the data.
Step 2 :: Transport adds a header with the port numbers: a segment.
Step 3 :: Network adds a header with the IP addresses: a packet.
Step 4 :: Data link adds a header AND a trailer with the MAC addresses and an error check: a frame.
Step 5 :: Physical sends the frame as bits.
Note: the receiver does the same in reverse (de-encapsulation).
Note: MAC addresses change at every hop. IP addresses stay the same from end to end (unless NAT changes them).
'@
        }
        @{
            Title  = 'DEVICES AND THE LAYER THEY WORK AT'
            Rows   = @'
Hub / repeater :: Layer 1. Repeats bits to all ports. One collision domain.
Switch :: Layer 2. Forwards frames by MAC address. One collision domain per port, one broadcast domain per VLAN.
Wireless access point :: Layer 2 (connects Wi-Fi clients to the wired network).
Router :: Layer 3. Forwards packets between networks. Every interface is its own broadcast domain.
Layer 3 switch :: Layer 2 and 3. Switches and routes between VLANs.
Firewall :: Layers 3 and 4 (a next-generation firewall also looks at layer 7).
Load balancer :: Layers 4 and 7.
'@
        }
        @{
            Title  = 'FIND THE LAYER BY SYMPTOM (a quick guide for troubleshooting)'
            Rows   = @'
Layer 1 :: No link light, unplugged or damaged cable, wrong cable type, SFP problem.
Layer 2 :: Wrong VLAN, trunk problem, duplex mismatch, spanning tree blocking, wrong Wi-Fi password, MAC filtering.
Layer 3 :: Wrong IP address, mask or gateway, missing route, ACL, NAT.
Layer 4 :: A port blocked by a firewall, nothing listening on the port, TCP resets.
Layer 7 :: The service is broken: a name does not resolve (DNS), a certificate has expired, a login fails.
Note: "ping works but the website does not" means layers 1 to 3 are fine. Test the port, then DNS.
'@
        }
    )
}
