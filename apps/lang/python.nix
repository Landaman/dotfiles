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
  files.ignoreGlobs = [
    ".venv/"
    "__pycache__/"
  ];

  environment.systemPackages = with pkgs; [ python313 ];

  home-manager.users.${username} = {
    programs.neovim = {
      mason.packages = [
        "basedpyright"
        "black"
        "debugpy"
      ];
      extraPackages = with pkgs; [
        basedpyright
        black
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
          after = {
            path = ./python.lua;
          };
        };

        nvim-dap.options = [
          {
            handlers.debugpy = luaUtils.mkLuaExpression ''
              function(config)
                require("lze").trigger_load({ "nvim-dap-python" })
                return config
              end
            '';
          }
        ];
      };
    };

    programs.vscode.profiles.default =
      lib.mkIf config.home-manager.users.${username}.programs.vscode.enable
        {
          extensions = with pkgs.vscode-extensions; [
            ms-python.python
            ms-python.vscode-python-envs
            ms-python.vscode-pylance
            ms-python.debugpy
            ms-python.black-formatter
          ];

          userSettings = {
            "[python]"."editor.defaultFormatter" = "ms-python.black-formatter";
            "black-formatter.path" = [ "${pkgs.black}/bin/black" ];
            "python.terminal.activateEnvInCurrentTerminal" = true;
          };
        };
  };
}
