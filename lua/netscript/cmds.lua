local ws = require("netscript.ws")
local rpc = require("netscript.rpc")

local M = {}

function M.setup()
	vim.api.nvim_create_user_command("NSUpdateDefs", function()
		if not ws._running then
			return
		end

		local def_file = "NS.d.ts"
		local cwd = vim.uv.cwd()
		if not cwd then
			error("unable to get cwd")
		end

		rpc.get_definition_file(function(_, contents)
			local fd = vim.uv.fs_open(cwd .. "/" .. def_file, "w", 420)
			if not fd then
				error("unable to open file handle for netscript definition file")
			end

			vim.uv.fs_write(fd, contents)
			vim.uv.fs_close(fd)
		end)
	end, { desc = "Pull TypeScript definitions for the Netscript interface to a local file." })
end

return M
