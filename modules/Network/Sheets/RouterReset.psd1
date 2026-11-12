@{
    Command  = 'Show-RouterReset'
    Alias    = 'netror'
    Synopsis = 'Router: password recovery and factory reset'
    Group    = 'ROUTER'
    Order    = 61
    Index    = 'Show-NetCommands'
    Title    = 'NETWORK MODULE - ROUTER PASSWORD RECOVERY AND RESET'
    Prompt   = 'rommon 1 >'

    Sections = @(
        @{
            Title  = 'PASSWORD RECOVERY (you must be at the console, cable in hand)'
            Rows   = @'
Note: this works on classic Cisco IOS routers. Newer platforms (and routers where "no service password-recovery" is set) work differently.
Note: restart the router and press Ctrl+Break (in PuTTY: right-click the title bar > Special Command > Break) during the first 60 seconds.
confreg 0x2142 :: Tells the router to start without reading the saved configuration (and so without the passwords)
rommon 2 > :: reset :: Restarts the router
Note: say "no" to the setup dialog (or press Ctrl+C).
Router> :: enable :: No password is asked this time
Router# :: copy startup-config running-config :: Loads the old configuration NOW, so you do not lose it. Interfaces will be shut down.
Router# :: configure terminal :: Goes to configuration mode
Router(config)# :: enable algorithm-type scrypt secret <new-password> :: Sets a new privileged password
Router(config)# :: no shutdown :: Turn each interface back on (go in with: interface <name>)
Router(config)# :: config-register 0x2102 :: Puts the register back, so the router reads its configuration at the next start
Router# :: copy running-config startup-config :: SAVE. Without this the old password comes back after the next restart.
Router# :: show version :: At the bottom it says "Configuration register is 0x2142 (will be 0x2102 at next reload)": that is correct
'@
        }
        @{
            Title  = 'FACTORY RESET'
            Rows   = @'
Router# :: erase startup-config :: Deletes the saved configuration
Router# :: reload :: Restarts. Answer "no" to saving, and "no" to the initial dialog.
Router# :: show version :: Checks the configuration register, flash and the IOS version
Note: to also wipe the Cisco SD-WAN or licensing data, follow the platform guide. This sheet only covers classic IOS.
'@
        }
        @{
            Title  = 'IF IOS IS MISSING OR DAMAGED (ROMMON)'
            Rows   = @'
rommon 1 > :: dir flash: :: Lists the files in flash
rommon 2 > :: boot flash:<image-name>.bin :: Starts the IOS image in flash
rommon 3 > :: IP_ADDRESS=192.168.1.2 :: Sets the router's own address for a network boot
rommon 4 > :: IP_SUBNET_MASK=255.255.255.0 :: Sets the mask
rommon 5 > :: DEFAULT_GATEWAY=192.168.1.1 :: Sets the gateway
rommon 6 > :: TFTP_SERVER=192.168.1.10 :: The TFTP server that has the image
rommon 7 > :: TFTP_FILE=<image-name>.bin :: The file to fetch
rommon 8 > :: tftpdnld :: Downloads the image into flash (this erases the old one)
'@
        }
    )
}
