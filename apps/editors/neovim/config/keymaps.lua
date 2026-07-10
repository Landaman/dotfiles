-- Lsp keymaps
vim.keymap.set('n', 'grt', vim.lsp.buf.type_definition, {
  desc = 'vim.lsp.buf.type_definition()',
})

vim.keymap.set('n', 'gP', vim.lsp.buf.workspace_symbol, {
  desc = 'vim.lsp.buf.workspace_symbol()',
})

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- vim: ts=2 sts=2 sw=2 et
