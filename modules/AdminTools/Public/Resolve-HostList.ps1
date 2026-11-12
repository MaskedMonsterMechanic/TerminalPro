function Resolve-HostList {
<#
.SYNOPSIS
    Looks up many names or IP addresses in DNS and tells you what each one is.

.DESCRIPTION
    Give it host names and it returns their IP addresses. Give it IP addresses and it returns their host
    names. Names and addresses can be mixed. One result per input, so a failed lookup never stops the rest.
    Replaces the old separate scripts for "name to IP" and "IP to name".

.PARAMETER Name
    One or more host names or IP addresses. Can also come from the pipeline.

.PARAMETER Path
    A text file with one name or address per line. Empty lines and lines starting with # are skipped.

.EXAMPLE
    Resolve-HostList localhost, 127.0.0.1

.EXAMPLE
    Resolve-HostList -Path .\hosts.txt | Where-Object Status -eq NotFound
#>
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, ValueFromPipeline)]
        [string[]]$Name,

        [string]$Path
    )

    begin {
        $targets = New-Object System.Collections.Generic.List[string]
    }
    process {
        foreach ($n in $Name) {
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
        if ($targets.Count -eq 0) { throw 'Give at least one name or address with -Name or -Path.' }
        if (-not (Get-Command Resolve-DnsName -ErrorAction SilentlyContinue)) { throw 'Resolve-DnsName is not available on this computer.' }

        foreach ($target in $targets) {
            $ip = $null
            $isAddress = [System.Net.IPAddress]::TryParse($target, [ref]$ip)
            $direction = if ($isAddress) { 'IP to name' } else { 'Name to IP' }
            $values = @()
            $status = 'NotFound'

            try {
                $records = @(Resolve-DnsName -Name $target -ErrorAction Stop)
                if ($isAddress) { $values = @($records | Where-Object { $_.Type -eq 'PTR' } | ForEach-Object { $_.NameHost }) }
                else            { $values = @($records | Where-Object { $_.Type -in 'A', 'AAAA' } | ForEach-Object { $_.IPAddress }) }
                if ($values.Count -gt 0) { $status = 'Found' }
            }
            catch {
                $status = 'NotFound'
            }

            [pscustomobject]@{
                PSTypeName = 'TerminalPro.HostResolution'
                Target     = $target
                Direction  = $direction
                Result     = ($values -join ', ')
                Status     = $status
            }
        }
    }
}
