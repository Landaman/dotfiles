local M = {}

function M.vscodeKeymaps()
  if vim.g.vscode then
    vim.keymap.set("n", "]g", function()
      require("vscode").call("workbench.action.editor.nextChange")
    end, { desc = "Next change" })
    vim.keymap.set("n", "[g", function()
      require("vscode").call("workbench.action.editor.previousChange")
    end, { desc = "Previous change" })
  end
end

function M.opts()
  return {
    on_attach = function(bufnr)
      local gitsigns = require("gitsigns")

      local function map(mode, lhs, rhs, opts)
        opts = opts or {}
        opts.buffer = bufnr
        vim.keymap.set(mode, lhs, rhs, opts)
      end

      map("n", "]g", function()
        if vim.wo.diff then
          vim.cmd.normal({ "]c", bang = true })
        else
          gitsigns.nav_hunk("next")
        end
      end, { desc = "Next git change" })

      map("n", "[g", function()
        if vim.wo.diff then
          vim.cmd.normal({ "[c", bang = true })
        else
          gitsigns.nav_hunk("prev")
        end
      end, { desc = "Previous git change" })

      map("v", "<leader>hs", function()
        gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
      end, { desc = "Stage git hunk toggle" })
      map("v", "<leader>hr", function()
        gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
      end, { desc = "Reset git hunk" })
      map("n", "<leader>hs", gitsigns.stage_hunk, { desc = "Git stage hunk toggle" })
      map("n", "<leader>hr", gitsigns.reset_hunk, { desc = "Git reset hunk" })
      map("n", "<leader>hS", gitsigns.stage_buffer, { desc = "Git stage buffer" })
      map("n", "<leader>hR", gitsigns.reset_buffer, { desc = "Git reset buffer" })
      map("n", "<leader>hp", gitsigns.preview_hunk_inline, { desc = "Git preview hunk" })
      map("n", "<leader>hb", gitsigns.blame_line, { desc = "Git blame line" })
      map("n", "<leader>hd", gitsigns.diffthis, { desc = "Git diff against index" })
      map("n", "<leader>hD", function()
        gitsigns.diffthis("@")
      end, { desc = "Git diff against last commit" })
    end,
  }
end

M.vscodeKeymaps()

return M
