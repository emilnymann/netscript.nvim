local M = {}

function M.check()
	vim.health.start("netscript.nvim")
	if vim.fn.executable("websocat") == 1 then
		vim.health.ok("`websocat` found")
	else
		vim.health.error("`websocat` not found in PATH", "install `websocat`: https://github.com/vi/websocat")
	end
end

return M
