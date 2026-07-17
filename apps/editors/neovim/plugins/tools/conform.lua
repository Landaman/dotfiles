local M = {}

function M.web_formatter()
	if #vim.fs.find(".oxfmtrc.json", { upward = true, type = "file" }) >= 1 then
		return "oxfmt"
	end

	return "prettierd"
end

function M.opts()
	return {
		formatters = {
			web = {
				inherit = M.web_formatter(),
			},
		},
	}
end

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
