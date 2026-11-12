function Show-ModuleList {
<#
.SYNOPSIS
    Lists the Terminal Pro modules that are installed, with the command that opens each one's index.

.DESCRIPTION
    Built from the modules themselves (their manifest and their index sheet), so it can never
    go out of date. A module is listed when its manifest has the tag 'TerminalPro'.

.EXAMPLE
    Show-ModuleList
#>
    [CmdletBinding()]
    param()

    $folder = Split-Path -Path $script:ModuleRoot -Parent

    foreach ($dir in Get-ChildItem -LiteralPath $folder -Directory | Sort-Object Name) {
        $manifest = Join-Path $dir.FullName "$($dir.Name).psd1"
        if (-not (Test-Path -LiteralPath $manifest)) { continue }

        $info = Import-PowerShellDataFile -LiteralPath $manifest
        if ($info.PrivateData.PSData.Tags -notcontains 'TerminalPro') { continue }

        $command = $null
        $alias   = $null
        $sheets  = Join-Path $dir.FullName 'Sheets'
        if (Test-Path -LiteralPath $sheets) {
            foreach ($file in Get-ChildItem -LiteralPath $sheets -Filter '*.psd1') {
                $sheet = Import-PowerShellDataFile -LiteralPath $file.FullName
                if ($sheet.Kind -eq 'Index') { $command = $sheet.Command; $alias = $sheet.Alias; break }
            }
        }

        [pscustomobject]@{
            PSTypeName  = 'TerminalPro.ModuleInfo'
            Name        = $dir.Name
            Version     = $info.ModuleVersion
            Description = $info.Description
            Command     = $command
            Alias       = $alias
        }
    }
}
