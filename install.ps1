<#
.SYNOPSIS
    Installs Terminal Pro for the current user. Remove it again with uninstall.ps1.

.DESCRIPTION
    Everything lives in one folder (default: %LOCALAPPDATA%\TerminalPro).
    The only file outside that folder is Windows Terminal's own settings.json,
    which is backed up first and restored by uninstall.ps1.

    No admin rights, no registry, no Program Files, nothing written to Documents.

    Use -WhatIf to see every step without doing anything.

.PARAMETER InstallPath
    Where Terminal Pro lives. Default: %LOCALAPPDATA%\TerminalPro

.PARAMETER SettingsPath
    Windows Terminal settings.json to write. Detected automatically; override for testing.

.PARAMETER SkipPowerShell
    Do not download the portable PowerShell 7.

.PARAMETER SkipModules
    Do not download the modules listed in modules.psd1.

.PARAMETER UpdateModules
    Fetch the modules in modules.psd1 again, even if they are already saved. Close other PowerShell windows first: a module that is loaded there cannot be replaced.

.PARAMETER SkipHelp
    Do not download the help files for PowerShell 7 (Get-Help then shows only the short form until you run Update-Help).

.EXAMPLE
    .\install.ps1 -WhatIf
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [string]$InstallPath = (Join-Path $env:LOCALAPPDATA 'TerminalPro'),
    [string]$SettingsPath,
    [switch]$SkipPowerShell,
    [switch]$SkipModules,
    [switch]$UpdateModules,
    [switch]$SkipHelp
)

$ErrorActionPreference = 'Stop'
$Source  = $PSScriptRoot
$Version = '0.1.0'

function Invoke-Step {
    param([string]$Text, [scriptblock]$Action)
    if ($WhatIfPreference) {
        Write-Host "[would] $Text" -ForegroundColor Yellow
        return
    }
    Write-Host "[ .. ] $Text" -ForegroundColor Cyan
    & $Action
}

function Find-TerminalSettings {
    $local = $env:LOCALAPPDATA
    $candidates = @(
        "$local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json",
        "$local\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json",
        "$local\Microsoft\Windows Terminal\settings.json"
    )
    foreach ($c in $candidates) {
        if (Test-Path (Split-Path $c)) { return $c }
    }
}

# ------------------------------------------------------------------ preflight (read-only)
Write-Host "Terminal Pro $Version" -ForegroundColor Cyan
if ($env:OS -ne 'Windows_NT') { throw 'Terminal Pro is for Windows.' }

$archRaw = if ($env:PROCESSOR_ARCHITEW6432) { $env:PROCESSOR_ARCHITEW6432 } else { $env:PROCESSOR_ARCHITECTURE }
$arch = switch ($archRaw) {
    'AMD64' { 'x64' }
    'ARM64' { 'arm64' }
    'x86'   { 'x86' }
    default { throw "Unsupported CPU: $archRaw" }
}

$InstallPath = [IO.Path]::GetFullPath($InstallPath).TrimEnd('\')
if (-not $SettingsPath) { $SettingsPath = Find-TerminalSettings }
if (-not $SettingsPath) {
    throw 'Windows Terminal was not found. Install "Windows Terminal" from the Microsoft Store, start it once, then run this again.'
}

foreach ($needed in 'terminal\settings.template.json', 'profile\profile.ps1', 'uninstall.ps1', 'modules.psd1') {
    if (-not (Test-Path (Join-Path $Source $needed))) { throw "Missing file in the Terminal Pro folder: $needed" }
}

# Render the settings now, so a broken template stops us before anything changes.
$template = Get-Content (Join-Path $Source 'terminal\settings.template.json') -Raw
$rendered = $template.Replace('{{HOME}}', $InstallPath.Replace('\', '\\'))
try { $null = $rendered | ConvertFrom-Json } catch { throw "The settings template is not valid JSON: $($_.Exception.Message)" }

$manifestPath = Join-Path $InstallPath 'install.json'
$prior = $null
if (Test-Path $manifestPath) { $prior = Get-Content $manifestPath -Raw | ConvertFrom-Json }

Write-Host "  Install folder   : $InstallPath"
Write-Host "  Terminal settings: $SettingsPath"
Write-Host "  CPU              : $arch"
if ($prior) { Write-Host '  Already installed: updating in place (your original settings backup is kept).' }
Write-Host ''

$pwshDir     = Join-Path $InstallPath 'pwsh'
$modulesDir  = Join-Path $InstallPath 'modules'
$script:PwshExe     = Join-Path $pwshDir 'pwsh.exe'
$script:PwshVersion = $null

# ------------------------------------------------------------------ 1. folders and files
Invoke-Step 'Create the Terminal Pro folder' {
    foreach ($d in '', 'images', 'profile', 'modules', 'backup') {
        New-Item -ItemType Directory -Path (Join-Path $InstallPath $d) -Force | Out-Null
    }
}

Invoke-Step 'Copy images, profile, modules and uninstall.ps1' {
    Copy-Item (Join-Path $Source 'terminal\images\*') (Join-Path $InstallPath 'images') -Recurse -Force
    Copy-Item (Join-Path $Source 'profile\*') (Join-Path $InstallPath 'profile') -Recurse -Force -Exclude '.gitkeep'
    Get-ChildItem (Join-Path $Source 'modules') -Directory -ErrorAction SilentlyContinue | ForEach-Object {
        Copy-Item $_.FullName $modulesDir -Recurse -Force
    }
    Copy-Item (Join-Path $Source 'uninstall.ps1') $InstallPath -Force
    Copy-Item (Join-Path $Source 'modules.psd1') $InstallPath -Force
}

# ------------------------------------------------------------------ 2. portable PowerShell 7
if ($SkipPowerShell) {
    Write-Host '[skip] PowerShell 7 (-SkipPowerShell)' -ForegroundColor DarkGray
}
else {
    Invoke-Step 'Download the latest PowerShell 7 (portable zip, checked against its published SHA256)' {
        $ProgressPreference = 'SilentlyContinue'
        [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
        $headers = @{ 'User-Agent' = 'TerminalPro-installer' }
        $release = Invoke-RestMethod 'https://api.github.com/repos/PowerShell/PowerShell/releases/latest' -Headers $headers
        $asset = $release.assets | Where-Object { $_.name -match "^PowerShell-[\d\.]+-win-$arch\.zip$" } | Select-Object -First 1
        if (-not $asset) { throw "No PowerShell 7 zip for $arch found in release $($release.tag_name)." }

        # Already have this exact version? Then there is nothing to download.
        $latest = $release.tag_name.TrimStart('v')
        if (Test-Path $script:PwshExe) {
            $have = (& $script:PwshExe -NoProfile -Command '$PSVersionTable.PSVersion.ToString()')
            if ($have -eq $latest) {
                $script:PwshVersion = $have
                Write-Host "       PowerShell $have is already the latest - nothing to download"
                return
            }
        }

        $zip = Join-Path ([IO.Path]::GetTempPath()) $asset.name
        Invoke-WebRequest $asset.browser_download_url -OutFile $zip -UseBasicParsing -Headers $headers

        $hashAsset = $release.assets | Where-Object { $_.name -eq 'hashes.sha256' } | Select-Object -First 1
        if ($hashAsset) {
            $hashText = (Invoke-WebRequest $hashAsset.browser_download_url -UseBasicParsing -Headers $headers).Content
            if ($hashText -is [byte[]]) {
                # The published file is UTF-16 with a byte-order mark. Detect it instead of guessing.
                $b = $hashText
                if     ($b.Length -ge 2 -and $b[0] -eq 0xFF -and $b[1] -eq 0xFE) { $hashText = [Text.Encoding]::Unicode.GetString($b, 2, $b.Length - 2) }
                elseif ($b.Length -ge 2 -and $b[0] -eq 0xFE -and $b[1] -eq 0xFF) { $hashText = [Text.Encoding]::BigEndianUnicode.GetString($b, 2, $b.Length - 2) }
                elseif ($b.Length -ge 3 -and $b[0] -eq 0xEF -and $b[1] -eq 0xBB -and $b[2] -eq 0xBF) { $hashText = [Text.Encoding]::UTF8.GetString($b, 3, $b.Length - 3) }
                else   { $hashText = [Text.Encoding]::UTF8.GetString($b) }
            }
            $line = ($hashText -split "`n") | Where-Object { $_ -match [regex]::Escape($asset.name) } | Select-Object -First 1
            if (-not $line) { Remove-Item $zip -Force; throw "No checksum listed for $($asset.name)." }
            $expected = ($line.Trim() -split '\s+')[0]
            $actual = (Get-FileHash $zip -Algorithm SHA256).Hash
            if ($actual -ne $expected) { Remove-Item $zip -Force; throw "Checksum mismatch for $($asset.name). The download was deleted." }
            Write-Host '       checksum OK'
        }
        else {
            Write-Warning 'This release has no hashes.sha256, so the download could not be verified.'
        }

        if (Test-Path $pwshDir) {
            if (-not $pwshDir.StartsWith($InstallPath + '\')) { throw 'Refusing to clear a folder outside the Terminal Pro folder.' }
            Remove-Item $pwshDir -Recurse -Force
        }
        Expand-Archive -Path $zip -DestinationPath $pwshDir -Force
        Remove-Item $zip -Force

        $script:PwshVersion = (& $script:PwshExe -NoProfile -Command '$PSVersionTable.PSVersion.ToString()')
        Write-Host "       PowerShell $script:PwshVersion ready"
    }
}

# ------------------------------------------------------------------ 2b. help files for PowerShell 7
# PowerShell ships without help text. Saving it now means Get-Help works from the first window.
# The help goes into the PowerShell 7 folder inside the Terminal Pro folder, so uninstall removes it too.
if ($SkipHelp) {
    Write-Host '[skip] Help files (-SkipHelp)' -ForegroundColor DarkGray
}
elseif (-not $WhatIfPreference -and -not (Test-Path $script:PwshExe)) {
    Write-Warning 'Help files need the portable PowerShell 7, which is not installed. Skipping help.'
}
else {
    Invoke-Step 'Download the help files for PowerShell 7 (so Get-Help works at once; a few minutes)' {
        # The command is passed encoded: Windows PowerShell 5.1 strips double quotes from a plain -Command text.
        # Progress is switched off, because a progress bar would come back through stderr as noise.
        $cmd = '$ProgressPreference = ''SilentlyContinue''; try { Update-Help -UICulture en-US -ErrorAction SilentlyContinue -ErrorVariable helpErrors; "Help saved. Modules that reported a problem: $($helpErrors.Count)" } catch { [Console]::Error.WriteLine($_.Exception.Message); exit 1 }'
        $encoded = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($cmd))
        # Text a native program writes to stderr must not stop the installer here; the exit code tells.
        $ErrorActionPreference = 'Continue'
        $out = & $script:PwshExe -NoProfile -NoLogo -EncodedCommand $encoded 2>&1 | ForEach-Object { "$_" }
        if ($LASTEXITCODE -ne 0) {
            Write-Warning "The help download did not finish: $($out -join ' ') You can run Update-Help later."
        }
        else {
            Write-Host "       $($out -join ' ')"
            Write-Host '       (A few modules have no help online. That is normal.)'
        }
    }
}
# ------------------------------------------------------------------ 3. modules (saved into our folder only)
if ($SkipModules) {
    Write-Host '[skip] Modules (-SkipModules)' -ForegroundColor DarkGray
}
else {
    $wanted = @((Import-PowerShellDataFile (Join-Path $Source 'modules.psd1')).Modules | Where-Object { $_.Enabled })
    if ($wanted.Count -eq 0) {
        Write-Host '[skip] Modules (none enabled in modules.psd1)' -ForegroundColor DarkGray
    }
    elseif (-not $WhatIfPreference -and -not (Test-Path $script:PwshExe)) {
        Write-Warning 'Modules need the portable PowerShell 7, which is not installed. Skipping modules.'
    }
    else {
        foreach ($m in $wanted) {
            # A module that is already saved is left alone. (Windows will not replace one that a PowerShell window has loaded.)
            if (-not $UpdateModules -and (Test-Path (Join-Path $modulesDir $m.Name))) {
                Write-Host "[skip] Module $($m.Name) is already saved (-UpdateModules fetches it again)" -ForegroundColor DarkGray
                continue
            }
            # A module that cannot be saved is a warning, not the end of the install.
            try {
                Invoke-Step "Save module $($m.Name) into the Terminal Pro folder" {
                    # Values go in through environment variables, so quotes or spaces in a path can never break the command.
                    $env:TERMINALPRO_MODULE = $m.Name
                    $env:TERMINALPRO_MODULES_DIR = $modulesDir
                    try {
                        $cmd = 'try { Save-PSResource -Name $env:TERMINALPRO_MODULE -Repository PSGallery -Path $env:TERMINALPRO_MODULES_DIR -TrustRepository -Quiet -ErrorAction Stop } catch { [Console]::Error.WriteLine($_.Exception.Message); exit 1 }'
                        $ErrorActionPreference = 'Continue'   # stderr text must not stop us here; the exit code tells
                        $out = & $script:PwshExe -NoProfile -NoLogo -Command $cmd 2>&1 | ForEach-Object { "$_" }
                        if ($LASTEXITCODE -ne 0) { throw "Could not save module $($m.Name): $($out -join ' ')" }
                    }
                    finally {
                        Remove-Item Env:\TERMINALPRO_MODULE, Env:\TERMINALPRO_MODULES_DIR -ErrorAction SilentlyContinue
                    }
                }
            }
            catch {
                Write-Warning "$($_.Exception.Message) The rest of the install goes on."
            }
        }
    }
}

# ------------------------------------------------------------------ 4. Windows Terminal settings
Invoke-Step 'Back up the current Terminal settings, then write the Terminal Pro settings' {
    $existedBefore = Test-Path $SettingsPath
    $backupPath = $null

    if ($prior -and $prior.settingsPath -eq $SettingsPath) {
        # Re-install: keep the first backup. Never back up our own file as "the original".
        $existedBefore = [bool]$prior.settingsExistedBefore
        $backupPath = $prior.backupPath
    }
    elseif ($existedBefore) {
        $backupPath = Join-Path $InstallPath 'backup\settings.original.json'
        Copy-Item $SettingsPath $backupPath -Force
        Write-Host "       backup: $backupPath"
    }

    $settingsDir = Split-Path $SettingsPath
    if (-not (Test-Path $settingsDir)) { New-Item -ItemType Directory -Path $settingsDir -Force | Out-Null }
    [IO.File]::WriteAllText($SettingsPath, $rendered, (New-Object System.Text.UTF8Encoding($false)))

    $manifest = [ordered]@{
        version                = $Version
        installedAt            = (Get-Date).ToString('s')
        installPath            = $InstallPath
        settingsPath           = $SettingsPath
        settingsExistedBefore  = $existedBefore
        backupPath             = $backupPath
        settingsHash           = (Get-FileHash $SettingsPath -Algorithm SHA256).Hash
        powershellVersion      = $script:PwshVersion
    }
    $manifest | ConvertTo-Json | Set-Content $manifestPath -Encoding UTF8
}

# ------------------------------------------------------------------ done
Write-Host ''
if ($WhatIfPreference) {
    Write-Host 'Dry run finished. Nothing was changed.' -ForegroundColor Yellow
}
else {
    Write-Host 'Terminal Pro is installed. Open Windows Terminal to see it.' -ForegroundColor Green
    Write-Host "Remove it again with:  & '$InstallPath\uninstall.ps1'"
}
