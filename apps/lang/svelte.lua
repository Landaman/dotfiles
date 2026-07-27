return function()
  local dap = require("dap")
  local vscode = require("dap.ext.vscode")
  local filetype = "svelte"

  for _, adapter in ipairs({ "pwa-node", "node", "pwa-chrome", "chrome" }) do
    local filetypes = vscode.type_to_filetypes[adapter] or {}
    if not vim.tbl_contains(filetypes, filetype) then
      table.insert(filetypes, filetype)
    end
    vscode.type_to_filetypes[adapter] = filetypes
  end

  vim.schedule(function()
    dap.configurations.svelte = dap.configurations.svelte or dap.configurations.javascript
  end)
end
