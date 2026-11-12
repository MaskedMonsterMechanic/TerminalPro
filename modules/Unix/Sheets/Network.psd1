@{
    Command  = 'Show-UnixNetwork'
    Alias    = 'unixnet'
    Synopsis = 'IP, DNS, SSH and file transfer'
    Group    = 'ADMIN & NETWORK'
    Order    = 60
    Index    = 'Show-UnixCommands'
    Title    = 'UNIX MODULE - NETWORK, DNS & SSH'
    Prompt   = 'user@ubuntu:~$'

    Sections = @(
        @{
            Title  = 'ADDRESSES AND ROUTES'
            Rows   = @'
ip a :: Shows the network interfaces and their IP addresses
ip -br a :: The same, short, one line per interface
ip r :: Shows the routing table
ip link set eth0 up :: Turns the interface eth0 on
hostname -I :: Shows the IP addresses of this host
nmcli device status :: Shows the interfaces as NetworkManager sees them
ifconfig :: The old way of showing addresses (replaced by ip)
'@
        }
        @{
            Title  = 'TESTING'
            Rows   = @'
ping -c 4 host :: Sends 4 echo requests to the host
traceroute host :: Shows the hops on the way to the host
ss -tulpn :: Shows listening TCP and UDP ports and the programs using them
ss -tn :: Shows established TCP connections
dig example.com :: Asks DNS for the address of a name
dig -x 8.8.8.8 :: Asks DNS for the name of an address (reverse lookup)
nslookup example.com :: The older DNS lookup tool
curl -I https://example.com :: Shows only the headers a web server answers with
curl -O https://example.com/file :: Downloads a file and keeps its name
wget https://example.com/file :: Downloads a file
'@
        }
        @{
            Title  = 'SSH AND COPYING'
            Rows   = @'
ssh user@host :: Logs in on another machine
ssh -p 2222 user@host :: Logs in on a different port
ssh-keygen -t ed25519 :: Creates a key pair (private and public key)
ssh-copy-id user@host :: Puts your public key on the host, for logins without a password
scp file.txt user@host:/tmp/ :: Copies a file to another machine
scp user@host:/tmp/file.txt . :: Copies a file from another machine to here
rsync -av folder/ user@host:/backup/ :: Copies only what changed, and keeps dates and rights
'@
        }
        @{
            Title  = 'FIREWALL (ufw, Ubuntu)'
            Rows   = @'
sudo ufw status :: Shows whether the firewall is on and its rules
sudo ufw allow 22/tcp :: Lets SSH in
sudo ufw deny 23/tcp :: Blocks telnet
sudo ufw enable :: Turns the firewall on
sudo ufw delete allow 22/tcp :: Removes a rule
'@
        }
    )
}
