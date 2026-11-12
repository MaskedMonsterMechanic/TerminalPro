@{
    RootModule            = 'Network.psm1'
    ModuleVersion         = '2.0.0'
    GUID                  = '5b1f6d3e-8a47-4c92-9e0b-3d7a21c4f8e6'
    Author                = 'PaulShell'
    CompanyName           = 'PaulShell'
    Copyright             = '(c) 2026 PaulShell. MIT licence.'
    Description           = 'Networking tools (IPv4 and IPv6 calculators, subnetting, VLSM, route summary, converters, port test) and networking reference pages (router and switch setup, DHCP, NAT, static routing, troubleshooting, theory).'
    PowerShellVersion     = '5.1'
    CompatiblePSEditions  = @('Desktop', 'Core')
    RequiredModules       = @('TerminalPro.Core')
    FormatsToProcess      = @('Network.Format.ps1xml')
    FunctionsToExport     = @(
        'Show-NetCommands',
        'Get-NetCalculator', 'Get-IPv6Calculator', 'Get-SubnetTable', 'Split-Subnet', 'Get-VlsmPlan', 'Get-RouteSummary',
        'Test-IPInSubnet', 'Convert-NetNumber', 'ConvertTo-Eui64', 'ConvertTo-SubnetMask', 'ConvertTo-PrefixLength', 'Test-TcpPort', 'Get-EigrpMetric', 'Get-OspfCost',
        'Show-NetAcronyms', 'Show-NetBasic', 'Show-NetBinHexa', 'Show-NetDHCP', 'Show-NetHierarchy', 'Show-NetInterVlan', 'Show-NetNat', 'Show-NetOsiModel', 'Show-NetPortNumbers', 'Show-NetStatic', 'Show-NetSubnetting', 'Show-NetWan', 'Show-CcnaCli', 'Show-CcnaRouting', 'Show-CcnaAcl', 'Show-CcnaDynamic', 'Show-CcnaOspf', 'Show-CcnaHsrp',
        'Show-CcnpEigrp', 'Show-CcnpEigrpDual', 'Show-CcnpEigrpNamed',
        'Show-CcnpOspf', 'Show-CcnpOspfAdvanced',
        'Show-CcnpBgp', 'Show-CcnpRedistribution',
        'Show-CcnpSecurity', 'Show-CcnpIpv6', 'Show-CcnpVpn',
        'Show-CcieBlueprint', 'Show-CcieSwitching', 'Show-CcieRouting', 'Show-CcieOspf', 'Show-CcieEigrp',
        'Show-CcieBgp', 'Show-CcieMulticast', 'Show-CcieSwitchSecurity',
        'Show-CcieQos', 'Show-CcieSdn', 'Show-CcieAutomation', 'Show-ThousandEyes',
        'Show-CcieQos', 'Show-CcieSdn', 'Show-CcieAutomation', 'Show-ThousandEyes',
        'Show-PCTrouble', 'Show-RouterBasic', 'Show-RouterReset', 'Show-RouterTrouble', 'Show-SwitchBasic', 'Show-SwitchReset', 'Show-SwitchTrouble'
    )
    CmdletsToExport       = @()
    VariablesToExport     = @()
    AliasesToExport       = @(
        'netcmd', 'netcalc', 'netcalc6', 'netsubt', 'netsplit', 'netvlsm', 'netsum',
        'netin', 'netconv', 'neteui', 'netmask', 'netpfx', 'nettp', 'ccnpmetric', 'ccnacost',
        'netacro', 'ccnacli', 'ccnaroute', 'ccnaacl', 'ccnadyn', 'ccnaospf', 'ccnahsrp',
        'ccnpeigrp', 'ccnpeigrp2', 'ccnpeigrp3',
        'ccnpospf', 'ccnpospf2',
        'ccnpbgp', 'ccnpredist',
        'ccnpsec', 'ccnpipv6', 'ccnpvpn',
        'ccie', 'ccieswitch', 'ccierouting', 'ccieospf', 'ccieeigrp',
        'cciebgp', 'cciemcast', 'ccieswsec',
        'ccieqos', 'cciesdn', 'ccieauto', 'ccnpte',
        'ccieqos', 'cciesdn', 'ccieauto', 'ccnpte',
        'netbc', 'netbh', 'netdhcp', 'nethiarc', 'netiv', 'netnt', 'netosi', 'netpct', 'netpn', 'netrob', 'netror', 'netrot', 'netsta', 'netsub', 'netswb', 'netswr', 'netswt', 'netwan'
    )
    PrivateData           = @{
        PSData = @{
            Tags = @('TerminalPro', 'Network', 'Subnet', 'IPv4', 'IPv6', 'CCNA')
        }
    }
}






