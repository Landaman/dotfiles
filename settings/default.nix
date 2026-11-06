{ pkgs, ... }:
{
  # Necessary for using flakes on this system
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nix.settings.trusted-users = [
    "root"
    (if pkgs.stdenv.hostPlatform.isDarwin then "@admin" else "@wheel")
  ];

  nixpkgs.config.allowUnfree = true;

  nix.gc.automatic = true;
}
