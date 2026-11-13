{
  config,
  pkgs,
  lib,
  _class,
  ...
}:
{
  home-manager.users.${config.user.username}.home.packages =
    lib.mkIf (!pkgs.stdenv.hostPlatform.isDarwin)
      [
        pkgs.proxyman
      ];
}
// lib.optionalAttrs (_class == "darwin") {
  homebrew.casks = [ "proxyman" ];
}
