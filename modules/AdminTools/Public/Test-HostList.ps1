function Test-HostList {
<#
.SYNOPSIS
    Pings many computers and tells you which are up, which are down, and which have no DNS name.

.DESCRIPTION
    One result per computer, so a dead host never stops the rest. Works the same in Windows PowerShell 5.1
    and PowerShell 7. Replaces the old "Test-Connection (Multiple)" scripts.

.PARAMETER ComputerName
    One or more host names or IP addresses. Can also come from the pipeline.

.PARAMETER Path
    A text file with one name or address per line. Empty lines and lines starting with # are skipped.

.PARAMETER Count
    How many pings per computer (1 to 20, default 1).

.PARAMETER TimeoutMs
    How long to wait for each reply, in milliseconds (default 2000).

.EXAMPLE
    Test-HostList localhost, 127.0.0.1

.EXAMPLE
    Test-HostList -Path .\servers.txt -Count 3 | Where-Object Status -ne Up
#>
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, ValueFromPipeline)]
        [string[]]$ComputerName,

        [string]$Path,

        [ValidateRange(1, 20)]
        [int]$Count = 1,

        [ValidateRange(100, 60000)]
        [int]$TimeoutMs = 2000
    )

    begin {
        $targets = New-Object System.Collections.Generic.List[string]
    }
    process {
        foreach ($n in $ComputerName) {
            if ($n -and $n.Trim()) { $targets.Add($n.Trim()) }
        }
    }
    end {
        if ($Path) {
            if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { throw "The file was not found: $Path" }
            foreach ($line in Get-Content -LiteralPath $Path) {
                $t = $line.Trim()
                if ($t -and -not $t.StartsWith('#')) { $targets.Add($t) }
            }
        }
        if ($targets.Count -eq 0) { throw 'Give at least one computer with -ComputerName or -Path.' }

        foreach ($target in $targets) {
            $ping = New-Object System.Net.NetworkInformation.Ping
            $replies = 0
            $times = @()
            $address = $null
            $status = 'Down'
            try {
                for ($i = 0; $i -lt $Count; $i++) {
                    $r = $ping.Send($target, $TimeoutMs)
                    if ($r.Status -eq [System.Net.NetworkInformation.IPStatus]::Success) {
                        $replies++
                        $times += $r.RoundtripTime
                        $address = $r.Address.ToString()
                    }
                }
                if ($replies -gt 0) { $status = 'Up' }
            }
            catch {
                # The name could not be turned into an address (or the address is not valid).
                $status = 'NoDns'
            }
            finally {
                $ping.Dispose()
            }

            [pscustomobject]@{
                PSTypeName = 'TerminalPro.HostPing'
                Target     = $target
                Status     = $status
                Address    = $address
                AvgMs      = if ($times.Count) { [math]::Round(($times | Measure-Object -Average).Average, 1) } else { $null }
                Replies    = "$replies/$Count"
            }
        }
    }
}
