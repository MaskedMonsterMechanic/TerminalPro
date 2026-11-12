function Get-DiskStorage {
<#
.SYNOPSIS
    Shows the drives with free and total space.

.DESCRIPTION
    Returns one object per drive. Read-only.
    Volumes without a drive letter (recovery partitions and so on) are left out unless you use -All.

.PARAMETER ComputerName
    One or more other computers. Leave it out for this computer.

.PARAMETER All
    Also show volumes that have no drive letter.

.EXAMPLE
    Get-DiskStorage

.EXAMPLE
    Get-DiskStorage | Where-Object FreePercent -lt 15
#>
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [string[]]$ComputerName,

        [switch]$All
    )

    $targets = @('')
    if ($ComputerName) { $targets = $ComputerName }

    foreach ($target in $targets) {
        $session = $null
        try {
            if ($target) {
                $session = New-CimSession -ComputerName $target -ErrorAction Stop
                $volumes = @(Get-Volume -CimSession $session -ErrorAction Stop)
            }
            else {
                $volumes = @(Get-Volume -ErrorAction Stop)
            }
        }
        catch {
            $where = if ($target) { $target } else { 'this computer' }
            Write-Error "Could not read the disks of $where : $($_.Exception.Message)"
            continue
        }
        finally {
            if ($session) { Remove-CimSession $session }
        }

        $name = if ($target) { $target } else { $env:COMPUTERNAME }

        foreach ($v in $volumes | Sort-Object { [int]$_.DriveLetter }) {
            $hasLetter = [int]$v.DriveLetter -ne 0
            if (-not $hasLetter -and -not $All) { continue }

            # An empty card reader or DVD drive has size 0, so never divide by it.
            $freePercent = $null
            if ($v.Size -gt 0) { $freePercent = [math]::Round(100 * $v.SizeRemaining / $v.Size) }

            [pscustomobject]@{
                PSTypeName   = 'TerminalPro.DiskStorage'
                ComputerName = $name
                Drive        = if ($hasLetter) { [string]$v.DriveLetter } else { '' }
                Label        = $v.FileSystemLabel
                FileSystem   = $v.FileSystem
                Health       = [string]$v.HealthStatus
                FreeGB       = [math]::Round($v.SizeRemaining / 1GB, 2)
                FreePercent  = $freePercent
                SizeGB       = [math]::Round($v.Size / 1GB, 2)
            }
        }
    }
}
