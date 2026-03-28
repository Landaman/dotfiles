{
  description = "My nix-darwin system Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    catppuccin.url = "github:catppuccin/nix";
  };

  outputs =
    {
      self,
      nix-darwin,
      nixpkgs,
      home-manager,
      catppuccin,
    }:
    let
      hostname = "Ians-MacBook-Pro";
      appleName = "Ian's MacBook Pro";
      username = "ianwright";
      configuration =
        { pkgs, ... }:
        {
          nixpkgs.overlays = import ./overlays/default.nix;

          # Allow unfree packages, e.g., raycast
          nixpkgs.config.allowUnfree = true;

          networking.computerName = appleName;
          networking.hostName = hostname;

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
          system.stateVersion = 6;

          # The platform the configuration will be used on.
          nixpkgs.hostPlatform = "aarch64-darwin";

          nix.linux-builder = {
            enable = true;
          };

          security.pam.services.sudo_local.touchIdAuth = true;

          # Disable compinit for ZSH, since we will use it locally
          programs.zsh.promptInit = "";
          programs.zsh.enableCompletion = false;
          programs.zsh.enableBashCompletion = false;

          # Setup homebrew and install necessary dependencies
          system.primaryUser = username;
          homebrew.enable = true;

          # Uninstall all Casks/Brews not specified here on activation
          homebrew.onActivation.cleanup = "zap"; # Zap removes associated files for casks (just in brew directory, not ~/.config etc.)

          # Defaults
          system.defaults.dock.mru-spaces = false; # Do not rearrange spaces by MRU, this is super annoying
          system.defaults.dock.show-recents = false; # Disable recents in Dock
          system.defaults.CustomUserPreferences = {
            "com.apple.dock" = {
              "contents-immutable" = 1; # Disable changing dock contents interactively
              "size-immutable" = 1; # Disable dock resizing
              "position-immutable" = 1; # Disable dock position changes
            };
          };

          # Dock contents
          system.defaults.dock.persistent-apps = [
            "/System/Applications/Apps.app"
            "/Applications/Bitwarden.app"
            "/System/Cryptexes/App/System/Applications/Safari.app"
            "/System/Applications/Mail.app"
            "/System/Applications/Phone.app"
            "/System/Applications/Messages.app"
            "${pkgs.discord}/Applications/discord.app"
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

          user.username = username;

          window.floatingApps = [
            "com.apple.MobileSMS"
            "com.hnc.Discord"
            "com.facebook.archon"
            "com.apple.mail"
            "com.apple.Music"
            "com.apple.iBooksX"
            "com.apple.podcasts"
            "com.bitwarden.desktop"
            "com.apple.iCal"
            "net.whatsapp.WhatsApp"
            "com.apple.weather"
            "com.spotify.client"
            "com.flightyapp.flighty"
            "com.apple.Home"
          ];

          files.neverShowGlobs = [
            ".git/"
            ".DS_Store"
          ];

          files.ignoreGlobs = [
            "metals.sbt"
            "node_modules/"
            ".venv/"
            "__pycache__/"
            ".metals/"
            ".bloop/"
            ".ammonite/"
            ".turbo/"
            ".yarn/"
            ".firebase/"
            ".next/"
            ".svelte-kit/"
            "**/.husky/_/"
            "!.env*"
            "!.vscode/"
          ];
        };

    in
    # Doing this out of line like this allows for inference via nixd
    {
      darwinConfigurations.${hostname} = nix-darwin.lib.darwinSystem {
        modules = [
          ./modules/user.nix
          ./modules/files.nix
          ./modules/window.nix
          configuration
          ./apps/ai
          ./apps/shell
          ./apps/tools
          ./apps/editors
          ./apps/lang
          ./apps/window
          ./apps/utilities
          ./apps/desktop
          ./apps/catppuccin.nix
          home-manager.darwinModules.home-manager
          {
            # Without this, home-manager looses its mind
            users.users.${username}.home = "/Users/${username}";

            # I trust myself :)
            nix.settings.trusted-users = [ username ];

            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.${username} = {
              imports = [
                ./home.nix
                catppuccin.homeModules.catppuccin
              ];
            };
          }
        ];
      };

      # Configurations for typehinting. These aren't really used for anything, just for nixd inference
      editorDarwinConfiguration = self.darwinConfigurations.${hostname};
      editorHomeManagerConfiguration = home-manager.lib.homeManagerConfiguration {
        pkgs = self.editorDarwinConfiguration.pkgs; # Inherit pkgs from Darwin
        modules = [
          ./home.nix
          catppuccin.homeModules.catppuccin

        ];
      };
    };
}
