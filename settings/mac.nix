{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ../modules/user.nix
  ];

  system.primaryUser = config.user.username;
  security.pam.services.sudo_local.touchIdAuth = true;

  nix.linux-builder = {
    enable = true;
    package = pkgs.darwin.linux-builder-vz;
    systems = [
      "aarch64-linux"
      "x86_64-linux"
    ];
    config = {
      nix.gc.automatic = true;

      virtualisation = {
        darwin-builder = {
          diskSize = 24 * 1024;
          memorySize = 8 * 1024;
        };
      };
    };
  };

  # Setup homebrew and install necessary dependencies
  homebrew.enable = true;
  homebrew.enableZshIntegration = true;
  # Uninstall all Casks/Brews not specified here on activation
  homebrew.onActivation.cleanup = lib.mkDefault "zap"; # Zap removes associated files for casks (just in brew directory, not ~/.config etc.)

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
