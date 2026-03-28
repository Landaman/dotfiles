{
  config,
  pkgs,
  ...
}:
let
  username = config.user.username;
in
{
  home-manager.users.${username}.home.packages = with pkgs; [
    raycast
  ];

  homebrew.masApps = {
    "Raycast Companion" = 6738274497;
  };
}
