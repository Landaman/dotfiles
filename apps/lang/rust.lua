return function(opts)
	local codelldb_path = opts.codelldb_path
	local liblldb_path = opts.liblldb_path
	opts.codelldb_path = nil
	opts.liblldb_path = nil

	if codelldb_path and liblldb_path then
		opts.dap = opts.dap or {}
		opts.dap.adapter = require("rustaceanvim.config").get_codelldb_adapter(codelldb_path, liblldb_path)
	end

	vim.g.rustaceanvim = vim.tbl_deep_extend("keep", vim.g.rustaceanvim or {}, opts or {})
end
