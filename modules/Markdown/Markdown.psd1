@{
    RootModule            = 'Markdown.psm1'
    ModuleVersion         = '1.0.0'
    GUID                  = 'd3b6e8f1-7a42-4c19-9e05-6f1a2c84b7d3'
    Author                = 'PaulShell'
    CompanyName           = 'PaulShell'
    Copyright             = '(c) 2026 PaulShell. MIT licence.'
    Description           = 'Cheat-sheets for writing Markdown: the basics, lists and links, code and tables, and the extras GitHub adds.'
    PowerShellVersion     = '5.1'
    CompatiblePSEditions  = @('Desktop', 'Core')
    RequiredModules       = @('TerminalPro.Core')
    FunctionsToExport     = @('Show-MdCommands', 'Show-MdBasics', 'Show-MdLists', 'Show-MdCode', 'Show-MdGitHub')
    CmdletsToExport       = @()
    VariablesToExport     = @()
    AliasesToExport       = @('mdcmd', 'mdbasic', 'mdlist', 'mdcode', 'mdgit')
    PrivateData           = @{
        PSData = @{
            Tags = @('TerminalPro', 'Markdown', 'GitHub', 'CheatSheet')
        }
    }
}
