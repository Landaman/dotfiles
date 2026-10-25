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
  webFormat.languages = [
    "yaml"
  ];

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
      };
    };

    programs.vscode.profiles.default =
      lib.mkIf config.home-manager.users.${username}.programs.vscode.enable
        {
          extensions = [ pkgs.vscode-extensions.redhat.vscode-yaml ];
        };
  };
}
