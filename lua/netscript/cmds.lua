local ws = require("netscript.ws")
local rpc = require("netscript.rpc")
local utils = require("netscript.utils")

local M = {}

local function update_defs()
	if not ws._running then
		return
	end

	local tsc_template_path = assert(
		vim.api.nvim_get_runtime_file("assets/tsconfig.template.json", false)[1],
		"tsconfig template asset not found"
	)

	local def_file_name = "NS.d.ts"
	local tsc_file_path = vim.fn.getcwd() .. "/tsconfig.json"

	rpc.get_definition_file(function(_, contents)
		utils.write_file(def_file_name, contents:gsub("export ", ""), true)

		local template = table.concat(vim.fn.readfile(tsc_template_path), "\n")
		local tsconfig = vim.json.decode(template)
		local bitburner_dir = utils.get_bitburner_dir()

		if bitburner_dir ~= "" then
			tsconfig.compilerOptions.paths = {
				["/" .. bitburner_dir .. "/*"] = { "./*" },
			}
		end

		local output = vim.fn.system({ "jq", "." }, vim.json.encode(tsconfig))
		assert(vim.v.shell_error == 0, "failed to format tsconfig.json")

		local ok = vim.fn.writefile(vim.split(output, "\n"), tsc_file_path)
		assert(ok == 0, "failed to write tsconfig.json")
	end)
end

local function pull_file()
	if not ws._running then
		return
	end

	local buf_id = vim.api.nvim_get_current_buf()
	local path = vim.api.nvim_buf_get_name(buf_id)

	if path == "" then
		return
	end

	local filename = utils.get_game_filename(path)

	if not filename then
		vim.notify("Current file is outside root_dir; skipping pull.", vim.log.levels.WARN)
		return
	end

	rpc.get_file(filename, "home", function(err, contents)
		if err then
			error(string.format("failed to pull file %s: %s", filename, err.message))
		end
		vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, vim.split(contents, "\n"))
	end)
end

local function sync()
	if not ws._running then
		return
	end

	vim.api.nvim_command("NSUpdateDefs")

	rpc.get_all_files("home", function(err, files)
		assert(not err, err and string.format("failed to get all files: %s", err.message))

		for _, file in ipairs(files) do
			local path = utils.get_local_filename(file.filename)

			if path then
				utils.write_file(path, file.content)
			end
		end

		vim.notify("Finished syncing files.", vim.log.levels.INFO)
	end)
end

function M.setup()
	vim.api.nvim_create_user_command("NSUpdateDefs", update_defs, {
		desc = "Pull TypeScript definitions for the Netscript interface to a local file.",
	})

	vim.api.nvim_create_user_command("NSPullFile", pull_file, {
		desc = "Pull the file in the current buffer from the game and overwrite the local file with its contents.",
	})

	vim.api.nvim_create_user_command("NSSync", sync, {
		desc = "Sync files from the home server into root_dir.",
	})
end

return M
