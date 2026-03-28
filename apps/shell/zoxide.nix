{
  config,
  pkgs,
  ...
}:
let
  username = config.user.username;
in
{
  home-manager.users.${username} = {
    programs.zoxide.enable = true;

    home.packages = [
      pkgs.zoxide-fzf-tmux-session
    ];

  };
}
