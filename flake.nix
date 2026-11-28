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
    deploy-rs.url = "github:serokell/deploy-rs";
    deploy-rs.inputs.nixpkgs.follows = "nixpkgs";
    nixos-hardware.url = "github:nixos/nixos-hardware";
    nixos-hardware.inputs.nixpkgs.follows = "nixpkgs";
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
      deploy-rs,
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

      nixosConfigurations = {
        fedora-home-server = import ./hosts/fedora-home-server.nix {
          inherit
            nixpkgs
            secrets
            overlays
            home-manager
            catppuccin
            ;
          flake = self;
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

      deploy = {
        sshUser = secrets.user.name;
        interactiveSudo = false;

        # Create a system deployment profile for each NixOS host
        nodes = builtins.mapAttrs (_: host: {
          hostname = host.config.networking.hostName;
          remoteBuild = host.config.networking.hostName == "fedora-home-server";
          profiles.system = {
            user = "root";
            path = deploy-rs.lib.${host.pkgs.stdenv.hostPlatform.system}.activate.nixos host;
          };
        }) self.nixosConfigurations;
      };

      # Unstable nixpkgs no longer supports Intel Macs
      apps = builtins.mapAttrs (_: apps: { deploy = apps.deploy-rs; }) (
        removeAttrs deploy-rs.apps [ "x86_64-darwin" ]
      );

      checks = builtins.mapAttrs (_: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
    };
}
