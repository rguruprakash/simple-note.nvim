vim.api.nvim_create_user_command("SimpleNoteList", require("simple_note").listNotes, {})
vim.api.nvim_create_user_command("SimpleNoteCreate", function(args)
  require("simple_note").createAndOpenNoteFile(args)
end, {})
