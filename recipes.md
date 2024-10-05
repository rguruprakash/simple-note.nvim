# Recipes
This is an attempt to provide some basic use cases for the plugin.

## Datebook

It might be useful to create a datebook-like workflow by creating a note for the current day.
Put the code below into your configuration file:

``` lua

local function openOrCreateTodayNote()
  local filename = os.date('%Y_%m_%d')
  vim.cmd('SimpleNoteCreate ' .. filename)
end

vim.api.nvim_create_user_command('SimpleNoteToday', openOrCreateTodayNote, {})

require('simple-note').setup { }

```
The `SimpleNoteToday` command creates a note with the name like `yyyy_mm_dd.md` and opens it, or it simply opens the note if it has already been created before.
