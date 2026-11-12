@{
    Command  = 'Show-UnixCommunication'
    Alias    = 'unixcomm'
    Synopsis = 'Unix communication commands'
    Group    = 'GENERAL COMMANDS'
    Order    = 40
    Index    = 'Show-UnixCommands'
    Title    = 'UNIX MODULE - COMMUNICATION COMMANDS'
    Prompt   = 'user@ubuntu:~$'

    Sections = @(
        @{
            Title  = 'MAIL'
            Rows   = @'
apt-get install mailutils :: Install mail utilities
mail user :: Send a mail to "user" @ the same system
mail user@differentsystem :: Send a mail to "user" @ "differentsystem"
<CTRL>+d :: To finish typing the mail
mail :: Opens your inbox
'@
        }
        @{
            Title  = 'WRITE'
            Rows   = @'
write user :: Writes to "user"
o :: Means over
oo :: Means over and out
<CTRL>+d :: To end the session
write user@differentsystem :: Write session with "user" @ "differentsystem"
'@
        }
        @{
            Title  = 'WALL'
            Rows   = @'
wall pickle riiiiick :: Notifies all users on the system about "pickle riiiiick"
'@
        }
        @{
            Title  = 'TALK'
            Rows   = @'
talk user :: "user" Receives a talk invite
'@
        }
    )
}
