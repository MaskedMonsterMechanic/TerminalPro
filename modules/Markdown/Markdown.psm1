# Markdown - cheat-sheets for writing Markdown (READMEs, notes, GitHub pages).
# Every file in Sheets\ becomes a command and an alias. To add a sheet, add a file (see Sheets\Basics.psd1).

foreach ($file in Get-ChildItem -Path (Join-Path $PSScriptRoot 'Sheets') -Filter '*.psd1') {
    $sheet = Import-PowerShellDataFile -LiteralPath $file.FullName
    if (-not $sheet.Command) { continue }
    $path = $file.FullName

    if ($sheet.Kind -eq 'Index') {
        $body = {
            [CmdletBinding()] param([switch]$NoClear)
            Show-CheatSheetIndex -Path $path -NoClear:$NoClear
        }.GetNewClosure()
    }
    else {
        $body = {
            [CmdletBinding()] param([string]$Filter, [switch]$NoClear, [switch]$AsObject)
            Show-CheatSheet -Path $path -Filter $Filter -NoClear:$NoClear -AsObject:$AsObject
        }.GetNewClosure()
    }

    Set-Item -Path "function:$($sheet.Command)" -Value $body
    if ($sheet.Alias) { Set-Alias -Name $sheet.Alias -Value $sheet.Command }
}
