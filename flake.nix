{
  description = "My nix-darwin system Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-26.05";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    catppuccin.url = "github:catppuccin/nix";
    herdr.url = "github:herdrdev/herdr";
  };

  outputs =
    {
      self,
      nix-darwin,
      nixpkgs,
      nixpkgs-stable,
      home-manager,
      catppuccin,
      herdr,
    }:
    let
      hostname = "Ians-MacBook-Pro";
    in
    # Doing this out of line like this allows for inference via nixd
    {
      darwinConfigurations.${hostname} = nix-darwin.lib.darwinSystem {
        specialArgs = {
          inherit
            hostname
            nixpkgs-stable
            catppuccin
            nixpkgs
            ;
          flake = self;
          homeManager = home-manager;
        };
        modules = [
          ./hosts/Ians-MacBook-Pro.nix
          home-manager.darwinModules.home-manager
          {
            nixpkgs.overlays = [
              (import ./overlays/herdr.nix { inherit herdr; })
            ]
            ++ import ./overlays/default.nix;
            # Set Git commit hash for darwin-version.
            system.configurationRevision = self.rev or self.dirtyRev or null;
          }
        ];
      };

      # Configurations for typehinting. These aren't really used for anything, just for nixd inference
      editorDarwinConfiguration = self.darwinConfigurations.${hostname};
      editorHomeManagerConfiguration = home-manager.lib.homeManagerConfiguration {
        pkgs = self.editorDarwinConfiguration.pkgs; # Inherit pkgs from Darwin
        modules = [
          ./settings/home.nix
          catppuccin.homeModules.catppuccin
          {
            home =
              let
                config = self.editorDarwinConfiguration.config;
                home = config.home-manager.users.${config.user.username}.home;
              in
              {
                inherit (home) username homeDirectory stateVersion;
              };
          }
        ];
      };
    };
}
