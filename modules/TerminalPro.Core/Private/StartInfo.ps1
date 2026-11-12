# Short, one-line-per-item views for the start page. Not exported.
# They take the objects from Get-NetIPAdapter and Get-DiskStorage and draw them in the same style as the menu.

function Get-TPFreeColor {
    # More than half free = green, 10% up to half = yellow, under 10% = red.
    param($Percent)
    if ($null -eq $Percent) { return $script:Colors.Time }
    if ($Percent -ge 50) { return 'Green' }
    if ($Percent -ge 10) { return 'Yellow' }
    'Red'
}

function Write-StartAdapters {
    # One line per adapter address: name, address/prefix, gateway, DNS, speed, description.
    param([object[]]$Items)

    $rows = @(foreach ($a in $Items) {
        $address = if ($a.IPAddress) { "$($a.IPAddress)/$($a.PrefixLength)" } else { '-' }
        $dns     = @($a.DnsServers | Where-Object { $_ }) -join ','
        $desc    = [string]$a.Description
        if ($a.Status -and $a.Status -ne 'Up') { $desc = "$desc ($($a.Status))" }
        [pscustomobject]@{
            Adapter = [string]$a.Adapter
            Address = $address
            Gateway = if ($a.Gateway) { [string]$a.Gateway } else { '-' }
            Dns     = if ($dns) { $dns } else { '-' }
            Speed   = if ($a.Speed) { [string]$a.Speed } else { '-' }
            Desc    = $desc
        }
    })
    if ($rows.Count -eq 0) { return }

    $heads  = @('ADAPTER', 'ADDRESS', 'GATEWAY', 'DNS', 'SPEED')
    $widths = @(0, 0, 0, 0, 0, 0)
    for ($i = 0; $i -lt 5; $i++) {
        $prop = @('Adapter', 'Address', 'Gateway', 'Dns', 'Speed')[$i]
        $widths[$i] = [int](@($heads[$i].Length) + @($rows | ForEach-Object { $_.$prop.Length }) | Measure-Object -Maximum).Maximum
    }

    # What is left of the window goes to the description. It is cut so a line never wraps.
    $room = (Get-TPWidth) - (($widths[0..4] | Measure-Object -Sum).Sum + 6 + 1)
    $colors = @($null, $script:Colors.Output, $null, $null, $script:Colors.Time, $script:Colors.Time)

    Write-SheetSectionTitle -Title 'NETWORK' -Width ([Math]::Min((Get-TPWidth), 100))
    Write-SheetCells -Cells ($heads + 'DESCRIPTION') -Widths $widths -Colors @($script:Colors.Time, $script:Colors.Time, $script:Colors.Time, $script:Colors.Time, $script:Colors.Time, $script:Colors.Time)
    foreach ($r in $rows) {
        $text = $r.Desc
        if ($room -gt 10 -and $text.Length -gt $room) { $text = $text.Substring(0, $room - 3).TrimEnd() + '...' }
        Write-SheetCells -Cells @($r.Adapter, $r.Address, $r.Gateway, $r.Dns, $r.Speed, $text) -Widths $widths -Colors $colors
    }
}

function Write-StartDisks {
    # One line per drive: letter, label, free GB, size GB, free percent and a small bar. No computer name.
    param([object[]]$Items)

    $rows = @(foreach ($d in $Items) {
        $pct = $d.FreePercent
        $filled = 0
        if ($null -ne $pct) { $filled = [int][Math]::Min(10, [Math]::Max(0, [Math]::Round($pct / 10))) }
        $note = ''
        if ($d.Health -and $d.Health -ne 'Healthy') { $note = "  ! $($d.Health)" }
        [pscustomobject]@{
            Drive = if ($d.Drive) { "$($d.Drive):" } else { '-' }
            Label = [string]$d.Label
            Free  = ('{0:F1}' -f $d.FreeGB)
            Size  = ('{0:F1}' -f $d.SizeGB)
            Pct   = if ($null -ne $pct) { "$pct%" } else { '-' }
            Bar   = ('[' + ('#' * $filled) + ('.' * (10 - $filled)) + ']' + $note)
            Color = Get-TPFreeColor $pct
        }
    })
    if ($rows.Count -eq 0) { return }

    $widths = @(
        [Math]::Max(5, [int]($rows | ForEach-Object { $_.Drive.Length } | Measure-Object -Maximum).Maximum),
        [Math]::Max(5, [int]($rows | ForEach-Object { $_.Label.Length } | Measure-Object -Maximum).Maximum),
        [Math]::Max(7, [int]($rows | ForEach-Object { $_.Free.Length }  | Measure-Object -Maximum).Maximum),
        [Math]::Max(7, [int]($rows | ForEach-Object { $_.Size.Length }  | Measure-Object -Maximum).Maximum),
        [Math]::Max(5, [int]($rows | ForEach-Object { $_.Pct.Length }   | Measure-Object -Maximum).Maximum),
        0
    )
    $headColors = @($script:Colors.Time, $script:Colors.Time, $script:Colors.Time, $script:Colors.Time, $script:Colors.Time, $script:Colors.Time)

    Write-SheetSectionTitle -Title 'DISKS' -Width ([Math]::Min((Get-TPWidth), 100))
    Write-SheetCells -Cells @('DRIVE', 'LABEL', 'FREE GB'.PadLeft($widths[2]), 'SIZE GB'.PadLeft($widths[3]), 'FREE'.PadLeft($widths[4]), 'FREE SPACE') -Widths $widths -Colors $headColors
    foreach ($r in $rows) {
        Write-SheetCells -Cells @(
            $r.Drive, $r.Label, $r.Free.PadLeft($widths[2]), $r.Size.PadLeft($widths[3]), $r.Pct.PadLeft($widths[4]), $r.Bar
        ) -Widths $widths -Colors @($null, $script:Colors.Output, $r.Color, $script:Colors.Time, $r.Color, $r.Color)
    }
}

function Write-StartPC {
    # The computer: its name as the header, then one short line each for system, hardware, CPU, memory, uptime, owner.
    param([object[]]$Items)

    foreach ($pc in $Items) {
        $name = if ($pc.Name) { ([string]$pc.Name).ToUpper() } else { 'THIS PC' }

        $system = @($pc.OS, $pc.Version) | Where-Object { $_ }
        $system = ($system -join ' ')
        if ($pc.Build) { $system += "  (build $($pc.Build))" }

        $hardware = (@($pc.Manufacturer, $pc.Model) | Where-Object { $_ }) -join '  '

        $uptime = ''
        if ($pc.Uptime -is [TimeSpan]) {
            if ($pc.Uptime.Days -gt 0) { $uptime = '{0}d {1}h {2}m' -f $pc.Uptime.Days, $pc.Uptime.Hours, $pc.Uptime.Minutes }
            else { $uptime = '{0}h {1}m' -f $pc.Uptime.Hours, $pc.Uptime.Minutes }
        }

        $owner = (@($pc.Owner) | Where-Object { $_ }) -join ''
        if ($pc.Domain) { $owner = (@($owner, "($($pc.Domain))") | Where-Object { $_ }) -join '  ' }

        $ram = if ($null -ne $pc.RamGB) { '{0:F1} GB' -f $pc.RamGB } else { '' }

        $lines = @(
            @('SYSTEM',   $system),
            @('HARDWARE', $hardware),
            @('CPU',      [string]$pc.CPU),
            @('MEMORY',   $ram),
            @('UPTIME',   $uptime),
            @('OWNER',    $owner)
        ) | Where-Object { $_[1] }

        Write-SheetSectionTitle -Title $name -Width ([Math]::Min((Get-TPWidth), 100))
        foreach ($l in $lines) {
            Write-SheetCells -Cells @($l[0], $l[1]) -Widths @(8, 0) -Colors @($script:Colors.Time, $null)
        }
    }
}