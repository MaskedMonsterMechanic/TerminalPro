@{
    Command  = 'Show-MdLists'
    Alias    = 'mdlist'
    Synopsis = 'Lists, task lists, links and images'
    Group    = 'CHEAT-SHEETS'
    Order    = 20
    Index    = 'Show-MdCommands'
    Title    = 'MARKDOWN - LISTS AND LINKS'

    Sections = @(
        @{
            Title  = 'LISTS'
            Rows   = @'
- item :: A bullet list. A star (*) or a plus (+) works too.
1. item :: A numbered list. The numbers can all be 1., Markdown counts for you.
2 spaces + - item :: A list inside a list. Indent with 2 spaces (4 under a numbered item).
(an empty line) :: Ends the list
Note: Put an empty line above the list, or some viewers do not see it as a list.
Note: To put a paragraph or a code block inside an item, indent it the same as the item text.
'@
        }
        @{
            Title  = 'TASK LISTS (GITHUB)'
            Rows   = @'
- [ ] to do :: An open box
- [x] done :: A ticked box
Note: On GitHub the boxes can be clicked in issues and pull requests.
'@
        }
        @{
            Title  = 'LINKS'
            Rows   = @'
[the text](https://example.com) :: A link
[the text](https://example.com "A tooltip") :: A link with a tooltip
[the text](docs/guide.md) :: A link to another file in the same project
[the text](#my-heading) :: A link to a heading on the same page
Note: The heading link is the heading in lower case, with dashes for spaces. "My Heading" becomes #my-heading.
[the text][guide] :: A link whose address is written somewhere else on the page
[guide]: https://example.com :: The address for [guide], on a line of its own (it is not shown)
<name@example.com> :: An e-mail link
'@
        }
        @{
            Title  = 'IMAGES'
            Rows   = @'
![describe it](picture.png) :: An image. The text in the [] is read by screen readers.
![describe it](picture.png "A tooltip") :: An image with a tooltip
[![describe it](picture.png)](https://example.com) :: An image you can click
Note: Use a path from the file itself (images/picture.png) so the picture follows the project.
Note: Need a size? Use HTML: <img src="picture.png" width="400">
'@
        }
    )
}
