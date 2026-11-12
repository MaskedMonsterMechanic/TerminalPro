@{
    Command  = 'Show-AdminBuildFiles'
    Alias    = 'adfiles'
    Synopsis = 'Build recipe: two file servers with shares, DFS namespace, replication and quotas'
    Group    = 'CHEAT-SHEETS'
    Order    = 49
    Index    = 'Show-AdminCommands'
    Title    = 'ADMINTOOLS MODULE - BUILD FILE SERVERS'
    Prompt   = 'PS>'

    Sections = @(
        @{
            Title  = 'READ THIS FIRST'
            Rows   = @'
 :: The plan :: Two file servers (file01, file02) with the same shares. One DFS name (\\contoso.local\Files) points to both. DFS replication keeps them equal. NTFS rights come from the groups made in adusers.
 :: Where to run it :: On your PC with the RSAT tools (see adad), against the servers by name. Run it as a domain admin.
 :: What it changes :: It makes shares, folders and replication. To look at file servers, use adsrv. The undo is at the bottom.
 :: One list :: $res = 'Manuals', 'Applications' is the same list as in adusers. Every loop below works on it.
'@
        }
        @{
            Title  = 'DISK AND ROLES (BOTH SERVERS)'
            Rows   = @'
Get-Disk -CimSession file01 | Where-Object PartitionStyle -eq Raw | Initialize-Disk -PartitionStyle GPT :: Starts a new (RAW) disk. Look first with Get-Disk.
New-Volume -CimSession file01 -DiskNumber 1 -FriendlyName FILE01-DATA -FileSystem NTFS -DriveLetter F :: A volume on it, drive F. The disk number comes from Get-Disk.
'file01', 'file02' | ForEach-Object { Install-WindowsFeature FS-FileServer, FS-DFS-Namespace, FS-DFS-Replication, FS-Resource-Manager -IncludeManagementTools -ComputerName $_ } :: The roles for shares, DFS namespace, DFS replication and quotas
Invoke-Command -ComputerName file01, file02 -ScriptBlock { Install-Module NTFSSecurity -Force } :: The module that sets NTFS rights with simple commands
'@
        }
        @{
            Title  = 'SHARES (ONE LOOP, BOTH SERVERS)'
            Rows   = @'
$res = 'Manuals', 'Applications' :: The shares to make
Invoke-Command -ComputerName file01, file02 -ScriptBlock { foreach ($s in $using:res) { New-Item -Path "F:\Files\$s" -ItemType Directory -Force | Out-Null; New-SmbShare -Name $s -Path "F:\Files\$s" -FullAccess Everyone } } :: A folder and a share for every name, on both servers
Get-SmbShare -CimSession file01, file02 | Where-Object Path -like 'F:\Files*' :: Check: the shares on both servers
Note: Everyone on the SHARE is normal here. The rights that count are the NTFS rights below.
'@
        }
        @{
            Title  = 'NTFS RIGHTS (ONE LOOP, THE GROUPS FROM ADUSERS)'
            Rows   = @'
$map = @{ R = 'ReadAndExecute'; RW = 'ReadAndExecute', 'Write'; RWM = 'Modify' } :: What each group level means in NTFS
foreach ($s in $res) { Disable-NTFSAccessInheritance -Path "F:\Files\$s" -RemoveInheritedAccessRules } :: Step 1: removes the rights the folder inherited from F:\
foreach ($s in $res) { foreach ($a in 'Domain Admins', 'NT AUTHORITY\SYSTEM') { Add-NTFSAccess -Path "F:\Files\$s" -Account $a -AccessRights FullControl } } :: Step 2: admins and the system keep full control
foreach ($s in $res) { foreach ($l in 'R', 'RW', 'RWM') { Add-NTFSAccess -Path "F:\Files\$s" -Account "CONTOSO\$s - $l" -AccessRights $map[$l] } } :: Step 3: every group (Manuals - R, Manuals - RW, ...) gets its level
Get-NTFSAccess -Path F:\Files\Manuals :: Check: the rights on one folder (run it on the server)
Note: Run the three steps ON each file server. Or put them in Invoke-Command -ComputerName file01, file02 -ScriptBlock { ... } and write $using:res and $using:map inside.
Note: CONTOSO\Manuals - RW is the Domain Local group that adusers makes. The names must match.
Note: Do not give rights to single users. Put them in a group, see adusers.
'@
        }
        @{
            Title  = 'DFS NAMESPACE (ONE NAME FOR BOTH SERVERS)'
            Rows   = @'
Invoke-Command -ComputerName file01, file02 -ScriptBlock { New-Item -Path F:\DFSRoot\Files -ItemType Directory -Force | Out-Null; New-SmbShare -Name Files -Path F:\DFSRoot\Files -FullAccess Everyone } :: A small share on each server for the namespace itself
New-DfsnRoot -Path \\contoso.local\Files -TargetPath \\file01\Files -Type DomainV2 :: The namespace, first server
New-DfsnRootTarget -Path \\contoso.local\Files -TargetPath \\file02\Files :: The second server for the same namespace
foreach ($s in $res) { New-DfsnFolder -Path "\\contoso.local\Files\$s" -TargetPath "\\file01\$s" -EnableTargetFailback $true; New-DfsnFolderTarget -Path "\\contoso.local\Files\$s" -TargetPath "\\file02\$s" } :: A folder in the namespace for every share, pointing to both servers
$res | ForEach-Object { Get-DfsnFolderTarget -Path "\\contoso.local\Files\$_" } :: Check: both servers are targets for every folder
DFSDiag /TestDFSIntegrity /DFSRoot:\\contoso.local\Files /Recurse /Full :: A health test of the whole namespace
Note: Users only know \\contoso.local\Files\Manuals. They never see which server answers.
'@
        }
        @{
            Title  = 'DFS REPLICATION (KEEPS BOTH SERVERS EQUAL)'
            Rows   = @'
foreach ($s in $res) { New-DfsReplicationGroup -GroupName "Rep-$s" -DomainName contoso.local; Add-DfsrMember -GroupName "Rep-$s" -ComputerName file01, file02; New-DfsReplicatedFolder -GroupName "Rep-$s" -FolderName $s -DfsnPath "\\contoso.local\Files\$s" } :: A replication group for every share, with both servers in it
foreach ($s in $res) { Set-DfsrMembership -GroupName "Rep-$s" -FolderName $s -ComputerName file01 -ContentPath "F:\Files\$s" -PrimaryMember $true -Force; Set-DfsrMembership -GroupName "Rep-$s" -FolderName $s -ComputerName file02 -ContentPath "F:\Files\$s" -Force } :: file01 is the primary (its files win the first time), file02 gets the copy
foreach ($s in $res) { Add-DfsrConnection -GroupName "Rep-$s" -SourceComputerName file01 -DestinationComputerName file02 } :: The link between the servers
Get-DfsrBacklog -GroupName Rep-Manuals -FolderName Manuals -SourceComputerName file01 -DestinationComputerName file02 :: Check: how many files wait to be copied (nothing = in sync)
Note: Put your files on file01 (the primary) before replication starts. The primary wins the first copy.
'@
        }
        @{
            Title  = 'QUOTAS (FSRM)'
            Rows   = @'
foreach ($mb in 100, 200, 350) { New-FsrmQuotaTemplate -Name "Quota $mb Limit" -Size ($mb * 1MB) -Description "$mb MB hard limit" } :: Hard limits: the user cannot save more
foreach ($mb in 400, 500, 1000) { New-FsrmQuotaTemplate -Name "Soft $mb Limit" -Size ($mb * 1MB) -SoftLimit -Description "$mb MB soft limit" } :: Soft limits: only a warning and a report
New-FsrmAutoQuota -Path F:\Files\Users -Template 'Quota 200 Limit' :: Every new sub-folder in Users (one per person) gets the 200 MB limit by itself
Get-FsrmQuotaTemplate | Format-Table Name, Size, SoftLimit :: Check: the templates
Get-FsrmAutoQuota -Path F:\Files\Users :: Check: the auto quota on the folder
Note: Run these on the file server itself, or add -CimSession file01.
'@
        }
        @{
            Title  = 'UNDO'
            Rows   = @'
foreach ($s in $res) { Remove-DfsnFolderTarget -Path "\\contoso.local\Files\$s" -TargetPath "\\file02\$s" -Force; Remove-DfsnFolder -Path "\\contoso.local\Files\$s" -Force } :: Takes the folders out of the namespace (the files stay)
Remove-DfsnRootTarget -Path \\contoso.local\Files -TargetPath \\file02\Files -Force; Remove-DfsnRoot -Path \\contoso.local\Files -Force :: Takes the namespace away
Get-DfsReplicationGroup -GroupName 'Rep-*' | Remove-DfsReplicationGroup -RemoveReplicatedFolders -Force :: Stops replication (the files stay)
Invoke-Command -ComputerName file01, file02 -ScriptBlock { foreach ($s in $using:res) { Remove-SmbShare -Name $s -Force } } :: Removes the shares (the folders and files stay)
'@
        }
    )
}
