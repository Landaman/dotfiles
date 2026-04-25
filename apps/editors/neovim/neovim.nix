{
  config,
  pkgs,
  ...
}:
let
  username = config.user.username;
in
{
  home-manager.users.${username}.programs.neovim = {
    enable = true;
    defaultEditor = true;
    extraPackages = with pkgs; [
      tree-sitter
    ];
  };
}
