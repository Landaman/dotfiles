{
  description = "My Darwin and NixOS configurations";

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
      secrets = builtins.fromJSON (builtins.readFile ./secrets.json);
      overlays = import ./overlays { inherit herdr rex; };
      mkPiHole = import ./hosts/mk-pi-hole.nix {
        inherit
          nixpkgs
          nixos-hardware
          secrets
          overlays
          ;
      };
    in
    {
      nixosConfigurations = {
        fedora-home-server = import ./hosts/fedora-home-server.nix {
          inherit nixpkgs secrets overlays;
        };

        nine-cross-pi-hole = mkPiHole {
          systemName = "nine-cross-pi-hole";
        };

        nine-cross-pi-hole-secondary = mkPiHole {
          systemName = "nine-cross-pi-hole-secondary";
          extraModules = [ ./apps/services/homebridge.nix ];
        };

        adria-pi-hole = mkPiHole {
          systemName = "adria-pi-hole";
        };

        adria-pi-hole-secondary = mkPiHole {
          systemName = "adria-pi-hole-secondary";
        };
      };

      darwinConfigurations.Ians-MacBook-Pro = import ./hosts/Ians-MacBook-Pro.nix {
        inherit
          self
          nix-darwin
          nixpkgs
          nixpkgs-stable
          home-manager
          catppuccin
          overlays
          ;
      };
    };
}
