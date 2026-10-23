{
  config,
  lib,
  pkgs,
  ...
}:
let
  username = config.user.username;
in
{
  files.ignoreGlobs = [ ".svelte-kit/" ];

  home-manager.users.${username} = {
    programs.neovim = {
      mason.packages = [
        "svelte-language-server"
      ];
      extraPackages = with pkgs; [
        svelte-language-server
      ];

      lzePlugins = {
        nvim-treesitter.options = [
          {
            ensure_installed = [ "svelte" ];
          }
        ];

        nvim-lspconfig.options = [
          {
            config.svelte = { };
          }
        ];

        conform-nvim.options = [
          {
            formatters_by_ft.svelte = [ "prettierd" ];
          }
        ];

        nvim-dap.options = [
          {
            adapters = [
              {
                path = ./svelte.lua;
              }
            ];
          }
        ];
      };
    };

    programs.vscode.profiles.default =
      lib.mkIf config.home-manager.users.${username}.programs.vscode.enable
        {
          extensions = [ pkgs.vscode-extensions.svelte.svelte-vscode ];
          userSettings = {
            "[svelte]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
            "svelte.enable-ts-plugin" = true;
          };
        };
  };
}
