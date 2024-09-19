local entry = {}

entry.__index = entry

function entry:new(opts)
    opts = opts or {}
    local obj = setmetatable({
        id = opts.id or 0,
        iscurrent = opts.iscurrent or false,
        filenames = opts.filenames or {},
    }, self)
    return obj
end

function entry:format(opts)
    local default_name = opts.default_name
    local filenames = {}
    for _, item in ipairs(self.filenames) do
        table.insert(filenames, item ~= "" and item or default_name)
    end
    local filename = table.concat(filenames, ", ")
    if opts.leading_tabnr then return string.format("%d: %s%s", self.id, filename, self.iscurrent and " <" or "") end
    return string.format("%s%s", filename, self.iscurrent and " <" or "")
end

--- add filename to filenames
---@param filename string
function entry:add_file(filename) table.insert(self.filenames, filename) end

return entry
