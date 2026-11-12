@{
    RootModule            = 'Unix.psm1'
    ModuleVersion         = '1.0.0'
    GUID                  = 'a4d19b62-5e0c-4c7b-8f33-2b6e91c0d7a5'
    Author                = 'PaulShell'
    CompanyName           = 'PaulShell'
    Copyright             = '(c) 2026 PaulShell. MIT licence.'
    Description           = 'Cheat-sheets for Unix and Linux commands, shown as coloured pages in the terminal.'
    PowerShellVersion     = '5.1'
    CompatiblePSEditions  = @('Desktop', 'Core')
    RequiredModules       = @('TerminalPro.Core')
    FunctionsToExport     = @(
        'Show-UnixCommands', 'Show-UnixCommon', 'Show-UnixDirFile', 'Show-UnixUserGroup', 'Show-UnixCommunication',
        'Show-UnixSystem', 'Show-UnixNetwork', 'Show-UnixText'
    )
    CmdletsToExport       = @()
    VariablesToExport     = @()
    AliasesToExport       = @('unixcmd', 'unixcom', 'unixdf', 'unixug', 'unixcomm', 'unixsys', 'unixnet', 'unixtxt')
    PrivateData           = @{
        PSData = @{
            Tags = @('TerminalPro', 'Unix', 'Linux', 'CheatSheet')
        }
    }
}
