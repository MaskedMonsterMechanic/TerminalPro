@{
    Command  = 'Show-NetHierarchy'
    Alias    = 'nethiarc'
    Synopsis = 'Network design: access, distribution, core, redundancy, spine-leaf'
    Group    = 'THEORY'
    Order    = 81
    Index    = 'Show-NetCommands'
    Title    = 'NETWORK MODULE - NETWORK DESIGN BASICS'

    Sections = @(
        @{
            Title  = 'THREE-TIER HIERARCHY'
            Rows   = @'
Access layer :: Where devices plug in: PCs, phones, printers, access points. VLANs, port security, PoE, PortFast, BPDU guard.
Distribution layer :: Joins the access switches: inter-VLAN routing, ACLs, summarization, QoS policy. Redundant pairs.
Core layer :: The fast backbone: moves traffic as quickly as possible. Keep it simple: no policy, no filtering.
Note: the hierarchy keeps problems small (a fault stays in one block) and growth easy (add a block, not a rebuild).
'@
        }
        @{
            Title  = 'COLLAPSED CORE (two tiers)'
            Rows   = @'
When :: Small and medium networks: core and distribution are the same switches.
Why :: Costs less and has fewer devices to manage.
Cost :: Less room to grow, and a failure there takes both functions away. Use a redundant pair.
'@
        }
        @{
            Title  = 'SPINE-LEAF (data centers)'
            Rows   = @'
Leaf :: Every server and every access switch connects to leaf switches.
Spine :: Every leaf connects to every spine. No leaf connects to another leaf.
Result :: Every server is the same number of hops from every other (leaf, spine, leaf), and you add capacity by adding spines.
'@
        }
        @{
            Title  = 'DESIGN WORDS'
            Rows   = @'
Broadcast domain :: Everything that receives a broadcast: one VLAN, or one router interface. Keep them small.
Collision domain :: Where frames can collide: one hub, or one half-duplex port. A full-duplex switch port has none.
Oversubscription :: More access capacity than uplink capacity (for example 48 x 1 Gb ports over a 10 Gb uplink = 4.8:1).
Redundancy :: Two of everything on the important path, so one failure does not stop the network.
Convergence :: The time the network needs to settle on a new path after a change or a failure.
Scalability :: How easy it is to grow without changing the whole design.
Failure domain :: The area that is affected by one fault. Smaller is better.
'@
        }
        @{
            Title  = 'REDUNDANCY TOOLS'
            Rows   = @'
Spanning tree (RSTP) :: Keeps redundant switch links from making loops, and uses the backup if a link fails.
EtherChannel (LACP) :: Bundles links into one logical link: more speed and a failure only slowly lowers speed.
HSRP / VRRP / GLBP :: Two routers share one virtual gateway address, so the hosts keep working if one fails.
Dual links / dual ISPs :: Two connections to the outside, with a floating static route or BGP.
Routing protocols :: OSPF and EIGRP find another path by themselves.
Stacking / VSS :: Two or more switches act as one device.
'@
        }
        @{
            Title  = 'RULES OF THUMB'
            Rows   = @'
Note: use one VLAN for each group of devices with similar needs (users, voice, servers, guests, management).
Note: do not stretch a VLAN across the whole network: keep each VLAN in one building or one block.
Note: use a separate management VLAN, and do not use VLAN 1 for anything.
Note: unused ports: put them in an unused VLAN and shut them down.
Note: draw the network and keep the drawing current. It is the best troubleshooting tool you have.
'@
        }
    )
}
