@{
    Command  = 'Show-NetSubnetting'
    Alias    = 'netsub'
    Synopsis = 'Subnetting by hand: block sizes, the prefix table, VLSM steps'
    Group    = 'THEORY'
    Order    = 84
    Index    = 'Show-NetCommands'
    Title    = 'NETWORK MODULE - SUBNETTING BY HAND'

    Sections = @(
        @{
            Title  = 'THE PREFIX TABLE (mask, wildcard, addresses and usable hosts)'
            Rows   = @'
/8 :: 255.0.0.0 - 0.255.255.255 - 16,777,214 hosts
/12 :: 255.240.0.0 - 0.15.255.255 - 1,048,574 hosts
/16 :: 255.255.0.0 - 0.0.255.255 - 65,534 hosts
/17 :: 255.255.128.0 - 0.0.127.255 - 32,766 hosts
/18 :: 255.255.192.0 - 0.0.63.255 - 16,382 hosts
/19 :: 255.255.224.0 - 0.0.31.255 - 8,190 hosts
/20 :: 255.255.240.0 - 0.0.15.255 - 4,094 hosts
/21 :: 255.255.248.0 - 0.0.7.255 - 2,046 hosts
/22 :: 255.255.252.0 - 0.0.3.255 - 1,022 hosts
/23 :: 255.255.254.0 - 0.0.1.255 - 510 hosts
/24 :: 255.255.255.0 - 0.0.0.255 - 254 hosts
/25 :: 255.255.255.128 - 0.0.0.127 - 126 hosts
/26 :: 255.255.255.192 - 0.0.0.63 - 62 hosts
/27 :: 255.255.255.224 - 0.0.0.31 - 30 hosts
/28 :: 255.255.255.240 - 0.0.0.15 - 14 hosts
/29 :: 255.255.255.248 - 0.0.0.7 - 6 hosts
/30 :: 255.255.255.252 - 0.0.0.3 - 2 hosts (a link between two routers)
/31 :: 255.255.255.254 - 0.0.0.1 - 2 hosts (point-to-point, no network or broadcast address; RFC 3021)
/32 :: 255.255.255.255 - 0.0.0.0 - 1 host (a single address, like a loopback)
'@
        }
        @{
            Title  = 'THE BLOCK SIZE METHOD (find the subnet of an address in your head)'
            Rows   = @'
Step 1 :: Find the "interesting octet": the one where the mask is not 255 or 0.
Step 2 :: Block size = 256 minus the mask value in that octet. (Mask 255.255.255.192: 256 - 192 = 64.)
Step 3 :: The subnets start at 0 and go up in steps of the block size: 0, 64, 128, 192.
Step 4 :: The subnet of an address is the largest start that is not bigger than the address's octet.
Step 5 :: The broadcast address is the next subnet's start minus 1. The usable hosts are between.
Example :: 192.168.1.100 /26. Block 64. 100 lies between 64 and 128. Network 192.168.1.64, broadcast 192.168.1.127, hosts .65 to .126.
Check :: netcalc 192.168.1.100/26
'@
        }
        @{
            Title  = 'HOW MANY BITS DO I BORROW?'
            Rows   = @'
Subnets :: 2 to the power of the borrowed bits. Need 6 subnets? 2^3 = 8, so borrow 3 bits.
Hosts :: 2 to the power of the remaining host bits, minus 2. Need 50 hosts? 2^6 = 64, minus 2 = 62: six host bits, so /26.
Rule :: Always count the network and broadcast addresses when you count hosts (except on /31 and /32).
'@
        }
        @{
            Title  = 'VLSM (different sizes, no waste): the order of work'
            Rows   = @'
Step 1 :: List the networks with the number of hosts each one needs. Remember the router interface is a host.
Step 2 :: Sort them from the biggest to the smallest.
Step 3 :: Give the biggest the first block of the right size.
Step 4 :: Give the next one the first free address after it. Blocks start on a multiple of their size.
Step 5 :: Point-to-point links get a /30 (or /31).
Step 6 :: Check that nothing overlaps, and write the plan down.
Check :: netvlsm 192.168.10.0/24 100,50,20,10 gives /25, /26, /27 and /28 in that order.
'@
        }
        @{
            Title  = 'SUMMARIZING (the opposite of subnetting)'
            Rows   = @'
Step 1 :: Write the networks in binary.
Step 2 :: Count the bits all the networks have in common, from the left.
Step 3 :: That number is the summary's prefix length. The address is the first network.
Example :: 192.168.0.0/24 to 192.168.3.0/24: the third octet is 00000000 to 00000011. Six bits are shared, so 24 - 2 = /22: 192.168.0.0/22.
Check :: netsum 192.168.0.0/24,192.168.1.0/24,192.168.2.0/24,192.168.3.0/24
'@
        }
        @{
            Title  = 'THE TOOLS IN THIS MODULE'
            Rows   = @'
netcalc 10.1.2.3/20 :: Everything about an address
netsubt :: The prefix table from the top of this page, worked out by the computer
netsplit 192.168.0.0/24 -NewPrefix 27 :: All the /27 subnets inside a /24
netsplit 192.168.0.0/24 -Count 4 :: Cut a network into 4 equal parts
netvlsm 192.168.10.0/24 100,50,20,10 :: Plan different sizes
netsum 10.0.0.0/24,10.0.1.0/24 :: The shortest route that covers some networks
netin 10.1.2.3 10.1.0.0/16 :: Is an address inside a network?
netmask 27 :: Prefix length to mask (add -Wildcard for the wildcard)
netpfx 255.255.255.224 :: Mask or wildcard to prefix length
'@
        }
    )
}
