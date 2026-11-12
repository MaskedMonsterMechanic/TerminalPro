@{
    Kind     = 'Index'
    Command  = 'Show-AdminCommands'
    Alias    = 'admincmd'
    Synopsis = 'AdminTools module commands'
    Group    = 'GENERAL COMMANDS'
    Order    = 1
    Title    = 'ADMINTOOLS MODULE - COMMAND LIST'

    Info     = @(
        'This is the command list for the AdminTools Module. The tools give you real'
        'objects (sort them, filter them, export them), the cheat-sheets give you the'
        'commands for administration, remoting and troubleshooting.'
        ''
        'Tip: the tools can be piped,  Get-DiskStorage | Where-Object FreePercent -lt 15'
        'Tip: show only some lines,    admincom -Filter acl'
        'Tip: search every sheet,      Find-CheatSheet dns'
        ''
        'Enjoy and have fun.'
    )
}
