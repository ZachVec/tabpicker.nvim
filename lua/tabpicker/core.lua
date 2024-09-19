local entry = require("tabpicker.entry")
local core = {}

--- Get all tabs
---@return table
function core.get_tab_entries()
    local current_tab_id = vim.api.nvim_get_current_tabpage()
    local tabs = {}
    for _, tabid in ipairs(vim.api.nvim_list_tabpages()) do
        local tab = entry:new({ id = tabid, iscurrent = current_tab_id == tabid })
        local winids = vim.tbl_filter(
            function(winid) return vim.api.nvim_win_get_config(winid).relative ~= nil end,
            vim.api.nvim_tabpage_list_wins(tabid)
        )
        for _, winid in ipairs(winids) do
            local bufnr = vim.api.nvim_win_get_buf(winid)
            local filepath = vim.api.nvim_buf_get_name(bufnr)
            local filename = vim.fn.fnamemodify(filepath, ":t")
            tab:add_file(filename)
        end
        table.insert(tabs, tab)
    end
    return tabs
end

return core
