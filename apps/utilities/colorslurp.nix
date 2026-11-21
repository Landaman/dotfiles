{
  config,
  pkgs,
  lib,
  homeManager,
  _class,
  ...
}:
let
  containerDefaults = import ../../lib/mac-container-defaults.nix { inherit lib pkgs; };
in
lib.optionalAttrs (_class == "darwin") {
  homebrew.masApps = {
    colorslurp = 1287239339;
  };

  # Disable KB shortcuts for ColorSlurp
  home-manager.users.${config.user.username}.home.activation.setColorSlurpDefaults =
    homeManager.lib.hm.dag.entryAfter [ "writeBoundary" ]
      (
        containerDefaults "com.IdeaPunch.ColorSlurp" {
          KeyboardShortcuts_copyLastColorGlobal = false;
          KeyboardShortcuts_showMagnifierGlobal = false;
          KeyboardShortcuts_toggleColorSlurpGlobal = false;
        }
      );
}
