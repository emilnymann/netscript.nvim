local utils = require("netscript.utils")
local conf = require("netscript.conf")

---@class WsConfig
---@field port number?
---@field on_message fun(line: string)?
---@field on_disconnect fun(code: number)?

---@class WsModule
---@field _job_id number?
---@field _running boolean is the websocket server currently running?
---@field _config WsConfig
local M = {}

M._job_id = nil
M._running = false
M._config = {}

local msg_buffer = ""

---@return nil
local function spawn()
	local cmd = { "websocat", "--text", "-s", tostring(M._config.port) }

	M._job_id = vim.fn.jobstart(cmd, {
		---@param data string[]
		on_stdout = function(_, data, _)
			for _, line in ipairs(data) do
				msg_buffer = msg_buffer .. line
				if line == "" then
					M._config.on_message(msg_buffer)
					msg_buffer = line
				end
			end
		end,

		on_stderr = function(_, _, _) end,

		---@param code number
		on_exit = function(_, code, _)
			M._job_id = nil
			if M._config.on_disconnect then
				M._config.on_disconnect(code)
			end
			if M._running then
				vim.defer_fn(spawn, 100)
			end
		end,
	})
end

---@param opts WsConfig?
---@return nil
function M.start(opts)
	if M._running then
		return
	end

	local cwd = vim.uv.cwd()

	if not cwd or cwd ~= conf.opts.root_dir then
		return
	end

	M._config = vim.tbl_extend("force", { port = 12525 }, opts or {})
	M._running = true

	utils.print("starting ws server")
	spawn()
end

---@return nil
function M.stop()
	M._running = false
	if M._job_id then
		vim.fn.jobstop(M._job_id)
		M._job_id = nil
	end
end

---@param data string
---@return nil
function M.send(data)
	if M._job_id then
		vim.fn.chansend(M._job_id, data .. "\n")
	end
end

return M
