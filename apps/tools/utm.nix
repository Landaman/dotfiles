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
  home-manager.users.${username}.home.packages = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin (
    with pkgs;
    [
      utm
    ]
  );
}
