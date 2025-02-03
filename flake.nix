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
      hostname = "Ians-MacBook-Pro";
      username = "ianwright";
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

              # Ghostty is broken for just MacOS, so rebuild it for just MacOS
              ghostty =
                if prev.stdenv.isDarwin then
                  pkgs.stdenvNoCC.mkDerivation rec {
                    inherit (prev.ghostty)
                      pname
                      version
                      ;

                    meta = prev.ghostty.meta // {
                      broken = false;
                      outputsToInstall = outputs;
                    };

                    src = prev.fetchurl {
                      url = "https://release.files.ghostty.org/${version}/Ghostty.dmg";
                      name = "Ghostty.dmg";
                      hash = "sha256-QA9oy9EXLSFbzcRybKM8CxmBnUYhML82w48C+0gnRmM=";
                    };

                    nativeBuildInputs = [
                      prev._7zz
                      prev.makeBinaryWrapper
                    ];

                    sourceRoot = ".";
                    installPhase = ''
                      runHook preInstall

                      mkdir -p $out/Applications
                      mv Ghostty.app $out/Applications/
                      makeWrapper $out/Applications/Ghostty.app/Contents/MacOS/ghostty $out/bin/ghostty

                      runHook postInstall
                    '';

                    outputs = [
                      "out"
                      "man"
                      "shell_integration"
                      "terminfo"
                      "vim"
                    ];

                    postFixup =
                      let
                        resources = "$out/Applications/Ghostty.app/Contents/Resources";
                      in
                      ''
                        mkdir -p $man/share
                        ln -s ${resources}/man $man/share/man

                        mkdir -p $terminfo/share
                        ln -s ${resources}/terminfo $terminfo/share/terminfo

                        mkdir -p $shell_integration
                        for folder in "${resources}/ghostty/shell-integration"/*; do
                                ln -s $folder $shell_integration/$(basename "$folder")
                        done

                        mkdir -p $vim
                        for folder in "${resources}/vim/vimfiles"/*; do
                                ln -s $folder $vim/$(basename "$folder")
                        done

                        mkdir -p $out/share/bash-completion
                        cp -R ${resources}/bash-completion/* $out/share/bash-completion

                        mkdir -p $out/share/zsh
                        cp -R ${resources}/zsh/* $out/share/zsh

                        mkdir -p $out/share/fish
                        cp -R ${resources}/fish/* $out/share/fish

                        mkdir -p $out/share/bat
                        cp -R ${resources}/bat/* $out/share/bat
                      '';
                  }
                else
                  prev.ghostty;

              tmuxPlugins = prev.tmuxPlugins // {
                catppuccin = prev.tmuxPlugins.catppuccin.overrideAttrs (oldAttrs: {
                  version = "2024-12-07";
                  src = prev.fetchFromGitHub {
                    owner = "catppuccin";
                    repo = "tmux";
                    rev = "320e184a31d0825cb4f4af550492cbdff2fc3ffc";
                    hash = "sha256-gMBpINeHS+5TCsbJBHhXKEF+fG58FmJrIJoQWYdQqc0=";
                  };
                });

              };
              zoxide-fzf-tmux-session = (import ./zoxide-fzf-tmux-session.nix { pkgs = final; });
            })
          ];

          # Allow unfree packages, e.g., raycast
          nixpkgs.config.allowUnfree = true;

          networking.computerName = hostname;
          networking.hostName = hostname;

          # Packages available to all users
          environment.systemPackages = with pkgs; [
            vim
            python313
            nodejs_20
            bun
            lua
            openjdk
            maven
            coursier
            sbt
            qemu
            curl
            wget
            gnupg
            zulu17
            awscli2
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

          # Disable compinit for ZSH, since we will use it locally
          programs.zsh.promptInit = "";
          programs.zsh.enableCompletion = false;
          programs.zsh.enableBashCompletion = false;

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
      darwinConfigurations.${hostname} = nix-darwin.lib.darwinSystem {
        modules = [
          configuration
          home-manager.darwinModules.home-manager
          {
            # Without this, home-manager looses its mind
            users.users.${username}.home = "/Users/${username}";

            # I trust myself :)
            nix.settings.trusted-users = [ username ];

            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.${username} = import ./home.nix;
          }
        ];
      };

      # Configurations for typehinting. These aren't really used for anything, just for nixd inference
      editorDarwinConfiguration = self.darwinConfigurations.${hostname};
      editorHomeManagerConfiguration = home-manager.lib.homeManagerConfiguration {
        pkgs = self.editorDarwinConfiguration.pkgs; # Inherit pkgs from Darwin
        modules = [ ./home.nix ]; # Load the OS
      };
    };
}
