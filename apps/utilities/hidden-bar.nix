{
  pkgs,
  lib,
  config,
  ...
}:
let
  username = config.user.username;
in
{
  home-manager.users.${username}.home.packages =
    with pkgs;
    lib.mkIf pkgs.stdenv.hostPlatform.isDarwin [ hidden-bar ];
}
