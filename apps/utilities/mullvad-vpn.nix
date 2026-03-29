{
  config,
  pkgs,
  lib,
  ...
}:
{
  homebrew.casks = lib.mkIf pkgs.stdenv.isDarwin [ "mullvad-vpn" ];

  home-manager.users.${config.user.username}.home.packages = lib.mkIf (!pkgs.stdenv.isDarwin) [
    pkgs.mullvad-vpn
  ];
}
