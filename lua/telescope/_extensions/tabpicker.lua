local conf = {
    preview = false,
    mappings = {
        n = {},
    },
    format = {
        default_name = "[No Name]",
        leading_tabnr = true,
    },
}

local tabpicker = require("tabpicker.builtin")
local actions = require("tabpicker.builtin.actions")
return require("telescope").register_extension({
    setup = function(ext_config, config) conf = vim.tbl_deep_extend("force", conf, ext_config) end,
    exports = {
        find_tabpages = function(opts)
            opts = vim.tbl_extend("force", conf, opts or {})
            return tabpicker.pickers.find_tabpages(opts)
        end,
        actions = {
            close_tab = actions.close_tab,
        },
    },
})
