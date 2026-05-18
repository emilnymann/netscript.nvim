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

return M
