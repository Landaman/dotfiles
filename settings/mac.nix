{
  security.pam.services.sudo_local.touchIdAuth = true;

  # Defaults
  system.defaults = {
    dock.mru-spaces = false; # Do not rearrange spaces by MRU, this is super annoying
    dock.show-recents = false; # Disable recents in Dock
    CustomUserPreferences."com.apple.dock" = {
      "contents-immutable" = 1; # Disable changing dock contents interactively
      "size-immutable" = 1; # Disable dock resizing
      "position-immutable" = 1; # Disable dock position changes
    };
  };
}
