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
  webFormat.languages = [ "svelte" ];

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
            "svelte.enable-ts-plugin" = true;
          };
        };
  };
}
