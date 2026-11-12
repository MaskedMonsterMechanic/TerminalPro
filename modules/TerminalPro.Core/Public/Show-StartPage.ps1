function Show-StartPage {
<#
.SYNOPSIS
    The start page: this PC at a glance, and a menu of all Terminal Pro modules.

.DESCRIPTION
    Shows the PowerShell version and folder, then the info commands (PC info, network adapters and
    disks by default), then every installed Terminal Pro module with the command that opens it.
    Type a module's command (or its alias) to go in. Every page has a "home" line at the bottom:
    type  home  to come back here.

    The info commands come from $global:TerminalProStartInfo (set in the profile). A command that
    is not installed is skipped. The module list is built from the modules themselves: a module is
    listed when its manifest has the tag 'TerminalPro' and it has an index sheet.

.PARAMETER NoClear
    Do not clear the screen first.

.EXAMPLE
    home
#>
    [CmdletBinding()]
    param([switch]$NoClear)

    if (-not $NoClear) { try { Clear-Host } catch { } }

    $name = (Get-TPPromptName).ToUpper()
    Write-SheetHeader -Title "$name - START"

    Write-TPText (' PowerShell Version: ' + $PSVersionTable.PSVersion) $script:Colors.Topic
    Write-TPText (' ' + (Get-Location).Path) $script:Colors.Time

    # The info block: any commands that are installed.
    $infoCommands = if ($global:TerminalProStartInfo) { @($global:TerminalProStartInfo) } else { @('Get-PCInfo', 'Get-NetIPAdapter', 'Get-DiskStorage') }
    foreach ($cmd in $infoCommands) {
        if (Get-Command $cmd -ErrorAction SilentlyContinue) {
            try {
                $items = @(& $cmd)
                if ($items.Count -eq 0) { continue }
                $types = @($items[0].PSObject.TypeNames)
                if ($types -contains 'TerminalPro.PCInfo')          { Write-StartPC -Items $items }
                elseif ($types -contains 'TerminalPro.NetIPAdapter') { Write-StartAdapters -Items $items }
                elseif ($types -contains 'TerminalPro.DiskStorage') { Write-StartDisks -Items $items }
                else { $items | Out-Host }
            }
            catch { Write-TPText " ($cmd failed: $($_.Exception.Message))" $script:Colors.Time }
        }
    }

    # The menu: every Terminal Pro module that has an index sheet.
    $entries = @(Get-TPModuleEntry)
    if ($entries.Count -eq 0) { Write-Host ''; return }

    $prompt = (Get-TPPromptName) + ' >'
    $cmdW   = [int](($entries | ForEach-Object { $_.Command.Length } | Measure-Object -Maximum).Maximum)
    $aliasW = [int](($entries | ForEach-Object { $_.Alias.Length }   | Measure-Object -Maximum).Maximum)
    $widths = @([Math]::Max($prompt.Length, 6), $cmdW, [Math]::Max($aliasW, 5), 0)
    $colors = @($script:Colors.Prompt, $script:Colors.Input, $script:Colors.Output, $script:Colors.Input)

    # In a small window the command column gets narrower (down to 16); the description wraps under OUTPUT.
    $window  = Get-TPWidth
    $longest = [int](($entries | ForEach-Object { $_.Description.Length } | Measure-Object -Maximum).Maximum)
    $minOut  = [Math]::Min($longest, [Math]::Max(20, [int]($window / 3)))
    while (($window - (1 + $widths[0] + 1 + $widths[1] + 1 + $widths[2] + 1)) -lt $minOut -and $widths[1] -gt 16) { $widths[1]-- }

    Write-SheetSectionTitle -Title 'MODULES  (type a command to go in)' -Width ([Math]::Min($window, 100))
    Write-SheetWrapped -Cells @('PROMPT', 'INPUT', 'ALIAS', 'OUTPUT') -Widths $widths -Colors $colors
    $gap = $false   # a module whose description wrapped gets an empty line after it
    foreach ($e in $entries) {
        if ($gap) { Write-Host '' }
        Write-SheetWrapped -Cells @($prompt, $e.Command, $e.Alias, $e.Description) -Widths $widths -Colors $colors
        $gap = ($script:LastWrappedLines -gt 1)
    }

    Write-Host ''
    Write-TPText ' Come back to this page from anywhere with:  ' $script:Colors.Rule -NoNewline
    Write-TPText 'home' $script:Colors.Output
    Write-TPText ' Search every page:                          ' $script:Colors.Rule -NoNewline
    Write-TPText 'Find-CheatSheet <word>' $script:Colors.Output
    Write-Host ''
}
