{
  config,
  pkgs,
  lib,
  ...
}:
{
  homebrew.casks = lib.mkIf pkgs.stdenv.isDarwin [ "drawio" ];

  home-manager.users.${config.user.username}.home.packages = lib.mkIf (!pkgs.stdenv.isDarwin) [
    pkgs.drawio
  ];
}
