@{
    Command  = 'Show-WinCommon'
    Alias    = 'wincom'
    Synopsis = 'Common Windows administration commands'
    Group    = 'GENERAL COMMANDS'
    Order    = 10
    Index    = 'Show-WinToolsCommands'
    Title    = 'WINTOOLS MODULE - COMMON WINDOWS COMMANDS'
    Prompt   = 'C:\>'

    Sections = @(
        @{
            Title  = 'NETWORK'
            Rows   = @'
ipconfig /all :: Shows the full IP configuration of every adapter
ipconfig /displaydns :: Shows the DNS cache
ipconfig /flushdns :: Empties the DNS cache
ipconfig /release :: Gives up the DHCP address
ipconfig /renew :: Asks DHCP for an address
nslookup name :: Asks DNS for the address of a name
tracert host :: Shows the hops on the way to the host
pathping host :: Tracert and packet loss per hop together
netstat -ano :: Shows connections, ports and the process ID that owns them
arp -a :: Shows the address table (IP to MAC)
route print :: Shows the routing table
netsh interface ip show config :: Shows the IP settings per interface
PS> :: Test-NetConnection host -Port 443 :: Tests that a TCP port answers (PowerShell)
PS> :: Get-NetIPAddress :: Lists the IP addresses (PowerShell)
PS> :: Resolve-DnsName name :: Asks DNS for a name (PowerShell)
'@
        }
        @{
            Title  = 'REPAIR AND INFORMATION'
            Rows   = @'
sfc /scannow :: Checks the system files and repairs them (run as administrator)
DISM /Online /Cleanup-Image /RestoreHealth :: Repairs the Windows image (run as administrator)
chkdsk C: /f :: Checks the disk and fixes errors (may ask for a restart)
gpupdate /force :: Applies Group Policy now
gpresult /r :: Shows the Group Policy that applies to this machine and user
gpresult /user domain\user /r :: Shows the Group Policy for a specific user
systeminfo :: Shows the operating system, hotfixes, memory and network cards
winver :: Shows the Windows version
tree /a :: Shows a folder tree
osk :: Opens the on-screen keyboard
shutdown /r /t 0 :: Restarts the machine now
'@
        }
        @{
            Title  = 'PROCESSES AND SERVICES'
            Rows   = @'
tasklist :: Lists the running processes
taskkill /pid 1234 /f :: Forces process 1234 to end
sc query :: Lists the services
net start :: Lists the running services
PS> :: Get-Process -Name chrome* :: Finds processes by name (PowerShell)
PS> :: Get-Service -Name Spooler :: Shows one service (PowerShell)
PS> :: Restart-Service Spooler :: Restarts a service (PowerShell, as administrator)
'@
        }
        @{
            Title  = 'USERS, GROUPS AND SHARES'
            Rows   = @'
whoami /groups :: Shows the groups you are a member of
net user :: Lists the local users
net localgroup administrators :: Lists who is a local administrator
net use Z: \\server\share :: Connects a network drive
net share :: Shows the folders this machine shares
icacls C:\folder /t :: Shows the rights on a folder and everything in it
netdom query fsmo :: Shows the domain roles (FSMO) in a domain
'@
        }
        @{
            Title  = 'PROGRAMS (winget)'
            Rows   = @'
winget search name :: Searches for a program
winget install --id Publisher.Name :: Installs a program
winget list :: Lists the installed programs
winget upgrade :: Lists programs that have an update
winget upgrade --all :: Updates everything
'@
        }
    )
}
