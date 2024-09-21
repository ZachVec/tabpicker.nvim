local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local conf = require("telescope.config").values
local core = require("tabpicker.core")

local _pickers = {}
function _pickers.find_tabpages(opts)
    pickers
        .new(opts, {
            prompt_title = "Tabs",
            finder = finders.new_table({
                results = core.get_tab_entries(),
                entry_maker = function(entry)
                    return {
                        value = entry,
                        display = function(self) return self.value:format(opts.format) end,
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
                for mode, mappings in pairs(opts.mappings or {}) do
                    for key, fn in pairs(mappings) do
                        map(mode, key, fn)
                    end
                end
                return true
            end,
        })
        :find()
end

return _pickers
