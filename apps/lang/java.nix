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
    openjdk25
    maven
  ];

  home-manager.users.${username} = {
    programs.neovim = {
      mason.packages = [
        "jdtls"
        "java-debug-adapter"
        "java-test"
      ];
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
          options = [
            (
              if config.home-manager.users.${username}.programs.neovim.standalone then
                {
                  java_debug_path = luaUtils.mkLuaExpression ''vim.fn.stdpath("data") .. "/mason/share/java-debug-adapter"'';
                  java_test_path = luaUtils.mkLuaExpression ''vim.fn.stdpath("data") .. "/mason/share/java-test"'';
                  lombok_path = luaUtils.mkLuaExpression ''vim.fn.stdpath("data") .. "/mason/share/jdtls/lombok.jar"'';
                }
              else
                {
                  java_debug_path = "${pkgs.vscode-extensions.vscjava.vscode-java-debug}/share/vscode/extensions/vscjava.vscode-java-debug/server";
                  java_test_path = "${pkgs.vscode-extensions.vscjava.vscode-java-test}/share/vscode/extensions/vscjava.vscode-java-test/server";
                  lombok_path = "${pkgs.lombok}/share/java/lombok.jar";
                }
            )
          ];
          after = {
            path = ./java.lua;
          };
        };

        nvim-dap.options = [
          {
            handlers.java = luaUtils.mkLuaExpression ''
              function(config)
                require("lze").trigger_load({ "nvim-jdtls" })
                return config
              end
            '';
          }
        ];

        blink-cmp.dependencyOf = [ "nvim-jdtls" ];
      };
    };
    programs.vscode.profiles.default =
      lib.mkIf config.home-manager.users.${username}.programs.vscode.enable
        {
          extensions = with pkgs.vscode-extensions; [
            vscjava.vscode-java-pack
            redhat.java
            vscjava.vscode-java-dependency
            vscjava.vscode-maven
            vscjava.vscode-gradle
            vscjava.vscode-java-debug
            vscjava.vscode-java-test
          ];
          userSettings = {
            "java.jdt.ls.java.home" = "${pkgs.openjdk.home}";
            "java.inlayHints.parameterNames.enabled" = "all";
          };
        };
  };
}
