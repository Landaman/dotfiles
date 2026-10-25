local highlight_method = "textDocument/documentHighlight"
local highlight_fallbacks = setmetatable({}, { __mode = "k" })

--- Find exact keyword matches under the requested position using buffer-local 'iskeyword'
---@param params lsp.DocumentHighlightParams Document position
---@param encoding "utf-8"|"utf-16"|"utf-32" Client position encoding
---@return lsp.DocumentHighlight[] highlights Case-sensitive whole-word matches
local function word_highlights(params, encoding)
	local buf = vim.uri_to_bufnr(params.textDocument.uri)
	if not vim.api.nvim_buf_is_loaded(buf) then
		return {}
	end

	-- Use the buffer settings to determine 'iskeyword' pattern
	local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
	return vim.api.nvim_buf_call(buf, function()
		-- Convert the lsp info back into an actual position in the buffer
		local line = lines[params.position.line + 1] or ""
		local column = vim.str_byteindex(line, encoding, params.position.character, false)

		-- Search through the line to try and find the word
		local offset, word = 0, nil
		while offset < #line do
			local match = vim.fn.matchstrpos(line, [[\k\+]], offset) -- Use the 'iskeyword' pattern
			if match[2] == -1 then
				break
			end
			if match[2] <= column and column < match[3] then
				word = match[1]
				break
			end
			offset = match[3]
		end

		-- No matches
		if not word then
			return {}
		end

		-- Build a pattern that looks for the exact word we found, case
		-- sensitive and respecting word boundaries
		local pattern = [[\C\V\<]] .. vim.fn.escape(word, [[\]]) .. [[\>]]

		-- Search through the rest of the buffer line-by-line for all matches to the word
		local highlights = {}
		for row, text in ipairs(lines) do
			offset = 0
			while offset < #text do
				local match = vim.fn.matchstrpos(text, pattern, offset)
				if match[2] == -1 then
					break
				end

				-- Response back to the client
				highlights[#highlights + 1] = {
					kind = vim.lsp.protocol.DocumentHighlightKind.Text,
					range = {
						-- Response to the client is 0-indexed, but matchstrpos returns 1-indexed positions
						start = { line = row - 1, character = vim.str_utfindex(text, encoding, match[2], false) },
						["end"] = { line = row - 1, character = vim.str_utfindex(text, encoding, match[3], false) },
					},
				}

				offset = match[3]
			end
		end
		return highlights
	end)
end

--- Add local document highlights to a client that lacks native support
---@param client vim.lsp.Client Attached language server to augment once
---@param buf integer Buffer used to check native support
local function attach_highlight_fallback(client, buf)
	if highlight_fallbacks[client] or client:supports_method(highlight_method, buf) then
		return
	end

	-- Replace the supports method check with some logic that prefers native
	-- but will allow it for our logic
	local old_supports_method = client.supports_method
	highlight_fallbacks[client] = old_supports_method
	client.supports_method = function(self, method, bufnr)
		if method ~= highlight_method or old_supports_method(self, method, bufnr) then
			return old_supports_method(self, method, bufnr)
		end

		-- Select one fallback per buffer and always prefer native providers
		for _, other in ipairs(vim.lsp.get_clients({ bufnr = bufnr or vim.api.nvim_get_current_buf() })) do
			local native_supports = highlight_fallbacks[other] or other.supports_method
			if native_supports(other, method, bufnr) or (highlight_fallbacks[other] and other.id < self.id) then
				return false
			end
		end
		return true
	end

	-- Replace the rpc methods with a local implementation that will do the fallback
	local old_request, old_notify = client.rpc.request, client.rpc.notify
	local request_id, pending = 0, {}
	client.rpc.request = function(method, params, callback, notify_reply)
		if
			method ~= highlight_method or old_supports_method(client, method, vim.uri_to_bufnr(params.textDocument.uri))
		then
			return old_request(method, params, callback, notify_reply)
		end

		-- Negative IDs keep local requests separate from the server's request IDs
		request_id = request_id - 1 -- -1, -2, -3, etc
		local id = request_id
		pending[id] = true
		vim.schedule(function()
			local result = pending[id] and word_highlights(params, client.offset_encoding) or nil
			pending[id] = nil
			callback(nil, result, id)
			if notify_reply then
				notify_reply(id)
			end
		end)
		return true, id
	end
	client.rpc.notify = function(method, params)
		if method == "$/cancelRequest" and params.id < 0 then
			pending[params.id] = nil
			return true
		end
		return old_notify(method, params)
	end
end

return attach_highlight_fallback
