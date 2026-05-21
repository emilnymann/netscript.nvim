local ws = require("netscript.ws")
local rpc = require("netscript.rpc")
local utils = require("netscript.utils")

local M = {}

local function update_defs()
	if not ws._running then
		return
	end

	local def_file = "NS.d.ts"

	rpc.get_definition_file(function(_, contents)
		utils.write_file(def_file, contents, true)
	end)
end

local function pull_file()
	if not ws._running then
		return
	end

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
end

local function sync()
	if not ws._running then
		return
	end

	local server = "home"

	vim.api.nvim_command("NSUpdateDefs")
	rpc.get_all_files(server, function(err, files)
		if err then
			return utils.print(
				"failed to sync all files",
				{ server = server, error = err.message },
				vim.log.levels.ERROR
			)
		end

		for _, file in ipairs(files) do
			utils.write_file(file.filename, file.content)
		end

		utils.print("finished syncing files", {}, vim.log.levels.INFO)
	end)
end

function M.setup()
	vim.api.nvim_create_user_command(
		"NSUpdateDefs",
		update_defs,
		{ desc = "Pull TypeScript definitions for the Netscript interface to a local file." }
	)

	vim.api.nvim_create_user_command(
		"NSPullFile",
		pull_file,
		{ desc = "Pull the file in the current buffer from the game and overwrite the local file with its contents." }
	)

	vim.api.nvim_create_user_command(
		"NSSync",
		sync,
		{ desc = "Sync all files from the home server to the working directory" }
	)
end

return M
