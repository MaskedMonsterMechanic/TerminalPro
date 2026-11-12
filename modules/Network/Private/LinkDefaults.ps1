# Default bandwidth (kbps) and delay (microseconds) of Cisco interface types.
# Used by Get-EigrpMetric and Get-OspfCost so you can type "FastEthernet" instead of the numbers.
# Serial links: Cisco defaults to T1 values (1544 kbps, 20000 us) whatever the real speed is.

$script:LinkDefaults = [ordered]@{
    'Ethernet'           = @{ Bandwidth = 10000;    Delay = 1000 }
    'FastEthernet'       = @{ Bandwidth = 100000;   Delay = 100 }
    'GigabitEthernet'    = @{ Bandwidth = 1000000;  Delay = 10 }
    'TenGigabitEthernet' = @{ Bandwidth = 10000000; Delay = 10 }
    'Serial'             = @{ Bandwidth = 1544;     Delay = 20000 }
    'T1'                 = @{ Bandwidth = 1544;     Delay = 20000 }
    'E1'                 = @{ Bandwidth = 2048;     Delay = 20000 }
}

function Resolve-NetLinkType {
    # Matches a typed name (fe, FastEthernet, gig...) to a key of $script:LinkDefaults.
    param([Parameter(Mandatory)][string]$Name)
    $found = @($script:LinkDefaults.Keys | Where-Object { $_ -like "$Name*" })
    if ($found.Count -eq 1) { return $found[0] }
    $exact = @($script:LinkDefaults.Keys | Where-Object { $_ -eq $Name })
    if ($exact.Count -eq 1) { return $exact[0] }
    $alias = @{ 'fa' = 'FastEthernet'; 'fe' = 'FastEthernet'; 'gi' = 'GigabitEthernet'; 'gig' = 'GigabitEthernet'; 'ge' = 'GigabitEthernet'; 'te' = 'TenGigabitEthernet'; 'eth' = 'Ethernet'; 'se' = 'Serial' }
    if ($alias.ContainsKey($Name.ToLower())) { return $alias[$Name.ToLower()] }
    throw "'$Name' is not a known link type. Use one of: $($script:LinkDefaults.Keys -join ', ')."
}
