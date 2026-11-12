<#
.SYNOPSIS
    From your own PC: your addresses, then DNS, ping and a few TCP ports on a target.

.DESCRIPTION
    A small client-side network check that mixes PaulShell tools:
      Get-NetIPAdapter   - the addresses on this PC (and the gateway)
      Resolve-HostList   - DNS for the target
      Test-HostList      - does it answer a ping?
      Test-TcpPort       - which of a few ports are open?

    With no target it uses your default gateway (from Get-NetIPAdapter), so it is
    runnable straight away from a client. Pass a name or address to check a server
    instead. Returns objects: first the local adapters (Kind = Local), then one
    row per port (Kind = Port).

    Pair it with the sheets: anipa (adapters), aping / ares (many hosts), and the
    Network pages for the ports you care about. The script is the loop; AI can
    widen the port list or point it at a CSV of servers.

.PARAMETER ComputerName
    The host to check. Default: the first IPv4 gateway on this PC.

.PARAMETER Port
    Ports to try. Default: 22, 80, 443, 3389, 445, 5985
    (SSH, HTTP, HTTPS, RDP, SMB, PowerShell remoting).

.PARAMETER TimeoutMs
    How long each port wait is, in milliseconds. Default 1000.

.PARAMETER LocalOnly
    Only show this PC's adapters. Do not probe a target.

.EXAMPLE
    .\Client-NetCheck.ps1
    Your adapters, then the gateway on the common ports.

.EXAMPLE
    .\Client-NetCheck.ps1 dc01
    Your adapters, then dc01 on the common ports.

.EXAMPLE
    .\Client-NetCheck.ps1 192.0.2.10 -Port 389, 636, 53 |
        Where-Object { $_.Kind -eq 'Port' -and $_.Open }
    Only the ports that answered on that host.

.EXAMPLE
    .\Client-NetCheck.ps1 -LocalOnly
    Just the addresses on this PC.
#>
[CmdletBinding()]
param(
    [Parameter(Position = 0, ValueFromPipeline)]
    [string]$ComputerName,

    [ValidateRange(1, 65535)]
    [int[]]$Port = @(22, 80, 443, 3389, 445, 5985),

    [ValidateRange(50, 60000)]
    [int]$TimeoutMs = 1000,

    [switch]$LocalOnly
)

begin {
    foreach ($needed in 'Get-NetIPAdapter', 'Resolve-HostList', 'Test-HostList', 'Test-TcpPort') {
        if (-not (Get-Command $needed -ErrorAction SilentlyContinue)) {
            throw "This script needs AdminTools and Network (command $needed). Open a PaulShell window, or run: Import-Module AdminTools, Network"
        }
    }
}

process {
    $adapters = @(Get-NetIPAdapter | Where-Object { $_.Status -eq 'Up' -and $_.Family -eq 'IPv4' -and $_.Type -eq 'Unicast' })
    foreach ($a in $adapters) {
        [pscustomobject]@{
            Kind      = 'Local'
            Name      = $a.Adapter
            Address   = $a.IPAddress
            Prefix    = $a.PrefixLength
            Gateway   = $a.Gateway
            Dns       = ($a.DnsServers -join ', ')
            Target    = $null
            Port      = $null
            Open      = $null
            Result    = $null
            DnsStatus = $null
            PingStatus= $null
        }
    }

    if ($LocalOnly) { return }

    $target = $ComputerName
    if (-not $target) {
        $target = ($adapters | Where-Object Gateway | Select-Object -First 1).Gateway
        if (-not $target) {
            Write-Warning 'No IPv4 gateway on this PC, and no -ComputerName given. Showing local adapters only.'
            return
        }
    }

    $dns  = @(Resolve-HostList -Name $target) | Select-Object -First 1
    $ping = @(Test-HostList -ComputerName $target) | Select-Object -First 1
    $ports = @(Test-TcpPort -ComputerName $target -Port $Port -TimeoutMs $TimeoutMs)

    foreach ($p in $ports) {
        [pscustomobject]@{
            Kind       = 'Port'
            Name       = $null
            Address    = if ($dns) { $dns.Result } elseif ($ping) { $ping.Address } else { $null }
            Prefix     = $null
            Gateway    = $null
            Dns        = $null
            Target     = $target
            Port       = $p.Port
            Open       = $p.Open
            Result     = $p.Result
            DnsStatus  = if ($dns)  { $dns.Status }  else { $null }
            PingStatus = if ($ping) { $ping.Status } else { $null }
        }
    }
}
