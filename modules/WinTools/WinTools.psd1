@{
    RootModule            = 'WinTools.psm1'
    ModuleVersion         = '1.0.0'
    GUID                  = 'c7e0b3a9-1d54-4f28-b6a3-9e82d4f15c60'
    Author                = 'PaulShell'
    CompanyName           = 'PaulShell'
    Copyright             = '(c) 2026 PaulShell. MIT licence.'
    Description           = 'Windows setup helpers (IP, DNS and computer name in one go), a Windows command cheat-sheet, a page on installing programs from the terminal, and a catalogue of free, checked programs you can install with one command.'
    PowerShellVersion     = '5.1'
    CompatiblePSEditions  = @('Desktop', 'Core')
    RequiredModules       = @('TerminalPro.Core')
    FormatsToProcess      = @('WinTools.Format.ps1xml')
    FunctionsToExport     = @('Show-WinToolsCommands', 'Show-WinCommon', 'Show-WinPrograms', 'Set-IpDnsRename', 'Get-WinApp', 'Install-WinApp')
    CmdletsToExport       = @()
    VariablesToExport     = @()
    AliasesToExport       = @('wincmd', 'wincom', 'winpkg', 'winsidr', 'winapps', 'wininst')
    PrivateData           = @{
        PSData = @{
            Tags = @('TerminalPro', 'Windows', 'CheatSheet')
        }
    }
}
