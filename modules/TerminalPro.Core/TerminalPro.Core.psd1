@{
    RootModule            = 'TerminalPro.Core.psm1'
    ModuleVersion         = '1.1.0'
    GUID                  = '3f2a5c7e-8b41-4d6a-9c0e-5a1b7d2e4f90'
    Author                = 'PaulShell'
    CompanyName           = 'PaulShell'
    Copyright             = '(c) 2026 PaulShell. MIT licence.'
    Description           = 'Shared engine for the Terminal Pro cheat-sheet modules: Write-Color, Show-CheatSheet, Find-CheatSheet, and the start page (home).'
    PowerShellVersion     = '5.1'
    CompatiblePSEditions  = @('Desktop', 'Core')
    FunctionsToExport     = @('Write-Color', 'Show-CheatSheet', 'Show-CheatSheetIndex', 'Find-CheatSheet', 'Show-StartPage')
    CmdletsToExport       = @()
    VariablesToExport     = @()
    AliasesToExport       = @('home')
}
