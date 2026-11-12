@{
    Command  = 'Show-MdBasics'
    Alias    = 'mdbasic'
    Synopsis = 'The basics: headings, paragraphs, text style, quotes'
    Group    = 'CHEAT-SHEETS'
    Order    = 10
    Index    = 'Show-MdCommands'
    Title    = 'MARKDOWN - THE BASICS'

    Sections = @(
        @{
            Title  = 'HEADINGS'
            Rows   = @'
# Heading 1 :: The biggest heading. Use one per page, at the top.
## Heading 2 :: A section heading
### Heading 3 :: A sub-section. It goes down to ###### (level 6).
Note: Put a space after the #. "#Heading" is plain text on GitHub.
Note: Leave an empty line above and below a heading.
'@
        }
        @{
            Title  = 'PARAGRAPHS AND LINE BREAKS'
            Rows   = @'
(an empty line) :: Starts a new paragraph
text + two spaces at the end of the line :: A line break inside a paragraph (you cannot see the spaces)
text + a backslash at the end of the line :: Also a line break, and easier to see
<br> :: A line break written as HTML (GitHub allows it)
Note: A single line break in your text is NOT a line break in the result. The lines are joined into one paragraph.
'@
        }
        @{
            Title  = 'TEXT STYLE'
            Rows   = @'
*italic*  or  _italic_ :: Italic
**bold**  or  __bold__ :: Bold
***bold and italic*** :: Both at once
~~strikethrough~~ :: Strikethrough (GitHub)
`code` :: Code in the middle of a sentence (backticks)
<kbd>Ctrl</kbd> :: Looks like a keyboard key (GitHub allows it)
H<sub>2</sub>O  and  x<sup>2</sup> :: Subscript and superscript (HTML, GitHub allows it)
Note: In the middle of a word use stars, not underscores: un*believ*able works, snake_case_name is left alone.
'@
        }
        @{
            Title  = 'QUOTES AND LINES'
            Rows   = @'
> a quote :: A block quote
> > a quote in a quote :: A nested quote
---  or  ***  or  ___ :: A horizontal line
Note: Put an empty line above ---. Right under a line of text it makes that text a heading.
'@
        }
        @{
            Title  = 'SHOWING A SPECIAL CHARACTER'
            Rows   = @'
\*  \_  \#  \`  \[  \| :: A backslash in front shows the character itself instead of using it
<https://example.com> :: A link made from the address itself
Note: GitHub also turns a plain address (https://example.com) into a link.
'@
        }
    )
}
