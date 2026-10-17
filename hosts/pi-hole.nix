# Helper to make multiple pi systems with the same config
{
  nixpkgs,
  nixos-hardware,
  secrets,
}:
(
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
      ../hardware/pi/hardware-pi02.nix
      ../common.nix
      ../components/pi-hole.nix
      {
        nixpkgs.overlays = [ (import ../overlays/pihole-ftl.nix) ];
      }
    ]
    ++ extraModules;
  }
)
