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
  local lfs = require("lfs")
  local dir = vim.fn.stdpath("data") .. M.config.notes_dir
  if not lfs.attributes(dir) then
    lfs.mkdir(dir)
    vim.notify("Created " .. dir)
  else
    vim.notify("Directory " .. dir .. " already exists")
  end
end

M.listNotes = function()
  local actions = require("telescope.actions")
  local actions_state = require("telescope.actions.state")
  require("telescope.builtin").find_files({
    cwd = M.config.notes_dir,
    layout_strategy = "flex",
    prompt_title = "Find Notes",
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

M.createAndOpenNoteFile = function(extension)
  local full_path = M.createNoteFile(extension)
  vim.cmd("edit " .. full_path)
  vim.notify(full_path .. " has been created")
end

M.createNoteFile = function(extension)
  local notes_path = vim.fn.expand(M.config.notes_dir)
  local filename = os.date("%Y%m%d%H%M%S")
  if extension and extension ~= "" then
    filename = filename .. "." .. extension
  else
    filename = filename .. ".md"
  end
  local full_path = notes_path .. "/" .. filename
  local file = io.open(full_path, "w")
  file:close()
  return full_path
end

return M
