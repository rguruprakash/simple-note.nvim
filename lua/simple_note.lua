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
        local full_path = M.createNoteFile()
        local picker = actions_state.get_current_picker(prompt_bufnr)

        vim.notify(full_path .. " has been created")
        picker:refresh(finders.new_oneshot_job(find_command, { cwd = M.config.notes_dir }), { reset_prompt = false })
      end)
      map({ "i", "n" }, "<C-x>", function(prompt_bufnr)
        local entry = actions_state.get_selected_entry(prompt_bufnr)
        local filePath = vim.fn.expand(M.config.notes_dir) .. entry.value
        local picker = actions_state.get_current_picker(prompt_bufnr)
        local confirm = vim.fn.confirm("Are you sure you want to delete " .. filePath .. "?", "&Yes\n&No")

        if confirm == 1 then
          os.remove(filePath)
          vim.notify(filePath .. " has been deleted")
          picker:refresh(finders.new_oneshot_job(find_command, { cwd = M.config.notes_dir }), { reset_prompt = false })
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
        picker:refresh(finders.new_oneshot_job(find_command, { cwd = M.config.notes_dir }), { reset_prompt = false })
      end)
      return true
    end,
  })
end

M.createAndOpenNoteFile = function(opts)
  local full_path = M.createNoteFile(opts)

  vim.cmd("edit " .. full_path)
  vim.notify(full_path .. " has been created")
end

M.createNoteFile = function(opts)
  local notes_path = vim.fn.expand(M.config.notes_dir)
  local full_path = notes_path

  if (opts ~= nil and opts.fargs[1]) then
    full_path = full_path .. opts.fargs[1]
  else
    full_path = full_path .. os.date("%A_%B_%d_%Y_%I_%M_%S_%p") .. ".md"
  end

  local file = io.open(full_path, "a")

  if file == nil then
    vim.notify("Unable to create file " .. full_path)
    return
  end

  file:close()
  return full_path
end

return M
