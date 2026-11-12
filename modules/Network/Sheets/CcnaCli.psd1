@{
    Command  = 'Show-CcnaCli'
    Alias    = 'ccnacli'
    Synopsis = 'Cisco CLI: keyboard shortcuts, help, filtering output, history'
    Group    = 'CCNA'
    Order    = 100
    Index    = 'Show-NetCommands'
    Title    = 'CCNA - THE CISCO COMMAND LINE: SHORTCUTS AND FILTERS'

    Sections = @(
        @{
            Title  = 'MOVE AROUND THE LINE'
            Rows   = @'
Ctrl+A :: Go to the start of the line
Ctrl+E :: Go to the end of the line
Ctrl+B or Left arrow :: One character to the left
Ctrl+F or Right arrow :: One character to the right
Esc B :: One word to the left
Esc F :: One word to the right
Ctrl+P or Up arrow :: The previous command in the history
Ctrl+N or Down arrow :: The next command in the history
Ctrl+R :: Draws the prompt and the line again (use it when a log message landed in the middle of your typing)
Tab :: Completes a partly typed command
'@
        }
        @{
            Title  = 'DELETE'
            Rows   = @'
Backspace :: Delete the character to the left
Ctrl+D :: Delete the character at the cursor
Ctrl+K :: Delete from the cursor to the end of the line
Ctrl+U or Ctrl+X :: Delete from the cursor to the start of the line
Ctrl+W :: Delete the word to the left
Esc D :: Delete from the cursor to the end of the word
Note: the Delete key does not work in some terminal programs. Use Ctrl+D instead.
'@
        }
        @{
            Title  = 'STOP AND LEAVE'
            Rows   = @'
Ctrl+Z :: Leaves any configuration mode and goes back to privileged mode (the same as typing "end")
Ctrl+C :: Aborts the current command. In setup mode it goes back to the prompt.
Ctrl+Shift+6, then X :: The all-purpose break: stops a ping, a traceroute or a DNS lookup that hangs
Any key at --More-- :: Stops the output
Space at --More-- :: Next screen
Enter at --More-- :: Next line
Note: a command you mistyped can start a DNS lookup that freezes the console. "no ip domain-lookup" prevents it.
'@
        }
        @{
            Title  = 'HELP'
            Prompt = 'Router#'
            Rows   = @'
? :: Lists the commands you can use in this mode
show ? :: Lists what can follow "show"
sh ip int ? :: Abbreviations work as long as they are not ambiguous
show ip int<Tab> :: Completes the word (if there is only one match)
cl? :: Lists the commands that start with "cl" (no space before the question mark)
% Incomplete command :: You left something out: add "?" to see what
% Ambiguous command :: Your abbreviation matches several commands: type more letters
% Invalid input detected at '^' marker :: The caret points to the first wrong character
Router(config)# :: do show ip route :: Runs an exec command from inside configuration mode
'@
        }
        @{
            Title  = 'FILTER THE OUTPUT'
            Prompt = 'Router#'
            Rows   = @'
show running-config | include ip route :: Only the lines that contain this text
show running-config | exclude ! :: Everything except the lines with this text
show running-config | begin line vty :: From the first matching line to the end
show running-config | section ospf :: The whole block that starts with this text (a router ospf block, for example)
show ip interface brief | include up :: Only the interfaces that are up
show interfaces | include line protocol|errors :: More than one word: use | between them
show run | begin f0/18 :: The short form is fine
Note: the filter is case-sensitive.
'@
        }
        @{
            Title  = 'HISTORY AND SCREEN'
            Prompt = 'Router#'
            Rows   = @'
show history :: Lists the last commands you typed
terminal history size 200 :: Remembers 200 commands for this session (default is 10)
terminal length 0 :: Turns off the --More-- prompt for this session
terminal monitor :: Shows log messages in a telnet or SSH session
Router(config-line)# :: logging synchronous :: Stops log messages from cutting into your typing (use on line con 0 and line vty)
Router(config-line)# :: exec-timeout 0 0 :: Never logs you out. Only for the lab, not for real equipment.
'@
        }
    )
}
