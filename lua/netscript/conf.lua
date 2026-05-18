---@class NetscriptConfig
---@field port number? The port that the websocket server will bind to
---@field root_dir string? The plugin will only activate when the workdir is in this directory
---@field file_sync_exts table<string>? File extensions not in this table will be ignored for any file sync operations

local M = {}

---@type NetscriptConfig
local _defaults = {
	port = 12525,
	root_dir = "~/bitburner-files",
	file_sync_exts = { "js", "ts", "jsx", "tsx" },
}

---@param opts NetscriptConfig
function M.setup(opts)
	M.opts = vim.tbl_deep_extend("force", _defaults, opts or {})
end

return M
