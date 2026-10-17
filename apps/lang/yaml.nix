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
      extraPackages = with pkgs; [
        vscode-langservers-extracted
      ];

      lzePlugins = {
        nvim-treesitter.options = [
          {
            ensure_installed = [
              "yaml"
            ];
          }
        ];

        conform-nvim.options = [
          {
            formatters_by_ft.yaml = [ "web" ];
          }
        ];
      };
    };

    programs.vscode.profiles.default =
      lib.mkIf config.home-manager.users.${username}.programs.vscode.enable
        {
          extensions = [ pkgs.vscode-extensions.redhat.vscode-yaml ];
          userSettings."[yaml]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
        };
  };
}
