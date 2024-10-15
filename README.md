# Neovim Simple Note Plugin

This is a very minimalist note-taking plugin for Neovim. It provides functionality to create, list, preview, rename, and delete notes.

#### Motivation
I've always desired a simple, straightforward note-taking method in vim. I'm only interested in basic functions such as creating, listing, deleting, renaming, and previewing notes. I don't need advanced features like nested notes or linking notes - just plain markdown notes will do. This plugin attempts to do the same with the help of telescope.nvim

## Features

- Create a new note file with a unique timestamp or the provided filename as argument.
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
        'nvim-lua/plenary.nvim',
        'nvim-telescope/telescope.nvim',
    },
    config = function ()
        require('simple-note').setup({
            -- Optional Configurations
            notes_dir = '~/notes/', -- default: '~/notes/'
            notes_directories = { -- default: {}
                '~/notes/',
                '~/work/',
                '~/personal/'
            },
            telescope_new = '<C-n>', -- default: <C-n> 
            telescope_delete = '<C-x>', -- default: <C-x>
            telescope_rename = '<C-r>', -- default: <C-r>
            telescope_change_directory = '<C-c>'  -- default: <C-c>
        })
    end
}
```

## Usage

### Commands

- `:SimpleNoteList`: Lists all existing notes in a Telescope prompt.
- `:SimpleNoteCreate [filename (optional)]`: Creates a new note file and opens it in Neovim.
- `:SimpleNotePickDirectory`: Pick notes directory.

### Telescope default prompt keymaps

- `<c-n>`: Creates new note (using the current line in the search prompt if any)
- `<c-x>`: Delete note
- `<c-r>`: Rename note
- `<c-c>`: Change notes directory

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
