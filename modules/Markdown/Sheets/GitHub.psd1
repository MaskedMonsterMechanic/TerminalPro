@{
    Command  = 'Show-MdGitHub'
    Alias    = 'mdgit'
    Synopsis = 'GitHub extras: alerts, mentions, emoji, badges, maths, diagrams'
    Group    = 'CHEAT-SHEETS'
    Order    = 40
    Index    = 'Show-MdCommands'
    Title    = 'MARKDOWN - GITHUB EXTRAS'

    Sections = @(
        @{
            Title  = 'ALERTS (BOXES WITH A COLOUR)'
            Rows   = @'
> [!NOTE] :: A blue box. Extra information.
> [!TIP] :: A green box. A helpful hint.
> [!IMPORTANT] :: A purple box. Something the reader must know.
> [!WARNING] :: A yellow box. Something that can go wrong.
> [!CAUTION] :: A red box. Something that can do damage.
Note: Write the text of the alert on the next line, also starting with >.
Note: These are a GitHub thing. Other viewers show them as a plain quote.
'@
        }
        @{
            Title  = 'LINKING INSIDE GITHUB'
            Rows   = @'
@username :: Mentions a person and sends them a message
#123 :: Links to issue or pull request number 123 in the same project
owner/project#123 :: Links to an issue in another project
a1b2c3d :: A commit id (7 or more characters) turns into a link
Fixes #123 :: In a pull request: closes issue 123 when the pull request is merged. Also: Closes, Resolves.
Note: These links work in issues, pull requests and comments. In a README file only @ and the plain addresses are certain.
'@
        }
        @{
            Title  = 'EMOJI'
            Rows   = @'
:tada: :rocket: :warning: :white_check_mark: :bug: :memo: :: Type the name between two colons
Note: For the full list of names, search the web for: github emoji cheat sheet
'@
        }
        @{
            Title  = 'BADGES'
            Rows   = @'
https://img.shields.io/badge/licence-MIT-green :: The address of a small status label (an image from shields.io). Pattern: /badge/TEXT-TEXT-COLOUR
![Licence](ADDRESS) :: Shows the badge, like any image
[![Licence](ADDRESS)](LICENSE) :: A badge you can click (here it opens the LICENSE file)
Note: A dash in the text is written as two dashes (--). A space is _ or %20.
'@
        }
        @{
            Title  = 'FOOTNOTES'
            Rows   = @'
Some text[^1] :: Puts a small number 1 in the text
[^1]: The footnote. :: On a line of its own: the text of the footnote. GitHub puts it at the bottom.
'@
        }
        @{
            Title  = 'MATHS'
            Rows   = @'
$x^2 + y^2 = z^2$ :: A formula in the middle of a sentence (between two dollar signs)
$$ ... $$ :: A formula on a line of its own, centred
'@
        }
        @{
            Title  = 'DIAGRAMS'
            Rows   = @'
```mermaid :: A code block that GitHub draws as a diagram
graph TD; A[Start] --> B[End]; :: The text inside: a flow chart going top down, with two boxes
Note: Other types exist: sequenceDiagram, gantt, pie, classDiagram. See mermaid.js.org
'@
        }
        @{
            Title  = 'THE REST'
            Rows   = @'
<!-- TOC --> :: Not needed. GitHub makes a table of contents by itself (the list button, top right of the file).
README.md :: GitHub shows this file on the front page of the project
Note: Also known as: CONTRIBUTING.md and SECURITY.md in the project root, and LICENSE for the licence text.
'@
        }
    )
}
