local M = {}

function M.beforeAll()
	vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"

	vim.api.nvim_create_autocmd("LspAttach", {
		group = vim.api.nvim_create_augroup("ConformLspAttach", { clear = true }),
		desc = "Setup Conform as the formatexpr on LspAttach",
		callback = function(event)
			vim.bo[event.buf].formatexpr = "v:lua.require'conform'.formatexpr()"
		end,
	})
end

return M
