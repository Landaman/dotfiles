{
  config,
  lib,
  pkgs,
  ...
}:
let
  luaUtils = import ../../lib/lua.nix { inherit lib; };
  username = config.user.username;
in
{
  environment.systemPackages = with pkgs; [ python313 ];

  home-manager.users.${username}.programs.neovim = {
    extraPackages = with pkgs; [
      basedpyright
      black
      prettierd
      python313Packages.debugpy
    ];

    lzePlugins = {
      nvim-treesitter.options = [
        {
          ensure_installed = [
            "htmldjango"
            "python"
          ];
        }
      ];

      nvim-lspconfig.options = [
        {
          config.basedpyright.settings.basedpyright.analysis = {
            diagnosticMode = "workspace";
            typeCheckingMode = "standard";
            diagnosticSeverityOverrides = {
              reportAssertAlwaysTrue = "warning";
              reportUnnecessaryCast = "warning";
              reportUnnecessaryComparison = "warning";
              reportUnnecessaryContains = "warning";
              reportUnnecessaryIsInstance = "warning";
            };
          };
        }
      ];

      conform-nvim.options = [
        {
          formatters_by_ft = {
            htmldjango = [ "prettierd" ];
            python = [ "black" ];
          };
        }
      ];

      nvim-dap-python = {
        enabled = luaUtils.mkLuaExpression "not vim.g.vscode";
        plugin = pkgs.vimPlugins.nvim-dap-python;
        filetype = [ "python" ];
        dependencyOf = "nvim-dap";
        after = {
          path = ./python.lua;
        };
      };

      nvim-dap.options = [
        {
          handlers.debugpy = luaUtils.mkLuaExpression ''
            function(config)
              require("lze").load({ "nvim-dap-python" })
              return config
            end
          '';
        }
      ];
    };
  };
}
