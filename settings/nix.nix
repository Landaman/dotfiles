{
  lib,
  pkgs,
  config,
  ...
}:
{
  # Necessary for using flakes on this system
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin true;

  nix.settings.trusted-users =
    if pkgs.stdenv.hostPlatform.isDarwin then
      [ config.user.username ]
    else
      [
        "root"
        "@wheel"
      ];

  # Cleanup the store periodically
  nix.gc.automatic = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin true;
}
