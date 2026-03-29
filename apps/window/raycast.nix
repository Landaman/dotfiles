{
  config,
  pkgs,
  lib,
  ...
}:
let
  username = config.user.username;
in
{
  home-manager.users.${username}.home.packages =
    with pkgs;
    lib.mkIf pkgs.stdenv.isDarwin [
      raycast
    ];

  homebrew.masApps = lib.mkIf pkgs.stdenv.isDarwin {
    "Raycast Companion" = 6738274497;
  };
}
