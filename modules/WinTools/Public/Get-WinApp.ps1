function Get-WinApp {
<#
.SYNOPSIS
    Lists the programs in the Terminal Pro app catalogue (free, checked programs you can install with Install-WinApp).

.DESCRIPTION
    Read-only. Returns one object per program: Key, Name, Category, License, Description, and also Id (the winget
    id), Publisher, Homepage and Note. The catalogue is the file Data\apps.psd1 inside the WinTools module.

    Every program in it is a free program (open source, or freeware from its maker) from the winget community
    repository. Each entry was checked with "winget show" on the date shown in the file: the program exists,
    the publisher and the licence are written down, and the installer has a SHA256 hash that winget checks
    when it installs. Install-WinApp checks the publisher again right before it installs.

    Free here means: free to download and use. Read the Note and the licence if you use a program at work.

.PARAMETER Name
    Part of a key or a name, for example nmap or "terminal". Wildcards work. Leave out to list everything.

.PARAMETER Category
    One or more categories: Developer, Terminal, Network, System, Security, Media. Wildcards work.

.PARAMETER Path
    Another catalogue file (same format). Leave out for the one that comes with the module.

.EXAMPLE
    Get-WinApp

.EXAMPLE
    Get-WinApp -Category Network

.EXAMPLE
    Get-WinApp treesize | Format-List *
#>
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [string[]]$Name,

        [string[]]$Category,

        [string]$Path
    )

    if (-not $Path) { $Path = $script:AppCatalogPath }
    if (-not (Test-Path -LiteralPath $Path)) { throw "App catalogue not found: $Path" }
    $data = Import-PowerShellDataFile -LiteralPath $Path

    $required = 'Key', 'Name', 'Category', 'Id', 'Publisher', 'License', 'Homepage', 'Description'
    $seenKeys = @{}
    $seenIds  = @{}
    $apps = foreach ($a in @($data.Apps)) {
        foreach ($field in $required) {
            if (-not $a[$field]) { throw "App catalogue: an entry is missing '$field' (key: $($a.Key))." }
        }
        if ($a.Id -notmatch '^[A-Za-z0-9][A-Za-z0-9.+\-]*$') { throw "App catalogue: '$($a.Id)' is not a valid winget id." }
        if ($a.Key -notmatch '^[a-z0-9\-]+$')               { throw "App catalogue: the key '$($a.Key)' may only use lower-case letters, digits and hyphens." }
        if ($seenKeys.ContainsKey($a.Key)) { throw "App catalogue: the key '$($a.Key)' is used twice." }
        if ($seenIds.ContainsKey($a.Id.ToLower())) { throw "App catalogue: the id '$($a.Id)' is used twice." }
        $seenKeys[$a.Key] = $true
        $seenIds[$a.Id.ToLower()] = $true

        [pscustomobject]@{
            PSTypeName  = 'TerminalPro.WinApp'
            Key         = [string]$a.Key
            Name        = [string]$a.Name
            Category    = [string]$a.Category
            License     = [string]$a.License
            Description = [string]$a.Description
            Id          = [string]$a.Id
            Publisher   = [string]$a.Publisher
            Homepage    = [string]$a.Homepage
            Note        = [string]$a.Note
        }
    }
    $apps = @($apps)

    if ($Name) {
        $patterns = foreach ($n in $Name) { if ($n -match '[\*\?\[]') { $n } else { "*$n*" } }
        $apps = @($apps | Where-Object { $app = $_; $patterns | Where-Object { $app.Key -like $_ -or $app.Name -like $_ } })
        if ($apps.Count -eq 0) { Write-Warning "No program matches: $($Name -join ', '). List them all with: Get-WinApp" }
    }
    if ($Category) {
        $apps = @($apps | Where-Object { $app = $_; $Category | Where-Object { $app.Category -like $_ } })
    }

    $apps | Sort-Object Category, Name
}
