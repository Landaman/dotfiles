{
  config,
  pkgs,
  lib,
  ...
}:
{
  homebrew.casks = lib.mkIf pkgs.stdenv.isDarwin [ "google-drive" ];

  home-manager.users.${config.user.username}.home.packages = lib.mkIf (!pkgs.stdenv.isDarwin) [
    pkgs.google-drive
  ];
}
