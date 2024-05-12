local createNotesDir = function(notes_dir)
  local dir = tostring(vim.fn.expand(notes_dir))
  if not vim.loop.fs_stat(dir) then
    vim.loop.fs_mkdir(dir, 511) -- 511 (0777 in octal) means the owner, group and others can read, write and execute.
    vim.notify("Created " .. dir)
  end
end

---@class Config
---@field notes_dir string path to the directory where the notes should be created
---@field notes_name_template string template for generating new note names. it supports any tag from the os.date function.
local config = {
  notes_dir = "~/notes/",
  notes_directories = {},
  notes_name_template = "%A_%B_%d_%Y_%I_%M_%S_%p",
  telescope_new = "<C-n>",
  telescope_delete = "<C-x>",
  telescope_rename = "<C-r>",
  telescope_change_directory = "<C-c>",
}

---@class MyModule
local M = {}

---@type Config
M.config = config

---@param args table
M.setup = function(args)
  M.config = vim.tbl_deep_extend("force", M.config, args or {})
  createNotesDir(M.config.notes_dir)
end

M.listNotes = function()
  local actions = require("telescope.actions")
  local actions_state = require("telescope.actions.state")

  M.picker = require("telescope.builtin").find_files({
    cwd = M.config.notes_dir,
    find_command = function()
      if vim.fn.has "win32" == 1 then
        return { "cmd", "/c", "dir", "/b", "/a:-d" }
      else
        return { "find", ".", "-maxdepth", "1", "-not", "-type", "d" }
      end
    end,
    layout_strategy = "flex",
    prompt_title = "Find Notes (" .. M.config.notes_dir .. ")",
    results_title = "Notes",
    attach_mappings = function(_, map)
      map({ "i", "n" }, M.config.telescope_new, function(prompt_bufnr)
        local current_line = actions_state.get_current_line()
        local opts = current_line ~= "" and { fargs = { current_line } } or {}
        M.createNoteFile(opts)
        local picker = actions_state.get_current_picker(prompt_bufnr)
        actions.close(prompt_bufnr) -- Close the previewer
        M.listNotes()
      end, { desc = "Create new note" })
      map({ "i", "n" }, M.config.telescope_delete, function(prompt_bufnr)
        local entry = actions_state.get_selected_entry(prompt_bufnr)
        local filePath = vim.fn.expand(M.config.notes_dir) .. entry.value
        local picker = actions_state.get_current_picker(prompt_bufnr)
        local confirm = vim.fn.confirm("Are you sure you want to delete " .. filePath .. "?", "&Yes\n&No")

        if confirm == 1 then
          os.remove(filePath)
          vim.notify(filePath .. " has been deleted")
          actions.close(prompt_bufnr) -- Close the previewer
          M.listNotes()
        end
      end, { desc = "Delete note" })
      map({ "i", "n" }, M.config.telescope_rename, function(prompt_bufnr)
        local entry = actions_state.get_selected_entry(prompt_bufnr)
        local oldFilePath = vim.fn.expand(M.config.notes_dir) .. entry.value
        local newFileName = vim.fn.input("Enter new filename: ", entry.value)
        local newFilePath = vim.fn.expand(M.config.notes_dir) .. newFileName
        local picker = actions_state.get_current_picker(prompt_bufnr)
        os.rename(oldFilePath, newFilePath)
        vim.notify(oldFilePath .. " has been renamed to " .. newFilePath)
        actions.close(prompt_bufnr) -- Close the previewer
        M.listNotes()
      end, { desc = "Rename note" })
      map({ "i", "n" }, M.config.telescope_change_directory, function(prompt_bufnr)
        actions.close(prompt_bufnr) -- Close the previewer
        M.pickNotesDirectory()
      end, { desc = "Change notes directory" })
      return true
    end,
  })
end

M.pickNotesDirectory = function()
  vim.ui.select(M.config.notes_directories, {
    prompt = "Select Notes Directory",
  }, function(selected)
    if selected ~= nil then
      M.config.notes_dir = selected
      createNotesDir(M.config.notes_dir)
    end
    M.listNotes()
  end)
end

---@param opts table
M.createAndOpenNoteFile = function(opts)
  local full_path = M.createNoteFile(opts)

  if full_path == nil then
    return
  end

  vim.cmd("edit " .. full_path)
end

---@param opts table
---@return string|nil full_path
M.createNoteFile = function(opts)
  local notes_path = vim.fn.expand(M.config.notes_dir)
  local full_path = notes_path

  if opts ~= nil and opts.fargs ~= nil and opts.fargs[1] then
    local filename = opts.fargs[1]
    -- Check if filename has an extension
    if filename:match("%.([^%.]+)$") then
      full_path = full_path .. filename
    else
      full_path = full_path .. filename .. ".md"
    end
  else
    full_path = full_path .. os.date(M.config.notes_name_template) .. ".md"
  end

  if vim.fn.filereadable(full_path) == 1 then
    return full_path
  end

  local file = io.open(full_path, "a")

  if file == nil then
    vim.notify("Unable to create file " .. full_path)
    return nil
  end

  vim.notify(full_path .. " has been created")

  file:close()
  return full_path
end

return M
