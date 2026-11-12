function Test-TcpPort {
<#
.SYNOPSIS
    Checks if TCP ports answer, quickly and with a timeout you choose.

.DESCRIPTION
    Tries to connect to each computer and port, and says Open, Closed (the computer answered "no")
    or Timeout (nothing answered: a firewall, or the computer is off). Only connects; sends no data.
    Faster and quieter than Test-NetConnection when you check several ports.

.PARAMETER ComputerName
    One or more names or addresses.

.PARAMETER Port
    One or more ports, 1 to 65535.

.PARAMETER TimeoutMs
    How long to wait for each connection, in milliseconds. Default 1000.

.EXAMPLE
    Test-TcpPort server01 22, 80, 443

.EXAMPLE
    'dc01', 'dc02' | Test-TcpPort -Port 389, 636, 3389 | Where-Object Open
#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [string[]]$ComputerName,

        [Parameter(Mandatory, Position = 1)]
        [ValidateRange(1, 65535)]
        [int[]]$Port,

        [ValidateRange(50, 60000)]
        [int]$TimeoutMs = 1000
    )

    process {
        foreach ($computer in $ComputerName) {
            foreach ($p in $Port) {
                $client = New-Object System.Net.Sockets.TcpClient
                $watch  = [System.Diagnostics.Stopwatch]::StartNew()
                $open   = $false
                $reason = ''
                try {
                    $task = $client.ConnectAsync($computer, $p)
                    if ($task.Wait($TimeoutMs)) {
                        $open   = $client.Connected
                        $reason = if ($open) { 'Open' } else { 'Closed' }
                    }
                    else {
                        $reason = 'Timeout'
                    }
                }
                catch {
                    $inner = $_.Exception
                    while ($inner.InnerException) { $inner = $inner.InnerException }
                    if ($inner -is [System.Net.Sockets.SocketException] -and $inner.SocketErrorCode -eq 'ConnectionRefused') { $reason = 'Closed' }
                    elseif ($inner -is [System.Net.Sockets.SocketException] -and $inner.SocketErrorCode -in 'HostNotFound', 'TryAgain', 'NoData') { $reason = 'Name not found' }
                    else { $reason = $inner.Message }
                }
                finally {
                    $watch.Stop()
                    $client.Close()
                }

                [pscustomobject]@{
                    PSTypeName   = 'TerminalPro.TcpPort'
                    ComputerName = $computer
                    Port         = $p
                    Open         = $open
                    Result       = $reason
                    Milliseconds = $watch.ElapsedMilliseconds
                }
            }
        }
    }
}
