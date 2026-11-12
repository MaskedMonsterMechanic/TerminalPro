@{
    Command  = 'Show-UnixSystem'
    Alias    = 'unixsys'
    Synopsis = 'Services, packages, disks and processes'
    Group    = 'ADMIN & NETWORK'
    Order    = 50
    Index    = 'Show-UnixCommands'
    Title    = 'UNIX MODULE - SYSTEM & SERVICES'
    Prompt   = 'user@ubuntu:~$'

    Sections = @(
        @{
            Title  = 'SERVICES (systemd)'
            Rows   = @'
systemctl status ssh :: Shows whether the service "ssh" is running
sudo systemctl start ssh :: Starts the service
sudo systemctl stop ssh :: Stops the service
sudo systemctl restart ssh :: Stops and starts the service
sudo systemctl enable ssh :: Starts the service at every boot
sudo systemctl disable ssh :: Does not start the service at boot
systemctl list-units --type=service :: Lists the services that are loaded
systemctl --failed :: Lists the services that failed
journalctl -u ssh :: Shows the log of the service "ssh"
journalctl -u ssh -f :: Follows the log of the service as it grows
journalctl -p err -b :: Shows errors since the last boot
'@
        }
        @{
            Title  = 'PACKAGES (Debian and Ubuntu: apt)'
            Rows   = @'
sudo apt update :: Refreshes the list of available packages
sudo apt upgrade :: Installs newer versions of the installed packages
sudo apt install name :: Installs a package
sudo apt remove name :: Removes a package
sudo apt autoremove :: Removes packages nothing needs any more
apt search word :: Searches for a package
apt show name :: Shows information about a package
dpkg -l :: Lists the installed packages
sudo dnf install name :: The same on Fedora and Red Hat (dnf instead of apt)
'@
        }
        @{
            Title  = 'DISKS, MEMORY AND PROCESSES'
            Rows   = @'
df -h :: Disk space per file system
lsblk :: Lists disks and partitions
free -h :: Memory and swap in use
uptime :: How long the system has been running, and the load
top :: Live view of the processes (q to quit)
htop :: A nicer top (may need to be installed)
ps aux | grep name :: Finds a process by name
uname -a :: Kernel and system information
hostnamectl :: Shows the host name and operating system
'@
        }
        @{
            Title  = 'SCHEDULING AND POWER'
            Rows   = @'
crontab -e :: Edits your scheduled jobs
crontab -l :: Lists your scheduled jobs
0 2 * * * /path/script.sh :: A cron line: minute, hour, day, month, weekday, command (here: 02:00 every day)
sudo reboot :: Restarts the machine
sudo shutdown -h now :: Shuts the machine down now
sudo shutdown -r +10 :: Restarts in 10 minutes
'@
        }
    )
}
