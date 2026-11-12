<#
.SYNOPSIS
    Quick health check across a list of servers: DNS, ping, remoting, OS and uptime.

.DESCRIPTION
    A small example of mixing PaulShell tools into one script:
      Resolve-HostList   - DNS name or address for each host
      Test-HostList      - which ones answer a ping
      Test-WSMan         - does remoting answer? (optional, -Remoting)
      Get-PCInfo         - OS, version and uptime when the host is up

    Pass names on the command line, or put one name per line in a text file
    (empty lines and lines starting with # are skipped).

    This is the pattern the cheat-sheets are for: look up a page (adsrv, adbuild,
    addns, ...), then ask an AI or write a loop that runs the same job on many
    hosts. The sheet is the recipe; the script is the repeatable work.

.PARAMETER ComputerName
    One or more host names or IP addresses.

.PARAMETER Path
    A text file with one name or address per line.

.PARAMETER Remoting
    Also check whether PowerShell remoting answers (Test-WSMan).

.EXAMPLE
    .\Lab-HealthCheck.ps1
    Checks this computer only.

.EXAMPLE
    .\Lab-HealthCheck.ps1 dc01, file01, file02 -Remoting
    Checks three servers, including remoting.

.EXAMPLE
    .\Lab-HealthCheck.ps1 -Path .\servers.txt -Remoting |
        Where-Object PingStatus -ne Up |
        Format-Table
    Only the hosts that failed a ping, from a file.
#>
[CmdletBinding()]
param(
    [Parameter(ValueFromPipeline)]
    [string[]]$ComputerName,

    [string]$Path,

    [switch]$Remoting
)

begin {
    foreach ($needed in 'Resolve-HostList', 'Test-HostList', 'Get-PCInfo') {
        if (-not (Get-Command $needed -ErrorAction SilentlyContinue)) {
            throw "This script needs the AdminTools module (command $needed). Open a PaulShell window, or run: Import-Module AdminTools"
        }
    }
    $names = [System.Collections.Generic.List[string]]::new()
}

process {
    foreach ($n in @($ComputerName)) {
        if ($n) { $names.Add($n.Trim()) }
    }
}

end {
    if ($Path) {
        if (-not (Test-Path -LiteralPath $Path)) { throw "File not found: $Path" }
        Get-Content -LiteralPath $Path | ForEach-Object {
            $line = $_.Trim()
            if ($line -and -not $line.StartsWith('#')) { $names.Add($line) }
        }
    }

    if ($names.Count -eq 0) { $names.Add('localhost') }

    $dns  = @(Resolve-HostList -Name $names)  | Group-Object -Property Target -AsHashTable -AsString
    $ping = @(Test-HostList -ComputerName $names) | Group-Object -Property Target -AsHashTable -AsString

    foreach ($name in $names) {
        $d = if ($dns  -and $dns.ContainsKey($name))  { @($dns[$name])[0] }  else { $null }
        $p = if ($ping -and $ping.ContainsKey($name)) { @($ping[$name])[0] } else { $null }

        $row = [ordered]@{
            Name       = $name
            Address    = if ($d) { $d.Result }  elseif ($p) { $p.Address } else { $null }
            DnsStatus  = if ($d) { $d.Status }  else { 'Unknown' }
            PingStatus = if ($p) { $p.Status }  else { 'Unknown' }
            Remoting   = $null
            OS         = $null
            Uptime     = $null
        }

        $up = $p -and ($p.Status -eq 'Up')

        if ($Remoting) {
            try {
                $null = Test-WSMan -ComputerName $name -ErrorAction Stop
                $row.Remoting = 'Up'
            }
            catch {
                $row.Remoting = 'Down'
            }
        }

        if ($up) {
            try {
                $local = @('localhost', '.', '127.0.0.1', '::1', $env:COMPUTERNAME)
                if ($local -contains $name) {
                    $info = Get-PCInfo -ErrorAction Stop
                }
                else {
                    $info = Get-PCInfo -ComputerName $name -ErrorAction Stop
                }
                $row.OS     = $info.OS
                $row.Uptime = $info.Uptime
            }
            catch {
                # Host answered a ping but not CIM/WMI. Leave OS and Uptime empty.
            }
        }

        [pscustomobject]$row
    }
}
