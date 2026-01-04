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

      # Helper to make multiple pi systems with the same config
      mkPiHole =
        {
          systemName,
          specialArgs ? { },
          extraModules ? [ ],
        }:
        nixpkgs.lib.nixosSystem {
          specialArgs = specialArgs // {
            inherit secrets systemName;
            hardware = nixos-hardware;
          };
          modules = [
            ./hardware/pi/hardware-pi02.nix
            ./common.nix
            ./components/pi-hole.nix
            (
              { config, lib, ... }:
              {
                services.tailscale.serve = {
                  "443" =
                    let
                      portsStr = config.services.pihole-web.ports; # e.g., "80r,443s,8080"
                      portsList = lib.splitString "," portsStr;

                      firstNonRedirect = lib.head (lib.filter (p: !lib.hasSuffix "r" p) portsList);

                      port = builtins.head (builtins.split "[[:alpha:]]+" firstNonRedirect);
                      tls = lib.hasSuffix "s" firstNonRedirect;
                    in
                    {
                      target = "${if tls then "https+insecure" else "http"}://localhost:${port}";
                      depends = [ "pihole-ftl.service" ];
                    };
                };
              }
            )
          ]
          ++ extraModules;
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
            (
              { config, ... }:
              {
                services.tailscale.serve."8581" = {
                  target = "http://localhost:${toString config.services.homebridge.uiSettings.port}";
                  depends = [ "homebridge.service" ];
                };
                # Required so that Homebridge subrouters/service discovery works
                networking.firewall.trustedInterfaces = [ "wlan0" ];
              }
            )
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
