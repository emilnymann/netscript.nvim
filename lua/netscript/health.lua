local M = {}

function M.check()
	vim.health.start("netscript.nvim")

	if vim.fn.has("nvim-0.11") == 1 then
		vim.health.ok("Neovim 0.11+ found")
	else
		vim.health.error("Neovim 0.11 or newer is required", "Upgrade Neovim to version 0.11 or newer")
	end

	if vim.fn.executable("websocat") == 1 then
		vim.health.ok("`websocat` found")
	else
		vim.health.error("`websocat` not found in PATH", "install `websocat`: https://github.com/vi/websocat")
	end
end

return M
