@{
    RootModule            = 'AdminTools.psm1'
    ModuleVersion         = '3.1.0'
    GUID                  = '77345f1e-3b45-458a-bb76-cc1614b65520'
    Author                = 'PaulShell'
    CompanyName           = 'PaulShell'
    Copyright             = '(c) 2026 PaulShell. MIT licence.'
    Description           = 'Administration tools that return real objects (PC info, disks, network adapters, elevated shells, runas, remote tasks) and admin cheat-sheets.'
    PowerShellVersion     = '5.1'
    CompatiblePSEditions  = @('Desktop', 'Core')
    RequiredModules       = @('TerminalPro.Core')
    FormatsToProcess      = @('AdminTools.Format.ps1xml')
    FunctionsToExport     = @(
        'Show-AdminCommands', 'Show-AdminCommon', 'Show-HyperV', 'Show-Remoting', 'Show-ADCommands', 'Show-AdminServers', 'Show-AdminBuildDomain', 'Show-AdminBuildDns', 'Show-AdminBuildDhcp', 'Show-AdminBuildUsers', 'Show-AdminBuildFiles',
        'Get-PCInfo', 'Get-NetIPAdapter', 'Get-DiskStorage',
        'Start-AdminShell', 'Start-RunAs', 'Register-RemoteTask', 'Show-ModuleList',
        'Resolve-HostList', 'Test-HostList', 'Restart-RemoteService'
    )
    CmdletsToExport       = @()
    VariablesToExport     = @()
    AliasesToExport       = @('admincmd', 'admincom', 'shv', 'adremote', 'adad', 'adsrv', 'adbuild', 'addns', 'addhcp', 'adusers', 'adfiles', 'apci', 'anipa', 'adisk', 'aps', 'rap', 'scht', 'modlist', 'ares', 'aping', 'arsvc')
    PrivateData           = @{
        PSData = @{
            Tags = @('TerminalPro', 'Admin', 'Windows')
        }
    }
}
