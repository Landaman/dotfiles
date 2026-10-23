---Set up Mason and install missing exported tools before configuring their consumers
return function(opts)
  local packages = opts.packages
  opts.packages = nil

  -- Expose and load local definitions through Mason's Lua registry loader
  local registry_packages = opts.registry_packages
  opts.registry_packages = nil
  local modules = {}
  for name, spec in pairs(registry_packages) do
    local module = "dotfiles-mason-registry." .. name
    package.loaded[module] = spec
    table.insert(modules, module)
  end
  package.loaded["dotfiles-mason-registry"] = modules
  require("mason").setup(opts)

  local registry = require("mason-registry")
  for source in registry.sources:iterate({ include_uninstalled = true }) do
    if source.id == "dotfiles-mason-registry" then
      source:install():get_or_throw()
    end
  end
  local missing = vim.tbl_filter(function(name)
    return not registry.is_installed(name)
  end, packages)

  if #missing > 0 then
    vim.notify("Installing exported Neovim tools; see :Mason for progress")
    -- Refresh metadata only when tools are missing
    local refreshed = false
    local success = false
    registry.refresh(function(ok)
      success = ok
      refreshed = true
    end)
    if not vim.wait(60000, function() return refreshed end, 100) or not success then
      vim.notify("Mason registry refresh failed; see :MasonLog", vim.log.levels.ERROR)
      return
    end

    local pending = 0
    for _, name in ipairs(missing) do
      local ok, package = pcall(registry.get_package, name)
      if ok then
        pending = pending + 1
        package:install():once("closed", vim.schedule_wrap(function()
          pending = pending - 1
          if not package:is_installed() then
            vim.notify("Mason failed to install " .. name .. "; see :MasonLog", vim.log.levels.ERROR)
          end
        end))
      else
        vim.notify("Unknown Mason package: " .. name, vim.log.levels.ERROR)
      end
    end
    -- Wait for tools before dependent plugins start
    if not vim.wait(600000, function() return pending == 0 end, 100) then
      vim.notify("Mason installation timed out; see :MasonLog", vim.log.levels.ERROR)
    end
  end
end
