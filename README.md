# Neovim Simple Note Plugin

This is a very minimalist note-taking plugin for Neovim. It provides functionality to create, list, preview, rename, and delete notes.

## Features

- Create a new note file with a unique timestamp as the filename.
- List all existing notes in a Telescope prompt.
- Preview notes in a Telescope prompt.
- Delete a selected note file.
- Rename a selected note file.

## Installation and Configuration

**Lazy**

```lua
{
    'rguruprakash/simple-note.nvim',
    dependencies = {
        'nvim-telescope/telescope.nvim',
    },
    config = function ()
        require('simple-note').setup({
            notes_dir = '~/my-notes/' -- default: '~/notes/'
        })
    end
}
```

## Usage

You can use the following commands to interact with your notes:

- `:SimpleNoteList`: Lists all existing notes in a Telescope prompt.
- `:SimpleNoteCreate`: Creates a new note file and opens it in Neovim.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
