local M = {}

function M.keys()
  return {
    {
      lhs = "<F5>",
      rhs = function()
        require("dap").continue()
      end,
      desc = "Debug start/continue",
    },
    {
      lhs = "<F6>",
      rhs = function()
        require("dap").run_last()
      end,
      desc = "Debug restart",
    },
    {
      lhs = "<F7>",
      rhs = function()
        require("dap").terminate()
      end,
      desc = "Debug terminate",
    },
    {
      lhs = "<F1>",
      rhs = function()
        require("dap").step_into()
      end,
      desc = "Step into",
    },
    {
      lhs = "<F2>",
      rhs = function()
        require("dap").step_over()
      end,
      desc = "Step over",
    },
    {
      lhs = "<F3>",
      rhs = function()
        require("dap").step_out()
      end,
      desc = "Step out",
    },
    {
      lhs = "<F4>",
      rhs = function()
        require("dap").step_back()
      end,
      desc = "Step back",
    },
    {
      lhs = "<leader>b",
      rhs = function()
        require("dap").toggle_breakpoint()
      end,
      desc = "Toggle breakpoint",
    },
    {
      lhs = "<leader>B",
      rhs = function()
        require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
      end,
      desc = "Set breakpoint",
    },
    {
      lhs = "<F10>",
      rhs = function()
        require("dapui").toggle()
      end,
      desc = "See last debug session result",
    },
    {
      lhs = "<F9>",
      rhs = function()
        require("dapui").toggle({ layout = 0, reset = true })
      end,
      desc = "Reset debug UI layout",
    },
  }
end

function M.after(opts)
  for _, setup_adapter in ipairs(opts.adapters or {}) do
    if type(setup_adapter) == "function" then
      setup_adapter(opts)
    end
  end

  vim.fn.sign_define("DapBreakpoint", { text = "", texthl = "DAPUIStop" })
  vim.fn.sign_define("DapBreakpointCondition", { text = "", texthl = "DAPUIStop" })
  vim.fn.sign_define("DapLogPoint", { text = "", texthl = "DAPUIStop" })
  vim.fn.sign_define("DapStopped", { text = "", texthl = "DAPUIStop" })
  vim.fn.sign_define("DapBreakpointRejected", { text = "", texthl = "DAPUIStop" })

  local vscode = require("dap.ext.vscode")
  local json = require("plenary.json")
  vscode.json_decode = function(str)
    local raw_config = vim.json.decode(json.json_strip_comments(str))

    local result = {
      version = raw_config.version,
      configurations = {},
    }

    for index, config in ipairs(raw_config.configurations) do
      if opts.handlers and opts.handlers[config.type] then
        result.configurations[index] = opts.handlers[config.type](config)
      else
        result.configurations[index] = config
      end
    end

    return result
  end
end

return M
