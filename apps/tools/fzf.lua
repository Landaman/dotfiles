local M = {}

local ui_select_registered = false

local function register_ui_select_if_required()
  if not ui_select_registered then
    require("fzf-lua").register_ui_select()
    ui_select_registered = true
  end
end

function M.beforeAll()
  vim.ui.select = function(...)
    register_ui_select_if_required()
    vim.ui.select(...)
  end
end

function M.directories()
  require("fzf-lua").files({
    fd_opts = [[--color=never --hidden --type d --exclude .git]],
    previewer = false,
    preview = "cd {2} && fd . -u --max-depth=1",
  })
end

function M.codeActions()
  register_ui_select_if_required()
  require("fzf-lua").lsp_code_actions()
end

return M
