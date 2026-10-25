{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:nixos/nixos-hardware";
  };

  outputs =
    {
      nixpkgs,
      nixos-hardware,
      ...
    }:
    let
      secrets = builtins.fromJSON (builtins.readFile ./secrets.json);

      mkPiHole = import ./hosts/pi-hole.nix {
        inherit nixpkgs nixos-hardware secrets;
      };

    in
    {
      nixosConfigurations = {
        fedora-home-server = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit secrets;
            systemName = "fedora-home-server";
          };
          modules = [ ./hosts/fedora-home-server.nix ];
        };

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
    };
}
