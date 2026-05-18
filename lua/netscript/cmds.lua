local ws = require("netscript.ws")
local rpc = require("netscript.rpc")
local utils = require("netscript.utils")

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

	vim.api.nvim_create_user_command("NSPullFile", function()
		local buf_id = vim.api.nvim_get_current_buf()
		local filename = vim.fs.basename(vim.api.nvim_buf_get_name(buf_id))

		rpc.get_file(filename, "home", function(err, contents)
			if err then
				return utils.print(
					"failed to pull file",
					{ filename, server = "home", error = err.message },
					vim.log.levels.ERROR
				)
			end

			vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, vim.split(contents, "\n"))
		end)
	end, { desc = "Pull the file in the current buffer from the game and overwrite the local file with its contents." })
end

return M
