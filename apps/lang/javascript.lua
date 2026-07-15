return function(opts)
  local dap = require("dap")
  local debug_server = (opts.js_debug_path or "") .. "/src/dapDebugServer.js"

  local function js_debug_adapter()
    return {
      type = "server",
      host = "localhost",
      port = "${port}",
      executable = {
        command = "node",
        args = {
          debug_server,
          "${port}",
        },
      },
    }
  end

  dap.adapters["node-terminal"] = dap.adapters["node-terminal"] or js_debug_adapter()
  dap.adapters["pwa-chrome"] = dap.adapters["pwa-chrome"] or js_debug_adapter()
  dap.adapters["pwa-node"] = dap.adapters["pwa-node"] or js_debug_adapter()

  if not dap.adapters.chrome then
    dap.adapters.chrome = function(cb, config)
      if config.type == "chrome" then
        config.type = "pwa-chrome"
      end

      local native_adapter = dap.adapters["pwa-chrome"]
      if type(native_adapter) == "function" then
        native_adapter(cb, config)
      else
        cb(native_adapter)
      end
    end
  end

  if not dap.adapters.node then
    dap.adapters.node = function(cb, config)
      if config.type == "node" then
        config.type = "pwa-node"
      end

      local native_adapter = dap.adapters["pwa-node"]
      if type(native_adapter) == "function" then
        native_adapter(cb, config)
      else
        cb(native_adapter)
      end
    end
  end

  local js_filetypes = { "typescript", "javascript", "typescriptreact", "javascriptreact" }
  local vscode = require("dap.ext.vscode")
  vscode.type_to_filetypes["pwa-node"] = js_filetypes
  vscode.type_to_filetypes.node = js_filetypes
  vscode.type_to_filetypes["pwa-chrome"] = js_filetypes
  vscode.type_to_filetypes.chrome = js_filetypes

  for _, language in ipairs(js_filetypes) do
    dap.configurations[language] = dap.configurations[language]
      or {
        {
          type = "pwa-node",
          request = "launch",
          name = "Launch file (Node.js)",
          program = "${file}",
          cwd = "${workspaceFolder}",
        },
        {
          type = "pwa-node",
          request = "attach",
          name = "Attach (Node.js)",
          processId = require("dap.utils").pick_process,
          cwd = "${workspaceFolder}",
        },
      }
  end

end
