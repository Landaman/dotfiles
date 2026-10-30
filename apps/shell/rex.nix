{
  config,
  lib,
  pkgs,
  ...
}:
{
  home-manager.users.${config.user.username}.home.packages =
    lib.mkIf pkgs.stdenv.hostPlatform.isDarwin
      [
        pkgs.rex
      ];
}
