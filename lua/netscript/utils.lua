local conf = require("netscript.conf")

local M = {}

---@param msg string message title
---@param data table<string, string>? key-value pairs of data to print
---@param level vim.log.levels? log level to print at, default is DEBUG
function M.print(msg, data, level)
	local text = string.format("netscript: %s", msg)
	for key, value in pairs(data or {}) do
		text = string.format("%s\n%s: %s", text, key, value)
	end
	vim.notify(text, level or vim.log.levels.DEBUG)
end

---@param filename string
---@param content string
---@param skip_ext_filter boolean?
function M.write_file(filename, content, skip_ext_filter)
	if not skip_ext_filter then
		local ext = vim.fs.ext(filename)
		if not vim.tbl_contains(conf.opts.file_sync_exts, ext) then
			M.print(
				"file write skipped, extension not in sync list",
				{ filename = filename, sync_list = table.concat(conf.opts.file_sync_exts, ", ") }
			)
			return
		end
	end

	local cwd = vim.uv.cwd()
	if not cwd then
		return M.print("failed to get cwd", {}, vim.log.levels.ERROR)
	end

	local path = cwd .. "/" .. filename

	local fd = vim.uv.fs_open(path, "w", 420)
	if not fd then
		return M.print("failed to open file handle", { path }, vim.log.levels.ERROR)
	end

	vim.uv.fs_write(fd, content)
	vim.uv.fs_close(fd)
end

return M
