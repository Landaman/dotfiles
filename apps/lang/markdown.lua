return function(opts)
  local lint = require("lint")
  lint.linters_by_ft = opts.linters_by_ft or {}

  vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
    group = vim.api.nvim_create_augroup("NvimLint", { clear = true }),
    callback = function()
      lint.try_lint()
    end,
  })
end
