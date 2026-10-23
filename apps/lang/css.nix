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
  home-manager.users.${username} = {
    programs.neovim = {
      mason.packages = [
        "tailwindcss-language-server"
        "css-lsp"
      ];
      extraPackages = with pkgs; [
        tailwindcss-language-server
        vscode-langservers-extracted
      ];

      lzePlugins = {
        nvim-treesitter.options = [
          {
            ensure_installed = [
              "css"
              "scss"
            ];
          }
        ];

        nvim-lspconfig.options = [
          {
            config.cssls = { };
            config.tailwindCSS = { };
          }
        ];

        conform-nvim.options = [
          {
            formatters_by_ft = {
              css = [ "web" ];
              less = [ "web" ];
              scss = [ "web" ];
            };
          }
        ];
      };
    };

    programs.vscode.profiles.default =
      lib.mkIf config.home-manager.users.${username}.programs.vscode.enable
        {
          extensions = [ pkgs.vscode-extensions.bradlc.vscode-tailwindcss ];
          userSettings = {
            "files.associations"."*.css" = "tailwindcss";
            "editor.quickSuggestions".strings = "on"; # Since classes a string...
            "[css]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
            "[scss]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
            "[less]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
          };
        };
  };
}
