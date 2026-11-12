@{
    Command  = 'Show-UnixCommon'
    Alias    = 'unixcom'
    Synopsis = 'Common Unix commands'
    Group    = 'GENERAL COMMANDS'
    Order    = 10
    Index    = 'Show-UnixCommands'
    Title    = 'UNIX MODULE - COMMON COMMANDS'
    Prompt   = 'user@ubuntu:~$'

    Sections = @(
        @{
            Title  = 'BASIC COMMANDS'
            Rows   = @'
man <command> :: Opens a manual on any command
whatis <command> :: Outputs a short description on any command
apropos <keyword> :: Searches manual page names and descriptions for a keyword
sudo <command> :: Executes a command as another user (by default root)
sudo su - :: Gives root access (may prompt for password)
nano file.txt :: Opens file.txt in the Nano editor
vim file.txt :: Opens file.txt in the Vim editor
who :: Outputs who is logged on the machine
who am i :: Outputs what user you are logged in as
who | sort :: Outputs who is logged on the machine and sorts the output
finger <user> :: User information lookup program (may need to be installed)
* :: Wildcard, can be used as one or more signs in a file name
ls file* :: Finds all files that start with "file"
quota :: Displays disk usage and limits
df :: Reports file system disk space usage
df -h :: Same, in human-readable sizes (K, M, G)
du :: Estimates file space usage
du -sh * :: Size of each item in the current folder, human-readable
gzip zipfile.txt :: Compresses a file
gunzip zipfile.txt.gz :: Unzips a file
find . -name "*.txt" -print :: Searches all subfolders for .txt extensions. Writes output.
find / -type f -size +100M :: Searches all subfolders from root, for files bigger than 100MB
date :: Outputs date in terminal
cal 5 2008 :: Outputs the calendar for May 2008
clear :: Clears the terminal
echo something :: Outputs something to the terminal
banner :: Prints a large banner (may need to be installed)
'@
        }
        @{
            Title  = 'PROCESS COMMANDS'
            Rows   = @'
ps :: Reports a snapshot of the current processes
ps aux :: Reports every process on the system
jobs :: Outputs running jobs
fg %1 :: Foreground (open) job number 1
kill %1 :: Kills job number 1
kill <pid> :: Ends the process with that process ID (asks it nicely: SIGTERM)
kill -9 <pid> :: Forces the process to end (SIGKILL). Last resort.
'@
        }
        @{
            Title  = 'HISTORY COMMANDS'
            Rows   = @'
history :: GNU History Library
!! :: Executes the previously executed command
!-3 :: Executes the command from 3 commands ago
!5 :: Executes command number 5 in the history
!grep :: Executes the most recent command that starts with grep
HISTSIZE=100 :: Sets the history size to 100 commands (bash)
Ctrl+r :: Searches backwards through the history as you type
'@
        }
    )
}
