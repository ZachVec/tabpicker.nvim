local TabEntry = require("tabpicker.entry")

---@class (exact) TabpickerConf
---@field prompt string
---@field formatter fun(entry: TabEntry): string
local TabPickerConf = {
  prompt = "Tabs",
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
    return string.format("%s", table.concat(fnames, ", "))
  end,
}

return {
  setup = function(opts) TabPickerConf = vim.tbl_deep_extend("force", TabPickerConf, opts or {}) end,
  find_tabpages = function(opts)
    opts = vim.tbl_deep_extend("force", TabPickerConf, opts or {})
    vim.ui.select(TabEntry.get_all(), {
      prompt = opts.prompt,
      kind = "Tab-Selector",
      format_item = opts.formatter,
    }, function(item)
      if item ~= nil then return vim.api.nvim_set_current_tabpage(item.id) end
    end)
  end,
}
