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
  home-manager.users.${username}.programs.neovim.lzePlugins = {
    nvim-metals = {
      enabled = luaUtils.mkLuaExpression "not vim.g.vscode";
      plugin = pkgs.vimPlugins.nvim-metals;
      filetype = [
        "scala"
        "sbt"
        "java"
      ];
      after = {
        path = ./scala.lua;
      };
    };

    nvim-treesitter.options = [
      {
        ensure_installed = [ "scala" ];
      }
    ];

    nvim-dap.options = [
      {
        handlers.scala = luaUtils.mkLuaExpression ''
          function(config)
            require("lze").trigger_load({ "nvim-metals" })
            require("metals").setup_dap()

            local scala_config = { metals = {} }
            for key, value in pairs(config) do
              if key == "type" or key == "request" or key == "name" then
                scala_config[key] = value
              else
                scala_config.metals[key] = value
              end
            end

            return scala_config
          end
        '';
      }
    ];

    blink-cmp.dependencyOf = [ "nvim-metals" ];
    fidget-nvim.dependencyOf = [ "nvim-metals" ];
    nvim-dap.dependencyOf = [ "nvim-metals" ];
    plenary-nvim.dependencyOf = [ "nvim-metals" ];
  };

  environment.systemPackages = with pkgs; [
    coursier
    sbt
  ];
}
