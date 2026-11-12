@{
    Command  = 'Show-AdminBuildUsers'
    Alias    = 'adusers'
    Synopsis = 'Build recipe: OUs, users and groups from tables and loops'
    Group    = 'CHEAT-SHEETS'
    Order    = 48
    Index    = 'Show-AdminCommands'
    Title    = 'ADMINTOOLS MODULE - BUILD OUS, USERS AND GROUPS'
    Prompt   = 'PS>'

    Sections = @(
        @{
            Title  = 'READ THIS FIRST'
            Rows   = @'
 :: Where to run it :: On a domain controller, or on your PC with the RSAT tools (see adad). Run it as a domain admin.
 :: What it changes :: It makes OUs, users and groups. To look at users and groups that already exist, use adad. The undo is at the bottom.
 :: The plan :: Users sit in a Users OU per department. A Global group per department holds those users. A Domain Local group per resource and level (R, RW, RWM) holds the Global groups. Rights are given to the Domain Local group only.
 :: The names :: contoso.local, Contoso, IT, HR and the example users are made up. Use your own.
'@
        }
        @{
            Title  = 'START: THE DOMAIN AND THE DEPARTMENTS'
            Rows   = @'
$base = (Get-ADDomain).DistinguishedName :: The domain as an address, for example DC=contoso,DC=local. Read from the domain, so there is nothing to type.
$dept = 'IT', 'HR', 'Sales', 'Finance', 'Development' :: The departments. This list is all the OU and group loops need.
$res = 'Manuals', 'Applications' :: The resources that people need rights on (a file share, for example)
'@
        }
        @{
            Title  = 'OUS (ONE LOOP)'
            Rows   = @'
New-ADOrganizationalUnit -Name Contoso -Path $base :: The top OU for everything
foreach ($x in 'Computers', 'Resources') { New-ADOrganizationalUnit -Name $x -Path "OU=Contoso,$base" } :: Two more: one for computers, one for the resource groups
foreach ($d in $dept) { New-ADOrganizationalUnit -Name $d -Path "OU=Contoso,$base"; New-ADOrganizationalUnit -Name "${d}Users" -Path "OU=$d,OU=Contoso,$base" } :: For each department: an OU, and a Users OU inside it
Get-ADOrganizationalUnit -Filter * -SearchBase "OU=Contoso,$base" | Select-Object Name, DistinguishedName :: Check: the whole tree
Note: Add -Description "text" to any of them. OUs are protected against deletion by default, see UNDO.
'@
        }
        @{
            Title  = 'USERS (ONE TABLE, ONE LOOP)'
            Rows   = @'
$users = Import-Csv .\users.csv :: The table as a file: a header line Given,Surname,Sam,Dept,Title and one line per person
$users = 'Given,Surname,Sam,Dept,Title', 'Ann,Example,AE001,IT,Technician', 'Bob,Sample,BS001,HR,Advisor', 'Cy,Test,CT001,Sales,Seller' | ConvertFrom-Csv :: The same table typed in the prompt (three made-up users)
$pw = Read-Host 'Start password' -AsSecureString :: Asked once, so it is not written in the script
foreach ($u in $users) { New-ADUser -Name "$($u.Given) $($u.Surname)" -GivenName $u.Given -Surname $u.Surname -SamAccountName $u.Sam -UserPrincipalName "$($u.Sam)@contoso.local" -EmailAddress "$($u.Sam)@contoso.com" -Title $u.Title -Path "OU=$($u.Dept)Users,OU=$($u.Dept),OU=Contoso,$base" -AccountPassword $pw -Enabled $true -ChangePasswordAtLogon $true } :: Makes every user in the table, in the Users OU of their department. They choose a new password at first logon.
foreach ($u in $users) { if (-not (Get-ADUser -Filter "SamAccountName -eq '$($u.Sam)'")) { New-ADUser -Name "$($u.Given) $($u.Surname)" -SamAccountName $u.Sam -GivenName $u.Given -Surname $u.Surname -Path "OU=$($u.Dept)Users,OU=$($u.Dept),OU=Contoso,$base" -AccountPassword $pw -Enabled $true -ChangePasswordAtLogon $true } } :: The safe version: skips users that already exist, so you can run it twice
Get-ADUser <sam> | Move-ADObject -TargetPath "OU=SalesUsers,OU=Sales,OU=Contoso,$base" :: Moves one existing user to another OU
Note: Want the user name made for you? Leave the Sam column out and use: ($u.Given.Substring(0,1) + $u.Surname).ToLower()
Note: ChangePasswordAtLogon is on here. Only use -PasswordNeverExpires $true for lab accounts, never for real people.
'@
        }
        @{
            Title  = 'GROUPS: ONE GLOBAL GROUP PER DEPARTMENT'
            Rows   = @'
foreach ($d in $dept) { New-ADGroup -Name $d -GroupScope Global -Path "OU=$d,OU=Contoso,$base" -Description "Global group for $d" } :: A Global group for every department
foreach ($d in $dept) { Add-ADGroupMember -Identity $d -Members (Get-ADUser -Filter * -SearchBase "OU=${d}Users,OU=$d,OU=Contoso,$base") } :: Puts everybody from the Users OU into the group of the department
Note: An empty Users OU gives an error in the second line. Make the users first.
Note: Run the second line once per group. Running it again for people who are already members gives an error.
'@
        }
        @{
            Title  = 'GROUPS: DOMAIN LOCAL GROUPS FOR THE RESOURCES'
            Rows   = @'
foreach ($r in $res) { foreach ($l in 'R', 'RW', 'RWM') { New-ADGroup -Name "$r - $l" -GroupScope DomainLocal -Path "OU=Resources,OU=Contoso,$base" -Description "Domain Local group for $r ($l)" } } :: Three groups per resource: Read, Read and Write, Read and Write and Modify
$acl = 'Resource,Level,Group', 'Manuals,RW,IT', 'Manuals,R,Development', 'Applications,RWM,IT', 'Applications,R,HR' | ConvertFrom-Csv :: The table of who may do what (a file works too: Import-Csv .\access.csv)
foreach ($a in $acl) { Add-ADGroupMember -Identity "$($a.Resource) - $($a.Level)" -Members $a.Group } :: Puts each Global group into the right Domain Local group
Get-ADGroupMember "Manuals - RW" | Select-Object Name, ObjectClass :: Check: who is in one group
Note: Use the Domain Local groups (for example Manuals - RW) in the share and NTFS rights. Never give rights to a single user.
Note: A new person only has to be put in the Users OU of their department. The rest follows from the groups.
'@
        }
        @{
            Title  = 'COMPUTERS'
            Rows   = @'
redircmp "OU=Computers,OU=Contoso,$base" :: New computers that join the domain now land in this OU, not in the default Computers folder
Get-ADComputer PC-SALES01 | Move-ADObject -TargetPath "OU=Computers,OU=Contoso,$base" :: Moves a computer that is already in the domain
Note: redircmp (and redirusr for users) is run once and changes the default for the whole domain.
'@
        }
        @{
            Title  = 'UNDO'
            Rows   = @'
Get-ADOrganizationalUnit -Filter * -SearchBase "OU=Contoso,$base" | Set-ADObject -ProtectedFromAccidentalDeletion $false :: First take the delete protection off every OU in the tree
Remove-ADOrganizationalUnit -Identity "OU=Contoso,$base" -Recursive -Confirm:$false :: Removes the whole tree with all users, groups and computers in it. Check the name twice.
foreach ($u in $users) { Remove-ADUser -Identity $u.Sam -Confirm:$false } :: Removes only the users in the table
Note: Without the first line, the second one fails. That is the protection doing its job.
'@
        }
    )
}
