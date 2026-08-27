{
  config,
  pkgs,
  lib,
  ...
}:
{
  homebrew.casks = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin [ "proxyman" ];

  home-manager.users.${config.user.username}.home.packages = lib.mkIf (!pkgs.stdenv.hostPlatform.isDarwin) [
    pkgs.proxyman
  ];
}
