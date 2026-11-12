@{
    Command  = 'Show-HyperV'
    Alias    = 'shv'
    Synopsis = 'Hyper-V: turn it on or off, and manage virtual machines'
    Group    = 'CHEAT-SHEETS'
    Order    = 41
    Index    = 'Show-AdminCommands'
    Title    = 'ADMINTOOLS MODULE - HYPER-V'
    Prompt   = 'PS>'

    Sections = @(
        @{
            Title  = 'ON A WINDOWS SERVER (run as administrator)'
            Rows   = @'
Get-WindowsFeature Hyper-V* :: Shows if Hyper-V is installed
Install-WindowsFeature -Name Hyper-V -ComputerName <server> -IncludeManagementTools -Restart :: Installs Hyper-V and restarts
Uninstall-WindowsFeature -Name Hyper-V -Restart :: Removes Hyper-V (this replaces Remove-WindowsFeature)
'@
        }
        @{
            Title  = 'ON WINDOWS 10 / 11 PRO (run as administrator)'
            Rows   = @'
Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V* :: Shows if Hyper-V is on
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All :: Turns Hyper-V on (restart needed)
Disable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All :: Turns Hyper-V off (restart needed)
DISM /Online /Enable-Feature /All /FeatureName:Microsoft-Hyper-V :: The same as the first, with DISM
'@
        }
        @{
            Title  = 'SWITCH IT WITHOUT REMOVING IT (restart needed)'
            Rows   = @'
bcdedit /set hypervisorlaunchtype off :: The hypervisor does not start at boot
bcdedit /set hypervisorlaunchtype auto :: The hypervisor starts at boot again
bcdedit /enum | Select-String hypervisorlaunchtype :: Shows the current setting
Note: some tools (older VirtualBox or VMware, some anti-cheat) need the hypervisor off.
'@
        }
        @{
            Title  = 'VIRTUAL MACHINES'
            Rows   = @'
Get-VM :: Lists the virtual machines
Get-VM | Select-Object Name, State, CPUUsage, MemoryAssigned, Uptime :: A readable overview
Start-VM -Name <vm> :: Starts a machine
Stop-VM -Name <vm> :: Shuts it down (add -TurnOff to pull the plug)
Checkpoint-VM -Name <vm> -SnapshotName 'before change' :: Takes a checkpoint
Restore-VMSnapshot -VMName <vm> -Name 'before change' :: Goes back to a checkpoint
New-VM -Name <vm> -Generation 2 -MemoryStartupBytes 4GB -NewVHDPath D:\VM\<vm>.vhdx -NewVHDSizeBytes 60GB -SwitchName <switch> :: Creates a new machine
Set-VMProcessor -VMName <vm> -Count 4 :: Gives it four processors (machine must be off)
Set-VMProcessor -VMName <vm> -ExposeVirtualizationExtensions $true :: Lets it run Hyper-V itself (nested)
Get-VMHost :: Shows the host settings and paths
'@
        }
        @{
            Title  = 'VIRTUAL SWITCHES'
            Rows   = @'
Get-VMSwitch :: Lists the switches
New-VMSwitch -Name Lab -SwitchType Internal :: A switch for the host and the machines only
New-VMSwitch -Name External -NetAdapterName <adapter> -AllowManagementOS $true :: A switch on a real network adapter
Get-VMNetworkAdapter -VMName <vm> :: Shows the network cards of a machine
Connect-VMNetworkAdapter -VMName <vm> -SwitchName Lab :: Plugs a machine into a switch
'@
        }
        @{
            Title  = 'RELATED'
            Rows   = @'
wsl --install :: Installs Windows Subsystem for Linux
wsl --list --verbose :: Lists the Linux distributions and their state
Enable-WindowsOptionalFeature -Online -FeatureName Containers-DisposableClientVM -All :: Turns on Windows Sandbox (Pro, restart needed)
'@
        }
    )
}
