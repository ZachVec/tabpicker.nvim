local core = require("tabpicker.core")

local conf = {
    prompt = "Tabs",
    format = {
        default_name = "[No Name]",
        leading_tabnr = false,
    },
}

local tabpicker = {}

function tabpicker.setup(opts) conf = vim.tbl_deep_extend("force", conf, opts or {}) end

function tabpicker.find_tabpages(opts)
    opts = vim.tbl_deep_extend("force", conf, opts or {})
    vim.ui.select(core.get_tab_entries(), {
        prompt = opts.prompt,
        kind = "Tab-Selector",
        format_item = function(item) return item:format(conf.format) end,
    }, function(item)
        if item ~= nil then return vim.api.nvim_set_current_tabpage(item.id) end
    end)
end

return tabpicker
