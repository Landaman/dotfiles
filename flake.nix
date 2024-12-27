{
  description = "My nix-darwin system Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nix-darwin,
      nixpkgs,
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

          # This sets the nixPath environment variable to be our shell input packages, which makes Nixd work way better
          nix.nixPath = [
            "nixpkgs=${nixpkgs}"
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
    in
    {
      darwinConfigurations."Ians-MacBook-Pro-12928" = nix-darwin.lib.darwinSystem {
        modules = [ configuration ];
      };
    };
}
