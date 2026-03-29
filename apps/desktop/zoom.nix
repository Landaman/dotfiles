{
  config,
  pkgs,
  lib,
  ...
}:
{
  homebrew.casks = lib.mkIf pkgs.stdenv.isDarwin [ "zoom" ];

  home-manager.users.${config.user.username}.home.packages = lib.mkIf (!pkgs.stdenv.isDarwin) [
    pkgs.zoom-us
  ];
}
