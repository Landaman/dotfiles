{
  config,
  homeManager,
  lib,
  pkgs,
  ...
}:
let
  inherit (config.menuBar) hiddenApps;
in
{
  options.menuBar.hiddenApps = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [ ];
    description = "Bundle IDs of apps whose menu bar icons macOS should hide";
  };

  config.home-manager.users.${config.user.username} = {
    targets.darwin.currentHostDefaults = {
      "com.apple.controlcenter".BatteryShowPercentage = true;
      "com.apple.Spotlight".MenuItemHidden = true;
    };

    home.activation.hideMenuBarApps = lib.mkIf (hiddenApps != [ ]) (
      homeManager.lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        macosVersion=$(/usr/bin/sw_vers -productVersion)
        if (( ''${macosVersion%%.*} >= 27 )); then
          run ${pkgs.python3}/bin/python3 ${./mac-menu-bar.py} \
            "$HOME/Library/Group Containers/group.com.apple.controlcenter/Library/Preferences/group.com.apple.controlcenter" \
            ${lib.escapeShellArgs hiddenApps} || warnEcho "Could not apply menu bar app visibility"
        fi
      ''
    );
  };
}
