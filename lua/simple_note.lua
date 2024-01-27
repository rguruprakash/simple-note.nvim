---@class Config
---@field notes_dir string path to the directory where the notes should be created
local config = {
  notes_dir = "~/notes/",
}

---@class MyModule
local M = {}

---@type Config
M.config = config

M.setup = function(args)
  M.config = vim.tbl_deep_extend("force", M.config, args or {})
  local dir = vim.fn.expand(M.config.notes_dir)
  if not vim.loop.fs_stat(dir) then
    vim.loop.fs_mkdir(dir, 511) -- 511 (0777 in octal) means the owner, group and others can read, write and execute.
    vim.notify("Created " .. dir)
  end
end

M.listNotes = function()
  local actions = require("telescope.actions")
  local actions_state = require("telescope.actions.state")
  require("telescope.builtin").find_files({
    cwd = M.config.notes_dir,
    find_command = {'find', '.', '-maxdepth', '1', '-not', '-type', 'd'},
    layout_strategy = "flex",
    prompt_title = "Find Notes (" .. M.config.notes_dir .. ")",
    results_title = "Notes",
    attach_mappings = function(_, map)
      map({ "i", "n" }, "<C-n>", function(prompt_bufnr)
        local full_path = M.createNoteFile()
        vim.notify(full_path .. " has been created")
        actions.close(prompt_bufnr)
        M.listNotes()
      end)
      map({ "i", "n" }, "<C-x>", function(prompt_bufnr)
        local entry = actions_state.get_selected_entry(prompt_bufnr)
        local filePath = vim.fn.expand(M.config.notes_dir) .. entry.value
        os.remove(filePath)
        vim.notify(filePath .. " has been deleted")
        actions.close(prompt_bufnr)
        M.listNotes()
      end)
      map({ "i", "n" }, "<C-r>", function(prompt_bufnr)
        local entry = actions_state.get_selected_entry(prompt_bufnr)
        local oldFilePath = vim.fn.expand(M.config.notes_dir) .. entry.value
        local newFileName = vim.fn.input("Enter new filename: ", entry.value)
        local newFilePath = vim.fn.expand(M.config.notes_dir) .. newFileName
        os.rename(oldFilePath, newFilePath)
        vim.notify(oldFilePath .. " has been renamed to " .. newFilePath)
        actions.close(prompt_bufnr)
        M.listNotes()
      end)
      return true
    end,
  })
end

M.createAndOpenNoteFile = function()
  local full_path = M.createNoteFile()
  vim.cmd("edit " .. full_path)
  vim.notify(full_path .. " has been created")
end

M.createNoteFile = function()
  local notes_path = vim.fn.expand(M.config.notes_dir)
  local filename = os.date("%Y%m%d%H%M%S") .. ".md"
  local full_path = notes_path .. "/" .. filename
  local file = io.open(full_path, "w")
  file:close()
  return full_path
end

return M
