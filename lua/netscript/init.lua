local conf = require("netscript.conf")
local ws = require("netscript.ws")
local rpc = require("netscript.rpc")
local evh = require("netscript.event_handlers")
local utils = require("netscript.utils")

local M = {}

local function maybeInitWs()
	if ws._running then
		return
	end

	local cwd = vim.uv.cwd()

	if not cwd then
		error("couldn't get cwd")
	end
	if cwd ~= conf.opts.root_dir and not vim.startswith(cwd, conf.opts.root_dir .. "/") then
		return
	end

	utils.print("starting ws server")
	ws.start({
		port = conf.opts.port,
		on_message = rpc.handle,
	})
end

---@param opts NetscriptConfig
function M.setup(opts)
	conf.setup(opts)
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

	vim.api.nvim_create_autocmd("BufWrite", { group = group, callback = evh.on_buf_write })
end

return M
