local ws = require("netscript.ws")
local cache = require("netscript.cache")

local M = {}

function M.ns_status()
	if not ws._running then
		return ""
	end
	if not ws._client_connected then
		return "NS ❌"
	end
	return "NS ✔️"
end

function M.buffer_ram()
	local buf_id = vim.api.nvim_get_current_buf()
	local ram_usage = cache.buf_ram[buf_id] or nil
	if not ram_usage then
		return ""
	end

	return string.format("RAM: %.1f GB", ram_usage)
end

return M
