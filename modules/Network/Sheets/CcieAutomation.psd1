@{
    Command  = 'Show-CcieAutomation'
    Alias    = 'ccieauto'
    Synopsis = 'Automation: YANG, NETCONF, RESTCONF, HTTP and JSON basics, Python snippets, Jinja2, EEM, Guest Shell, telemetry'
    Group    = 'CCIE'
    Order    = 310
    Index    = 'Show-NetCommands'
    Title    = 'CCIE - AUTOMATION AND PROGRAMMABILITY'
    Prompt   = 'Router(config)#'

    Sections = @(
        @{
            Title  = 'DATA MODELS AND PROTOCOLS'
            Rows   = @'
 :: YANG :: A language that describes the config and state of a device as a tree (containers, lists, leaves). The model is the contract.
 :: Model families :: Native (Cisco-IOS-XE-native: follows the CLI), IETF (ietf-interfaces), OpenConfig (vendor neutral).
 :: NETCONF :: Over SSH, TCP port 830. XML messages. Operations: get, get-config, edit-config, commit, lock. Has a candidate datastore and transactions on some platforms.
 :: RESTCONF :: Over HTTPS. HTTP methods on YANG data: GET read, POST create, PUT replace, PATCH merge, DELETE remove. JSON or XML.
 :: gNMI :: gRPC based: get, set and subscribe. Often used for telemetry.
 :: Datastores :: running (what the device does), startup (after a reload), candidate (staged), operational (state, read only).
'@
        }
        @{
            Title  = 'TURN IT ON'
            Rows   = @'
netconf-yang :: Starts the NETCONF-YANG service (port 830)
restconf :: Starts RESTCONF
ip http secure-server :: The HTTPS server (RESTCONF uses it)
ip http authentication local :: Log in with local users
username api privilege 15 secret <password> :: A user with the right to change the config
Router# :: show platform software yang-management process :: Are the YANG services running? (the command differs between platforms)
Router# :: show netconf-yang sessions :: Active NETCONF sessions
'@
        }
        @{
            Title  = 'RESTCONF: URLs, HEADERS, STATUS'
            Rows   = @'
 :: Base URL :: https://<device>/restconf/data/<module>:<container>
 :: Example :: https://192.0.2.1/restconf/data/ietf-interfaces:interfaces/interface=GigabitEthernet1
 :: Content type :: Accept: application/yang-data+json (or +xml), and the same in Content-Type when you send data.
 :: Discovery :: https://<device>/.well-known/host-meta shows where the RESTCONF root is.
 :: 200 OK :: The read worked
 :: 201 Created :: The new item was created (POST)
 :: 204 No Content :: Success, with nothing to return (PUT, PATCH, DELETE)
 :: 400 :: A bad request, the data does not fit the model
 :: 401 :: Not logged in, or a wrong password
 :: 403 :: Not allowed
 :: 404 :: The path does not exist
 :: 409 :: A conflict: the item already exists, or it is locked
'@
        }
        @{
            Title  = 'PYTHON: A FEW LINES THAT YOU WILL USE'
            Rows   = @'
 :: Read with requests :: r = requests.get(url, auth=("api", "pw"), headers={"Accept": "application/yang-data+json"}, verify=False)
 :: Look at the answer :: r.status_code    r.json()    r.text
 :: Send with requests :: requests.patch(url, auth=..., headers={"Content-Type": "application/yang-data+json"}, data=json.dumps(body), verify=False)
 :: NETCONF with ncclient :: m = manager.connect(host="192.0.2.1", port=830, username="api", password="pw", hostkey_verify=False)
 :: ...read the config :: m.get_config(source="running").data_xml
 :: ...send a change :: m.edit_config(target="running", config=xml_text)
 :: JSON to Python :: json.loads(text) gives a dict. json.dumps(dict, indent=2) prints it nicely.
 :: Loop over a list :: for item in data["ietf-interfaces:interfaces"]["interface"]: print(item["name"])
 :: SSH with netmiko :: ConnectHandler(device_type="cisco_xe", host=..., username=..., password=...).send_command("show ip int brief")
Note: verify=False and hostkey_verify=False are fine in a lab. In real networks use certificates and known hosts.
'@
        }
        @{
            Title  = 'JINJA2 TEMPLATES (one template, many devices)'
            Rows   = @'
 :: Variable :: hostname {{ name }}
 :: Loop :: {% for i in interfaces %} ... {% endfor %}
 :: Condition :: {% if i.shut %} shutdown {% else %} no shutdown {% endif %}
 :: Filter :: {{ name | upper }}
 :: Render in Python :: Template(text).render(name="R1", interfaces=[...])
 :: Data file :: Keep the variables in YAML or JSON, one file per device, and the template in one file. Then generating 100 configs is a loop.
 :: Check :: Render, read the output, and test it on a lab device before a real one.
'@
        }
        @{
            Title  = 'EEM (Embedded Event Manager)'
            Rows   = @'
event manager applet LINK-DOWN :: An applet...
Router(config-applet)# :: event syslog pattern "Interface GigabitEthernet0/1, changed state to down" :: ...runs when a syslog line matches
Router(config-applet)# :: action 1.0 syslog msg "Link is down, EEM is working" :: ...first action (actions run in order of their number)
Router(config-applet)# :: action 2.0 cli command "enable" :: ...CLI actions need enable first
Router(config-applet)# :: action 3.0 cli command "show ip interface brief" :: ...a command
Router(config-applet)# :: action 4.0 mail server 192.0.2.25 to ops@example.com from router@example.com subject "Link down" body "See log" :: ...an e-mail
event manager applet NIGHTLY :: A timer applet...
Router(config-applet)# :: event timer cron cron-entry "0 3 * * *" :: ...every day at 03:00
Router(config-applet)# :: event none :: ...or: only by hand, with "event manager run NAME"
Router# :: show event manager policy registered :: The applets that are active
Router# :: show event manager history events :: When they ran
 :: Variables :: $_syslog_msg and other built-in variables hold the trigger details. Use them in the actions.
 :: Tip :: Test an applet with "event none" first, before you connect it to a real event.
'@
        }
        @{
            Title  = 'ON-BOX PYTHON (Guest Shell)'
            Rows   = @'
iox :: Turns on the application hosting service...
Router# :: guestshell enable :: ...then starts the Guest Shell (a Linux container on the router)
Router# :: guestshell run python3 :: Runs Python in it
 :: Run a command :: from cli import cli, configure   then   cli("show version")   and   configure(["interface lo99", "ip address 99.99.99.99 255.255.255.255"])
 :: Run a script :: guestshell run python3 /flash/guest-share/script.py
 :: Why :: Quick checks and fixes at the device, no connection from outside needed. Used with EEM to run a script on an event.
Note: the availability and the command names depend on the platform and release.
'@
        }
        @{
            Title  = 'MODEL-DRIVEN TELEMETRY'
            Rows   = @'
telemetry ietf subscription 101 :: A subscription (the device pushes data: "dial-out")...
Router(config-mdt-subs)# :: encoding encode-kvgpb :: ...encoding (key-value protobuf)...
Router(config-mdt-subs)# :: filter xpath /interfaces-ios-xe-oper:interfaces/interface/statistics :: ...WHAT to send (an XPath in the model)...
Router(config-mdt-subs)# :: stream yang-push :: ...from the YANG push stream...
Router(config-mdt-subs)# :: update-policy periodic 1000 :: ...every 10 seconds (the unit is 1/100 s). Or: update-policy on-change.
Router(config-mdt-subs)# :: receiver ip address 192.0.2.50 57000 protocol grpc-tcp :: ...to this collector
Router# :: show telemetry ietf subscription all :: The subscriptions and their state
 :: Dial-in vs dial-out :: Dial-in: the collector connects and subscribes (gNMI, NETCONF). Dial-out: the device connects to the collector (configured on the device).
 :: Polling vs streaming :: SNMP polls on a timer. Telemetry streams, so the data is fresher and the load is lower. A pull is still fine for occasional reads.
Note: the lines for telemetry depend on the release. Check with ?.
'@
        }
    )
}
