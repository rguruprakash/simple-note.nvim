# Neovim Simple Note Plugin

This is a very minimalist note-taking plugin for Neovim. It provides functionality to create, list, preview, rename, and delete notes.

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
        'nvim-telescope/telescope.nvim',
    },
    config = function ()
        require('simple_note').setup({
            notes_dir = '~/my-notes/' -- default: '~/notes/'
        })
    end
}
```

## Usage

### Commands

- `:SimpleNoteList`: Lists all existing notes in a Telescope prompt.
- `:SimpleNoteCreate [filename (optional)]`: Creates a new note file and opens it in Neovim.

### Telescope prompt keymaps

- `<c-n>`: Creates new note
- `<c-x>`: Delete note
- `<c-r>`: Rename note

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
