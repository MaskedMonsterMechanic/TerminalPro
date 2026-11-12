# WinTools - Windows setup helpers and a Windows cheat-sheet.
# Importing this module changes nothing on the machine: no execution policy, no folder change.

# The app catalogue (checked, free programs) that Get-WinApp and Install-WinApp read.
$script:AppCatalogPath = Join-Path $PSScriptRoot 'Data\apps.psd1'

# Real commands live in Public\
foreach ($file in Get-ChildItem -Path (Join-Path $PSScriptRoot 'Public') -Filter '*.ps1') { . $file.FullName }

# Every file in Sheets\ becomes a command and an alias. Kind = 'Command' only adds the alias and
# the index entry for a command that is written in Public\.
foreach ($file in Get-ChildItem -Path (Join-Path $PSScriptRoot 'Sheets') -Filter '*.psd1') {
    $sheet = Import-PowerShellDataFile -LiteralPath $file.FullName
    if (-not $sheet.Command) { continue }
    $path = $file.FullName

    if ($sheet.Kind -eq 'Index') {
        $body = {
            [CmdletBinding()] param([switch]$NoClear)
            Show-CheatSheetIndex -Path $path -NoClear:$NoClear
        }.GetNewClosure()
        Set-Item -Path "function:$($sheet.Command)" -Value $body
    }
    elseif ($sheet.Kind -ne 'Command') {
        $body = {
            [CmdletBinding()] param([string]$Filter, [switch]$NoClear, [switch]$AsObject)
            Show-CheatSheet -Path $path -Filter $Filter -NoClear:$NoClear -AsObject:$AsObject
        }.GetNewClosure()
        Set-Item -Path "function:$($sheet.Command)" -Value $body
    }

    if ($sheet.Alias) { Set-Alias -Name $sheet.Alias -Value $sheet.Command }
}
