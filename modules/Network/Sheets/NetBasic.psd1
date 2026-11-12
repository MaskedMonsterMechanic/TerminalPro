@{
    Command  = 'Show-NetBasic'
    Alias    = 'netbc'
    Synopsis = 'First connection and first setup of a Cisco router or switch'
    Group    = 'DEVICE SETUP'
    Order    = 40
    Index    = 'Show-NetCommands'
    Title    = 'NETWORK MODULE - BASIC SETUP (ROUTER AND SWITCH)'
    Prompt   = 'Router#'

    Sections = @(
        @{
            Title  = 'CONNECT WITH THE CONSOLE CABLE'
            Rows   = @'
Note: use a terminal program such as PuTTY, MobaXterm, SecureCRT, Tera Term, or the serial support in Windows Terminal with a tool like plink.
Note: settings for a Cisco console port: speed 9600, 8 data bits, no parity, 1 stop bit, no flow control (9600 8-N-1).
mode :: Serial line (COM3 or similar: see Device Manager > Ports). A USB console cable shows up as a new COM port.
Ctrl+Shift+6 then X :: Breaks out of a stuck ping, traceroute or DNS lookup
'@
        }
        @{
            Title  = 'MODES AND MOVING BETWEEN THEM'
            Rows   = @'
Router> :: enable :: Goes from user mode to privileged mode (the # prompt)
Router# :: configure terminal :: Goes to global configuration mode (alias: conf t)
Router(config)# :: interface g0/0 :: Goes to interface configuration mode
Router(config-if)# :: exit :: Goes one level back
Router(config-if)# :: end :: Goes straight back to privileged mode (same as Ctrl+Z)
Router# :: disable :: Goes back to user mode
Router# :: show running-config | section interface :: Filters output (section, include, exclude, begin)
Router(config)# :: do show ip interface brief :: Runs a privileged command from inside configuration mode
'@
        }
        @{
            Title  = 'THE FIRST TEN MINUTES'
            Rows   = @'
Router(config)# :: hostname R1 :: Names the device (do this before generating keys)
Router# :: clock set 14:30:00 11 Nov 2026 :: Sets the time (privileged mode, not config mode)
Router(config)# :: no ip domain-lookup :: Stops the router from trying to look up mistyped commands as host names
Router(config)# :: ip domain-name lab.example :: Gives the device a domain name (needed for SSH keys)
Router(config)# :: banner motd # Authorized access only # :: Sets the login warning
Router(config)# :: enable algorithm-type scrypt secret <password> :: Strong hashed password for privileged mode (older IOS: enable secret <password>)
Router(config)# :: service password-encryption :: Lightly scrambles line passwords in the config (not real security)
Router(config)# :: username admin privilege 15 algorithm-type scrypt secret <password> :: Creates a local administrator (older IOS: username admin privilege 15 secret <password>)
Router(config)# :: security passwords min-length 10 :: Refuses short passwords
Router(config)# :: login block-for 120 attempts 3 within 60 :: Blocks logins for 2 minutes after 3 failures in 1 minute
'@
        }
        @{
            Title  = 'SSH INSTEAD OF TELNET'
            Rows   = @'
Router(config)# :: crypto key generate rsa modulus 2048 :: Makes the keys (needs hostname and domain name first)
Router(config)# :: ip ssh version 2 :: Only allows SSH version 2
Router(config)# :: line console 0 :: Configures the console line
Router(config-line)# :: logging synchronous :: Stops messages from breaking what you type
Router(config-line)# :: exec-timeout 10 0 :: Logs out after 10 minutes without typing
Router(config-line)# :: login local :: Asks for a user name and password from the local user list
Router(config)# :: line vty 0 15 :: Configures the remote lines (older devices have only 0 4)
Router(config-line)# :: transport input ssh :: Only SSH, no telnet
Router(config-line)# :: login local :: Uses the local users
Router(config-line)# :: access-class 10 in :: Only lets the addresses in standard ACL 10 connect
Router# :: show ip ssh :: Shows the SSH version and settings
Router# :: show ssh :: Shows the open SSH sessions
'@
        }
        @{
            Title  = 'SAVE, LOOK AT, AND ERASE THE CONFIGURATION'
            Rows   = @'
Router# :: copy running-config startup-config :: Saves your work (older shortcut: write memory, or wr)
Router# :: show startup-config :: Shows what the device will start with
Router# :: show running-config :: Shows what the device is using now
Router# :: erase startup-config :: Deletes the saved configuration (alias: write erase)
Router# :: delete vlan.dat :: Switches only: deletes the VLAN database in flash
Router# :: reload :: Restarts the device (answer no to saving if you want the old config back)
Router# :: reload in 10 :: Restarts in 10 minutes: a safety net while you change something risky
Router# :: reload cancel :: Cancels the planned restart
'@
        }
        @{
            Title  = 'COPY COMMANDS'
            Rows   = @'
Router# :: copy running-config tftp: :: Backs up the configuration to a TFTP server
Router# :: copy tftp: running-config :: Merges a configuration file from a TFTP server into the running one
Router# :: copy running-config flash:backup.cfg :: Makes a backup on the device itself
Router# :: copy scp: flash: :: Fetches a file with secure copy (IOS XE and newer IOS)
Router# :: show flash: :: Lists the files in flash (the IOS image lives here)
Router# :: configure replace flash:backup.cfg :: Replaces the whole running configuration (supported platforms)
Note: sources and destinations include running-config, startup-config, flash:, tftp:, ftp:, scp:, nvram:, usbflash0: (names vary by platform).
'@
        }
        @{
            Title  = 'HELP THAT IS ALWAYS THERE'
            Rows   = @'
? :: Lists the commands that fit here
sh? :: Lists the commands that start with "sh"
show ip ? :: Lists what can follow "show ip"
Tab :: Completes a partly typed command
Ctrl+A / Ctrl+E :: Start / end of the line
Ctrl+W :: Deletes the word before the cursor
Ctrl+R :: Redraws the line after a console message
Up arrow / Ctrl+P :: Earlier command
show history :: Shows the last commands you typed
terminal history size 100 :: Remembers 100 commands in this session
'@
        }
        @{
            Title  = 'WINDOWS SIDE: ALLOW PING TO THIS PC'
            Rows   = @'
PS> :: New-NetFirewallRule -DisplayName 'Allow ICMPv4 In' -Protocol ICMPv4 -IcmpType 8 -Direction Inbound -Action Allow :: Lets this PC answer ping (run as administrator)
PS> :: Get-NetFirewallRule -DisplayName 'Allow ICMPv4 In' | Remove-NetFirewallRule :: Removes the rule again
'@
        }
    )
}
