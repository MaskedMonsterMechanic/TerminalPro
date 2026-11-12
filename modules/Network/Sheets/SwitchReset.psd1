@{
    Command  = 'Show-SwitchReset'
    Alias    = 'netswr'
    Synopsis = 'Switch: password recovery and factory reset'
    Group    = 'SWITCH'
    Order    = 51
    Index    = 'Show-NetCommands'
    Title    = 'NETWORK MODULE - SWITCH PASSWORD RECOVERY AND RESET'
    Prompt   = 'switch:'

    Sections = @(
        @{
            Title  = 'PASSWORD RECOVERY (Catalyst 2960 and similar; you must be at the console)'
            Rows   = @'
Note: unplug the power, hold the MODE button while you plug it back in, and let go when the first LED goes out (about 15 seconds). You get the "switch:" prompt.
flash_init :: Starts the flash file system
load_helper :: Loads the helper files
dir flash: :: Lists the files: look for config.text
rename flash:config.text flash:config.text.old :: Hides the saved configuration, so the switch starts without it (and without the passwords)
boot :: Starts the switch with an empty configuration
Note: say "no" to the initial setup dialog.
Switch> :: enable :: No password is asked
Switch# :: rename flash:config.text.old flash:config.text :: Puts the old configuration file back
Switch# :: copy flash:config.text system:running-config :: Loads it into memory NOW (the interfaces stay up this way, unlike on a router)
Switch# :: configure terminal :: Goes to configuration mode
Switch(config)# :: enable algorithm-type scrypt secret <new-password> :: Sets a new privileged password
Switch(config)# :: end :: Back to privileged mode
Switch# :: copy running-config startup-config :: SAVE it
Note: on switches with "no service password-recovery" this does not work (the only way is a full reset).
'@
        }
        @{
            Title  = 'FACTORY RESET'
            Rows   = @'
Switch# :: erase startup-config :: Deletes the saved configuration
Switch# :: delete flash:vlan.dat :: Deletes the VLAN database (it is a separate file)
Switch# :: reload :: Restarts the switch (answer "no" to saving)
Switch# :: show vlan brief :: After the restart only the default VLANs should be left
Switch# :: show version :: Checks the IOS version, uptime and the configuration register
'@
        }
        @{
            Title  = 'MANAGE THE IOS FILE AND THE CONFIGURATION'
            Rows   = @'
Switch# :: show flash: :: Lists what is in flash
Switch# :: copy running-config tftp: :: Backs up the configuration to a TFTP server
Switch# :: copy tftp: flash: :: Fetches a file (for example a new IOS image) from a TFTP server
Switch# :: archive download-sw /overwrite tftp://192.0.2.10/<image>.tar :: Installs a new IOS image on a classic Catalyst
Switch# :: boot system flash:<image>.bin :: Chooses which image to start (global config mode on some models)
Switch# :: show boot :: Shows which image the switch will start
'@
        }
    )
}
