local function resolve_keymaps(spec)
	local key_parser = require("lze.h.keys").lib.parse
	local keymaps = {}

	for _, value in ipairs(spec or {}) do
		for _, keymap in ipairs(key_parser(value)) do
			if keymap.rhs == vim.NIL or keymap.rhs == false then
				keymaps[keymap.id] = nil
			else
				keymaps[keymap.id] = keymap
			end
		end
	end

	return keymaps
end

local function keymap_opts(keymap)
	local keymap_skip_opts = {
		mode = true,
		id = true,
		ft = true,
		rhs = true,
		lhs = true,
		has = true,
		cond = true,
	}

	local opts = {}
	for key, value in pairs(keymap) do
		if type(key) ~= "number" and not keymap_skip_opts[key] then
			opts[key] = value
		end
	end
	opts.silent = opts.silent ~= false

	return opts
end

return function(opts)
	require("lspconfig")

	for lsp, config in pairs(opts.config or {}) do
		vim.lsp.config(lsp, config) -- Ensure the config is updated. This is better than lsp/* since here we know for sure everything will overwrite that

		local resolved_config = vim.lsp.config[lsp]
		local cmd = resolved_config and resolved_config.cmd -- Sometimes these can be fns, which we can't really check this way
		if type(cmd) == "table" and cmd[1] and not vim.fn.executable(cmd[1]) then
			vim.notify("lspconfig: Failed to find executable for LSP " .. lsp, vim.log.levels.WARN)
		else
			vim.lsp.enable(lsp) -- Otherwise, start up
		end
	end

	vim.api.nvim_create_autocmd("LspAttach", {
		group = vim.api.nvim_create_augroup("LspKeymaps", { clear = true }),
		desc = "Restore Configuration on LSP Attach",
		callback = function(event)
			local client = vim.lsp.get_client_by_id(event.data.client_id)
			if not client then
				return
			end

			for _, keymap in pairs(resolve_keymaps(opts.keymaps)) do
				if not keymap.has or client:supports_method(keymap.has, event.buf) then
					local key_opts = keymap_opts(keymap)
					key_opts.buffer = event.buf

					vim.keymap.set(keymap.mode or "n", keymap.lhs, keymap.rhs, key_opts)
				end
			end
		end,
	})
end
