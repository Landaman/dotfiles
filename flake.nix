{
  description = "My nix-darwin system Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nix-darwin,
      nixpkgs,
      home-manager,
    }:
    let
      configuration =
        { pkgs, ... }:
        {
          nixpkgs.overlays = [
            (final: prev: {
              # This must be an overlay
              bitwarden-cli = prev.bitwarden-cli.overrideAttrs (oldAttrs: {
                # Needs both, won't work without one or the other
                nativeBuildInputs = (oldAttrs.nativeBuildInputs or [ ]) ++ [ prev.llvmPackages_18.stdenv.cc ];
                stdenv = prev.llvmPackages_18.stdenv;
              });
            })
          ];

          # Allow unfree packages, e.g., raycast
          nixpkgs.config.allowUnfree = true;

          # Packages available to all users
          environment.systemPackages = [
            pkgs.vim
            pkgs.python313
            pkgs.nodejs_20
            pkgs.bun
            pkgs.lua
            pkgs.openjdk
            pkgs.maven
            pkgs.coursier
            pkgs.sbt
            pkgs.qemu
            pkgs.curl
            pkgs.wget
            pkgs.gnupg
          ];

          # Necessary for using flakes on this system.
          nix.settings.experimental-features = "nix-command flakes";

          # This allows nixd to find the Flake easier
          nix.nixPath = [
            "nixpkgs=${nixpkgs}" # Nixd looks for this even if not explicitly requested
            "flakepath=${self.outPath}"
          ];

          # Set Git commit hash for darwin-version.
          system.configurationRevision = self.rev or self.dirtyRev or null;

          # Used for backwards compatibility, please read the changelog before changing.
          # $ darwin-rebuild changelog
          system.stateVersion = 5;

          # The platform the configuration will be used on.
          nixpkgs.hostPlatform = "aarch64-darwin";

          security.pam.enableSudoTouchIdAuth = true;

          # Setup homebrew and install necessary dependencies
          homebrew.enable = true;
          homebrew.brews = [
            "sst"
            "webp"
            "inetutils"
          ];
          homebrew.casks = [
            "google-drive"
            "zoom"
            "mongodb-compass"
            "openvpn-connect"
            "logi-options+"
            "drawio"
            "proxyman"
            "balenaetcher"
            "figma"
            "firefox"
            "docker"
            "betterdisplay"
          ];
          homebrew.masApps = {
            daisydisk = 411643860;
            bitwarden = 1352778147;
            "Raycast Companion" = 6738274497;
            "The Unarchiver" = 425424353;
            "Hidden Bar" = 1452453066;
            colorslurp = 1287239339;
            goodnotes = 1444383602;
            messenger = 1480068668;
            adgaurd = 1440147259;
            whatsapp = 310633997;
            keynote = 409183694;
            pages = 409201541;
            numbers = 409203825;
            xcode = 497799835;
          };

          # Uninstall all Casks/Brews not specified here on activation
          homebrew.onActivation.cleanup = "zap"; # Zap removes associated files for casks (just in brew directory, not ~/.config etc.)

          # Defaults
          system.defaults.dock.mru-spaces = false; # Do not rearrange spaces by MRU, this is super annoying
          system.defaults.dock.show-recents = false; # Disable recents in Dock
          system.defaults.CustomUserPreferences = {
            # Disable KB shortcuts for ColorSlurp
            "com.IdeaPunch.ColorSlurp" = {
              "KeyboardShortcuts_copyLastCopiedColorGlobalShortcut" = 0;
              "KeyboardShortcuts_showColorSlurpGlobalShortcut" = 0;
              "KeyboardShortcuts_showMagnifierGlobalShortcut" = 0;
            };
            "com.apple.dock" = {
              "contents-immutable" = 1; # Disable changing dock contents interactively
              "size-immutable" = 1; # Disable dock resizing
              "position-immutable" = 1; # Disable dock position changes
            };
          };

          # Dock contents
          system.defaults.dock.persistent-apps = [
            "/System/Applications/Launchpad.app"
            "/Applications/Bitwarden.app"
            "/Applications/Safari.app"
            "/System/Applications/Mail.app"
            "/System/Applications/FaceTime.app"
            "/System/Applications/Messages.app"
            "${pkgs.discord}/Applications/discord.app"
            "/Applications/Messenger.app"
            "/Applications/WhatsApp.localized/WhatsApp.app"
            "/System/Applications/Calendar.app"
            "/Applications/Goodnotes.app"
            "/System/Applications/Notes.app"
            "/System/Applications/Reminders.app"
            "/System/Applications/Books.app"
            "/System/Applications/Music.app"
            "/System/Applications/Podcasts.app"
            "/System/Applications/Home.app"
            "/System/Applications/iPhone Mirroring.app"
            "/System/Applications/System Settings.app"
          ];
        };

    in
    # Doing this out of line like this allows for inference via nixd
    {
      darwinConfigurations."Ians-MacBook-Pro-13094" = nix-darwin.lib.darwinSystem {
        modules = [
          configuration
          home-manager.darwinModules.home-manager
          {
            # Without this, home-manager looses its mind
            users.users.ianwright.home = "/Users/ianwright";

            # I trust myself :)
            nix.settings.trusted-users = [ "ianwright" ];

            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.ianwright = import ./home.nix;
          }
        ];
      };

      # Configurations for typehinting. These aren't really used for anything, just for nixd inference
      editorDarwinConfiguration = self.darwinConfigurations."Ians-MacBook-Pro-13094";
      editorHomeManagerConfiguration = home-manager.lib.homeManagerConfiguration {
        pkgs = self.editorDarwinConfiguration.pkgs; # Inherit pkgs from Darwin
        modules = [ ./home.nix ]; # Load the OS
      };
    };
}
