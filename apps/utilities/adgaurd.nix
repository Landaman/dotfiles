{
  pkgs,
  lib,
  ...
}:
{
  homebrew.masApps = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
    adgaurd = 1440147259;
  };
}
