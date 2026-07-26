local M = {}

function M.nextReference()
	if vim.g.vscode then
		require("vscode").call("editor.action.wordHighlight.next")
	else
		Snacks.words.jump(vim.v.count1)
	end
end

function M.previousReference()
	if vim.g.vscode then
		require("vscode").call("editor.action.wordHighlight.prev")
	else
		Snacks.words.jump(-vim.v.count1)
	end
end

function M.beforeAll()
	vim.opt.shortmess:append({ I = true })
end

function M.after(opts)
	if opts.scratch.enabled then
		vim.api.nvim_create_user_command("Scratch", function(cmd_opts)
			local fargs = cmd_opts.fargs
			if #fargs == 0 or fargs[1] == "toggle" then
				Snacks.scratch()
				return
			elseif fargs[1] == "select" then
				Snacks.scratch.select()
				return
			end

			vim.notify("Unknown argument " .. fargs[1], vim.log.levels.ERROR)
		end, {
			nargs = "?",
			complete = function()
				return { "select", "toggle" }
			end,
		})
	end

	require("snacks").setup(opts)

	local old_jump = require("snacks.scope").jump
	require("snacks.scope").jump = function(...)
		vim.cmd.normal("m'")
		old_jump(...)
	end
end

return M
