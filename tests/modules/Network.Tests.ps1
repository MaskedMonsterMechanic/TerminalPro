# Extra tests for Network. Dot-sourced by Test-Modules.ps1 (so Check, $name, $modules and $dir are available).
#
# Every expected answer below was worked out by hand (or comes from the RFCs / Cisco documentation),
# so a mistake in the calculator cannot hide behind a test that makes the same mistake.
#
# SAFETY: nothing here leaves this computer. Test-TcpPort only talks to a listener this test opens
# on the loopback address (127.0.0.1) and to a name that cannot exist.

function Throws([scriptblock]$Block) { try { & $Block *>$null; $false } catch { $true } }
function Same($Actual, $Expected) { ($Actual -ceq $Expected) -or (($Actual -is [ValueType]) -and ($Actual -eq $Expected)) }

Write-Host '  -- Network: the calculators (answers worked out by hand)'

$code = Get-ChildItem $dir.FullName -Recurse -Include *.ps1, *.psm1 | ForEach-Object { [IO.File]::ReadAllText($_.FullName) }
Check 'no hard-coded user or Program Files paths in the code' (-not ($code -match 'C:\\Users|Program Files'))

# ------------------------------------------------------------------ IPv4 calculator
$r = Get-NetCalculator 192.168.1.10/24
Check 'calc /24: network, broadcast, host range'  ((Same $r.Network '192.168.1.0') -and (Same $r.Broadcast '192.168.1.255') -and (Same $r.FirstHost '192.168.1.1') -and (Same $r.LastHost '192.168.1.254'))
Check 'calc /24: mask, wildcard, hosts, class'    ((Same $r.Mask '255.255.255.0') -and (Same $r.Wildcard '0.0.0.255') -and $r.UsableHosts -eq 254 -and $r.TotalAddresses -eq 256 -and $r.Class -ceq 'C')
Check 'calc /24: type and binary'                 (($r.Type -ceq 'Private (RFC 1918)') -and ($r.BinaryAddress -ceq '11000000.10101000.00000001.00001010') -and ($r.BinaryMask -ceq '11111111.11111111.11111111.00000000'))

$r = Get-NetCalculator 10.1.23.19 255.255.240.0
Check 'calc with a dotted mask (/20)'             ($r.Prefix -eq 20 -and (Same $r.Network '10.1.16.0') -and (Same $r.Broadcast '10.1.31.255') -and $r.UsableHosts -eq 4094)

$r = Get-NetCalculator 172.16.5.130 26
Check 'calc with a plain prefix (/26)'            ((Same $r.Network '172.16.5.128') -and (Same $r.Broadcast '172.16.5.191') -and (Same $r.FirstHost '172.16.5.129') -and (Same $r.LastHost '172.16.5.190') -and $r.UsableHosts -eq 62)

$r = Get-NetCalculator 10.0.0.1 0.0.0.255
Check 'calc understands a wildcard mask'          ($r.Prefix -eq 24)

$r = Get-NetCalculator 10.0.0.0/31
Check 'calc /31 has 2 usable (RFC 3021)'          ($r.UsableHosts -eq 2 -and (Same $r.FirstHost '10.0.0.0') -and (Same $r.LastHost '10.0.0.1'))
$r = Get-NetCalculator 10.0.0.5/32
Check 'calc /32 is a single host'                 ($r.UsableHosts -eq 1 -and (Same $r.FirstHost '10.0.0.5') -and (Same $r.LastHost '10.0.0.5'))
$r = Get-NetCalculator 192.0.2.5/30
Check 'calc /30'                                  ((Same $r.Network '192.0.2.4') -and (Same $r.Broadcast '192.0.2.7') -and (Same $r.FirstHost '192.0.2.5') -and (Same $r.LastHost '192.0.2.6') -and $r.Type -ceq 'Documentation (TEST-NET-1)')
$r = Get-NetCalculator 0.0.0.0/0
Check 'calc /0 does not overflow'                 ((Same $r.Broadcast '255.255.255.255') -and $r.TotalAddresses -eq 4294967296 -and $r.UsableHosts -eq 4294967294 -and (Same $r.Mask '0.0.0.0'))

Check 'classful default: A is /8'                 ((Get-NetCalculator 10.5.5.5).Prefix -eq 8)
Check 'classful default: B is /16'                ((Get-NetCalculator 172.20.1.1).Prefix -eq 16)
Check 'classful default: C is /24'                ((Get-NetCalculator 200.1.1.1).Prefix -eq 24)

$types = @{ '8.8.8.8/32' = 'Public'; '127.0.0.1/8' = 'Loopback'; '169.254.1.1/16' = 'Link-local (APIPA)'; '100.64.0.1/10' = 'Shared address space (CGNAT)'; '224.0.0.5/4' = 'Multicast'; '172.31.255.254/12' = 'Private (RFC 1918)'; '172.32.0.1/12' = 'Public' }
$typeBad = @($types.Keys | Where-Object { (Get-NetCalculator $_).Type -cne $types[$_] })
Check 'address types (public, loopback, APIPA, CGNAT, multicast, 172.16/12 edges)' ($typeBad.Count -eq 0)
Check 'class D is shown as multicast'             ((Get-NetCalculator 224.0.0.5/4).Class -ceq 'D (multicast)')

Check 'calc rejects 300.1.1.1'                    (Throws { Get-NetCalculator 300.1.1.1/24 -ErrorAction Stop })
Check 'calc rejects /33'                          (Throws { Get-NetCalculator 10.1.1.1/33 -ErrorAction Stop })
Check 'calc rejects a mask with a hole'           (Throws { Get-NetCalculator 10.1.1.1 255.0.255.0 -ErrorAction Stop })
Check 'calc rejects text'                         (Throws { Get-NetCalculator hello -ErrorAction Stop })
Check 'calc takes several addresses from the pipeline' (@('10.0.0.1/8', '172.16.0.1/12' | Get-NetCalculator).Count -eq 2)
Check 'calc shows the netmask line in its default view' ((Get-NetCalculator 192.168.1.10/24 | Out-String) -match 'Netmask\s*:\s*255\.255\.255\.0 = /24')

# ------------------------------------------------------------------ IPv6 calculator
$r = Get-IPv6Calculator 2001:db8:acad:1234::1/64
Check 'ipv6: short and full form'                 ((Same $r.Address '2001:db8:acad:1234::1') -and (Same $r.Expanded '2001:0db8:acad:1234:0000:0000:0000:0001'))
Check 'ipv6: network, first, last'                ((Same $r.Network '2001:db8:acad:1234::') -and (Same $r.LastAddress '2001:db8:acad:1234:ffff:ffff:ffff:ffff') -and (Same $r.Cidr '2001:db8:acad:1234::/64'))
Check 'ipv6: a /64 holds one /64 and 2^64 addresses' ((Same $r.Subnets64 '1') -and (Same $r.Addresses '2^64') -and (Same $r.Type 'Documentation'))
Check 'ipv6: interface id'                        (Same $r.InterfaceId '0000:0000:0000:0001')
$r = Get-IPv6Calculator 2001:db8:acad:1234::1/48
Check 'ipv6: a /48 holds 65,536 /64 subnets'      ((Same $r.Subnets64 '65,536') -and (Same $r.Network '2001:db8:acad::'))
Check 'ipv6: a /65 is smaller than a /64'         ((Get-IPv6Calculator 2001:db8::1/65).Subnets64 -ceq 'less than one /64')
Check 'ipv6: no prefix means /64'                 ((Get-IPv6Calculator fe80::1).Prefix -eq 64)
Check 'ipv6: solicited-node address (Cisco example)' ((Get-IPv6Calculator fe80::2aa:ff:fe28:9c5a).SolicitedNode -ceq 'ff02::1:ff28:9c5a')
$v6types = [ordered]@{ 'fe80::1' = 'Link-local unicast'; '::1' = 'Loopback (::1)'; '::' = 'Unspecified (::)'; 'fd12:3456:789a::1' = 'Unique local (ULA, the private range)'; 'ff02::1' = 'Multicast'; '2606:4700::1111' = 'Global unicast'; '::ffff:192.0.2.1' = 'IPv4-mapped' }
$v6bad = @($v6types.Keys | Where-Object { (Get-IPv6Calculator $_).Type -cne $v6types[$_] })
Check 'ipv6: address types'                       ($v6bad.Count -eq 0)
Check 'ipv6: a zone id (%12) is ignored'          ((Get-IPv6Calculator 'fe80::1%12').Address -ceq 'fe80::1')
Check 'ipv6: rejects text and /129'               ((Throws { Get-IPv6Calculator 'not-an-ip' -ErrorAction Stop }) -and (Throws { Get-IPv6Calculator 2001:db8::/129 -ErrorAction Stop }))
Check 'ipv6: rejects an IPv4 address'             (Throws { Get-IPv6Calculator 192.168.1.1 -ErrorAction Stop })

# ------------------------------------------------------------------ subnet tables
$t = @(Get-SubnetTable)
Check 'subnet table: /8 to /32 (25 rows)'         ($t.Count -eq 25 -and $t[0].Prefix -ceq '/8' -and $t[-1].Prefix -ceq '/32')
$row = $t | Where-Object Prefix -eq '/24'
Check 'subnet table: /24 row'                     ((Same $row.Mask '255.255.255.0') -and (Same $row.Wildcard '0.0.0.255') -and $row.Addresses -eq 256 -and $row.UsableHosts -eq 254 -and $row.ClassASubnets -eq 65536 -and $row.ClassBSubnets -eq 256 -and $row.ClassCSubnets -eq 1)
Check 'subnet table: /11 has 2097150 usable (the old page said 2097152)' (($t | Where-Object Prefix -eq '/11').UsableHosts -eq 2097150)
Check 'subnet table: /30, /31, /32 usable hosts'  ((($t | Where-Object Prefix -eq '/30').UsableHosts -eq 2) -and (($t | Where-Object Prefix -eq '/31').UsableHosts -eq 2) -and (($t | Where-Object Prefix -eq '/32').UsableHosts -eq 1))
Check 'subnet table: /8 has no class B or C column' ($null -eq $t[0].ClassBSubnets -and $null -eq $t[0].ClassCSubnets)
Check 'subnet table: every mask matches its prefix' (@($t | Where-Object { (ConvertTo-PrefixLength $_.Mask) -ne [int]$_.Prefix.TrimStart('/') }).Count -eq 0)
Check 'subnet table prints its headers'           ((Get-SubnetTable | Out-String) -match 'CIDR\s+Mask\s+Wildcard\s+Addresses\s+Usable\s+In class A')

$t6 = @(Get-SubnetTable -IPv6)
$r48 = $t6 | Where-Object Prefix -eq '/48'
Check 'ipv6 table: a /48 holds 1, 16, 256, 4,096, 65,536' ((Same $r48.Sub48 '1') -and (Same $r48.Sub52 '16') -and (Same $r48.Sub56 '256') -and (Same $r48.Sub60 '4,096') -and (Same $r48.Sub64 '65,536'))
Check 'ipv6 table: a /64 has no bigger-subnet columns' ((($t6 | Where-Object Prefix -eq '/64').Sub48) -eq $null -and (($t6 | Where-Object Prefix -eq '/64').Sub64 -ceq '1'))

# ------------------------------------------------------------------ Split-Subnet
$s = @(Split-Subnet 192.168.0.0/24 -Count 4)
Check 'split in 4: four /26 networks'             ((($s.Network) -join ',') -ceq '192.168.0.0/26,192.168.0.64/26,192.168.0.128/26,192.168.0.192/26')
Check 'split in 4: host range and broadcast of #2' ((Same $s[1].FirstHost '192.168.0.65') -and (Same $s[1].LastHost '192.168.0.126') -and (Same $s[1].Broadcast '192.168.0.127') -and $s[1].UsableHosts -eq 62)
Check 'split by hosts (50 hosts needs /26)'       ((@(Split-Subnet 192.168.0.0/24 -Hosts 50).Count -eq 4))
Check 'split by hosts (500 hosts in a /16 is 128 x /23)' ((@(Split-Subnet 10.0.0.0/16 -Hosts 500).Count -eq 128))
Check 'split by hosts (2 hosts needs /30)'        ((@(Split-Subnet 10.0.0.0/24 -Hosts 2).Count -eq 64))
Check 'split by new prefix (/27 gives 8)'         ((@(Split-Subnet 192.168.0.0/24 -NewPrefix 27).Count -eq 8))
Check 'split 5 rounds up to 8 (and warns)'        ((@(Split-Subnet 192.168.0.0/24 -Count 5 -WarningAction SilentlyContinue).Count -eq 8))
Check 'split rejects hosts that do not fit'       (Throws { Split-Subnet 192.168.0.0/24 -Hosts 300 })
Check 'split rejects a prefix bigger than the network' (Throws { Split-Subnet 192.168.0.0/24 -NewPrefix 8 })
Check 'split rejects a network without a prefix'  (Throws { Split-Subnet 192.168.0.0 -Count 2 })
Check 'split starts from the network even if host bits are set' ((Split-Subnet 192.168.0.77/24 -Count 2)[0].Network -ceq '192.168.0.0/25')

# ------------------------------------------------------------------ VLSM
$v = @(Get-VlsmPlan 192.168.10.0/24 -Hosts 100, 50, 20, 10 -Name Sales, Office, Lab, Servers)
Check 'vlsm: biggest first, smallest fitting subnets' ((($v.Network) -join ',') -ceq '192.168.10.0/25,192.168.10.128/26,192.168.10.192/27,192.168.10.224/28')
Check 'vlsm: names stay with their subnet'        ((($v.Name) -join ',') -ceq 'Sales,Office,Lab,Servers')
Check 'vlsm: ranges and spare addresses'          ((Same $v[0].FirstHost '192.168.10.1') -and (Same $v[0].LastHost '192.168.10.126') -and $v[0].Spare -eq 26 -and $v[3].Spare -eq 4 -and (Same $v[3].Broadcast '192.168.10.239'))
$v = @(Get-VlsmPlan 10.0.0.0/24 -Hosts 2, 60, 2)
Check 'vlsm: input order does not matter, links get /30' ((($v.Network) -join ',') -ceq '10.0.0.0/26,10.0.0.64/30,10.0.0.68/30' -and $v[0].Name -ceq 'Subnet 2')
Check 'vlsm: says so when it does not fit'       (Throws { Get-VlsmPlan 192.168.1.0/24 -Hosts 200, 100 })
Check 'vlsm: rejects the wrong number of names'  (Throws { Get-VlsmPlan 192.168.1.0/24 -Hosts 10, 10 -Name OnlyOne })
Check 'vlsm: output does not overlap'            ((Get-VlsmPlan 172.16.0.0/22 -Hosts 500, 200, 100, 50, 25, 2, 2, 2).Count -eq 8)

# ------------------------------------------------------------------ route summary
$m = Get-RouteSummary 192.168.0.0/24, 192.168.1.0/24, 192.168.2.0/24, 192.168.3.0/24
Check 'summary: four /24s are one exact /22'      ((Same $m.Summary '192.168.0.0/22') -and $m.Exact -and (Same $m.Mask '255.255.252.0') -and $m.Extra -eq 0)
$m = Get-RouteSummary 192.168.1.0/24, 192.168.2.0/24
Check 'summary: .1 and .2 need a /22 and it is not exact' ((Same $m.Summary '192.168.0.0/22') -and -not $m.Exact -and $m.Extra -eq 512)
$m = Get-RouteSummary 10.1.0.0/24, 10.1.5.0/24
Check 'summary: 10.1.0.0 and 10.1.5.0 need a /21'  ((Same $m.Summary '10.1.0.0/21') -and -not $m.Exact)
Check 'summary: overlapping networks count once'  ((Get-RouteSummary 10.0.0.0/16, 10.0.1.0/24).Exact)
Check 'summary: one network is its own summary'   ((Get-RouteSummary 172.16.4.0/22).Summary -ceq '172.16.4.0/22')
Check 'summary: two halves are the default route' ((Get-RouteSummary 0.0.0.0/1, 128.0.0.0/1).Summary -ceq '0.0.0.0/0')

# ------------------------------------------------------------------ Test-IPInSubnet
Check 'in-subnet: inside, outside'                ((Test-IPInSubnet 10.1.5.9 10.1.0.0/16) -and -not (Test-IPInSubnet 10.2.0.1 10.1.0.0/16))
Check 'in-subnet: first and last address'         ((Test-IPInSubnet 10.1.0.0 10.1.0.0/16) -and (Test-IPInSubnet 10.1.255.255 10.1.0.0/16) -and -not (Test-IPInSubnet 10.0.255.255 10.1.0.0/16))
Check 'in-subnet: pipeline gives one answer each' ((('10.1.5.9', '10.2.0.1' | Test-IPInSubnet -Network 10.1.0.0/16) -join ',') -ceq 'True,False')
Check 'in-subnet: IPv6'                           ((Test-IPInSubnet 2001:db8::5 2001:db8::/32) -and -not (Test-IPInSubnet 2001:db9::1 2001:db8::/32))
Check 'in-subnet: IPv6 address in an IPv4 network is false' (-not (Test-IPInSubnet 2001:db8::5 10.0.0.0/8))
Check 'in-subnet: rejects a bad network'          (Throws { Test-IPInSubnet 10.1.1.1 10.1.0.0 })

# ------------------------------------------------------------------ converters
$n = Convert-NetNumber 192
Check 'convert 192'                               ($n.Decimal -eq 192 -and $n.Binary -ceq '11000000' -and $n.Hex -ceq 'C0')
Check 'convert 255 and 0'                         (((Convert-NetNumber 255).Hex -ceq 'FF') -and ((Convert-NetNumber 0).Binary -ceq '00000000'))
$n = Convert-NetNumber 256
Check 'convert 256 (two bytes)'                   ($n.Binary -ceq '00000001 00000000' -and $n.Hex -ceq '0100')
$n = Convert-NetNumber 192.168.1.10
Check 'convert an IPv4 address'                   ($n.Decimal -eq 3232235786 -and $n.Binary -ceq '11000000.10101000.00000001.00001010' -and $n.Hex -ceq 'C0A8010A' -and $n.Dotted -ceq '192.168.1.10')
Check 'convert 0xFF and 0b11000000'               (((Convert-NetNumber 0xFF).Decimal -eq 255) -and ((Convert-NetNumber 0b11000000).Decimal -eq 192))
Check 'convert dotted binary to an address'       ((Convert-NetNumber 11000000.10101000.00000001.00001010 -From Binary).Dotted -ceq '192.168.1.10')
Check 'convert hex with -From and with separators' (((Convert-NetNumber C0A8 -From Hex).Decimal -eq 49320) -and ((Convert-NetNumber '1100_0000' -From Binary).Decimal -eq 192))
Check 'convert rejects nonsense'                  ((Throws { Convert-NetNumber abc -ErrorAction Stop }) -and (Throws { Convert-NetNumber 102 -From Binary -ErrorAction Stop }) -and (Throws { Convert-NetNumber -5 -ErrorAction Stop }) -and (Throws { Convert-NetNumber 256.1.1.1 -ErrorAction Stop }))

$e = ConvertTo-Eui64 00-1A-2B-3C-4D-5E
Check 'eui-64: interface id and link-local'       ((Same $e.InterfaceId '021a:2bff:fe3c:4d5e') -and (Same $e.LinkLocal 'fe80::21a:2bff:fe3c:4d5e') -and (Same $e.MacAddress '00-1A-2B-3C-4D-5E'))
Check 'eui-64: with a prefix'                     ((ConvertTo-Eui64 001A.2B3C.4D5E -Prefix 2001:db8:acad:1::/64).Address -ceq '2001:db8:acad:1:21a:2bff:fe3c:4d5e')
Check 'eui-64: the 7th bit flips both ways'       ((ConvertTo-Eui64 02:00:00:00:00:01).LinkLocal -ceq 'fe80::ff:fe00:1')
Check 'eui-64: other MAC notations'               (((ConvertTo-Eui64 001a2b3c4d5e).InterfaceId -ceq '021a:2bff:fe3c:4d5e') -and ((ConvertTo-Eui64 '00:1a:2b:3c:4d:5e').InterfaceId -ceq '021a:2bff:fe3c:4d5e'))
Check 'eui-64: rejects a short MAC and a /65 prefix' ((Throws { ConvertTo-Eui64 00-1A -ErrorAction Stop }) -and (Throws { ConvertTo-Eui64 00-1A-2B-3C-4D-5E -Prefix 2001:db8::/65 -ErrorAction Stop }))

Check 'mask from prefix'                          (((ConvertTo-SubnetMask 24) -ceq '255.255.255.0') -and ((ConvertTo-SubnetMask 20) -ceq '255.255.240.0') -and ((ConvertTo-SubnetMask 0) -ceq '0.0.0.0') -and ((ConvertTo-SubnetMask 32) -ceq '255.255.255.255'))
Check 'wildcard from prefix'                      (((ConvertTo-SubnetMask 26 -Wildcard) -ceq '0.0.0.63') -and ((24, 22 | ConvertTo-SubnetMask -Wildcard) -join ',') -ceq '0.0.0.255,0.0.3.255')
Check 'mask rejects /33'                          (Throws { ConvertTo-SubnetMask 33 })
Check 'prefix from mask and wildcard'             (((ConvertTo-PrefixLength 255.255.240.0) -eq 20) -and ((ConvertTo-PrefixLength 0.0.3.255) -eq 22) -and ((ConvertTo-PrefixLength 255.255.255.255) -eq 32) -and ((ConvertTo-PrefixLength 0.0.0.0) -eq 0))
Check 'prefix rejects a mask with a hole and text' ((Throws { ConvertTo-PrefixLength 255.0.255.0 -ErrorAction Stop }) -and (Throws { ConvertTo-PrefixLength abc -ErrorAction Stop }))

# ------------------------------------------------------------------ Test-TcpPort (loopback only)
$listener = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Loopback, 0)
$listener.Start()
$port = $listener.LocalEndpoint.Port
try {
    $o = Test-TcpPort 127.0.0.1 $port
    Check 'tcp port: an open port on loopback is Open' ($o.Open -and $o.Result -ceq 'Open')
}
finally { $listener.Stop() }
$c = Test-TcpPort 127.0.0.1 $port -TimeoutMs 3000
Check 'tcp port: the same port after closing is not open' (-not $c.Open)
Check 'tcp port: a name that cannot exist is not open, and does not crash' (-not (Test-TcpPort no-such-host.invalid 80 -TimeoutMs 3000).Open)
Check 'tcp port: several ports give several rows'  (@(Test-TcpPort 127.0.0.1 $port, 65000 -TimeoutMs 3000).Count -eq 2)
Check 'tcp port: rejects port 0 and 70000'         ((Throws { Test-TcpPort 127.0.0.1 0 }) -and (Throws { Test-TcpPort 127.0.0.1 70000 }))

# ------------------------------------------------------------------ EIGRP metric and OSPF cost (CCNA / CCNP)
# Answers: 28160, 2169856 and 2170112 are the numbers in the CCNA/CCNP notes and Cisco documentation.
# 281600 (10 Mbps Ethernet) and 2816 (Gigabit) are the well-known default metrics.
Write-Host '  -- Network: EIGRP metric and OSPF cost'

Check 'eigrp: one FastEthernet link is 28160'            ((Get-EigrpMetric -Link FastEthernet).Metric -eq 28160)
Check 'eigrp: one T1 link is 2169856'                    ((Get-EigrpMetric -Bandwidth 1544 -Delay 20000).Metric -eq 2169856)
Check 'eigrp: a T1 plus a Gigabit link is 2170112 (the route in the notes)' ((Get-EigrpMetric -Link serial, gig).Metric -eq 2170112)
Check 'eigrp: 10 Mbps Ethernet is 281600'                ((Get-EigrpMetric -Link Ethernet).Metric -eq 281600)
Check 'eigrp: Gigabit is 2816'                           ((Get-EigrpMetric -Link gig).Metric -eq 2816)
Check 'eigrp: the lowest bandwidth and the summed delay are used' (($m = Get-EigrpMetric -Link gig, serial, fe) -and $m.MinBandwidthKbps -eq 1544 -and $m.TotalDelayUsec -eq 20110)
Check 'eigrp: a 64 kbps serial link is 40512000'         ((Get-EigrpMetric -Bandwidth 64 -Delay 20000).Metric -eq 40512000)
Check 'eigrp: K2 with a load of 255 (K1=K2=K3=1, Gigabit) is 5376' ((Get-EigrpMetric -Link gig -K2 1 -Load 255).Metric -eq 5376)
Check 'eigrp: short link names work (fe = FastEthernet)'  ((Get-EigrpMetric -Link fe).Metric -eq 28160)
Check 'eigrp: shows the formula'                         ((Get-EigrpMetric -Link fe).Formula -ceq '256 x (100 + 10)')
Check 'eigrp: rejects an unknown link and a bandwidth of 0' ((Throws { Get-EigrpMetric -Link carrierpigeon }) -and (Throws { Get-EigrpMetric -Bandwidth 0 -Delay 10 }))

Check 'ospf: FastEthernet costs 1 with the default reference'  ((Get-OspfCost -Link fe).TotalCost -eq 1)
Check 'ospf: a T1 serial link costs 64'                        ((Get-OspfCost -Link serial).TotalCost -eq 64)
Check 'ospf: a 128 kbps link costs 781 (rounded down)'         ((Get-OspfCost -Bandwidth 128).TotalCost -eq 781)
Check 'ospf: 10 Mbps Ethernet costs 10'                        ((Get-OspfCost -Link eth).TotalCost -eq 10)
Check 'ospf: a path adds the link costs (FastEthernet + T1 = 65)' (($c = Get-OspfCost -Link fe, serial) -and $c.TotalCost -eq 65 -and $c.LinkCosts -ceq '1 + 64')
Check 'ospf: with reference 10000 Gigabit is 10 and FastEthernet is 100' ((Get-OspfCost -Link gig, fe -ReferenceBandwidth 10000).TotalCost -eq 110)
Check 'ospf: with the default reference Gigabit and 10 Gigabit both cost 1' ((Get-OspfCost -Link gig, te).TotalCost -eq 2)
Check 'ospf: the cost is never more than 65535'                ((Get-OspfCost -Bandwidth 1).TotalCost -eq 65535)
Check 'ospf: rejects an unknown link'                          (Throws { Get-OspfCost -Link carrierpigeon })

Check 'eigrp: the topology example on the DUAL page (2297856/128256, 2809856/2297856)' (((Get-EigrpMetric -Bandwidth 8000000, 1544 -Delay 5000, 20000).Metric -eq 2297856) -and ((Get-EigrpMetric -Bandwidth 8000000 -Delay 5000).Metric -eq 128256) -and ((Get-EigrpMetric -Bandwidth 8000000, 1544, 1544 -Delay 5000, 20000, 20000).Metric -eq 2809856))
