@{
    Command  = 'Show-ThousandEyes'
    Alias    = 'ccnpte'
    Synopsis = 'ThousandEyes: Cisco service that monitors networks and apps from agents; agent kinds, test layers, views'
    Group    = 'CCNP'
    Order    = 270
    Index    = 'Show-NetCommands'
    Title    = 'THOUSANDEYES (CISCO) - WHAT IT IS'

    Sections = @(
        @{
            Title  = 'IN ONE SENTENCE'
            Rows   = @'
 :: What :: A Cisco cloud service that runs tests from many places (agents) to see how networks and applications really perform, including the parts of the internet that you do not own.
 :: Type :: Active monitoring: the agents send test traffic on a schedule (and some modes also watch real use). It is not a calculator, and there is nothing to install in PowerShell.
 :: Why it matters here :: Network assurance is part of the Cisco Enterprise track (the ENNA concentration exam for CCNP Enterprise). Check Cisco's exam topics for how much of it is covered.
 :: Where it is documented :: docs.thousandeyes.com (public documentation)
'@
        }
        @{
            Title  = 'THE THREE KINDS OF AGENT'
            Rows   = @'
 :: Cloud Agents :: Run by ThousandEyes in many cities. Ready to use, nothing to install. They give an "outside-in" view of your web apps and API endpoints. Shared with other customers.
 :: Enterprise Agents :: Installed by YOU inside your own network (branch, data centre, cloud). Dedicated to you, and online all the time. They see what your users and servers see.
 :: Endpoint Agents :: A small agent on the laptop or PC of a user. It sees the real path from where the user works (home, office, VPN), and the browser experience.
 :: Needs :: Enterprise Agents need a token to join your account, outbound internet access, DNS and NTP, and the firewall rules from the documentation.
'@
        }
        @{
            Title  = 'WHERE AN ENTERPRISE AGENT CAN RUN'
            Rows   = @'
 :: Linux package :: On a Linux server that you already have (for example Ubuntu or Red Hat)
 :: Docker container :: On a Linux host with Docker (not on Windows or Mac)
 :: Kubernetes :: As a container in a cluster
 :: Virtual appliance (TEVA) :: A ready virtual machine for VMware ESXi, VirtualBox or Hyper-V
 :: Physical appliance (TEPA) :: A small device such as an Intel NUC or a Raspberry Pi
 :: On Cisco devices :: Application hosting on supported Cisco switches and routers (Catalyst, ISR, ASR), and through Catalyst Center or the SD-WAN Manager
'@
        }
        @{
            Title  = 'THE TEST LAYERS'
            Rows   = @'
 :: Network :: Agent to Server, and Agent to Agent. Loss, latency, jitter, MTU and the PATH hop by hop. Agent-to-Agent measures both directions, which helps with asymmetric routing.
 :: Routing :: BGP tests. Watch the route to your prefixes from many BGP monitors: path changes, reachability, and updates. (Run by the platform, not by an agent.)
 :: DNS :: DNS Server (does a server answer), DNS Trace (follows the chain from the root), DNSSEC (is the signing valid).
 :: Web :: HTTP Server (availability, response time, codes), Page Load (every object on a page, with a waterfall), Transaction (a script in a real browser), FTP Server, API.
 :: Voice :: SIP Server (registration) and RTP Stream (voice quality metrics).
 :: Layered tests :: A web test also does a network test and a BGP test to the same target, so you can tie a slow page to loss in the network or a route change.
'@
        }
        @{
            Title  = 'WHAT YOU SEE'
            Rows   = @'
 :: Path Visualization :: The hop-by-hop path from agent to target, with loss and delay per hop, and which network (ISP) owns each hop.
 :: Timeline :: How the numbers change over time, so you can see when it started.
 :: Waterfall :: For web tests: how long each part of a page took.
 :: Alerts :: Rules on metrics (for example loss above 5%). They can notify by e-mail or a webhook.
 :: Dashboards :: Your own boards of the metrics that matter.
 :: Speaking to people :: "Is it us, the ISP, or the app?" is the question it is made to answer.
'@
        }
        @{
            Title  = 'A SMALL EXAMPLE OF HOW YOU WOULD USE IT'
            Rows   = @'
 :: 1 :: Put an Enterprise Agent in each branch and in the data centre.
 :: 2 :: Make an HTTP Server test to the important web app from all of them, and Agent-to-Agent tests between sites.
 :: 3 :: Add Cloud Agents for the view from outside, and Endpoint Agents on a few laptops.
 :: 4 :: Set alerts. When a user says "it is slow", open the path view for that time.
 :: Note :: It is a paid service. This page is only a short reference to the ideas: it does not replace Cisco's documentation or a trial account.
'@
        }
    )
}
