return function(opts)
  require("nvim-treesitter.config").setup(opts)
  require("nvim-treesitter.install").install(opts.ensure_installed or {})

  vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("lazyvim_treesitter", { clear = true }),
    callback = function(event)
      pcall(vim.treesitter.start, event.buf)
    end,
  })
end
