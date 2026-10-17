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
        prettierd
        oxfmt
      ];
      lzePlugins.conform-nvim.options = [
        {
          path = ./web-format.lua;
          call = "opts";
        }
      ];
    };

    programs.vscode.profiles.default =
      lib.mkIf config.home-manager.users.${username}.programs.vscode.enable
        {
          extensions = with pkgs.vscode-extensions; [
            esbenp.prettier-vscode
            oxc.oxc-vscode
          ];

          # Oxfmt projects select Oxc in workspace settings. Prettier is the default
          userSettings."oxc.path.oxfmt" = "${pkgs.oxfmt}/bin/oxfmt";
        };
  };
}
