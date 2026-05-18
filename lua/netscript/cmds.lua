local ws = require("netscript.ws")
local rpc = require("netscript.rpc")
local utils = require("netscript.utils")

local M = {}

function M.setup()
	vim.api.nvim_create_user_command("NetscriptPull", function()
		if not ws._running then
			return
		end

		local def_file = "NS.d.ts"

		rpc.get_definition_file(function(_, contents)
			utils.print("got definition file contents", { contents = contents })
			local cwd = vim.uv.cwd()
			if not cwd then
				error("couldn't get cwd")
			end

			local fd = vim.uv.fs_open(cwd .. "/" .. def_file, "w", 420)
			if not fd then
				error("unable to open file handle for NS definition file")
			end

			vim.uv.fs_write(fd, contents)
			vim.uv.fs_close(fd)
		end)
	end, { desc = "Sync" })
end

return M
