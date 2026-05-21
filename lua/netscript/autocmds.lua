local rpc = require("netscript.rpc")
local utils = require("netscript.utils")
local conf = require("netscript.conf")
local ws = require("netscript.ws")
local cache = require("netscript.cache")

local M = {}

local push_files_ignore = { "NS.d.ts" }

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
			if vim.tbl_contains(push_files_ignore, ev.file) or not vim.tbl_contains(conf.opts.file_sync_exts, ext) then
				utils.print(
					"file push skipped, file in ignore list or extension not in sync list",
					{ ext = ext, sync_list = table.concat(conf.opts.file_sync_exts, ", ") }
				)
				return
			end

			local filename = vim.fs.basename(ev.file)
			local lines = vim.api.nvim_buf_get_lines(ev.buf, 0, -1, false)
			local contents = table.concat(lines, "\n")

			rpc.push_file(filename, contents, "home", function()
				utils.print("pushed file to server", { file = filename, server = "home" })
				rpc.calculate_ram(filename, "home", function(_, result)
					cache.buf_ram[ev.buf] = result
				end)
			end)
		end,
	})

	vim.api.nvim_create_autocmd("BufAdd", {
		group = M._group,
		callback = function(ev)
			local filename = ev.file
			if not ws._running or not filename then
				return
			end

			filename = vim.fs.basename(filename)

			rpc.calculate_ram(filename, "home", function(err, result)
				if err then
					return
				end

				cache.buf_ram[ev.buf] = result
			end)
		end,
	})
end

return M
