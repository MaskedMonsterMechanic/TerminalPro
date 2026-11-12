@{
    Command  = 'Show-MdCode'
    Alias    = 'mdcode'
    Synopsis = 'Code in text, code blocks and tables'
    Group    = 'CHEAT-SHEETS'
    Order    = 30
    Index    = 'Show-MdCommands'
    Title    = 'MARKDOWN - CODE AND TABLES'

    Sections = @(
        @{
            Title  = 'CODE IN A SENTENCE'
            Rows   = @'
`Get-Process` :: Code in the middle of a sentence. Use backticks.
`` a `tick` in code `` :: Two backticks on each side let the code contain a backtick
'@
        }
        @{
            Title  = 'CODE BLOCKS'
            Rows   = @'
```  (3 backticks) :: Starts a code block. Three more backticks on a line of their own end it.
```powershell :: A code block with colours. Write the language right after the backticks.
4 spaces in front of each line :: The old way. It works, but has no colours.
```json  ```yaml  ```bash  ```sql :: Other languages that get colours: json, yaml, bash, sql, csharp, python, html, diff, text
Note: Use ```text for output that should not be coloured.
Note: Need three backticks inside a block? Start and end the block with four.
'@
        }
        @{
            Title  = 'SHOWING A CHANGE (DIFF)'
            Rows   = @'
```diff :: A code block that shows changes
+ added line :: A line starting with + is green
- removed line :: A line starting with - is red
'@
        }
        @{
            Title  = 'TABLES'
            Rows   = @'
| Name | Role | :: The header row. Columns are split with the | character.
|------|------| :: The line under the header. It is needed, with at least 3 dashes per column.
| DC01 | Domain controller | :: A row. Each row goes on its own line.
|:-----|  or  |:----:|  or  |-----:| :: In the dashes line: a colon on the left = left aligned, both sides = centred, on the right = right aligned
Note: The columns do not have to line up in your text. It only looks tidy.
Note: Need a | inside a cell? Write \| instead.
Note: A table cannot have a line break in a cell. Use <br> for one.
Note: There must be an empty line above the table.
'@
        }
        @{
            Title  = 'HIDING AND FOLDING'
            Rows   = @'
<!-- a comment --> :: Not shown in the result
<details> :: Starts a fold-out part (GitHub allows it). Close it with </details>
<summary>Click me</summary> :: Directly under <details>: the text that is always visible
Note: Leave an empty line after </summary>, or the Markdown inside will not work.
'@
        }
    )
}
