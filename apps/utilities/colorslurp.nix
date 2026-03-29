{
  pkgs,
  lib,
  ...
}:
{
  homebrew.masApps = lib.mkIf pkgs.stdenv.isDarwin {
    colorslurp = 1287239339;
  };

  system.defaults = lib.mkIf pkgs.stdenv.isDarwin {
    CustomUserPreferences = {
      # Disable KB shortcuts for ColorSlurp
      "com.IdeaPunch.ColorSlurp" = {
        "KeyboardShortcuts_copyLastCopiedColorGlobalShortcut" = 0;
        "KeyboardShortcuts_showColorSlurpGlobalShortcut" = 0;
        "KeyboardShortcuts_showMagnifierGlobalShortcut" = 0;
      };
    };
  };
}
