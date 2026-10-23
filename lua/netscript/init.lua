local conf = require("netscript.conf")
local autocmds = require("netscript.autocmds")
local cmds = require("netscript.cmds")

local M = {}

---@param opts NetscriptConfig
function M.setup(opts)
	if vim.fn.has("nvim-0.11") ~= 1 then
		error("netscript.nvim requires Neovim 0.11 or newer")
	end

	conf.setup(opts)
	autocmds.setup()
	cmds.setup()
end

return M
