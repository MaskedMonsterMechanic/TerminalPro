@{
    Command  = 'Show-ADCommands'
    Alias    = 'adad'
    Synopsis = 'Active Directory: users, groups, computers, domain checks'
    Group    = 'CHEAT-SHEETS'
    Order    = 43
    Index    = 'Show-AdminCommands'
    Title    = 'ADMINTOOLS MODULE - ACTIVE DIRECTORY'
    Prompt   = 'PS>'

    Sections = @(
        @{
            Title  = 'GET THE TOOLS'
            Rows   = @'
Get-Module -ListAvailable ActiveDirectory :: Checks if the module is here
Add-WindowsCapability -Online -Name Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0 :: Installs it on Windows 10 / 11 (as administrator)
Import-Module ActiveDirectory :: Loads it
'@
        }
        @{
            Title  = 'USERS'
            Rows   = @'
Get-ADUser <username> :: Basic information about a user
Get-ADUser <username> -Properties * | Format-List * :: Every property of a user
Get-ADUser -Filter "Name -like 'Smith*'" :: Finds users by name (use a text filter, not { })
Get-ADUser -Filter * -SearchBase "OU=Staff,DC=example,DC=com" :: All users in one OU
Get-ADUser <username> -Properties LastLogonDate, PasswordLastSet, PasswordExpired, LockedOut :: Logon and password state
Search-ADAccount -LockedOut :: Lists locked accounts
Unlock-ADAccount -Identity <username> :: Unlocks an account
Search-ADAccount -AccountInactive -TimeSpan 90.00:00:00 -UsersOnly :: Users that have not logged on for 90 days
Set-ADAccountPassword -Identity <username> -Reset :: Resets a password (asks for the new one)
Set-ADUser <username> -ChangePasswordAtLogon $true :: Forces a new password at next logon
Disable-ADAccount -Identity <username> :: Disables an account
'@
        }
        @{
            Title  = 'GROUPS'
            Rows   = @'
Get-ADGroup <group> -Properties * :: Shows a group
Get-ADGroupMember <group> -Recursive :: Members of a group, also through nested groups
Get-ADPrincipalGroupMembership <username> | Select-Object Name :: The groups a user belongs to
Add-ADGroupMember -Identity <group> -Members <username> :: Adds a user to a group
Remove-ADGroupMember -Identity <group> -Members <username> :: Takes a user out of a group
'@
        }
        @{
            Title  = 'COMPUTERS'
            Rows   = @'
Get-ADComputer <name> -Properties * :: Shows a computer account
Get-ADComputer -Filter "OperatingSystem -like '*Server*'" -Properties OperatingSystem :: All servers
Get-ADComputer -Filter * -Properties LastLogonDate | Sort-Object LastLogonDate | Select-Object -First 20 :: The computers that have been quiet the longest
Test-ComputerSecureChannel -Verbose :: Checks this computer's trust with the domain
Test-ComputerSecureChannel -Repair -Credential <domain\admin> :: Repairs it
'@
        }
        @{
            Title  = 'DOMAIN AND DOMAIN CONTROLLERS'
            Rows   = @'
Get-ADDomain :: Information about the domain
Get-ADForest :: Information about the forest
Get-ADDomainController -Filter * | Select-Object Name, Site, IPv4Address :: All domain controllers
netdom query fsmo :: Shows who has the five operations master roles
nltest /dsgetdc:<domain> :: Shows which domain controller answers you
nltest /sc_query:<domain> :: Checks the secure channel to the domain
dcdiag /s:<dc> :: Health check of a domain controller
repadmin /replsummary :: Replication summary
repadmin /showrepl :: Replication partners and result of the last run
'@
        }
        @{
            Title  = 'GROUP POLICY'
            Rows   = @'
Get-GPO -All | Select-Object DisplayName, GpoStatus, ModificationTime :: All policies
Get-GPOReport -Name <policy> -ReportType Html -Path .\policy.html :: A readable report of one policy
Invoke-GPUpdate -Computer <name> -Force :: Applies policy on another computer now
gpresult /r :: Which policy applies here (classic)
Get-GPResultantSetOfPolicy -ReportType Html -Path .\rsop.html :: The result of all policies for this computer and user
'@
        }
    )
}
