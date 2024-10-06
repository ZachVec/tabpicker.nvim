---@class (exact) TabEntry
---@field id number
---@field winnrs number[]
---@field get_one fun(tabnr: number): TabEntry
---@field get_all fun(): TabEntry[]
local TabEntry = {
  id = 0,
  winnrs = {},
}

function TabEntry:new(tabnr, winnrs)
  local obj = setmetatable({}, TabEntry)
  obj.id = tabnr
  obj.winnrs = winnrs
  return obj
end

function TabEntry.get_one(tabnr)
  return TabEntry:new(tabnr, vim.api.nvim_tabpage_list_wins(tabnr))
end

function TabEntry.get_all()
  return vim.tbl_map(TabEntry.get_one, vim.api.nvim_list_tabpages())
end

return TabEntry
