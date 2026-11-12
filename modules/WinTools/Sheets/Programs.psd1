@{
    Command  = 'Show-WinPrograms'
    Alias    = 'winpkg'
    Synopsis = 'Installing programs from the terminal: winget, Chocolatey, Scoop and PowerShell modules'
    Group    = 'GENERAL COMMANDS'
    Order    = 20
    Index    = 'Show-WinToolsCommands'
    Title    = 'WINTOOLS - INSTALLING PROGRAMS FROM THE TERMINAL'
    Prompt   = 'C:\>'

    Sections = @(
        @{
            Title  = 'WHICH TOOL'
            Rows   = @'
 :: winget :: Made by Microsoft. Comes with Windows 11 and recent Windows 10 (as App Installer). Most programs install without admin rights. Start here.
 :: Chocolatey (choco) :: The oldest and biggest package source. Most installs need an administrator window.
 :: Scoop :: Installs into your own user folder, so it never needs admin rights. Good for command-line and developer tools.
 :: PowerShell modules :: Not programs. They have their own commands (last section).
winget --version :: Is winget there? (choco --version and scoop --version do the same for the others)
'@
        }
        @{
            Title  = 'WINGET: THE ONE TO LEARN FIRST'
            Rows   = @'
winget search git :: Looks for a program (name, id and version)
winget show Git.Git :: Shows what a package is before you install it (publisher, licence, links)
winget install --id Git.Git -e :: Installs it. --id with -e (exact) picks exactly one package, not a look-alike
winget install --id Git.Git -e --silent :: Installs without windows to click through
winget install --id Git.Git -e --scope user :: Installs for your user only, when the package supports it
winget install --id Git.Git -e --version 2.45.0 :: A specific version (list them with: winget show Git.Git --versions)
winget install --id Git.Git -e --accept-package-agreements :: Answers the package licence question yes. For scripts, after you have read what you install.
 :: --accept-source-agreements :: Add it as well to answer the question about the package source (asked the first time you use a source).
winget list :: Lists the programs installed on this PC (also those not installed with winget)
winget list git :: Finds one installed program
winget upgrade :: Lists the programs that have a newer version
winget upgrade --id Git.Git -e :: Updates one program
winget upgrade --all :: Updates everything it can
winget uninstall --id Git.Git -e :: Removes a program
winget pin add --id Git.Git :: Keeps one program out of "upgrade --all" (newer winget versions)
winget source list :: Shows where winget looks (the winget list and the Microsoft Store)
winget source update :: Refreshes the package lists
winget --info :: Shows the version, the log folder and the settings links
'@
        }
        @{
            Title  = 'WINGET: MOVE A SETUP TO ANOTHER PC'
            Rows   = @'
winget export -o apps.json :: Writes the list of installed programs to a file
winget import -i apps.json :: Installs everything in the file (use it on a fresh PC)
winget import -i apps.json --ignore-unavailable :: Skips programs it cannot find, instead of stopping
 :: Note :: The file is plain JSON. You can open it, delete lines you do not want and keep it in your notes.
'@
        }
        @{
            Title  = 'CHOCOLATEY'
            Rows   = @'
 :: install :: Use the one-line install on chocolatey.org/install in an administrator window. Read the script first.
choco search git :: Searches the package list
choco info git :: Shows the details of a package
choco install git -y :: Installs a package. -y answers yes to the questions.
choco list --local-only :: Lists the installed packages (in version 2 plain "choco list" shows the installed ones)
choco outdated :: Shows which packages have a newer version
choco upgrade git -y :: Updates one package
choco upgrade all -y :: Updates everything
choco upgrade all --noop :: Shows what would be updated and changes nothing
choco uninstall git -y :: Removes a package
choco pin add -n=git :: Keeps one package out of "upgrade all"
choco source list :: Shows the package sources
choco -? :: Lists every choco command (choco install -? shows the options of one)
'@
        }
        @{
            Title  = 'SCOOP (NO ADMIN RIGHTS)'
            Rows   = @'
 :: install :: The one-line install is on scoop.sh. It installs into your user folder. Read the script first.
scoop search git :: Searches the package list
scoop install git :: Installs a program for your user
scoop list :: Lists what you have installed
scoop status :: Shows what has a newer version
scoop update * :: Updates every program (scoop update alone updates Scoop itself)
scoop uninstall git :: Removes a program
scoop bucket add extras :: Adds a bigger package list (a bucket is a package list)
scoop cleanup * :: Removes the old versions that updates leave behind
'@
        }
        @{
            Title  = 'POWERSHELL MODULES'
            Prompt = 'PS>'
            Rows   = @'
Find-PSResource posh-git :: Searches the PowerShell Gallery (PowerShell 7.4 and later)
Install-PSResource posh-git -Scope CurrentUser :: Installs a module for your user, no admin rights
Get-InstalledPSResource :: Lists the installed modules
Update-PSResource posh-git :: Updates a module
Uninstall-PSResource posh-git :: Removes a module
Install-Module posh-git -Scope CurrentUser :: The same job in Windows PowerShell 5.1
'@
        }
        @{
            Title  = 'SAFE HABITS'
            Rows   = @'
Look before you install: winget show (or choco info) tells you what it is and who made it.
Use the exact id (winget -e) so you do not install a look-alike.
One manager per program. If winget and Chocolatey both install the same program, their updates fight.
Never run an install one-liner you have not read. Download it, read it, then run it.
The switches --scope, pin and --ignore-unavailable depend on the winget version. Check with: winget install --help
'@
        }
    )
}
