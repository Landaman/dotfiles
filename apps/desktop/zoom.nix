{
  config,
  pkgs,
  lib,
  ...
}:
{
  homebrew.casks = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin [ "zoom" ];

  home-manager.users.${config.user.username}.home.packages = lib.mkIf (!pkgs.stdenv.hostPlatform.isDarwin) [
    pkgs.zoom-us
  ];
}
