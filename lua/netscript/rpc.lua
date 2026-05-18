local ws = require("netscript.ws")
local utils = require("netscript.utils")

---@class RpcError
---@field code number
---@field message string

---@class RpcFileMeta
---@field filename string
---@field atime string
---@field btime string
---@field mtime string

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
		id = id,
		method = method,
		params = params,
	}))

	return id
end

---@param line string
---@return nil
function M.handle(line)
	---@type boolean, { error: RpcError?, id: number, result: any }
	local ok, msg = pcall(vim.json.decode, line)
	if not ok or type(msg) ~= "table" then
		return
	end

	local pending = M._pending[msg.id]
	if not pending then
		return
	end

	if msg.error then
		utils.print(
			"error in rpc response message",
			{ err = msg.error.message, pending_callback = debug.getinfo(pending.callback, "n").name },
			vim.log.levels.ERROR
		)
	end

	M._pending[msg.id] = nil

	pending.callback(msg.error, msg.result)
end

---@param filename string
---@param content string
---@param server string
---@param callback fun(err: RpcError?, result: "OK"?)?
---@return number id
function M.push_file(filename, content, server, callback)
	return M.request("pushFile", {
		filename = filename,
		content = content,
		server = server,
	}, callback)
end

---@param filename string
---@param server string
---@param callback fun(err: RpcError?, result: string?)?
---@return number id
function M.get_file(filename, server, callback)
	return M.request("getFile", { filename = filename, server = server }, callback)
end

---@param filename string
---@param server string
---@param callback fun(err: RpcError?, result: RpcFileMeta?)?
---@return number id
function M.get_file_metadata(filename, server, callback)
	return M.request("getFileMetadata", { filename = filename, server = server }, callback)
end

---@param filename string
---@param server string
---@param callback fun(err: RpcError?, result: "OK"?)?
---@return number id
function M.delete_file(filename, server, callback)
	return M.request("deleteFile", { filename = filename, server = server }, callback)
end

---@param server string
---@param callback fun(err: RpcError?, result: string[]?)?
---@return number id
function M.get_file_names(server, callback)
	return M.request("getFileNames", { server = server }, callback)
end

---@param server string
---@param callback fun(err: RpcError?, result: { filename: string, content: string }[]?)?
---@return number id
function M.get_all_files(server, callback)
	return M.request("getAllFiles", { server = server }, callback)
end

---@param server string
---@param callback fun(err: RpcError?, result: RpcFileMeta[]?)?
---@return number id
function M.get_all_file_metadata(server, callback)
	return M.request("getAllFileMetadata", { server = server }, callback)
end

---@param filename string
---@param server string
---@param callback fun(err: RpcError?, result: number?)?
---@return number id
function M.calculate_ram(filename, server, callback)
	return M.request("calculateRam", { filename = filename, server = server }, callback)
end

---@param callback fun(err: RpcError?, result: string?)?
---@return number id
function M.get_definition_file(callback)
	return M.request("getDefinitionFile", {}, callback)
end

---@param callback fun(err: RpcError?, result: { identifier: string, binary: boolean, save: string}?)?
---@return number id
function M.get_save_file(callback)
	return M.request("getSaveFile", {}, callback)
end

---@param callback fun(err: RpcError?, result: { hostname: string, hasAdminRights: boolean, purchasedByPlayer: boolean}[]?)?
---@return number id
function M.get_all_servers(callback)
	return M.request("getAllServers", {}, callback)
end

return M
