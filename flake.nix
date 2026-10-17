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
    rex.url = "https://pkgs.superlogical.com/rex/nix/snapshot.tar.gz";
    nixos-hardware.url = "github:nixos/nixos-hardware";
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
      rex,
      nixos-hardware,
    }:
    let
      hostname = "Ians-MacBook-Pro";
      secrets = builtins.fromJSON (builtins.readFile ./secrets.json);

      mkPiHole = import ./hosts/pi-hole.nix {
        inherit nixpkgs nixos-hardware secrets;
      };

    in
    {
      nixosConfigurations = {
        nine-cross-pi-hole = mkPiHole {
          systemName = "nine-cross-pi-hole";
        };

        nine-cross-pi-hole-secondary = mkPiHole {
          systemName = "nine-cross-pi-hole-secondary";
          extraModules = [
            ./components/homebridge.nix
          ];
        };

        adria-pi-hole = mkPiHole {
          systemName = "adria-pi-hole";
        };

        adria-pi-hole-secondary = mkPiHole {
          systemName = "adria-pi-hole-secondary";
        };
      };
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
            home-manager.sharedModules = [ rex.homeManagerModules.default ];
            nixpkgs.overlays = [
              (import ./overlays/herdr.nix { inherit herdr; })
              (import ./overlays/rex.nix { inherit rex; })
            ]
            ++ import ./overlays/default.nix;
            # Set Git commit hash for darwin-version.
            system.configurationRevision = self.rev or self.dirtyRev or null;
          }
        ];
      };
    };
}
