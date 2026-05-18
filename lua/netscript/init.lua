local conf = require("netscript.conf")
local autocmds = require("netscript.autocmds")
local cmds = require("netscript.cmds")

local M = {}

---@param opts NetscriptConfig
function M.setup(opts)
	conf.setup(opts)
	autocmds.setup()
	cmds.setup()
end

return M
