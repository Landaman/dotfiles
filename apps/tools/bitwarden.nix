{
  config,
  pkgs,
  lib,
  ...
}:
let
  username = config.user.username;
in
{
  home-manager.users.${username}.home.packages = with pkgs; [
    bitwarden-cli
  ];

  homebrew.masApps = lib.mkIf pkgs.stdenv.isDarwin {
    bitwarden = 1352778147;
  };
}
