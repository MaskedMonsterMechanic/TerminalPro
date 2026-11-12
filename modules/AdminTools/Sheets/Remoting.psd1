@{
    Command  = 'Show-Remoting'
    Alias    = 'adremote'
    Synopsis = 'PowerShell remoting: sessions, Invoke-Command, SSH, copying files'
    Group    = 'CHEAT-SHEETS'
    Order    = 42
    Index    = 'Show-AdminCommands'
    Title    = 'ADMINTOOLS MODULE - POWERSHELL REMOTING'
    Prompt   = 'PS>'

    Sections = @(
        @{
            Title  = 'SET IT UP'
            Rows   = @'
Enable-PSRemoting -Force :: Turns remoting on, on THIS computer (as administrator)
Test-WSMan <server> :: Checks that the other computer answers
Test-NetConnection <server> -Port 5985 :: The same, at the port level (5986 is the encrypted port)
Get-Item WSMan:\localhost\Client\TrustedHosts :: Shows the computers you may reach without a domain
Set-Item WSMan:\localhost\Client\TrustedHosts -Value <server> -Concatenate :: Adds a computer to that list (as administrator)
Get-PSSessionConfiguration :: Shows the endpoints this computer offers
Note: in a domain, remoting works by name with Kerberos. Outside a domain you need TrustedHosts or HTTPS.
'@
        }
        @{
            Title  = 'ONE COMPUTER, INTERACTIVE'
            Rows   = @'
Enter-PSSession -ComputerName <server> :: Opens a shell on the other computer (alias: etsn)
Enter-PSSession -ComputerName <server> -Credential <domain\user> :: The same, as another user
Exit-PSSession :: Goes back to your own computer (alias: exsn)
$PSVersionTable.PSVersion :: Shows which PowerShell you are in, here or there
'@
        }
        @{
            Title  = 'RUN SOMETHING ON ONE OR MANY'
            Rows   = @'
Invoke-Command -ComputerName <server> -ScriptBlock { Get-Service Spooler } :: Runs a command there and brings the result back
Invoke-Command -ComputerName s1, s2, s3 -ScriptBlock { hostname } :: Runs it on several, at the same time
Invoke-Command -ComputerName <server> -FilePath .\script.ps1 :: Runs a local script file on the other computer
Invoke-Command -ComputerName <server> -ScriptBlock { param($n) Get-Service $n } -ArgumentList Spooler :: Sends a value in
Invoke-Command -ComputerName <server> -ScriptBlock { Get-Date } -ThrottleLimit 5 :: Limits how many run at once
Note: objects that come back are copies. They have properties but no methods.
'@
        }
        @{
            Title  = 'KEEP A SESSION'
            Rows   = @'
$s = New-PSSession -ComputerName <server> :: Opens a session and keeps it
Invoke-Command -Session $s -ScriptBlock { $x = 42 } :: Runs in it (the variable stays there)
Invoke-Command -Session $s -ScriptBlock { $x } :: Gets the variable back
Get-PSSession :: Lists your open sessions
Remove-PSSession $s :: Closes it
Import-PSSession $s -Module ActiveDirectory :: Uses a module from the other computer as if it were here (alias: ipsn)
'@
        }
        @{
            Title  = 'COPY FILES OVER A SESSION'
            Rows   = @'
Copy-Item .\file.txt -Destination C:\Temp\ -ToSession $s :: Sends a file to the other computer
Copy-Item C:\Temp\log.txt -Destination .\ -FromSession $s :: Fetches a file from it
'@
        }
        @{
            Title  = 'OVER SSH (PowerShell 7)'
            Rows   = @'
Enter-PSSession -HostName <user>@<host> :: Opens a shell over SSH (also to Linux)
New-PSSession -HostName <user>@<host> -KeyFilePath ~/.ssh/id_ed25519 :: A session over SSH, with a key
Invoke-Command -HostName <user>@<host> -ScriptBlock { uname -a } :: Runs something over SSH
Note: the other side needs a line in sshd_config:   Subsystem powershell pwsh -sshs -NoLogo
'@
        }
        @{
            Title  = 'CIM SESSIONS (NO REMOTING NEEDED)'
            Rows   = @'
$c = New-CimSession -ComputerName <server> :: Opens a CIM session (WinRM or DCOM)
Get-CimInstance -CimSession $c Win32_OperatingSystem :: Asks the other computer for information
Get-Volume -CimSession $c :: Many built-in commands take -CimSession
Remove-CimSession $c :: Closes it
'@
        }
        @{
            Title  = 'THE SECOND HOP'
            Rows   = @'
Note: from inside a remote session you cannot use your login on a THIRD computer (the "double hop").
Invoke-Command -ComputerName <server> -ScriptBlock { Get-ChildItem \\other\share } -Authentication Credssp -Credential <user> :: Works but sends your password: only for trusted servers
Note: better solutions are Kerberos delegation (resource-based constrained delegation) or running the command from your own computer.
'@
        }
    )
}
