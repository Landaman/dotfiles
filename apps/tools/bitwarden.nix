{
  config,
  pkgs,
  lib,
  _class,
  ...
}:
let
  username = config.user.username;
in
{
  home-manager.users.${username}.home.packages = with pkgs; [
    bitwarden-cli
  ];
}
// lib.optionalAttrs (_class == "darwin") {
  window.floatingApps = [ "com.bitwarden.desktop" ];

  homebrew.masApps = {
    bitwarden = 1352778147;
  };
}
