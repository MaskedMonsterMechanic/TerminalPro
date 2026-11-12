@{
    Kind     = 'Index'
    Command  = 'Show-NetCommands'
    Alias    = 'netcmd'
    Synopsis = 'Network module commands'
    Group    = 'GENERAL COMMANDS'
    Order    = 1
    Title    = 'NETWORK MODULE - COMMAND LIST'

    Info     = @(
        'This is the command list for the Network Module. The tools calculate and'
        'give you real objects, the cheat-sheets are the reference pages.'
        ''
        'Tip: netcalc 192.168.1.10/24         subnet details, with binary'
        'Tip: netvlsm 10.0.0.0/24 100,50,20   gives each group the smallest subnet'
        'Tip: netpn -Filter ssh               find a port number or an acronym'
        'Tip: Get-Help netsum -Examples       every tool has examples'
        ''
        'Enjoy and have fun.'
    )
}
