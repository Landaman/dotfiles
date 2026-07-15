return function(opts)
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
