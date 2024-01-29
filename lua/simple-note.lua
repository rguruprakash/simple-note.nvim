---@class Config
---@field notes_dir string path to the directory where the notes should be created
local config = {
  notes_dir = "~/notes/",
}

---@class MyModule
local M = {}

---@type Config
M.config = config

---@param args table
M.setup = function(args)
  M.config = vim.tbl_deep_extend("force", M.config, args or {})
  local dir = tostring(vim.fn.expand(M.config.notes_dir))

  if not vim.loop.fs_stat(dir) then
    vim.loop.fs_mkdir(dir, 511) -- 511 (0777 in octal) means the owner, group and others can read, write and execute.
    vim.notify("Created " .. dir)
  end
end

M.listNotes = function()
  local actions = require("telescope.actions")
  local actions_state = require("telescope.actions.state")
  local finders = require("telescope.finders")
  local find_command = { "find", ".", "-maxdepth", "1", "-not", "-type", "d"}

  M.picker = require("telescope.builtin").find_files({
    cwd = M.config.notes_dir,
    find_command = find_command,
    layout_strategy = "flex",
    prompt_title = "Find Notes (" .. M.config.notes_dir .. ")",
    results_title = "Notes",
    attach_mappings = function(_, map)
      map({ "i", "n" }, "<C-n>", function(prompt_bufnr)
        M.createNoteFile({})
        local picker = actions_state.get_current_picker(prompt_bufnr)
        actions.close(prompt_bufnr) -- Close the previewer
        M.listNotes() 
      end)
      map({ "i", "n" }, "<C-x>", function(prompt_bufnr)
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
      end)
      map({ "i", "n" }, "<C-r>", function(prompt_bufnr)
        local entry = actions_state.get_selected_entry(prompt_bufnr)
        local oldFilePath = vim.fn.expand(M.config.notes_dir) .. entry.value
        local newFileName = vim.fn.input("Enter new filename: ", entry.value)
        local newFilePath = vim.fn.expand(M.config.notes_dir) .. newFileName
        local picker = actions_state.get_current_picker(prompt_bufnr)
        os.rename(oldFilePath, newFilePath)
        vim.notify(oldFilePath .. " has been renamed to " .. newFilePath)
        actions.close(prompt_bufnr) -- Close the previewer
        M.listNotes()
      end)
      return true
    end,
  })
end

---@param opts table
M.createAndOpenNoteFile = function(opts)
  local full_path = M.createNoteFile(opts)

  if (full_path == nil) then
    return
  end

  vim.cmd("edit " .. full_path)
end

---@param opts table 
---@return string|nil full_path
M.createNoteFile = function(opts)
  local notes_path = vim.fn.expand(M.config.notes_dir)
  local full_path = notes_path

  if (opts ~= nil and opts.fargs ~= nil and opts.fargs[1]) then
    full_path = full_path .. opts.fargs[1] .. ".md"
  else
    full_path = full_path .. os.date("%A_%B_%d_%Y_%I_%M_%S_%p") .. ".md"
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
