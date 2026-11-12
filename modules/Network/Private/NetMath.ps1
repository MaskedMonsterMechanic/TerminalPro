# Helpers for IPv4 and IPv6 maths (not exported). Written from scratch for this module.
#
# An IPv4 address is held as a number between 0 and 4294967295 in an [int64], so shifts and
# masks never meet a sign bit. Nothing in this file touches the machine or the network.

function ConvertTo-NetInt {
    # 'a.b.c.d' -> number
    param([string]$Address)

    if ($Address -match '^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$') {
        $value = [int64]0
        foreach ($i in 1..4) {
            $octet = [int]$Matches[$i]
            if ($octet -gt 255) { throw "'$Address' is not an IPv4 address: $octet is bigger than 255." }
            $value = ($value -shl 8) + $octet
        }
        return $value
    }
    throw "'$Address' is not an IPv4 address (it should look like 192.168.1.10)."
}

function ConvertFrom-NetInt {
    # number -> 'a.b.c.d'
    param([int64]$Value)
    '{0}.{1}.{2}.{3}' -f (($Value -shr 24) -band 255), (($Value -shr 16) -band 255), (($Value -shr 8) -band 255), ($Value -band 255)
}

function Get-NetMaskInt {
    # prefix length -> mask number (24 -> 4294967040)
    param([ValidateRange(0, 32)][int]$Prefix)
    if ($Prefix -eq 0) { return [int64]0 }
    ([int64]4294967295 -shl (32 - $Prefix)) -band 4294967295
}

function Test-NetMaskInt {
    # true when the ones come first and the zeros after (a real mask)
    param([int64]$Mask)
    $inverse = (-bnot $Mask) -band 4294967295
    (($inverse -band ($inverse + 1)) -eq 0)
}

function ConvertTo-NetPrefixInt {
    # mask number -> prefix length
    param([int64]$Mask)
    $count = 0
    for ($bit = 31; $bit -ge 0; $bit--) {
        if ($Mask -band ([int64]1 -shl $bit)) { $count++ }
    }
    $count
}

function Resolve-NetMask {
    # '24', '/24', '255.255.255.0' or a wildcard '0.0.0.255' -> prefix length
    param([string]$Text)

    $t = $Text.Trim()
    if ($t -match '^/?(\d{1,2})$') {
        $p = [int]$Matches[1]
        if ($p -gt 32) { throw "The prefix length must be between 0 and 32 (got $p)." }
        return $p
    }
    if ($t -match '^\d{1,3}(\.\d{1,3}){3}$') {
        $n = ConvertTo-NetInt $t
        if (Test-NetMaskInt $n) { return (ConvertTo-NetPrefixInt $n) }
        $inverse = (-bnot $n) -band 4294967295
        if (Test-NetMaskInt $inverse) { return (ConvertTo-NetPrefixInt $inverse) }   # a wildcard mask, as used in ACLs
        throw "'$t' is not a valid subnet mask (the ones must come first, like 255.255.240.0)."
    }
    throw "'$t' is not a prefix length (like 24) or a mask (like 255.255.255.0)."
}

function Split-NetworkText {
    # '10.1.2.0/24' -> address number and prefix. The prefix is required.
    param([string]$Text)

    if ($Text -match '^\s*(\d{1,3}(?:\.\d{1,3}){3})\s*/\s*(\d{1,2})\s*$') {
        $prefix = [int]$Matches[2]
        if ($prefix -gt 32) { throw "The prefix length must be between 0 and 32 (got $prefix)." }
        $address = ConvertTo-NetInt $Matches[1]
        return [pscustomobject]@{ Address = $address; Prefix = $prefix }
    }
    throw "'$Text' is not a network. Write it as address/prefix, for example 192.168.1.0/24."
}

function ConvertTo-NetBinary {
    # number -> '11000000.10101000.00000001.00001010'
    param([int64]$Value)
    $octets = foreach ($shift in 24, 16, 8, 0) { [Convert]::ToString([int](($Value -shr $shift) -band 255), 2).PadLeft(8, '0') }
    $octets -join '.'
}

function Get-NetHostBits {
    # the number of host bits needed to give at least $Hosts usable addresses (minimum 2, so a /30)
    param([int]$Hosts)
    $bits = 2
    while ((([int64]1 -shl $bits) - 2) -lt $Hosts) { $bits++ }
    $bits
}

function Format-Power2 {
    # 2 to the power of $Exponent as a readable number; very big ones stay as 2^n
    param([int]$Exponent)
    if ($Exponent -le 62) { ([int64]1 -shl $Exponent).ToString('N0', [Globalization.CultureInfo]::InvariantCulture) }
    else { "2^$Exponent" }
}

# Special IPv4 ranges. The first match wins.
$script:Ipv4Ranges = @(
    @{ Net = '255.255.255.255'; Prefix = 32; Name = 'Limited broadcast' }
    @{ Net = '0.0.0.0';         Prefix = 8;  Name = 'This network (unspecified)' }
    @{ Net = '10.0.0.0';        Prefix = 8;  Name = 'Private (RFC 1918)' }
    @{ Net = '100.64.0.0';      Prefix = 10; Name = 'Shared address space (CGNAT)' }
    @{ Net = '127.0.0.0';       Prefix = 8;  Name = 'Loopback' }
    @{ Net = '169.254.0.0';     Prefix = 16; Name = 'Link-local (APIPA)' }
    @{ Net = '172.16.0.0';      Prefix = 12; Name = 'Private (RFC 1918)' }
    @{ Net = '192.0.0.0';       Prefix = 24; Name = 'IETF protocol assignments' }
    @{ Net = '192.0.2.0';       Prefix = 24; Name = 'Documentation (TEST-NET-1)' }
    @{ Net = '192.168.0.0';     Prefix = 16; Name = 'Private (RFC 1918)' }
    @{ Net = '198.18.0.0';      Prefix = 15; Name = 'Benchmark testing' }
    @{ Net = '198.51.100.0';    Prefix = 24; Name = 'Documentation (TEST-NET-2)' }
    @{ Net = '203.0.113.0';     Prefix = 24; Name = 'Documentation (TEST-NET-3)' }
    @{ Net = '224.0.0.0';       Prefix = 4;  Name = 'Multicast' }
    @{ Net = '240.0.0.0';       Prefix = 4;  Name = 'Reserved (class E)' }
)

function Get-NetAddressType {
    param([int64]$Address)
    foreach ($range in $script:Ipv4Ranges) {
        $mask = Get-NetMaskInt $range.Prefix
        if (($Address -band $mask) -eq (ConvertTo-NetInt $range.Net)) { return $range.Name }
    }
    'Public'
}

function Get-NetAddressClass {
    param([int64]$Address)
    $first = $Address -shr 24
    if     ($first -lt 128) { 'A' }
    elseif ($first -lt 192) { 'B' }
    elseif ($first -lt 224) { 'C' }
    elseif ($first -lt 240) { 'D (multicast)' }
    else                    { 'E (reserved)' }
}

function New-NetCalcObject {
    # Everything about one address and prefix. Used by Get-NetCalculator and the other tools.
    param([int64]$Address, [int]$Prefix)

    $mask      = Get-NetMaskInt $Prefix
    $network   = $Address -band $mask
    $broadcast = $network -bor ((-bnot $mask) -band 4294967295)
    $total     = [int64]1 -shl (32 - $Prefix)

    if     ($Prefix -le 30) { $usable = $total - 2; $first = $network + 1; $last = $broadcast - 1 }
    elseif ($Prefix -eq 31) { $usable = 2;          $first = $network;     $last = $broadcast }       # RFC 3021: point-to-point
    else                    { $usable = 1;          $first = $network;     $last = $network }         # a single host

    [pscustomobject]@{
        PSTypeName     = 'TerminalPro.NetCalc'
        Address        = ConvertFrom-NetInt $Address
        Prefix         = $Prefix
        Mask           = ConvertFrom-NetInt $mask
        Wildcard       = ConvertFrom-NetInt ((-bnot $mask) -band 4294967295)
        Network        = ConvertFrom-NetInt $network
        Cidr           = '{0}/{1}' -f (ConvertFrom-NetInt $network), $Prefix
        Broadcast      = ConvertFrom-NetInt $broadcast
        FirstHost      = ConvertFrom-NetInt $first
        LastHost       = ConvertFrom-NetInt $last
        TotalAddresses = $total
        UsableHosts    = $usable
        Class          = Get-NetAddressClass $Address
        Type           = Get-NetAddressType $Address
        BinaryAddress  = ConvertTo-NetBinary $Address
        BinaryMask     = ConvertTo-NetBinary $mask
        BinaryNetwork  = ConvertTo-NetBinary $network
    }
}

# ---------------------------------------------------------------- IPv6

function ConvertTo-NetIPv6Bytes {
    # text -> 16 bytes. Throws when it is not an IPv6 address.
    param([string]$Text)

    $t = $Text.Trim()
    if ($t.Contains('%')) { $t = $t.Substring(0, $t.IndexOf('%')) }     # drop a zone id such as %12
    $parsed = $null
    if ($t.Contains(':') -and [System.Net.IPAddress]::TryParse($t, [ref]$parsed) -and $parsed.AddressFamily -eq 'InterNetworkV6') {
        return , $parsed.GetAddressBytes()
    }
    throw "'$Text' is not an IPv6 address (it should look like 2001:db8:acad::1)."
}

function ConvertFrom-NetIPv6Bytes {
    # 16 bytes -> compressed text (2001:db8::1)
    param([byte[]]$Bytes)
    ([System.Net.IPAddress]::new($Bytes)).ToString()
}

function ConvertFrom-NetIPv6BytesLong {
    # 16 bytes -> full text (2001:0db8:0000:...)
    param([byte[]]$Bytes)
    (0..7 | ForEach-Object { '{0:x4}' -f ([int]$Bytes[2 * $_] * 256 + [int]$Bytes[2 * $_ + 1]) }) -join ':'
}

function Get-NetIPv6MaskBytes {
    param([ValidateRange(0, 128)][int]$Prefix)
    $mask = New-Object byte[] 16
    for ($i = 0; $i -lt 16; $i++) {
        $bits = [Math]::Max(0, [Math]::Min(8, $Prefix - 8 * $i))
        if ($bits -gt 0) { $mask[$i] = [byte]((0xFF -shl (8 - $bits)) -band 0xFF) }
    }
    , $mask
}

function Test-NetIPv6Prefix {
    # does the address start with the given network (bytes) and prefix?
    param([byte[]]$Address, [byte[]]$Network, [int]$Prefix)
    $mask = Get-NetIPv6MaskBytes $Prefix
    for ($i = 0; $i -lt 16; $i++) {
        if (($Address[$i] -band $mask[$i]) -ne ($Network[$i] -band $mask[$i])) { return $false }
    }
    $true
}

function Get-NetIPv6Type {
    param([byte[]]$Bytes)

    $isZero = -not ($Bytes | Where-Object { $_ -ne 0 })
    if ($isZero) { return 'Unspecified (::)' }
    $firstFifteenAreZero = -not ($Bytes[0..14] | Where-Object { $_ -ne 0 })
    if ($firstFifteenAreZero -and $Bytes[15] -eq 1) { return 'Loopback (::1)' }

    $ranges = @(
        @{ Net = '::ffff:0:0';    Prefix = 96;  Name = 'IPv4-mapped' }
        @{ Net = 'fe80::';        Prefix = 10;  Name = 'Link-local unicast' }
        @{ Net = 'fc00::';        Prefix = 7;   Name = 'Unique local (ULA, the private range)' }
        @{ Net = 'ff00::';        Prefix = 8;   Name = 'Multicast' }
        @{ Net = '2001:db8::';    Prefix = 32;  Name = 'Documentation' }
        @{ Net = '2002::';        Prefix = 16;  Name = '6to4 (old transition)' }
        @{ Net = '2001::';        Prefix = 32;  Name = 'Teredo (old transition)' }
        @{ Net = '2000::';        Prefix = 3;   Name = 'Global unicast' }
    )
    foreach ($r in $ranges) {
        if (Test-NetIPv6Prefix -Address $Bytes -Network ([System.Net.IPAddress]::Parse($r.Net).GetAddressBytes()) -Prefix $r.Prefix) { return $r.Name }
    }
    'Reserved or unassigned'
}
