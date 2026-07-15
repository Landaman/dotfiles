return function(opts)
  local function jdtls_config_dir(name)
    return vim.fn.stdpath("cache") .. "/jdtls/" .. name .. "/config"
  end

  local function jdtls_workspace_dir(name)
    return vim.fn.stdpath("cache") .. "/jdtls/" .. name .. "/workspace"
  end

  local function bundles()
    local patterns = {
      (opts.java_debug_path or "") .. "/share/vscode/extensions/vscjava.vscode-java-debug/server/com.microsoft.java.debug.plugin-*.jar",
      (opts.java_test_path or "") .. "/share/vscode/extensions/vscjava.vscode-java-test/server/*.jar",
    }
    local result = {}

    for _, pattern in ipairs(patterns) do
      for _, bundle in ipairs(vim.split(vim.fn.glob(pattern), "\n", { trimempty = true })) do
        table.insert(result, bundle)
      end
    end

    return result
  end

  local function attach_jdtls()
    local fname = vim.api.nvim_buf_get_name(0)
    local root_dir = require("lspconfig.configs.jdtls").default_config.root_dir(fname)
    local project_name = root_dir and vim.fs.basename(root_dir)
    local cmd = { vim.fn.exepath("jdtls") }

    if project_name then
      vim.list_extend(cmd, {
        "-configuration",
        jdtls_config_dir(project_name),
        "-data",
        jdtls_workspace_dir(project_name),
      })
    end

    require("jdtls").start_or_attach({
      root_dir = root_dir,
      cmd = cmd,
      settings = {
        java = {
          inlayHints = {
            parameterNames = {
              enabled = "all",
            },
          },
        },
      },
      capabilities = require("blink.cmp").get_lsp_capabilities(),
      init_options = {
        bundles = bundles(),
      },
    })
  end

  vim.api.nvim_create_autocmd("FileType", {
    pattern = "java",
    callback = attach_jdtls,
  })

  attach_jdtls()
end
