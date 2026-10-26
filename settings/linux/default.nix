{ ... }:
{
  # Packages that all systems should have
  imports = [
    ./account.nix
    ./networking.nix
    ./boot.nix
    ../nix.nix
  ];
}
