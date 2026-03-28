{
  config,
  ...
}:
let
  username = config.user.username;
in
{
  home-manager.users.${username}.programs.lazygit.enable = true;
}
