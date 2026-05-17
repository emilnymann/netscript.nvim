local rpc = require("netscript.rpc")
local ws = require("netscript.ws")

local M = {}

---@param ev vim.api.keyset.create_autocmd.callback_args
function M.on_buf_write(ev)
	if not ws._running then
		return
	end

	local relative_dir = vim.fn.fnamemodify(ev.file, ":~:.:h")

	local server = "home"
	if relative_dir ~= "." then
		server = relative_dir
	end

	local filename = vim.fs.basename(ev.file)
	local lines = vim.api.nvim_buf_get_lines(ev.buf, 0, -1, false)
	local contents = table.concat(lines, "\n")

	rpc.push_file(filename, contents, server, function(err)
		if err ~= nil then
			vim.notify(
				string.format("netscript: failed to push file <%s> to server <%s>\n%s", filename, server, err.message),
				vim.log.levels.ERROR
			)
			return
		end

		vim.notify(string.format("netscript: pushed file <%s> to server <%s>", filename, server), vim.log.levels.DEBUG)
	end)
end

---@param ev vim.api.keyset.create_autocmd.callback_args
function M.on_buf_delete(ev)
	if not ws._running then
		return
	end

	local relative_dir = vim.fn.fnamemodify(ev.file, ":~:.:h")

	local server = "home"
	if relative_dir ~= "." then
		server = relative_dir
	end

	local filename = vim.fs.basename(ev.file)

	rpc.delete_file(filename, server, function(err)
		if err ~= nil then
			vim.notify(
				string.format(
					"netscript: failed to delete file <%s> from server <%s>\n%s",
					filename,
					server,
					err.message
				),
				vim.log.levels.ERROR
			)
			return
		end

		vim.notify(
			string.format("netscript: deleted file <%s> from server <%s>", filename, server),
			vim.log.levels.DEBUG
		)
	end)
end

return M
