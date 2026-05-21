local conf = require("netscript.conf")

local M = {}

---@param filename string
---@param content string
---@param skip_ext_filter boolean?
function M.write_file(filename, content, skip_ext_filter)
	if not skip_ext_filter then
		if not vim.tbl_contains(conf.opts.file_sync_exts, vim.fs.ext(filename)) then
			return
		end
	end

	local path = assert(vim.uv.cwd(), "failed to get cwd") .. "/" .. filename

	local fd =
		assert(vim.uv.fs_open(path, "w", 420), string.format("failed to open file handle when writing '%s'", filename))

	vim.uv.fs_write(fd, content)
	vim.uv.fs_close(fd)
end

return M
