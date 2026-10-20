return function()
	local dap = require("dap")

	dap.adapters.coreclr = {
		type = "executable",
		command = "clrdbg",
	}

	require("dap.ext.vscode").type_to_filetypes.coreclr = { "cs" }

	dap.configurations.cs = {
		{
			type = "coreclr",
			request = "launch",
			name = "Launch .NET assembly",
			program = function()
				return vim.fn.input("Assembly path: ", vim.fn.getcwd() .. "/", "file")
			end,
			cwd = "${workspaceFolder}",
			console = "integratedTerminal",
		},
		{
			type = "coreclr",
			request = "attach",
			name = "Attach to .NET process",
			processId = require("dap.utils").pick_process,
		},
	}
end
