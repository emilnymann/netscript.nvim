local ws = require("netscript.ws")
local rpc = require("netscript.rpc")

local M = {}

---@class NetscriptConfig
---@field port number? Websocket port (default: 12525)
---@field server string? Default Bitburner server to push to (default: "home")
local _config = {
	port = 12525,
	root_dir = "~/bitburner-files",
}

local function maybeInitWs()
	if ws._running then
		return
	end

	local cwd = vim.uv.cwd()
	local root_dir = vim.fn.expand(_config.root_dir)

	if cwd == nil then
		vim.notify("netscript: could not get cwd", vim.log.levels.ERROR)
		return
	end
	if cwd ~= root_dir and not vim.startswith(cwd, root_dir .. "/") then
		return
	end

	vim.notify("netscript: starting websocket server", vim.log.levels.DEBUG)
	ws.start({
		port = _config.port,
		on_message = rpc.handle,
	})
end

function M.setup(opts)
	_config = vim.tbl_deep_extend("force", _config, opts or {})
	local group = vim.api.nvim_create_augroup("netscript.nvim", { clear = true })

	if vim.v.vim_did_enter then
		maybeInitWs()
	else
		vim.api.nvim_create_autocmd("VimEnter", {
			group = group,
			once = true,
			callback = maybeInitWs,
		})
	end

	vim.api.nvim_create_autocmd("BufEnter", {
		group = group,
		callback = maybeInitWs,
	})
end

return M
