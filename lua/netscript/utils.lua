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

	local path = conf.opts.root_dir .. "/" .. filename

	vim.fn.mkdir(vim.fn.fnamemodify(path, ":h"), "p")

	local fd =
		assert(vim.uv.fs_open(path, "w", 420), string.format("failed to open file handle when writing '%s'", filename))

	vim.uv.fs_write(fd, content)
	vim.uv.fs_close(fd)
end

function M.get_bitburner_dir()
	return conf.opts.bitburner_dir:gsub("^/+", ""):gsub("/+$", "")
end

---@param path string
---@return string?
function M.get_game_filename(path)
	if path == "" then
		return nil
	end

	local root_dir = vim.fn.fnamemodify(conf.opts.root_dir, ":p")
	path = vim.fn.fnamemodify(path, ":p")

	local filename = vim.fs.relpath(root_dir, path)

	if not filename or filename == "." then
		return nil
	end

	filename = filename:gsub("\\", "/")

	local bitburner_dir = M.get_bitburner_dir()
	if bitburner_dir ~= "" then
		filename = bitburner_dir .. "/" .. filename
	end

	return filename
end

---@param filename string
---@return string?
function M.get_local_filename(filename)
	filename = filename:gsub("\\", "/")

	local bitburner_dir = M.get_bitburner_dir()
	if bitburner_dir ~= "" then
		if filename:sub(1, #bitburner_dir + 1) ~= bitburner_dir .. "/" then
			return nil
		end

		filename = filename:sub(#bitburner_dir + 2)
	end

	for part in filename:gmatch("[^/]+") do
		if part == ".." then
			return nil
		end
	end

	if filename == "" or filename:match("^/") then
		return nil
	end

	return filename
end

return M
