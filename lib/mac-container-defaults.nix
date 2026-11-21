# Generate an activation fragment that merges preferences into an app's container
{ lib, pkgs }:
bundleId: preferences:
let
  domain = lib.escapeShellArg bundleId;
  plist = pkgs.writeText "${bundleId}-defaults.plist" (
    lib.generators.toPlist { escape = true; } preferences
  );
in
''
  if [[ -d "$HOME/Library/Containers/${bundleId}/Data/Library/Preferences" ]]; then
    run /usr/bin/defaults -container ${domain} import ${domain} ${plist} ||
      warnEcho "Could not apply protected preferences for ${bundleId}"
  else
    warnEcho "Open ${bundleId} once, then rerun activation to apply its preferences"
  fi
''
