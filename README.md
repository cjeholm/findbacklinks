# findbacklinks

A Telescope extension for finding backlinks in markdown notes.

For Zettelkasten and other methods.

`:FindBacklinks`
    Opens a Telescope window displaying all notes that link to the current note.
    Uses ripgrep (rg) to search for wikilinks (`[[example-title]]` format).

## Setup

1. Install with Lazy.nvim:
    ```
    {
        "cjeholm/findbacklinks",
        config = function()
            require("findbacklinks")
        end,
        lazy = true,
    }
    ```

2. Ensure ripgrep (`rg`) and bat is installed on your system.
