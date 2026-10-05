{
  hostname,
  nixpkgs-stable,
  pkgs,
  ...
}:
let
  stablePkgs = import nixpkgs-stable {
    system = pkgs.stdenv.hostPlatform.system;
    config.allowUnfree = true;
  };
in
{
  imports = [
    ../modules/user.nix
    ../modules/files.nix
    ../settings
    ../apps/ai
    ../apps/shell
    ../apps/tools
    ../apps/editors
    ../apps/lang
    ../apps/window
    ../apps/utilities
    ../apps/desktop
    ../apps/catppuccin.nix
  ];

  networking.computerName = "Ian's MacBook Pro";
  networking.hostName = hostname;
  user.username = "ianwright";
  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 6;
  home-manager.users.ianwright.home.stateVersion = "26.05";

  nix.linux-builder = {
    enable = true;
    package = stablePkgs.darwin.linux-builder;
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
}
