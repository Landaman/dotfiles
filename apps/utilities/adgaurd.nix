{
  config,
  lib,
  pkgs,
  homeManager,
  _class,
  ...
}:
let
  containerDefaults = import ../../lib/mac-container-defaults.nix { inherit lib pkgs; };
in
lib.optionalAttrs (_class == "darwin") {
  homebrew.masApps = {
    adgaurd = 1440147259;
  };

  home-manager.users.${config.user.username}.home.activation.setAdGuardDefaults =
    homeManager.lib.hm.dag.entryAfter [ "writeBoundary" ]
      (
        containerDefaults "com.adguard.safari.AdGuard" {
          showInMenuBar = false;
        }
      );
}
