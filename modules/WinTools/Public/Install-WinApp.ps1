function Install-WinApp {
<#
.SYNOPSIS
    Installs programs from the Terminal Pro app catalogue with winget.

.DESCRIPTION
    Takes the keys of programs from Get-WinApp (for example vscode, nmap, treesize) and installs them with
    winget. It only installs programs that are in the catalogue, and nothing else.

    Before it installs a program it asks winget about it again ("winget show") and compares the publisher with
    the one written in the catalogue. If they differ, or winget does not answer, that program is NOT installed.
    winget itself checks the SHA256 hash of the installer when it installs.

    It asks you to confirm each program. Use -WhatIf to run all the checks and see what would be installed,
    without installing anything. Some installers ask Windows for administrator rights (the UAC window).
    It never runs on its own: it is not part of the Terminal Pro installer.

    Returns one result per program: Key, Name, Id, Status (Installed, AlreadyUpToDate, AlreadyInstalled
    or Failed) and ExitCode.

.PARAMETER Key
    The key(s) of the programs, as Get-WinApp shows them. Several keys are allowed. Programs can also be
    sent in from Get-WinApp.

.PARAMETER Path
    Another catalogue file (same format). Leave out for the one that comes with the module.

.PARAMETER SkipPublisherCheck
    Install without comparing the publisher. Only for when winget shows its answer in a language this
    check cannot read, and you trust the program. Not recommended.

.EXAMPLE
    Install-WinApp vscode, git -WhatIf

.EXAMPLE
    Get-WinApp -Category Network | Install-WinApp

.EXAMPLE
    Install-WinApp treesize -Confirm:$false
#>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string[]]$Key,

        [string]$Path,

        [switch]$SkipPublisherCheck
    )

    begin {
        # Runs winget. Text it writes to stderr must not stop us (the exit code tells), but that is set only in here,
        # so the -ErrorAction the caller chose still counts for our own errors.
        $runWinget = {
            $ErrorActionPreference = 'Continue'
            winget @args 2>&1 | ForEach-Object { "$_" }
        }

        if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
            throw 'winget was not found. It comes with Windows 11 and recent Windows 10 (the App Installer from the Microsoft Store).'
        }
        $catalogArgs = @{}
        if ($Path) { $catalogArgs.Path = $Path }
        $catalog = @(Get-WinApp @catalogArgs)
    }

    process {
        foreach ($k in $Key) {
            $wanted = $k.Trim().ToLower()
            $app = $catalog | Where-Object { $_.Key -eq $wanted } | Select-Object -First 1
            if (-not $app) {
                Write-Error "'$k' is not in the catalogue. List the programs with: Get-WinApp"
                continue
            }

            # 1. Ask winget again who publishes this id. A changed publisher means: do not install.
            $show = @(& $runWinget show --id $app.Id -e --source winget --disable-interactivity)
            if (-not $SkipPublisherCheck) {
                $line = $show | Where-Object { $_ -match '^Publisher:\s' } | Select-Object -First 1
                if (-not $line) {
                    Write-Error "Could not read the publisher of $($app.Id) from winget, so $($app.Name) was not installed."
                    continue
                }
                $publisher = ($line -replace '^Publisher:\s*', '').Trim()
                if ($publisher -ne $app.Publisher) {
                    Write-Error "The publisher of $($app.Id) is now '$publisher'. The catalogue says '$($app.Publisher)'. $($app.Name) was not installed."
                    continue
                }
            }

            # 2. Confirm, or show with -WhatIf.
            $what = "$($app.Name) ($($app.Id), $($app.Publisher), $($app.License))"
            if (-not $PSCmdlet.ShouldProcess($what, 'Install with winget')) { continue }

            if ($app.Note) { Write-Host "  Note: $($app.Note)" }
            Write-Host "  Installing $($app.Name) ..."

            # 3. Install. winget checks the installer hash itself.
            $output = @(& $runWinget install --id $app.Id -e --source winget --silent --accept-package-agreements --accept-source-agreements --disable-interactivity)
            $code = $LASTEXITCODE

            # Exit codes from the winget documentation: 0x8A15002B = no newer version, 0x8A150061 = already installed.
            $status = switch ($code) {
                0           { 'Installed' }
                -1978335189 { 'AlreadyUpToDate' }
                -1978335135 { 'AlreadyInstalled' }
                default     { 'Failed' }
            }
            if ($status -eq 'Failed') {
                $tail = @($output | Where-Object { $_.Trim() -and $_ -notmatch '^\s*[\-\\|/]\s*$' } | Select-Object -Last 2) -join ' '
                Write-Warning "$($app.Name) did not install (exit code $code). $tail"
            }

            [pscustomobject]@{
                PSTypeName = 'TerminalPro.WinAppResult'
                Key        = $app.Key
                Name       = $app.Name
                Id         = $app.Id
                Status     = $status
                ExitCode   = $code
            }
        }
    }
}
