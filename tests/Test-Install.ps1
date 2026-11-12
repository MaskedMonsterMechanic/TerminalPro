<#
.SYNOPSIS
    Tests install.ps1 and uninstall.ps1 in a throwaway TEMP folder.
    It never touches your real Terminal settings or your real install.

.PARAMETER WithDownload
    Also test the real PowerShell 7 download and the module download (needs internet, ~100 MB, goes to TEMP).
#>
[CmdletBinding()]
param([switch]$WithDownload)

$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$tmp  = Join-Path ([IO.Path]::GetTempPath()) ('TerminalProTest-' + [guid]::NewGuid().ToString('N').Substring(0, 8))
# A space and an apostrophe on purpose: real user names have both (e.g. "Jane Doe", "O'Neil").
$fakeHome     = Join-Path $tmp "Ho me's TerminalPro"
$fakeSettings = Join-Path $tmp 'terminal\settings.json'
$script:failed = 0

function Check([string]$Name, [bool]$Ok) {
    if ($Ok) { Write-Host "  PASS  $Name" -ForegroundColor Green }
    else     { Write-Host "  FAIL  $Name" -ForegroundColor Red; $script:failed++ }
}
function Hash($p) { (Get-FileHash $p -Algorithm SHA256).Hash }
function Quiet([scriptblock]$Block) { & $Block *>&1 | Out-Null }
function Expect-Throw([scriptblock]$Block) { try { Quiet $Block; $false } catch { $true } }

# Runs a Terminal profile's commandline the way Windows would, minus -NoExit so it ends by itself.
function Run-CommandLine([string]$CommandLine) {
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = 'cmd.exe'
    $psi.Arguments = '/s /c "' + ($CommandLine -replace ' -NoExit', '') + '"'
    $psi.UseShellExecute = $false
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError  = $true
    $p = [System.Diagnostics.Process]::Start($psi)
    $out = $p.StandardOutput.ReadToEnd() + $p.StandardError.ReadToEnd()
    $p.WaitForExit()
    [pscustomobject]@{ ExitCode = $p.ExitCode; Output = $out }
}

try {
    New-Item -ItemType Directory -Path (Split-Path $fakeSettings) -Force | Out-Null
    '{ "original": true }' | Set-Content $fakeSettings -Encoding ASCII
    $original = Hash $fakeSettings
    $args1 = @{ InstallPath = $fakeHome; SettingsPath = $fakeSettings }
    $fast  = if ($WithDownload) { @{} } else { @{ SkipPowerShell = $true; SkipModules = $true; SkipHelp = $true } }

    Write-Host "`nTest folder: $tmp`n"

    Write-Host '1. Install dry run changes nothing'
    Quiet { & "$root\install.ps1" @args1 @fast -WhatIf }
    Check 'install folder was not created' (-not (Test-Path $fakeHome))
    Check 'settings file is unchanged'     ((Hash $fakeSettings) -eq $original)

    $dry = & "$root\install.ps1" @args1 -SkipPowerShell -SkipModules -WhatIf *>&1 | Out-String
    Check 'dry run lists the help download step'  ($dry -match '\[would\] Download the help files')
    Check 'dry run: -SkipHelp leaves it out'     ((& "$root\install.ps1" @args1 -SkipPowerShell -SkipModules -SkipHelp -WhatIf *>&1 | Out-String) -notmatch 'help files for PowerShell 7')

    # The help command has double quotes inside. Windows PowerShell 5.1 strips them from a plain -Command, so it must go encoded.
    $installText = [IO.File]::ReadAllText("$root\install.ps1")
    Check 'help step passes its command encoded (quotes survive on 5.1)' ($installText -match 'Update-Help[^\r\n]*' -and $installText -match '-EncodedCommand \$encoded')

    # A module that is already saved is skipped (Windows cannot replace one that a PowerShell window has loaded),
    # unless -UpdateModules is given. A fake folder stands in for the saved module; nothing is downloaded (-WhatIf).
    $modHome = Join-Path $tmp 'modhome'
    New-Item -ItemType Directory -Path "$modHome\modules\posh-git" -Force | Out-Null
    $modArgs = @{ InstallPath = $modHome; SettingsPath = $fakeSettings }
    $modDry  = & "$root\install.ps1" @modArgs -SkipPowerShell -SkipHelp -WhatIf *>&1 | Out-String
    Check 'a module that is already saved is skipped'            ($modDry -match '\[skip\] Module posh-git is already saved')
    Check 'a module that is not saved yet would be saved'        ($modDry -match '\[would\] Save module CompletionPredictor')
    $modUpd  = & "$root\install.ps1" @modArgs -SkipPowerShell -SkipHelp -UpdateModules -WhatIf *>&1 | Out-String
    Check '-UpdateModules fetches a saved module again'          (($modUpd -match '\[would\] Save module posh-git') -and ($modUpd -notmatch 'already saved'))
    Check 'a module that cannot be saved is a warning, not the end' ($installText -match 'The rest of the install goes on')

    Write-Host '2. Install'
    Quiet { & "$root\install.ps1" @args1 @fast }
    Check 'install.json exists'          (Test-Path "$fakeHome\install.json")
    Check 'uninstall.ps1 copied in'      (Test-Path "$fakeHome\uninstall.ps1")
    Check 'profile copied in'            (Test-Path "$fakeHome\profile\profile.ps1")
    Check '4 images copied in'           ((Get-ChildItem "$fakeHome\images" -File).Count -eq 4)
    $text = Get-Content $fakeSettings -Raw
    Check 'no {{HOME}} left in settings' ($text -notmatch '\{\{HOME\}\}')
    $json = $text | ConvertFrom-Json
    Check 'settings is valid JSON, 4 profiles' ($json.profiles.list.Count -eq 4)
    Check 'PowerShell is the first profile'    ($json.profiles.list[0].name -eq 'PowerShell')
    Check 'image paths point into the install folder' ($json.profiles.list[0].backgroundImage -like "$fakeHome*")
    Check 'every image path exists'      (@($json.profiles.list | Where-Object { $_.backgroundImage } | Where-Object { -not (Test-Path $_.backgroundImage) }).Count -eq 0)
    Check 'original settings were backed up' ((Hash "$fakeHome\backup\settings.original.json") -eq $original)
    Check 'settings file has no BOM'     ([IO.File]::ReadAllBytes($fakeSettings)[0] -eq [byte][char]'{')

    Write-Host '2a. The Windows PowerShell profile really starts and loads our profile'
    $wps = $json.profiles.list | Where-Object { $_.name -eq 'Windows PowerShell' }
    $r = Run-CommandLine $wps.commandline
    Check 'exit code 0'                    ($r.ExitCode -eq 0)
    Check 'profile ran (banner printed)'   ($r.Output -match 'PowerShell Version:')

    if ($WithDownload) {
        Write-Host '2b. Real PowerShell 7 and module download'
        Check 'portable pwsh.exe exists' (Test-Path "$fakeHome\pwsh\pwsh.exe")
        if (Test-Path "$fakeHome\pwsh\pwsh.exe") {
            $v = & "$fakeHome\pwsh\pwsh.exe" -NoProfile -Command '$PSVersionTable.PSVersion.ToString()'
            Check "pwsh runs (version $v)" ($v -match '^\d+\.\d+')
        }
        Check 'posh-git saved in our folder' (Test-Path "$fakeHome\modules\posh-git")
        $core = $json.profiles.list | Where-Object { $_.name -eq 'PowerShell' }
        $r7 = Run-CommandLine $core.commandline
        Check 'PowerShell 7 profile: exit code 0'  ($r7.ExitCode -eq 0)
        Check 'PowerShell 7 profile ran (banner printed)' ($r7.Output -match 'PowerShell Version: 7')
    }

    Write-Host '3. Installing again keeps the ORIGINAL backup'
    Quiet { & "$root\install.ps1" @args1 @fast }
    Check 'backup is still the original' ((Hash "$fakeHome\backup\settings.original.json") -eq $original)

    Write-Host '4. Uninstall dry run changes nothing'
    Quiet { & "$fakeHome\uninstall.ps1" -InstallPath $fakeHome -WhatIf }
    Check 'install folder still there' (Test-Path $fakeHome)
    Check 'settings still Terminal Pro' ((Hash $fakeSettings) -ne $original)

    Write-Host '5. Uninstall refuses if settings were edited after install'
    Add-Content $fakeSettings '// my edit'
    $edited = Hash $fakeSettings
    Check 'uninstall stops with an error'  (Expect-Throw { & "$fakeHome\uninstall.ps1" -InstallPath $fakeHome })
    Check 'nothing was removed'            (Test-Path $fakeHome)
    Check 'edited settings left alone'     ((Hash $fakeSettings) -eq $edited)

    Write-Host '6. Uninstall -Force from the installed copy'
    Quiet { & "$fakeHome\uninstall.ps1" -InstallPath $fakeHome -Force }
    Check 'install folder is gone'          (-not (Test-Path $fakeHome))
    Check 'original settings are back, byte for byte' ((Hash $fakeSettings) -eq $original)

    Write-Host '7. Uninstall with nothing installed is refused'
    Check 'stops with an error' (Expect-Throw { & "$root\uninstall.ps1" -InstallPath $fakeHome })
}
finally {
    if ($tmp.StartsWith([IO.Path]::GetTempPath()) -and (Test-Path $tmp)) {
        Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue
    }
}

Write-Host ''
if ($script:failed -eq 0) { Write-Host 'All checks passed.' -ForegroundColor Green }
else { Write-Host "$script:failed check(s) failed." -ForegroundColor Red; exit 1 }
