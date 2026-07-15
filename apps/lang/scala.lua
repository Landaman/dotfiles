return function()
  local metals_config = require("metals").bare_config()
  metals_config.init_options.statusBarProvider = "off"
  metals_config.capabilities = require("blink.cmp").get_lsp_capabilities()
  metals_config.on_attach = function()
    require("metals").setup_dap()
  end

  local function attach_metals()
    require("metals").initialize_or_attach(metals_config)
  end

  local group = vim.api.nvim_create_augroup("nvim-metals", { clear = true })
  vim.api.nvim_create_autocmd("FileType", {
    pattern = { "scala", "sbt", "java" },
    callback = attach_metals,
    group = group,
  })

  attach_metals()

  require("dap").configurations.scala = {
    {
      type = "scala",
      request = "launch",
      name = "Run or Test File",
      metals = {
        runType = "runOrTestFile",
      },
    },
    {
      type = "scala",
      request = "launch",
      name = "Test Target",
      metals = {
        runType = "testTarget",
      },
    },
  }
end
