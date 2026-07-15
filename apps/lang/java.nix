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
  environment.systemPackages = with pkgs; [
    openjdk
    maven
  ];

  home-manager.users.${username}.programs.neovim = {
    extraPackages = with pkgs; [
      jdt-language-server
    ];

    lzePlugins = {
      nvim-treesitter.options = [
        {
          ensure_installed = [ "java" ];
        }
      ];

      nvim-jdtls = {
        enabled = luaUtils.mkLuaExpression "not vim.g.vscode";
        plugin = pkgs.vimPlugins.nvim-jdtls;
        filetype = [ "java" ];
        dependencyOf = "nvim-dap";
        options = [
          {
            java_debug_path = "${pkgs.vscode-extensions.vscjava.vscode-java-debug}";
            java_test_path = "${pkgs.vscode-extensions.vscjava.vscode-java-test}";
          }
        ];
        after = {
          path = ./java.lua;
        };
      };

      nvim-dap.options = [
        {
          handlers.java = luaUtils.mkLuaExpression ''
            function(config)
              require("lze").load({ "nvim-jdtls" })
              return config
            end
          '';
        }
      ];
    };
  };
}
