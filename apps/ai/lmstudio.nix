{
  pkgs,
  config,
  ...
}:
let
  username = config.user.username;
in
{
  home-manager.users.${username}.home.packages = (
    with pkgs;
    [
      lmstudio
    ]
  );
}
