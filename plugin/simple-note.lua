vim.api.nvim_create_user_command("SimpleNoteList", require("simple-note").listNotes, {})
vim.api.nvim_create_user_command("SimpleNoteCreate", require("simple-note").createAndOpenNoteFile, { nargs = '?' })
