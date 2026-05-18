local rpc = require("netscript.rpc")
local utils = require("netscript.utils")
local conf = require("netscript.conf")

local M = {}

---@param ev vim.api.keyset.create_autocmd.callback_args
function M.on_buf_write(ev)
	local ext = vim.fs.ext(ev.file)
	if not vim.tbl_contains(conf.opts.file_sync_exts, ext) then
		utils.print(
			"file push skipped, extension not in sync list",
			{ ext = ext, sync_list = table.concat(conf.opts.file_sync_exts, ", ") }
		)
		return
	end

	local relative_dir = vim.fn.fnamemodify(ev.file, ":~:.:h")

	local server = "home"
	if relative_dir ~= "." then
		server = relative_dir
	end

	local filename = vim.fs.basename(ev.file)
	local lines = vim.api.nvim_buf_get_lines(ev.buf, 0, -1, false)
	local contents = table.concat(lines, "\n")

	rpc.push_file(filename, contents, server, function()
		utils.print("pushed file to server", { file = filename, server = server })
	end)
end

return M
