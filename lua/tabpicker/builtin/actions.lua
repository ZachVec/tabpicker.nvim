local action_state = require("telescope.actions.state")

local actions = {}

function actions.close_tab(bufnr)
    local picker = action_state.get_current_picker(bufnr)
    picker:delete_selection(function(entry) vim.api.nvim_command("tabclose " .. entry.value.id) end)
end

return actions
