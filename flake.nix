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
          # Packages available to all users
          environment.systemPackages = [
            pkgs.vim
            pkgs.nixd
            pkgs.nixfmt-rfc-style
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
          homebrew.casks = [
          ];
          homebrew.brews = [
          ];
        };
      # Doing this out of line like this allows for inference via nixd
      homeManagerConfiguration =
        { ... }:
        {
          # Without this, home-manager looses its mind
          users.users.ianwright.home = "/Users/ianwright";

          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.ianwright = import ./home.nix;
        };
    in
    {
      darwinConfigurations."Ians-MacBook-Pro-12928" = nix-darwin.lib.darwinSystem {
        modules = [
          configuration
          home-manager.darwinModules.home-manager
          homeManagerConfiguration
        ];
      };

      # Configurations for typehinting. These aren't really used for anything, just for nixd inference
      editorDarwinConfiguration = self.darwinConfigurations."Ians-MacBook-Pro-12928";
    };
}
