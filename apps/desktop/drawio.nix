{
  config,
  pkgs,
  lib,
  ...
}:
{
  homebrew.casks = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin [ "drawio" ];

  home-manager.users.${config.user.username}.home.packages = lib.mkIf (!pkgs.stdenv.hostPlatform.isDarwin) [
    pkgs.drawio
  ];
}
