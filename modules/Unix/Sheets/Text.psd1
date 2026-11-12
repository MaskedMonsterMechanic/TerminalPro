@{
    Command  = 'Show-UnixText'
    Alias    = 'unixtxt'
    Synopsis = 'Text tools, pipes and archives'
    Group    = 'TEXT & ARCHIVES'
    Order    = 70
    Index    = 'Show-UnixCommands'
    Title    = 'UNIX MODULE - TEXT, PIPES & ARCHIVES'
    Prompt   = 'user@ubuntu:~$'

    Sections = @(
        @{
            Title  = 'PIPES AND REDIRECTS'
            Rows   = @'
command > file :: Writes the output to a file (overwrites)
command >> file :: Adds the output to the end of a file
command 2> errors.txt :: Writes only the error messages to a file
command > out.txt 2>&1 :: Writes output and errors to the same file
command1 | command2 :: Sends the output of command1 into command2
command | tee file :: Shows the output and also saves it to a file
command | xargs rm :: Uses each line of the output as an argument for rm
'@
        }
        @{
            Title  = 'LOOKING AT TEXT'
            Rows   = @'
sort file :: Sorts the lines
sort -n file :: Sorts the lines as numbers
sort file | uniq :: Removes lines that repeat right after each other (sort first)
sort file | uniq -c :: Counts how many times each line occurs
grep -v word file :: Shows the lines that do NOT contain "word"
grep -c word file :: Counts the lines that contain "word"
cut -d, -f1 file.csv :: Shows the first column of a comma-separated file
awk '{print $1}' file :: Shows the first word on each line
sed 's/old/new/g' file :: Replaces "old" with "new" on every line
tr 'a-z' 'A-Z' :: Changes lower case to upper case (reads from a pipe)
diff file1 file2 :: Shows the differences between two files
nl file :: Shows the file with line numbers
'@
        }
        @{
            Title  = 'ARCHIVES'
            Rows   = @'
tar -czf archive.tar.gz folder :: Packs a folder into a compressed archive
tar -xzf archive.tar.gz :: Unpacks an archive here
tar -tf archive.tar.gz :: Lists what is in an archive without unpacking
tar -xzf archive.tar.gz -C /tmp :: Unpacks into /tmp
zip -r archive.zip folder :: Packs a folder into a zip file
unzip archive.zip :: Unpacks a zip file
gzip file :: Compresses a file (file becomes file.gz)
gunzip file.gz :: Unpacks a .gz file
'@
        }
    )
}
