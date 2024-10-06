local TabEntry = require("tabpicker.entry")

---@class TelescopeTabpickerConf
---@field preview false
---@field mappings table<string, table<string, function | string>>
---@field formatter fun(entry: TabEntry): string
local TelescopeTabpickerConf = {
  preview = false,
  mappings = {},
  formatter = function(entry)
    local function not_a_floating_window(winnr) return vim.api.nvim_win_get_config(winnr).relative ~= nil end

    local function filetype_filter(bufnr)
      local disabled_filetypes = { "toggleterm" }
      local filetype = vim.api.nvim_get_option_value("filetype", { buf = bufnr })
      return not vim.tbl_contains(disabled_filetypes, filetype)
    end

    local function buftype_filter(bufnr)
      local disabled_buftypes = { "acwrite", "help", "nofile", "quickfix", "prompt" }
      local buftype = vim.api.nvim_get_option_value("buftype", { buf = bufnr })
      return not vim.tbl_contains(disabled_buftypes, buftype)
    end

    local winnrs = vim.tbl_filter(not_a_floating_window, entry.winnrs)
    local bufnrs = vim.tbl_map(vim.api.nvim_win_get_buf, winnrs)
    bufnrs = vim.tbl_filter(buftype_filter, bufnrs)
    bufnrs = vim.tbl_filter(filetype_filter, bufnrs)
    local fpaths = vim.tbl_map(vim.api.nvim_buf_get_name, bufnrs)
    local fnames = vim.tbl_map(
      function(path) return path ~= "" and vim.fn.fnamemodify(path, ":t") or "[No Name]" end,
      fpaths
    )

    return string.format("%d: %s", entry.id, table.concat(fnames, ", "))
  end,
}

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local conf = require("telescope.config").values

local function find_tabpages(opts)
  opts = vim.tbl_deep_extend("force", opts or {}, { previewer = false })
  pickers
    .new(opts, {
      prompt_title = "Tabs",
      previewer = false,
      finder = finders.new_table({
        results = TabEntry.get_all(),
        ---entry maker
        ---@param entry TabEntry
        ---@return { value: TabEntry, display: string, ordinal: string }
        entry_maker = function(entry)
          return {
            value = entry,
            display = TelescopeTabpickerConf.formatter(entry),
            ordinal = tostring(entry.id),
          }
        end,
      }),
      sorter = conf.generic_sorter({}),
      attach_mappings = function(prompt_bufnr, map)
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local entry = action_state.get_selected_entry()
          vim.api.nvim_set_current_tabpage(entry.value.id)
        end)
        for mode, mappings in pairs(TelescopeTabpickerConf.mappings or {}) do
          for key, fn in pairs(mappings) do
            map(mode, key, fn)
          end
        end
        return true
      end,
    })
    :find()
end

local function close_tabpage(bufnr)
  local picker = action_state.get_current_picker(bufnr)
  picker:delete_selection(function(entry) vim.api.nvim_command("tabclose " .. entry.id) end)
end

return require("telescope").register_extension({
  setup = function(usr_config, _)
    TelescopeTabpickerConf = vim.tbl_deep_extend("force", TelescopeTabpickerConf, usr_config or {})
  end,
  exports = {
    find_tabpages = find_tabpages,
    actions = {
      close_tabpage = close_tabpage,
    }
  },
})
