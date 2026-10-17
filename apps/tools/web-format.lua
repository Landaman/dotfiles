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

return M
