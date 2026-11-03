# Helper to make multiple pi systems with the same config
# Inputs: pinned nixpkgs, nixos-hardware, secrets, and overlays
# Returns a host builder accepting systemName, optional specialArgs, and extraModules
{
  nixpkgs,
  nixos-hardware,
  secrets,
  overlays,
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
        nixpkgs.overlays = overlays;
        services.tailscale.autoConnect.enable = true;
      }
    ]
    ++ extraModules;
  }
)
