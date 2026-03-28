{
  config,
  ...
}:
let
  username = config.user.username;
in
{
  home-manager.users.${username}.programs.opencode = {
    enable = true;
    settings = {
      theme = "catppuccin";
      autoshare = false;
    };
  };
}
