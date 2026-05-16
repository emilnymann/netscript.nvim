local ws = require("netscript.ws")

---@class RpcError
---@field code number
---@field message string

---@class RpcPending
---@field callback fun(err: RpcError?, result: any)

---@class RpcModule
---@field _next_id number
---@field _pending table<number, RpcPending>
local M = {}

M._next_id = 1
M._pending = {}

---@param method string
---@param params table
---@param callback fun(err: RpcError?, result: any)?
---@return number
function M.request(method, params, callback)
	local id = M._next_id
	M._next_id = M._next_id + 1

	if callback then
		M._pending[id] = { callback = callback }
	end

	ws.send(vim.json.encode({
		jsonrpc = "2.0",
		method = method,
		params = params,
		id = id,
	}))

	return id
end

---@param line string
---@return nil
function M.handle(line)
	local ok, msg = pcall(vim.json.decode, line)
	if not ok or type(msg) ~= "table" then
		return
	end

	local pending = M._pending[msg.id]
	if not pending then
		return
	end

	M._pending[msg.id] = nil
	pending.callback(msg.error, msg.result)
end

---@param filename string
---@param content string
---@param server string
---@param callback fun(err: RpcError?, result: any)?
---@return number
function M.push_file(filename, content, server, callback)
	return M.request("pushFile", {
		filename = filename,
		content = content,
		server = server,
	}, callback)
end

return M
