@{
    Command  = 'Show-NetBinHexa'
    Alias    = 'netbh'
    Synopsis = 'Binary, decimal and hexadecimal: tables and tricks'
    Group    = 'THEORY'
    Order    = 82
    Index    = 'Show-NetCommands'
    Title    = 'NETWORK MODULE - BINARY, DECIMAL AND HEXADECIMAL'

    Sections = @(
        @{
            Title  = 'THE EIGHT BITS OF AN IPv4 OCTET'
            Rows   = @'
Bit position :: 8 . 7 . 6 . 5 . 4 . 3 . 2 . 1
Value :: 128 . 64 . 32 . 16 . 8 . 4 . 2 . 1
Note: to read a binary octet, add up the values where there is a 1. 11000000 = 128 + 64 = 192.
Note: to make one, subtract from the left: 172 - 128 = 44, 44 has no 64, 44 - 32 = 12, 12 has no 16, 12 - 8 = 4, 4 - 4 = 0: 10101100.
'@
        }
        @{
            Title  = 'MASK OCTETS (a mask is ones first, then zeros)'
            Rows   = @'
0 :: 00000000 - 0 bits
128 :: 10000000 - 1 bit
192 :: 11000000 - 2 bits
224 :: 11100000 - 3 bits
240 :: 11110000 - 4 bits
248 :: 11111000 - 5 bits
252 :: 11111100 - 6 bits
254 :: 11111110 - 7 bits
255 :: 11111111 - 8 bits
Note: the wildcard mask is the mask turned upside down: 255 minus each octet (255.255.255.0 gives 0.0.0.255).
'@
        }
        @{
            Title  = 'DECIMAL - BINARY - HEXADECIMAL, 0 TO 15'
            Rows   = @'
0 :: 0000 - 0
1 :: 0001 - 1
2 :: 0010 - 2
3 :: 0011 - 3
4 :: 0100 - 4
5 :: 0101 - 5
6 :: 0110 - 6
7 :: 0111 - 7
8 :: 1000 - 8
9 :: 1001 - 9
10 :: 1010 - A
11 :: 1011 - B
12 :: 1100 - C
13 :: 1101 - D
14 :: 1110 - E
15 :: 1111 - F
Note: one hexadecimal digit is exactly four bits. So 2 hex digits are one byte: 0xC0 = 1100 0000 = 192.
'@
        }
        @{
            Title  = 'POWERS OF TWO (worth knowing by heart)'
            Rows   = @'
2^1 to 2^8 :: 2, 4, 8, 16, 32, 64, 128, 256
2^9 to 2^12 :: 512, 1024, 2048, 4096
2^16 :: 65,536 (the number of ports; hosts in a /16 minus 2 = 65,534)
2^24 :: 16,777,216
2^32 :: 4,294,967,296 (all IPv4 addresses)
2^48 :: the number of MAC addresses
2^128 :: the number of IPv6 addresses (about 3.4 x 10^38)
Note: hosts in a subnet = 2^(host bits) minus 2. Subnets you can make = 2^(bits you borrowed).
'@
        }
        @{
            Title  = 'DO IT IN POWERSHELL'
            Rows   = @'
[Convert]::ToString(192, 2) :: Decimal to binary: 11000000
[Convert]::ToString(192, 2).PadLeft(8, '0') :: Always 8 digits
[Convert]::ToInt32('11000000', 2) :: Binary to decimal: 192
'{0:X}' -f 192 :: Decimal to hexadecimal: C0
[Convert]::ToInt32('C0', 16) :: Hexadecimal to decimal: 192
0xC0 :: A hexadecimal number in code: 192
netconv 192 :: The same with the Network module, in all three forms
netpfx 255.255.255.0 :: Mask to prefix length
netmask 24 -Wildcard :: Prefix length to wildcard
'@
        }
    )
}
