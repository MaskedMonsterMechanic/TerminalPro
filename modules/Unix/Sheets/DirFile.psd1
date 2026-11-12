@{
    Command  = 'Show-UnixDirFile'
    Alias    = 'unixdf'
    Synopsis = 'Unix directory and file commands'
    Group    = 'GENERAL COMMANDS'
    Order    = 20
    Index    = 'Show-UnixCommands'
    Title    = 'UNIX MODULE - DIRECTORY & FILE COMMANDS'
    Prompt   = 'user@ubuntu:~$'

    Sections = @(
        @{
            Title  = 'DIRECTORY COMMANDS'
            Rows   = @'
ls :: List directory contents
ls -a, --all :: Does not ignore entries starting with .
ls -A, --almost-all :: Does not list implied . and ..
ls --author :: With -l, print the author of each file
ls -d, --directory :: List directories themselves, not their contents
ls -l :: Use a long listing format
ls -s, --size :: Print the allocated size of each file, in blocks
ls -S :: Sort by file size, largest first
ls -lh :: Long listing with human-readable sizes
mkdir :: Make Directory
mkdir -p a/b/c :: Make Directory, and any parents that are missing
rmdir :: Remove Directory (must be empty in order to remove)
rm -r folder :: Remove a folder and everything in it (no undo!)
cd :: Change Directory
cd ~ :: Change Directory to Home
cd .. :: Change Directory one level up (the parent directory)
cd / :: Change Directory to the root of the file system
cd - :: Change back to the previous directory
pwd :: Print Working Directory
'@
        }
        @{
            Title  = 'FILE COMMANDS'
            Rows   = @'
touch file :: Creates a zero-length file called "file"
rm file :: Removes "file"
cp file1 file2 :: Copies file1 into file2
cp -r dir1 dir2 :: Copies a folder and its content
ls -a > file.txt :: Outputs content of ls -a command into file.txt
cp /home/files/file.txt . :: Copies file.txt into the working directory you are in
mv file.txt newname.txt :: Moves or renames file.txt
less file.txt :: Outputs content of file.txt, one page at a time
head file.txt :: Outputs the first 10 lines of file.txt
head -5 file.txt :: Outputs the first 5 lines of file.txt
tail file.txt :: Outputs the last 10 lines of file.txt
tail -f file.txt :: Keeps showing new lines as they are added to file.txt
locate file.txt :: Searches for everything containing "file.txt"
grep Coolaid file.txt :: Searches for every occurrence of "Coolaid" in file.txt
grep -i Coolaid file.txt :: Adding -i makes grep ignore upper and lower case
grep -r Coolaid . :: Searches every file in this folder and below
wc :: Counts lines, words and bytes
wc -l :: Counts lines
cat :: Inserts input until "End of File" (Ctrl+d)
cat > file.txt :: Overwrites file.txt with your input until "End of File" (Ctrl+d)
cat >> file.txt :: Adds your input to file.txt until "End of File" (Ctrl+d)
cat file.txt :: Outputs file.txt content to terminal
cat file1 file2 > giantfile :: Compiles both files into one file
find . -name "*.txt" -print :: Searches all subfolders for .txt extensions. Writes output.
find . -type f -size +100M :: Searches all subfolders for files bigger than 100MB
find / -type f -size +100M :: Searches all subfolders from root, for files bigger than 100MB
'@
        }
    )
}
