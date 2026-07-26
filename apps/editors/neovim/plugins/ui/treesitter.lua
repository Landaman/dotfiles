local M = {}

function M.after(opts)
  require("nvim-treesitter.config").setup(opts)
  require("nvim-treesitter.install").install(opts.ensure_installed or {})

  vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("lazyvim_treesitter", { clear = true }),
    callback = function(event)
      pcall(vim.treesitter.start, event.buf)
    end,
  })
end

local function key(lhs, rhs, mode, extra)
  local mapping = vim.tbl_extend("force", {
    lhs,
    rhs,
    mode = mode,
  }, extra or {})
  return mapping
end

function M.keys()
  return {
    key(";", function()
      require("nvim-treesitter-textobjects.repeatable_move").repeat_last_move()
    end, { "n", "x", "o" }),
    key(",", function()
      require("nvim-treesitter-textobjects.repeatable_move").repeat_last_move_opposite()
    end, { "n", "x", "o" }),
    key("f", function()
      return require("nvim-treesitter-textobjects.repeatable_move").builtin_f_expr()
    end, { "n", "x", "o" }, { expr = true }),
    key("F", function()
      return require("nvim-treesitter-textobjects.repeatable_move").builtin_F_expr()
    end, { "n", "x", "o" }, { expr = true }),
    key("t", function()
      return require("nvim-treesitter-textobjects.repeatable_move").builtin_t_expr()
    end, { "n", "x", "o" }, { expr = true }),
    key("T", function()
      return require("nvim-treesitter-textobjects.repeatable_move").builtin_T_expr()
    end, { "n", "x", "o" }, { expr = true }),
    key("]m", function()
      require("nvim-treesitter-textobjects.move").goto_next_start("@function.outer", "textobjects")
    end, { "n", "x", "o" }, { desc = "Next function start" }),
    key("]c", function()
      require("nvim-treesitter-textobjects.move").goto_next_start("@class.outer", "textobjects")
    end, { "n", "x", "o" }, { desc = "Next class start" }),
    key("]a", function()
      require("nvim-treesitter-textobjects.move").goto_next_start("@parameter.outer", "textobjects")
    end, { "n", "x", "o" }, { desc = "Next parameter start" }),
    key("]M", function()
      require("nvim-treesitter-textobjects.move").goto_next_end("@function.outer", "textobjects")
    end, { "n", "x", "o" }, { desc = "Next function end" }),
    key("]C", function()
      require("nvim-treesitter-textobjects.move").goto_next_end("@class.outer", "textobjects")
    end, { "n", "x", "o" }, { desc = "Next class end" }),
    key("]A", function()
      require("nvim-treesitter-textobjects.move").goto_next_end("@parameter.outer", "textobjects")
    end, { "n", "x", "o" }, { desc = "Next parameter end" }),
    key("[m", function()
      require("nvim-treesitter-textobjects.move").goto_previous_start("@function.outer", "textobjects")
    end, { "n", "x", "o" }, { desc = "Previous function start" }),
    key("[c", function()
      require("nvim-treesitter-textobjects.move").goto_previous_start("@class.outer", "textobjects")
    end, { "n", "x", "o" }, { desc = "Previous class start" }),
    key("[a", function()
      require("nvim-treesitter-textobjects.move").goto_previous_start("@parameter.outer", "textobjects")
    end, { "n", "x", "o" }, { desc = "Previous parameter start" }),
    key("[M", function()
      require("nvim-treesitter-textobjects.move").goto_previous_end("@function.outer", "textobjects")
    end, { "n", "x", "o" }, { desc = "Previous function end" }),
    key("[C", function()
      require("nvim-treesitter-textobjects.move").goto_previous_end("@class.outer", "textobjects")
    end, { "n", "x", "o" }, { desc = "Previous class end" }),
    key("[A", function()
      require("nvim-treesitter-textobjects.move").goto_previous_end("@parameter.outer", "textobjects")
    end, { "n", "x", "o" }, { desc = "Previous parameter end" }),
    key("am", function()
      require("nvim-treesitter-textobjects.select").select_textobject("@function.outer", "textobjects")
    end, { "x", "o" }, { desc = "Around function" }),
    key("im", function()
      require("nvim-treesitter-textobjects.select").select_textobject("@function.inner", "textobjects")
    end, { "x", "o" }, { desc = "Inside function" }),
    key("ac", function()
      require("nvim-treesitter-textobjects.select").select_textobject("@class.outer", "textobjects")
    end, { "x", "o" }, { desc = "Around class" }),
    key("ic", function()
      require("nvim-treesitter-textobjects.select").select_textobject("@class.inner", "textobjects")
    end, { "x", "o" }, { desc = "Inside class" }),
    key("aa", function()
      require("nvim-treesitter-textobjects.select").select_textobject("@parameter.outer", "textobjects")
    end, { "x", "o" }, { desc = "Around parameter" }),
    key("ia", function()
      require("nvim-treesitter-textobjects.select").select_textobject("@parameter.inner", "textobjects")
    end, { "x", "o" }, { desc = "Inside parameter" }),
    key("[p", function()
      require("nvim-treesitter-textobjects.swap").swap_previous("@parameter.inner")
    end, { "n" }, { desc = "Swap with previous parameter" }),
    key("]p", function()
      require("nvim-treesitter-textobjects.swap").swap_next("@parameter.inner")
    end, { "n" }, { desc = "Swap with next parameter" }),
  }
end

return M
