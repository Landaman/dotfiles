# Helper to make multiple pi systems with the same config
# Inputs: pinned nixpkgs, nixos-hardware, and decrypted secrets
# Returns a host builder accepting systemName, optional specialArgs, and extraModules
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
      ../settings
      ../apps/utilities/tailscale
      ../apps/services/pi-hole
      {
        nixpkgs.overlays = [ (import ../overlays/pihole-ftl.nix) ];
        services.tailscale.autoConnect.enable = true;
      }
    ]
    ++ extraModules;
  }
)
