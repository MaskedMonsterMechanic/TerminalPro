function Get-PCInfo {
<#
.SYNOPSIS
    Gets basic information about this computer, or about other computers.

.DESCRIPTION
    Returns one object per computer, so you can sort, filter and export it.
    Read-only. Uses CIM instead of Get-ComputerInfo, which is much faster.

.PARAMETER ComputerName
    One or more other computers. Leave it out for this computer.

.EXAMPLE
    Get-PCInfo

.EXAMPLE
    Get-PCInfo -ComputerName SRV01, SRV02 | Select-Object Name, OS, Uptime
#>
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [string[]]$ComputerName
    )

    $targets = @('')
    if ($ComputerName) { $targets = $ComputerName }

    foreach ($target in $targets) {
        $cim = @{ ErrorAction = 'Stop' }
        if ($target) { $cim.ComputerName = $target }

        try {
            $cs  = Get-CimInstance -ClassName Win32_ComputerSystem  @cim
            $os  = Get-CimInstance -ClassName Win32_OperatingSystem @cim
            $cpu = Get-CimInstance -ClassName Win32_Processor       @cim | Select-Object -First 1
        }
        catch {
            $where = if ($target) { $target } else { 'this computer' }
            Write-Error "Could not read $where : $($_.Exception.Message)"
            continue
        }

        # The friendly version (for example 25H2) is only in the registry, so only for this computer.
        $version = $null
        if (-not $target) {
            $key = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -ErrorAction SilentlyContinue
            if ($key.DisplayVersion) { $version = $key.DisplayVersion } elseif ($key.ReleaseId) { $version = $key.ReleaseId }
        }

        [pscustomobject]@{
            PSTypeName   = 'TerminalPro.PCInfo'
            Name         = $cs.Name
            Owner        = $cs.PrimaryOwnerName
            Domain       = $cs.Domain
            Manufacturer = $cs.Manufacturer
            Model        = $cs.Model
            OS           = $os.Caption
            Version      = $version
            Build        = $os.Version
            Uptime       = $os.LocalDateTime - $os.LastBootUpTime
            CPU          = ($cpu.Name -replace '\s+', ' ').Trim()
            RamGB        = [math]::Round($cs.TotalPhysicalMemory / 1GB, 1)
        }
    }
}
