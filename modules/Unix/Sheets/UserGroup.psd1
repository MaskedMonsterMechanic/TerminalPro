@{
    Command  = 'Show-UnixUserGroup'
    Alias    = 'unixug'
    Synopsis = 'Unix user and group commands'
    Group    = 'GENERAL COMMANDS'
    Order    = 30
    Index    = 'Show-UnixCommands'
    Title    = 'UNIX MODULE - USER & GROUP COMMANDS'
    Prompt   = 'user@ubuntu:~$'

    Sections = @(
        @{
            Title  = 'RIGHTS'
            Rows   = @'
chmod :: Change file mode bits
chmod go-rwx file :: Group, Other removed(-) Read, Write and Execute to file.
chmod ua+rwx file :: User, All users added(+) Read, Write and Execute to file.
chmod u :: The user who owns it
chmod g :: Other users in the file's Group
chmod o :: Other users not in the file's Group
chmod a :: All users
chmod + :: Add rights
chmod - :: Remove rights
chmod r (4) :: Read
chmod w (2) :: Write
chmod x (1) :: Execute
chmod 740 file :: The digits are owner, group, others. Add up r(4) w(2) x(1) for each.
Here: owner 7 = rwx, group 4 = r--, others 0 = ---.
ls -l :: Shows the rights of each file, for example -rwxr----- (type, owner, group, others)
chown user file :: Changes the owner of file to "user" (needs sudo)
chown user:group file :: Changes the owner and the group at the same time
chgrp group file :: Changes the group of file
'@
        }
        @{
            Title  = 'USERS & GROUPS'
            Prompt = 'root@ubuntu:~#'
            Rows   = @'
groupadd group :: Creates the group "group"
adduser user :: Creates user "user"
adduser user group :: Adds "user" to "group"
passwd user :: Sets or changes the password for "user"
groupmems -g group -a user :: Adds "user" to "group"
groupmems -g group -d user :: Removes "user" from "group"
groups user :: Displays what groups "user" is a member of
groupmems -l -g group :: Displays group members of "group"
usermod -aG group user :: Adds "user" to "group" (keeps the other groups)
deluser user :: Removes "user" (Debian and Ubuntu)
id user :: Shows the user ID, group ID and groups of "user"
'@
        }
        @{
            Title  = 'WHO IS HERE'
            Prompt = 'user@ubuntu:~$'
            Rows   = @'
whoami :: Prints the name of the current user
id :: Shows your user ID, group ID and groups
last :: Shows the latest logins
sudo -l :: Lists what you are allowed to do with sudo
'@
        }
    )
}
