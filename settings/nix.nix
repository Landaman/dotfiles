{ config, lib, ... }:
{
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  # Necessary for using flakes on this system.
  nix.settings.experimental-features = "nix-command flakes";
  # I trust myself :)
  nix.settings.trusted-users = [ config.user.username ];
  # Cleanup the store periodically
  nix.gc.automatic = lib.mkDefault true;
}
