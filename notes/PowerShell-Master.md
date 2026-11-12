# PowerShell Master

A personal cheat-sheet for PowerShell: the basics, parameters, splatting, modules and objects.
To read it nicely in a terminal:  `ConvertFrom-Markdown -Path .\PowerShell-Master.md | Show-Markdown`

## PowerShell: the basics

### Get-Help, Save-Help, Update-Help
| Command                                                           | Use                                          |
| ----------------------------------------------------------------- | -------------------------------------------- |
| **Get-Help** Out-Null                                             | Shows the help text for the Out-Null cmdlet  |
| **Get-Help** < InputAnyCommand >                                  | Help text for any command             |
| **Get-Help** Get-Command *-Online*                                | Opens a browser with online help             |
| **Get-Help** Get-Command *-Parameter* < ParameterName >           | Help for a specific parameter                |
| **Get-Help** default *-ShowWindow*                                | Opens default Help info in a window          |
| **Save-Help** -DestinationPath C:\PSPath *-Module* < ModuleName > | Saves the help files of a module to a folder          |
| **Update-Help**                                                   | Downloads the newest help files     |

### Aliases 
| Command                                                           | Use                                          |
| ----------------------------------------------------------------- | -------------------------------------------- |
| **Get-Alias** Get-Command                                         | Shows the alias of Get-Command              |
| **New-Alias** gh Get-Command                                      | Makes gh an alias for Get-Command |

### Parameters   
| Command                                                           | Use                                          |
| ----------------------------------------------------------------- | -------------------------------------------- |
| **Get-Process** [-ComputerName <String[]>] ...                    | An optional parameter                      |
| **Get-Process** [[-Name] <String[]>] ...                          | An Optional Positional Parameter             |
| **Get-ADUser** *-Filter* <String> ...                             | A mandatory parameter                       |
| **Get-ADUser** [-Identity] <ADUser> ...                           | An Optional Positional Parameter             |
| **Get-ChildItem** *-Recurse:$false*                               | Explicitly sets the recurse param to false   |
| **Get-Help** about_CommonParameters                               | The common parameters every cmdlet has        |

### Confirm, WhatIf, Force
| Command                                                           | Use                                          |
| ----------------------------------------------------------------- | -------------------------------------------- |
| **Get-Help** about_Preference_Variables                           | Settings such as $ErrorActionPreference      |
| **New-Item** notes.md *-Force*                                    | Creates the item, even if it exists                |
| **Remove-Item** .\notes.md *-Confirm*                             | Prompts for deletion confirmation            |
| **Clear-RecycleBin** *-Confirm:$false*                            | Skips the prompt and empties the bin     |
| **Remove-Item** .\notes.md *-WhatIf*                              | Shows what would happen, changes nothing                  |

### Splatting
Splatting is a way of defining the parameters of a command before calling the command.
Individual parameters are written in a hashtable (**@{}**), and then the **@** is used 
to tell Powershell that the content of the hashtable should be read as parameters.

```powershell
$getProcess = @{
    Name = 'firefox'
}
Get-Process @getProcess
```

### Splatting to avoid escaped end-of-line

```powershell
$taskAction = New-ScheduledTaskAction -Execute pwsh.exe `
                                      -Argument 'Write-Host "hello world"'
$taskTrigger = New-ScheduledTaskTrigger -Daily `
                                        -At '00:00:00'
Register-ScheduledTask -TaskName 'TaskName' `
                       -Action $taskAction `
                       -Trigger $taskTrigger `
                       -RunLevel 'Limited' `
                       -Description 'This line is too long to read'
```
> Common method, though fragile as you could easily miss something

### Splatting - The Best Way

```powershell
$newTaskAction = @{
    Execute = 'pwsh.exe'
    Argument = 'Write-Host "hello world"'
}
$newTaskTrigger = @{
    Daily = $true
    At    = '00:00:00'
}
$registerTask = @{
    TaskName    = 'TaskName'
    Action      = New-ScheduledTaskAction @newTaskAction
    Trigger     = New-ScheduledTaskTrigger @newTaskTrigger
    RunLevel    = 'Limited'
    Description = 'Splatting is easy to read'
}
Register-ScheduledTask @registerTask
```

### Splatting to avoid repetition

```powershell
# Parameters used to authenticate remote connections
$remoteParams = @{
    Credential   = Get-Credential
    ComputerName = $env:COMPUTERNAME
}
# Parameters which are specific to Test-WSMan
$testWSMan = @{
    Authentication = 'Default'
    ErrorAction    = 'SilentlyContinue'
}
# By default, do not pass any extra parameters to New-CimSession
$newCimSession = @{}
if (-not (Test-WSMan @testWSMan @remoteParams)) {
    # If WSMan fails, use DCOM (RPC over TCP) to connect
    $newCimSession.Add('SessionOption', (New-CimSessionOption -Protocol Dcom))
}
# Parameters to pass to Get-CimInstance
$getCimInstance = @{
    ClassName  = 'Win32_Service'
    CimSession = New-CimSession @newCimSession @remoteParams
}
Get-CimInstance @getCimInstance
```

### Positional Splatting

```powershell
$renameItem = 'oldname.txt', 'newname.txt'
Rename-Item @renameItem
```

## Modules and snap-ins


### Modules

```powershell
New-Module -Name TestModule -ScriptBlock { 
    function Get-Number { return 1 } 
}
```

| Command                                                           | Use                                          |
| ----------------------------------------------------------------- | -------------------------------------------- |
| **New-Module**                                                    | Creates a new module                         |
| **Get-Module**                                                    | Gets a list of modules                       |
| **Get-Module** *-ListAvailable*                                   | Lists the modules that are installed         |
| **$env:PSModulePath** *-split* ';'                               | List default Module locations                |
| **Import-Module**                                                 | Loads a module (PS 3+ also auto-loads them)  |
| **Import-Module** NetSecurity *-SkipEditionCheck*                 | Loads a module in Core                       |
| **Remove-Module**                                                 | Unloads a module                              |
| **Find-Module**                                                   | Searches PSGallery for a module              |
| **Install-Module**                                                | Installs a module from PSGallery             |
| **Update-Module**                                                 | Updates an installed module                  |
| **Save-Module**                                                   | Downloads a module without installing it     |

### PowerShell autoloading DSC (Desired State Configuration)

```powershell
Get-Module PSDesiredStateConfiguration
# Expects PSDesiredStateConfiguration not to be present

Get-DscResource | Out-Null
# Expects list of DSC resources

Get-Module PSDesiredStateConfiguration
# Expects PSDesiredStateConfiguration to be present
```

### PSModulePath

```powershell
$env:PSModulePath -split ';'
```

```powershell
# Get the value of the environment variable
$environmentVariable = [Environment]::GetEnvironmentVariable('PSMODULEPATH', 'User')
# If it is not set, use the User default path
if (-not $environmentVariable) {
    $environmentVariable = "$home\Documents\WindowsPowerShell\Modules"
}
# Add a new path
$paths = "$environmentVariable;C:\SomeNewModulePath"
# Set the environment variable
[Environment]::SetEnvironmentVariable('PSMODULEPATH', $paths, 'User')
```

### PowerShell Core and the WindowsCompatibility module
Implicit remoting makes it possible to run Windows PowerShell commands in PowerShell Core.

```powershell
Install-Module WindowsCompatibility -Scope CurrentUser
```

### Snap-ins
The core commands are loaded into PowerShell and live in `System.Management.Automation`.
This snap-in does not show up in the list of registered snap-ins.

```powershell
Get-PSSnapIn -Registered
```

```powershell
Add-PSSnapIn WDeploySnapin3.0
```

```powershell
Get-Command -Module WDeploySnapin3.0
```

## Working with objects in PowerShell

### Output and the pipeline, 1

```powershell
$stdout = Get-CimInstance -ClassName Win32_ComputerSystem
```

### Output and the pipeline, 2

```powershell
$stdout = Get-CimInstance Win32_ComputerSystem -Verbose

# Expects verbose output only

$stdout

# Expects normal output
```

### Output and the pipeline, 3
 
```powershell
Get-Process | Where-Object WorkingSet -gt 50MB

# Expects process objects where the WorkingSet property is greater than 50MB
```

### Get-Member

```powershell
Get-Process -Id $PID | Get-Member

# Expects full Get-Member output

Get-Process -Id $PID | Get-Member -MemberType Property

# Expects property members only
```

### Properties

```powershell
$process = Get-Process -Id $PID
$process.Name

(Get-Process -Id $PID).Name

$process = Get-Process -Id $PID
$process.StartTime.DayOfWeek

(Get-Process -Id $PID).StartTime.DayOfWeek

$object = [PSCustomObject]@{ 'Some Name' = 'Value' }
$object."Some Name"
$object.'Some Name'
$object.{Some Name}

$object = [PSCustomObject]@{ 'Some Name' = 'Value' }
$propertyName = 'Some Name'
$object.$propertyName

# Expects:
#
# Value
```

### Methods

```powershell
'thisString'.Substring

# Expects:
#
# OverloadDefinitions
# -------------------
# string Substring(int startIndex)
# string Substring(int startIndex, int length)

$date = Get-Date "01/01/2010"
$date.ToLongDateString()

# Expects:
#
# 01 January 2010

$tcpClient = New-Object System.Net.Sockets.TcpClient
$tcpClient.Connect("127.0.0.1", 135)

$tcpClient.Connected

# Expects:
#
# True

$tcpClient.Close()

(Get-Date).ToString('u')

# Expects output similar to:
#
# 2016-12-08 21:18:49Z

(Get-Date).Date.AddDays(-1).ToString('u')
```

### Access Modifiers

```powershell
$File = New-Item NewFile.txt -Force
$File | Get-Member -MemberType Property

# Expects:
#
#     TypeName: System.IO.FileInfo
#
# Name              MemberType    Definition
# ----              ----------    ----------
# Attributes        Property      System.IO.FileAttributes Attributes {get;set;}
# CreationTime      Property      datetime CreationTime {get;set;}
# CreationTimeUtc   Property      datetime CreationTimeUtc {get;set;}
# Directory         Property      System.IO.DirectoryInfo Directory {get;}
# DirectoryName     Property      string DirectoryName {get;}
# Exists            Property      bool Exists {get;}

$File = New-Item NewFile.txt -Force
$File.Name = 'NewName'

# Expects error:
#
# 'Name' is a ReadOnly property.
# At line:1 char:1
# + $File.Name = 'NewName'
# + ~~~~~~~~~~~~~~~~~~~~~~
#  + CategoryInfo : InvalidOperation: (:) [], RuntimeException
#  + FullyQualifiedErrorId : PropertyAssignmentException

$File = New-Item NewFile.txt -Force
$File.CreationTime = Get-Date -Day 1 -Month 2 -Year 1692

Get-Item NewFile.txt | Select-Object -ExpandProperty CreationTime
```

### Add-Member

```powershell
$empty = New-Object Object
$empty | Add-Member -Name New -Value 'Hello world' -MemberType NoteProperty
$empty

$empty = New-Object Object
$empty | Add-Member -Name New -Value 'Hello world' -MemberType NoteProperty
$empty | Add-Member -Name Calculated -Value { $this.New.Length } -MemberType ScriptProperty
$empty

$empty = New-Object Object
$empty | Add-Member -Name New -Value 'Hello world' -MemberType NoteProperty
$params = @{
    Name       = 'Replace'
    MemberType = 'ScriptMethod'
    Value      = { $this.New = $this.New -replace 'world', 'everyone' }
}
$empty | Add-Member @params
$empty.Replace()
```

### ForEach-Object

```powershell
Get-Process | ForEach-Object {
    Write-Host $_.Name -ForegroundColor Green
}

Get-Process | ForEach-Object Path

(Get-Date '01/01/2019'), (Get-Date '01/01/2020') | ForEach-Object ToString('yyyyMMdd')

# Expects output:
#
# 20190101
# 20200101
```


### Module manifest

```powershell
$params = @{
    Path              = "$HOME\Documents\PowerShell\Modules\AdminTools\AdminTools.psd1"
    RootModule        = 'AdminTools.psm1'
    Author            = 'Your Name'
    CompanyName       = 'PaulShell'
    ModuleVersion     = '1.0.0'
    Description       = 'An administrative toolset'
    FunctionsToExport = '*'
}
New-ModuleManifest @params
```

## Most used commands

| Command | Alias | Use |
| --- | --- | --- |
| **Get-ExecutionPolicy** -List | | Shows the execution policy for each scope |
| **Get-Help** <command> | `help`, `gh`* | Help for any command |
| **gh** about_CommonParameters | | The parameters every cmdlet supports |
| **Test-Path** <path> | `tp`* | Does a path exist? |
| **Get-Module** -ListAvailable | `gmo` | Lists installed modules |
| **Import-Module** <module> | `ipmo` | Loads a module |
| **Get-Command** -Module <module> | `gcm` | Lists the commands of a module |
| ... \| **Get-Member** | `gm` | Pipe anything into it to see its properties and methods |
| **Get-Process** | `gps` | Lists processes (also Start-Process, Stop-Process) |
| **Get-Service** | `gsv` | Lists services (also Start-Service, Stop-Service). Example: `Get-Service \| Where Status -eq Running` |
| **Get-ChildItem** | `gci` | Lists a folder. Example: `Get-ChildItem C:\Windows\System32 -Filter *.dll` |
| **Get-Acl** <folder> \| Format-List | | Shows the access list of a folder |
| **icacls** <folder> /t | | The same with the classic tool, including subfolders |
| **tree** /a | | Prints the folder tree |
| **netdom** /query FSMO | | Shows the domain role holders (needs the AD tools) |
| **net use** ? | | Drive mappings (and `net ?` for the other net commands) |
| **systeminfo** /S <server> | | System information for a computer (elevated) |
| **query user** /server:<server> | | Who is logged on (elevated) |
| **Get-ADUser** <name> | | An Active Directory user. Example: `Get-ADUser -Filter {Name -like "Smith*"}` |
| **Restart-Computer** | | Restarts a computer (also Stop-Computer) |
| **Enter-PSSession** <computer> | `etsn` | Opens a remote PowerShell session |
| **Exit-PSSession** | `exsn` | Leaves it again |
| **Export-PSSession** <session> | `epsn` | Saves the commands of a session as a module |

\* `gh` and `tp` are not built in: they are set in the Terminal Pro profile.