# findbacklinks

A Telescope extension for finding backlinks and outgoing `[[wikilinks]]` in markdown notes.

For Zettelkasten and other methods.

`:FindBacklinks`
Opens a Telescope window displaying all notes that link to the current note.
Uses ripgrep (rg) to search for wikilinks (`[[example-title]]` format).

`:FindOutlinks`
For outgoing links.

## Setup

1. Install with Lazy.nvim:

   ```
   {
       "cjeholm/findbacklinks",
       config = function()
           require("findbacklinks")
       end,
       lazy = false,
   }
   ```

2. Ensure ripgrep (`rg`) and bat is installed on your system.
