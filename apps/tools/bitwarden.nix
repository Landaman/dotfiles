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
  window.floatingApps = [ "com.bitwarden.desktop" ];

  home-manager.users.${username}.home.packages = with pkgs; [
    bitwarden-cli
  ];

  homebrew.masApps = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
    bitwarden = 1352778147;
  };
}
