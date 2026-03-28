{ ... }:
{

  homebrew.masApps = {
    colorslurp = 1287239339;
  };

  system.defaults.CustomUserPreferences = {
    # Disable KB shortcuts for ColorSlurp
    "com.IdeaPunch.ColorSlurp" = {
      "KeyboardShortcuts_copyLastCopiedColorGlobalShortcut" = 0;
      "KeyboardShortcuts_showColorSlurpGlobalShortcut" = 0;
      "KeyboardShortcuts_showMagnifierGlobalShortcut" = 0;
    };
  };
}
