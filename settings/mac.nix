{
  config,
  pkgs,
  lib,
  _class,
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

  home-manager.users.${config.user.username} = {
    # macOS reads these user preferences from its per-host store
    targets.darwin.currentHostDefaults = {
      NSGlobalDomain."com.apple.mouse.tapBehavior" = 1; # Tap to click
    };
  };

  system.defaults = {
    NSGlobalDomain = {
      AppleInterfaceStyleSwitchesAutomatically = true;
      AppleSpacesSwitchOnActivate = false;
    };

    dock = {
      mru-spaces = false; # Do not rearrange spaces by MRU, this is super annoying
      show-recents = false; # Disable recents in Dock
      expose-group-apps = true;
      showAppExposeGestureEnabled = true;
    };

    finder.FXRemoveOldTrashItems = true;
    iCal."TimeZone support enabled" = true;
    screencapture.target = "clipboard";
    trackpad.Clicking = true;
    WindowManager.EnableTiledWindowMargins = false;

    CustomUserPreferences = {
      NSGlobalDomain.AppleLanguages = [
        "en-US"
      ];

      "com.apple.dock" = {
        "contents-immutable" = 1; # Disable changing dock contents interactively
        "size-immutable" = 1; # Disable dock resizing
        "position-immutable" = 1; # Disable dock position changes
      };

      "com.apple.loginwindow".TALLogoutSavesState = false;

      # macOS 27 stores the screenshot destination separately
      "com.apple.screencapture".target-screenshot = "clipboard";
      "com.apple.Spotlight".PasteboardHistoryEnabled = true;
    };
  };
}
// lib.optionalAttrs (_class == "darwin") {
  # Setup homebrew and install necessary dependencies
  homebrew.enable = true;
  homebrew.enableZshIntegration = true;
  # Uninstall all Casks/Brews not specified here on activation
  homebrew.onActivation.cleanup = lib.mkDefault "zap"; # Zap removes associated files for casks (just in brew directory, not ~/.config etc.)
}
