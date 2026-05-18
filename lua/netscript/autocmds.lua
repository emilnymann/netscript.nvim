local rpc = require("netscript.rpc")
local utils = require("netscript.utils")
local conf = require("netscript.conf")
local ws = require("netscript.ws")

local M = {}

function M.setup()
	M._group = vim.api.nvim_create_augroup("netscript.nvim", { clear = true })

	vim.api.nvim_create_autocmd({ "BufEnter", "VimEnter" }, {
		group = M._group,
		callback = function()
			ws.start({ port = conf.opts.port, on_message = rpc.handle })
		end,
	})

	vim.api.nvim_create_autocmd("BufWrite", {
		group = M._group,
		callback = function(ev)
			if not ws._running then
				return
			end

			local ext = vim.fs.ext(ev.file)
			if not vim.tbl_contains(conf.opts.file_sync_exts, ext) then
				utils.print(
					"file push skipped, extension not in sync list",
					{ ext = ext, sync_list = table.concat(conf.opts.file_sync_exts, ", ") }
				)
				return
			end

			local filename = vim.fs.basename(ev.file)
			local lines = vim.api.nvim_buf_get_lines(ev.buf, 0, -1, false)
			local contents = table.concat(lines, "\n")

			rpc.push_file(filename, contents, "home", function()
				utils.print("pushed file to server", { file = filename, server = "home" })
			end)
		end,
	})
end

return M
