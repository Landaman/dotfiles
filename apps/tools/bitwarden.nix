{
  config,
  pkgs,
  lib,
  homeManager,
  _class,
  ...
}:
let
  username = config.user.username;
  containerDefaults = import ../../lib/mac-container-defaults.nix { inherit lib pkgs; };
in
{
  home-manager.users.${username}.home.packages = with pkgs; [
    bitwarden-cli
  ];
}
// lib.optionalAttrs (_class == "darwin") {
  window.floatingApps = [ "com.bitwarden.desktop" ];
  menuBar.hiddenApps = [ "com.bitwarden.desktop" ];

  homebrew.masApps = {
    bitwarden = 1352778147;
  };

  home-manager.users.${username}.home.activation.setBitwardenDefaults =
    homeManager.lib.hm.dag.entryAfter [ "writeBoundary" ]
      (
        containerDefaults "com.apple.Safari" {
          AutoFillFromiCloudKeychain = false;
          AutoFillPasswords = false;
        }
      );
}
