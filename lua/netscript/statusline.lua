local ws = require("netscript.ws")

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

return M
